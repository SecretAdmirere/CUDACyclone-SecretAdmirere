// CUDACyclone-SecretAdmirere
// Copyright (C) 2026 SecretAdmirere
//
// Inspired by Dookoo2 CUDACyclone
// (https://github.com/Dookoo2/CUDACyclone)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

// ============================================================================
// CUDACyclone-SecretAdmirere - 32 Bitcoin Challenge Solver
// ============================================================================
//
// You're not just competing against other developers.
// You're competing against the version of yourself from yesterday.
// And if that version keeps losing, that's all that matters.
//
// ============================================================================

#include <algorithm>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <thread>
#include <chrono>
#include <vector>
#include <fstream>
#include <array>
#include <windows.h>

// ============================================================================
// Parameter Tuning
// ============================================================================

#ifndef MAX_BATCH_SIZE
#define MAX_BATCH_SIZE 8192
#endif

#ifndef INVERSION_BATCH_SIZE
#define INVERSION_BATCH_SIZE 512
#endif

#ifndef FLUSH_THRESHOLD
#define FLUSH_THRESHOLD 32768u
#endif

#ifndef THREADS_PER_BLOCK
#define THREADS_PER_BLOCK 256
#endif

#ifndef GOLDEN_STEP_STRIDE
#define GOLDEN_STEP_STRIDE 4323785274574297ull
#endif

// ============================================================================
// Source Files Include
// ============================================================================

#include "CUDAMath.cuh"
#include "CUDAUtils.h"
#include "CUDAHash.cuh"

// ============================================================================
// Found Target
// ============================================================================

#define FOUND_NONE  0
#define FOUND_LOCK  1
#define FOUND_READY 2

struct FoundResult {
    uint64_t scalar[4];
    int found_case;
};

// ============================================================================
// Some Device Utility Functions
// ============================================================================

__device__ __forceinline__ int load_found_flag_relaxed(const int* p) {
    int v;
    asm volatile ("ld.relaxed.gpu.b32 %0, [%1];" : "=r"(v) : "l"(p));
    return v;
}

__device__ __forceinline__ unsigned int warp_reduce_add_ui(unsigned int v) {
    return __reduce_add_sync(0xFFFFFFFFu, v);
}

__device__ __forceinline__ bool warp_found_ready(const int* __restrict__ d_found_flag, unsigned full_mask, unsigned lane) {
    int f = (lane == 0) ? load_found_flag_relaxed(d_found_flag) : 0;
    return __shfl_sync(full_mask, f, 0) == FOUND_READY;
}

#define WARP_FLUSH(local_var, accum) \
do { \
    unsigned int v = warp_reduce_add_ui(local_var); \
    if (lane_id == 0) atomicAdd(accum, (unsigned long long)v); \
    local_var = 0; \
} while (0)

#define MAYBE_WARP_FLUSH(local_var, accum) \
do { \
    if (local_var == FLUSH_THRESHOLD) WARP_FLUSH(local_var, accum); \
} while (0)

// ============================================================================
// Precomputed n*Stride*G In Global Memory
// ============================================================================

__device__ uint64_t* g_stride_x;
__device__ uint64_t* g_stride_y;

// ============================================================================
// Constant Memory For Stride Value
// ============================================================================

__device__ __constant__ uint64_t c_default_stride_value[4];

// ============================================================================
// Constant Memory For Target Address Hash160
// ============================================================================

__device__ __constant__ uint32_t c_target_hash160[5];

// ============================================================================
// Address Kernel Hash Comparison
// ============================================================================

__device__ __forceinline__ bool Hash160_Prefix_Check(const uint32_t h[5]) {
    return (h[0] == c_target_hash160[0]);
}

__device__ __forceinline__ bool Hash160_Full_Check(const uint32_t h[5]) {
    return (h[1] == c_target_hash160[1]) &&
           (h[2] == c_target_hash160[2]) &&
           (h[3] == c_target_hash160[3]) &&
           (h[4] == c_target_hash160[4]);
}

// ============================================================================
// Constant Memory For Target Pubkey Coordinate
// ============================================================================

__device__ __constant__ uint32_t c_target_Qx[8];
__device__ __constant__ uint32_t c_target_Qy[8];

// ============================================================================
// Pubkey Kernel Coordinate Comparison
// ============================================================================

__device__ __forceinline__ bool Coordinate_Prefix_Check(const uint64_t x[4]) {
    const uint32_t* Qx = (const uint32_t*)x;

    return (Qx[0] == c_target_Qx[0]);
}

__device__ __forceinline__ bool Coordinate_Full_Check(const uint64_t x[4]) {
    const uint32_t* Qx = (const uint32_t*)x;
    
    return (Qx[1] == c_target_Qx[1]) &&
           (Qx[2] == c_target_Qx[2]) &&
           (Qx[3] == c_target_Qx[3]) &&
           (Qx[4] == c_target_Qx[4]) &&
           (Qx[5] == c_target_Qx[5]) &&
           (Qx[6] == c_target_Qx[6]) &&
           (Qx[7] == c_target_Qx[7]);
}

// ============================================================================
// Kernel: Address Hash Search Kernel
// ============================================================================

__launch_bounds__(256, 2)
__global__ void AddressHashSearchKernel(
    const uint64_t* __restrict__ Px,
    const uint64_t* __restrict__ Py,
    const uint64_t* __restrict__ start_scalars,
    uint32_t batch_size,
    int* __restrict__ d_found_flag,
    FoundResult* __restrict__ d_found_result,
    unsigned long long* __restrict__ checks_accum
)
{
    const uint64_t gid = (uint64_t)blockIdx.x * blockDim.x + threadIdx.x;

    const unsigned lane_id = (unsigned)(threadIdx.x & 31u);
    const unsigned full_mask = 0xFFFFFFFFu;

    if (__builtin_expect(warp_found_ready(d_found_flag, full_mask, lane_id), 0)) return;

    unsigned int local_checks = 0;

    uint64_t x1[4], y1[4];
    Load_2x128(x1, &Px[gid * 4]);
    Load_2x128(y1, &Py[gid * 4]);

    // ============================================================================
    // Check Initial Point
    // ============================================================================

    uint32_t h[5];
    GetHash160_Compressed((uint8_t)(0x02u + (y1[0] & 1ULL)), x1, h);

    bool local_pref = Hash160_Prefix_Check(h);
    
    ++local_checks;
    
    if (__builtin_expect(__any_sync(full_mask, local_pref), 0)) {
        if (Hash160_Full_Check(h)) {
            if (atomicCAS(d_found_flag, FOUND_NONE, FOUND_LOCK) == FOUND_NONE) {
                uint64_t base_scalar[4];
                Load_2x128(base_scalar, &start_scalars[gid * 4]);
                Store_2x128(d_found_result->scalar, base_scalar);
                d_found_result->found_case = 0;
                __threadfence_system();
                atomicExch(d_found_flag, FOUND_READY);
            }
        }
        __syncwarp(full_mask);
        WARP_FLUSH(local_checks, checks_accum);
        return;
    }

    // ============================================================================
    // Main Loop: Chunks Of INVERSION_BATCH_SIZE Points Through The Full Table
    // ============================================================================

    for (int inversion_base = 0; inversion_base < batch_size; inversion_base += INVERSION_BATCH_SIZE) {

        if (__builtin_expect(warp_found_ready(d_found_flag, full_mask, lane_id), 0)) {
            __syncwarp(full_mask);
            WARP_FLUSH(local_checks, checks_accum);
            return;
        }

        // ============================================================================
        // SINGLE INVERSE METHOD - STEP 1: Precompute Products For This Chunk
        // ============================================================================

        uint64_t subp[INVERSION_BATCH_SIZE][4];
        uint64_t acc[4], tmp[4];

        Load_2x128_NC(acc, &g_stride_x[(size_t)(inversion_base + INVERSION_BATCH_SIZE - 1) * 4]);
        ModSub(acc, acc, x1);

        for (int j = 0; j < 4; ++j) subp[INVERSION_BATCH_SIZE - 1][j] = acc[j];

        for (int i = INVERSION_BATCH_SIZE - 2; i >= 0; --i) {
            Load_2x128_NC(tmp, &g_stride_x[(size_t)(inversion_base + i + 1) * 4]);
            ModSub(tmp, tmp, x1);
            ModMult(acc, acc, tmp);
            for (int j = 0; j < 4; ++j) subp[i][j] = acc[j];
        }

        // ============================================================================
        // SINGLE INVERSE METHOD - STEP 2: Compute One Inverse For This Chunk
        // ============================================================================

        uint64_t d0[4], inverse[5];

        Load_2x128_NC(d0, &g_stride_x[(size_t)inversion_base * 4]);
        ModSub(d0, d0, x1);

        for (int j = 0; j < 4; ++j) inverse[j] = d0[j];
        ModMult(inverse, inverse, subp[0]);
        ModInv(inverse);

        // ============================================================================
        // SINGLE INVERSE METHOD - STEP 3: Iterate Through +/-Pi Points For This Chunk
        // ============================================================================

        uint64_t y1_neg[4];
        ModNeg(y1_neg, y1);

        for (int i = 0; i < INVERSION_BATCH_SIZE; ++i) {
            uint64_t dx[4];

            ModMult(dx, subp[i], inverse);

            uint64_t gx[4], gy[4];
            Load_2x128_NC(gx, &g_stride_x[(size_t)(inversion_base + i) * 4]);
            Load_2x128_NC(gy, &g_stride_y[(size_t)(inversion_base + i) * 4]);

            uint64_t lam[4], x3[4], s[4];

            // ============================================================================
            // P + (+Pi) -> Positive Point Addition
            // ============================================================================

            ModSub(s, gy, y1);
            ModMult(lam, s, dx);
            ModSqr(x3, lam);
            ModSub(x3, x3, x1);
            ModSub(x3, x3, gx);
            ModSub(s, x1, x3);
            ModMult(s, s, lam);
            ModSub(s, s, y1);

            uint32_t h[5];
            GetHash160_Compressed((uint8_t)(0x02u + (s[0] & 1ULL)), x3, h);

            bool pref = Hash160_Prefix_Check(h);

            ++local_checks;
            MAYBE_WARP_FLUSH(local_checks, checks_accum);

            if (__builtin_expect(__any_sync(full_mask, pref), 0)) {
                if (Hash160_Full_Check(h)) {
                    if (atomicCAS(d_found_flag, FOUND_NONE, FOUND_LOCK) == FOUND_NONE) {
                        uint64_t fs[4];
                        Load_2x128(fs, &start_scalars[gid * 4]);
                        uint64_t multiplier = (uint64_t)(inversion_base + i + 1);
                        
                        uint64_t temp_offset[5];
                        Mul_256_by_64(temp_offset, c_default_stride_value, multiplier);
                        Add_Stride(fs, temp_offset);

                        Store_2x128(d_found_result->scalar, fs);
                        d_found_result->found_case = 1;
                        __threadfence_system();
                        atomicExch(d_found_flag, FOUND_READY);
                    }
                }
                __syncwarp(full_mask);
                WARP_FLUSH(local_checks, checks_accum);
                return;
            }

            // ============================================================================
            // P + (-Pi) -> Negative Point Addition
            // ============================================================================

            ModSub(s, y1_neg, gy);
            ModMult(lam, s, dx);
            ModSqr(x3, lam);
            ModSub(x3, x3, x1);
            ModSub(x3, x3, gx);
            ModSub(s, x1, x3);
            ModMult(s, s, lam);
            ModSub(s, s, y1);

            GetHash160_Compressed((uint8_t)(0x02u + (s[0] & 1ULL)), x3, h);

            pref = Hash160_Prefix_Check(h);

            ++local_checks;
            MAYBE_WARP_FLUSH(local_checks, checks_accum);

            if (__builtin_expect(__any_sync(full_mask, pref), 0)) {
                if (pref && Hash160_Full_Check(h)) {
                    if (atomicCAS(d_found_flag, FOUND_NONE, FOUND_LOCK) == FOUND_NONE) {
                        uint64_t fs[4];
                        Load_2x128(fs, &start_scalars[gid * 4]);
                        uint64_t multiplier = (uint64_t)(inversion_base + i + 1);

                        uint64_t temp_offset[5];
                        Mul_256_by_64(temp_offset, c_default_stride_value, multiplier);
                        Sub_Stride(fs, temp_offset);

                        Store_2x128(d_found_result->scalar, fs);
                        d_found_result->found_case = 2;
                        __threadfence_system();
                        atomicExch(d_found_flag, FOUND_READY);
                    }
                }
                __syncwarp(full_mask);
                WARP_FLUSH(local_checks, checks_accum);
                return;
            }

            // ============================================================================
            // SINGLE INVERSE METHOD - STEP 4: Update Inverse For Current Batch Iteration
            // ============================================================================

            uint64_t gxmi[4];
            ModSub(gxmi, gx, x1);
            ModMult(inverse, inverse, gxmi);
        }
    }

    // ============================================================================
    // Kernel Final Flush
    // ============================================================================

    __syncwarp(full_mask);
    WARP_FLUSH(local_checks, checks_accum);
}

// ============================================================================
// Kernel: Pubkey Search Kernel
// ============================================================================

__launch_bounds__(256, 2)
__global__ void PubkeySearchKernel(
    const uint64_t* __restrict__ Px,
    const uint64_t* __restrict__ Py,
    const uint64_t* __restrict__ start_scalars,
    uint32_t batch_size,
    int* __restrict__ d_found_flag,
    FoundResult* __restrict__ d_found_result,
    unsigned long long* __restrict__ checks_accum
)
{
    const uint64_t gid = (uint64_t)blockIdx.x * blockDim.x + threadIdx.x;

    const unsigned lane_id = (unsigned)(threadIdx.x & 31u);
    const unsigned full_mask = 0xFFFFFFFFu;

    if (__builtin_expect(warp_found_ready(d_found_flag, full_mask, lane_id), 0)) return;

    unsigned int local_checks = 0;

    uint64_t x1[4];
    Load_2x128(x1, &Px[gid * 4]);

    // ============================================================================
    // Check Initial Point
    // ============================================================================

    bool local_pref = Coordinate_Prefix_Check(x1);

    ++local_checks;

    if (__builtin_expect(__any_sync(full_mask, local_pref), 0)) {
        if (local_pref && Coordinate_Full_Check(x1)) {
            if (atomicCAS(d_found_flag, FOUND_NONE, FOUND_LOCK) == FOUND_NONE) {
                uint64_t base_scalar[4];
                Load_2x128(base_scalar, &start_scalars[gid * 4]);
                Store_2x128(d_found_result->scalar, base_scalar);
                d_found_result->found_case = 0;
                __threadfence_system();
                atomicExch(d_found_flag, FOUND_READY);
            }
        }
        __syncwarp(full_mask);
        WARP_FLUSH(local_checks, checks_accum);
        return;
    }

    // ============================================================================
    // Main Loop: Chunks Of INVERSION_BATCH_SIZE Points Through The Full Table
    // ============================================================================

    for (int inversion_base = 0; inversion_base < batch_size; inversion_base += INVERSION_BATCH_SIZE) {

        if (__builtin_expect(warp_found_ready(d_found_flag, full_mask, lane_id), 0)) {
            __syncwarp(full_mask);
            WARP_FLUSH(local_checks, checks_accum);
            return;
        }

        // ============================================================================
        // SINGLE INVERSE METHOD - STEP 1: Precompute Products For This Chunk
        // ============================================================================

        uint64_t subp[INVERSION_BATCH_SIZE][4];
        uint64_t acc[4], tmp[4];

        Load_2x128_NC(acc, &g_stride_x[(size_t)(inversion_base + INVERSION_BATCH_SIZE - 1) * 4]);
        ModSub(acc, acc, x1);

        for (int j = 0; j < 4; ++j) subp[INVERSION_BATCH_SIZE - 1][j] = acc[j];

        for (int i = INVERSION_BATCH_SIZE - 2; i >= 0; --i) {
            Load_2x128_NC(tmp, &g_stride_x[(size_t)(inversion_base + i + 1) * 4]);
            ModSub(tmp, tmp, x1);
            ModMult(acc, acc, tmp);
            for (int j = 0; j < 4; ++j) subp[i][j] = acc[j];
        }

        // ============================================================================
        // SINGLE INVERSE METHOD - STEP 2: Compute One Inverse For This Chunk
        // ============================================================================

        uint64_t d0[4], inverse[5];

        Load_2x128_NC(d0, &g_stride_x[(size_t)inversion_base * 4]);
        ModSub(d0, d0, x1);

        for (int j = 0; j < 4; ++j) inverse[j] = d0[j];
        ModMult(inverse, inverse, subp[0]);
        ModInv(inverse);

        // ============================================================================
        // SINGLE INVERSE METHOD - STEP 3: Iterate Through +/-Pi Points For This Chunk
        // ============================================================================

        uint64_t y1[4], y1_neg[4];
        Load_2x128(y1, &Py[gid * 4]);
        ModNeg(y1_neg, y1);

        for (int i = 0; i < INVERSION_BATCH_SIZE; ++i) {
            uint64_t dx[4];
            ModMult(dx, subp[i], inverse);

            uint64_t gx[4], gy[4];
            Load_2x128_NC(gx, &g_stride_x[(size_t)(inversion_base + i) * 4]);
            Load_2x128_NC(gy, &g_stride_y[(size_t)(inversion_base + i) * 4]);

            uint64_t lam[4], x3[4];

            // ============================================================================
            // P + (+Pi) -> Positive Point Addition
            // ============================================================================

            ModSub(tmp, gy, y1);
            ModMult(lam, tmp, dx);
            ModSqr(x3, lam);
            ModSub(x3, x3, x1);
            ModSub(x3, x3, gx);

            bool pref = Coordinate_Prefix_Check(x3);

            ++local_checks;
            MAYBE_WARP_FLUSH(local_checks, checks_accum);

            if (__builtin_expect(__any_sync(full_mask, pref), 0)) {
                if (pref && Coordinate_Full_Check(x3)) {
                    if (atomicCAS(d_found_flag, FOUND_NONE, FOUND_LOCK) == FOUND_NONE) {
                        uint64_t fs[4];
                        Load_2x128(fs, &start_scalars[gid * 4]);
                        uint64_t multiplier = (uint64_t)(inversion_base + i + 1);

                        uint64_t temp_offset[5];
                        Mul_256_by_64(temp_offset, c_default_stride_value, multiplier);
                        Add_Stride(fs, temp_offset);

                        Store_2x128(d_found_result->scalar, fs);
                        d_found_result->found_case = 1;
                        __threadfence_system();
                        atomicExch(d_found_flag, FOUND_READY);
                    }
                }
                __syncwarp(full_mask);
                WARP_FLUSH(local_checks, checks_accum);
                return;
            }

            // ============================================================================
            // P + (-Pi) -> Negative Point Addition
            // ============================================================================

            ModSub(tmp, y1_neg, gy);
            ModMult(lam, tmp, dx);
            ModSqr(x3, lam);
            ModSub(x3, x3, x1);
            ModSub(x3, x3, gx);

            pref = Coordinate_Prefix_Check(x3);

            ++local_checks;
            MAYBE_WARP_FLUSH(local_checks, checks_accum);

            if (__builtin_expect(__any_sync(full_mask, pref), 0)) {
                if (pref && Coordinate_Full_Check(x3)) {
                    if (atomicCAS(d_found_flag, FOUND_NONE, FOUND_LOCK) == FOUND_NONE) {
                        uint64_t fs[4];
                        Load_2x128(fs, &start_scalars[gid * 4]);
                        uint64_t multiplier = (uint64_t)(inversion_base + i + 1);

                        uint64_t temp_offset[5];
                        Mul_256_by_64(temp_offset, c_default_stride_value, multiplier);
                        Sub_Stride(fs, temp_offset);

                        Store_2x128(d_found_result->scalar, fs);
                        d_found_result->found_case = 2;
                        __threadfence_system();
                        atomicExch(d_found_flag, FOUND_READY);
                    }
                }
                __syncwarp(full_mask);
                WARP_FLUSH(local_checks, checks_accum);
                return;
            }

            // ============================================================================
            // SINGLE INVERSE METHOD - STEP 4: Update Inverse For Current Batch Iteration
            // ============================================================================

            uint64_t gxmi[4];
            ModSub(gxmi, gx, x1);
            ModMult(inverse, inverse, gxmi);
        }
    }

    // ============================================================================
    // Kernel Final Flush
    // ============================================================================

    __syncwarp(full_mask);
    WARP_FLUSH(local_checks, checks_accum);
}

// ============================================================================
// Main Function
// ============================================================================

int main(int argc, char** argv) {
    SetConsoleCtrlHandler(ConsoleCtrlHandler, TRUE);
    bool use_pubkey_mode = false;
    std::string pubkey_hex;
    std::string range_hex;
    std::string address_base58;
    uint32_t default_runtime_points_batch_size = 512;
    uint32_t default_runtime_batches_per_sm = 512;
    uint32_t default_range_divisions = 1;
    uint64_t default_stride_value[4] = {3, 0, 0, 0};

    static_assert(INVERSION_BATCH_SIZE % THREADS_PER_BLOCK == 0,
        "INVERSION_BATCH_SIZE must be a multiple of THREADS_PER_BLOCK");

    // ============================================================================
    // Helper Function: Parse Grid Parameter
    // ============================================================================

    auto parse_pair = [](const std::string& s, uint32_t& a_out, uint32_t& b_out)->bool {
        size_t comma = s.find(',');
        if (comma == std::string::npos) return false;
        auto trim = [](std::string& z){
            size_t p1 = z.find_first_not_of(" \t");
            size_t p2 = z.find_last_not_of(" \t");
            if (p1 == std::string::npos) { z.clear(); return; }
            z = z.substr(p1, p2 - p1 + 1);
        };
        std::string a_str = s.substr(0, comma);
        std::string b_str = s.substr(comma + 1);
        trim(a_str); trim(b_str);
        char* endp = nullptr;
        unsigned long aa = std::strtoul(a_str.c_str(), &endp, 10); if (*endp!='\0') return false;
        endp = nullptr;
        unsigned long bb = std::strtoul(b_str.c_str(), &endp, 10); if (*endp!='\0') return false;
        if (!aa || !bb) return false;
        a_out = (uint32_t)aa; b_out = (uint32_t)bb; return true;
    };

    // ============================================================================
    // Command-Line Argument Parsing
    // ============================================================================

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "-h" || arg == "--help") {
            printf("\n= MAY THE ODDS BE EVER IN YOUR FAVOR ==================================================================\n\n");
            printf("\n");
            printf("  --range START:END     Hexadecimal Search Range\n");
            printf("  --address <base58>    Target Bitcoin Address (Base58, Compressed Only)\n");
            printf("  --pubkey <hex>        Target Public Key Compressed Only)\n");
            printf("  --grid A,B            GPU Grid Size (Points Per Batch, Batches Per SM)\n");
            printf("                        Default: 512,512\n");
            printf("\n");
            printf("  --divide N            Divide Range Into N Sections (Default: 1)\n");
            printf("  --stride N            Stride Value For K-Jumping (Default: 3)\n");
            printf("\n");
            printf("\n= MAY THE ODDS BE EVER IN YOUR FAVOR ==================================================================\n");
            return EXIT_SUCCESS;
        }
        else if (arg == "--address" && i + 1 < argc) address_base58 = argv[++i];
        else if (arg == "--range" && i + 1 < argc) range_hex = argv[++i];
        else if (arg == "--grid" && i + 1 < argc) {
            uint32_t a=0,b=0; if (!parse_pair(argv[++i], a, b)) { std::cerr<<"Error: --grid A,B\n"; return EXIT_FAILURE; }
            if (a < INVERSION_BATCH_SIZE) { std::cerr << "Error: --grid A must be >= INVERSION_BATCH_SIZE (" << INVERSION_BATCH_SIZE << ")\n"; return EXIT_FAILURE; }
            if (a > MAX_BATCH_SIZE) { std::cerr << "Error: --grid A must be <= MAX_BATCH_SIZE (" << MAX_BATCH_SIZE << ")\n"; return EXIT_FAILURE; }
            default_runtime_points_batch_size = a; default_runtime_batches_per_sm = b;
        }
        else if (arg == "--pubkey" && i + 1 < argc) {
            pubkey_hex = argv[++i];
            use_pubkey_mode = true;
        }
        else if (arg == "--divide" && i + 1 < argc) {
            char* endp = nullptr;
            unsigned long dv = std::strtoul(argv[++i], &endp, 10);
            if (*endp != '\0' || dv < 1) {
                std::cerr << "Error: --divide must be >= 1\n";
                return EXIT_FAILURE;
            }
            default_range_divisions = (uint32_t)dv;
        }
        else if (arg == "--stride" && i + 1 < argc) {
            char* endp = nullptr;
            std::string stride_str = argv[++i];
            if (stride_str.empty()) {
                std::cerr << "Error: --stride value is empty\n";
                return EXIT_FAILURE;
            }
            default_stride_value[0] = 0;
            default_stride_value[1] = 0;
            default_stride_value[2] = 0;
            default_stride_value[3] = 0;
            bool is_hex = false;
            if (stride_str.length() > 2 && stride_str[0] == '0' && stride_str[1] == 'x') {
                is_hex = true;
            }
            if (is_hex) {
                std::string hex_str = stride_str.substr(2);
                if (hex_str.length() > 64) {
                    std::cerr << "Error: --stride hex value exceeds 256 bits (64 hex digits)\n";
                    return EXIT_FAILURE;
                }
                size_t hex_pos = hex_str.length() - 1;
                size_t limb_pos = 0;
                size_t bit_pos = 0;
                uint64_t current_limb = 0;
                while (hex_pos < hex_str.length()) {
                    char c = hex_str[hex_pos];
                    uint64_t nibble;
                    if (c >= '0' && c <= '9') {
                        nibble = c - '0';
                    } else if (c >= 'a' && c <= 'f') {
                        nibble = 10 + (c - 'a');
                    } else if (c >= 'A' && c <= 'F') {
                        nibble = 10 + (c - 'A');
                    } else {
                        std::cerr << "Error: Invalid hex character in --stride: " << c << "\n";
                        return EXIT_FAILURE;
                    }
                    current_limb |= (nibble << (bit_pos * 4));
                    bit_pos++;
                    if (bit_pos == 16) {
                        default_stride_value[limb_pos] = current_limb;
                        limb_pos++;
                        if (limb_pos >= 4) break;
                        current_limb = 0;
                        bit_pos = 0;
                    }
                    if (hex_pos == 0) break;
                    hex_pos--;
                }
                if (limb_pos < 4 && bit_pos > 0) {
                    default_stride_value[limb_pos] = current_limb;
                }
            } else {
                if (stride_str.find('.') != std::string::npos) {
                    std::cerr << "Error: --stride must be an integer (no decimal values)\n";
                    return EXIT_FAILURE;
                }
                unsigned long long sv = std::strtoull(stride_str.c_str(), &endp, 10);
                if (*endp != '\0') {
                    std::cerr << "Error: --stride expects integer value\n";
                    return EXIT_FAILURE;
                }
                if (sv == 0) {
                    std::cerr << "Error: --stride must be positive\n";
                    return EXIT_FAILURE;
                }
                default_stride_value[0] = sv;
            }
            if (default_stride_value[0] <= 1 && default_stride_value[1] == 0 && 
                default_stride_value[2] == 0 && default_stride_value[3] == 0) {
                default_stride_value[0] = 3;
            }
            default_stride_value[0] |= 1ULL;
        }
    }

    // ============================================================================
    // Validate Required Arguments
    // ============================================================================

    if (range_hex.empty()) {
        std::cerr << "Usage: " << argv[0]
                  << " [--range <start_hex>:<end_hex>] [--address <base58> or --pubkey <hex>]"
                  << " [--grid A,B] [--stride N] [--divide N]\n";
        return EXIT_FAILURE;
    }

    if (!use_pubkey_mode && address_base58.empty()) {
        std::cerr << "Error: must provide either --address or --pubkey\n";
        return EXIT_FAILURE;
    }

    // ============================================================================
    // Parse Range
    // ============================================================================

    size_t colon_pos = range_hex.find(':');
    if (colon_pos == std::string::npos) { std::cerr << "Error: range format must be start:end\n"; return EXIT_FAILURE; }
    std::string start_hex = range_hex.substr(0, colon_pos);
    std::string end_hex   = range_hex.substr(colon_pos + 1);

    uint64_t range_start[4]{0}, range_end[4]{0};
    if (!hexToLE64(start_hex, range_start) || !hexToLE64(end_hex, range_end)) {
        std::cerr << "Error: invalid range hex\n"; return EXIT_FAILURE;
    }

    // ============================================================================
    // Decode Target Address
    // ============================================================================

    uint8_t target_hash160[20];
    uint64_t target_Qx[4] = {0}, target_Qy[4] = {0};

    if (use_pubkey_mode) {
        if (!parse_compressed_pubkey(pubkey_hex, target_Qx, target_Qy)) {
            std::cerr << "Error: invalid compressed public key\n";
            return EXIT_FAILURE;
        }

        cudaMemcpyToSymbol(c_target_Qx, target_Qx, 32);
        cudaMemcpyToSymbol(c_target_Qy, target_Qy, 32);
        cudaMemcpyToSymbol(c_default_stride_value, default_stride_value, 4 * sizeof(uint64_t));
        
    } else {
        if (address_base58.empty()) {
            std::cerr << "Error: must provide either --address or --pubkey\n";
            return EXIT_FAILURE;
        }
        
        if (!decode_p2pkh_address(address_base58, target_hash160)) {
            std::cerr << "Error: invalid P2PKH address\n";
            return EXIT_FAILURE;
        }

        subtract_ripemd_iv(target_hash160);
        
        cudaMemcpyToSymbol(c_target_hash160, target_hash160, 20);
        cudaMemcpyToSymbol(c_default_stride_value, default_stride_value, 4 * sizeof(uint64_t));
    }

    // ============================================================================
    // Validate Range Bounds
    // ============================================================================

    if (cmp256(range_end, range_start) < 0) {
        std::cerr << "Error: end < start in --range.\n";
        print_u256_hex("start", range_start);
        print_u256_hex("end", range_end);
        return EXIT_FAILURE;
    }

    uint64_t range_len[4];
    sub256(range_end, range_start, range_len);
    add256_u64(range_len, 1ull, range_len);

    if (range_len[1] == 0 && range_len[2] == 0 && range_len[3] == 0 &&
        range_len[0] < (uint64_t)default_range_divisions) {
        std::cerr << "Error: --divide exceeds range size\n";
        return EXIT_FAILURE;
    }

    // ============================================================================
    // GPU Device Setup
    // ============================================================================

    int device = 0;
    cudaDeviceProp prop{};

    if (cudaGetDevice(&device) != cudaSuccess || cudaGetDeviceProperties(&prop, device) != cudaSuccess) {
        std::cerr << "cudaGetDevice/Properties error\n"; return EXIT_FAILURE;
    }

    int threadsPerBlock = THREADS_PER_BLOCK;
    if (threadsPerBlock > (int)prop.maxThreadsPerBlock) threadsPerBlock = prop.maxThreadsPerBlock;
    if (threadsPerBlock < 32) threadsPerBlock = 32;

    const uint64_t bytesPerThread = 3 * 4 * sizeof(uint64_t);
    size_t totalGlobalMem = prop.totalGlobalMem;
    const uint64_t reserveBytes = 256ull * 1024 * 1024;
    uint64_t usableMem = (totalGlobalMem > reserveBytes) ? (totalGlobalMem - reserveBytes) : (totalGlobalMem / 2);
    uint64_t maxThreadsByMem = usableMem / bytesPerThread;

    // ============================================================================
    // Calculate Thread Counts
    // ============================================================================

    uint64_t userUpper = (uint64_t)prop.multiProcessorCount * (uint64_t)default_runtime_batches_per_sm * (uint64_t)threadsPerBlock;
    if (userUpper == 0ull) userUpper = UINT64_MAX;

    uint64_t upper = maxThreadsByMem;
    if (userUpper < upper) upper = userUpper;

    uint64_t threadsTotal = upper - (upper % (uint64_t)threadsPerBlock);
    if (threadsTotal < (uint64_t)threadsPerBlock) threadsTotal = (uint64_t)threadsPerBlock;

    uint64_t threads_per_section = threadsTotal / (uint64_t)default_range_divisions;
    if (threads_per_section == 0) threads_per_section = 1;
    threadsTotal = threads_per_section * (uint64_t)default_range_divisions;

    threadsTotal = (threadsTotal / threadsPerBlock) * threadsPerBlock;
    if (threadsTotal == 0ull) { 
        std::cerr << "Error: failed to pick threadsTotal.\n"; 
        return EXIT_FAILURE; 
    }

    uint64_t section_size[4];
    {
        uint64_t quotient[4], remainder = 0;
        divmod_256_by_u64(range_len, (uint64_t)default_range_divisions, quotient, remainder);

        if (remainder != 0) {
            add256_u64(quotient, 1ull, section_size);
        } else {
            section_size[0] = quotient[0];
            section_size[1] = quotient[1];
            section_size[2] = quotient[2];
            section_size[3] = quotient[3];
        }
    }

    // ============================================================================
    // Generate High-Entropy Seed From Multiple Sources
    // ============================================================================

    uint64_t seed = generate_high_entropy_seed(prop);

    // ============================================================================
    // Allocate Device Buffers
    // ============================================================================

    uint64_t *d_start_scalars=nullptr;
    uint64_t *d_Px=nullptr;
    uint64_t *d_Py=nullptr;
    int *d_found_flag=nullptr;
    FoundResult *d_found_result=nullptr;
    unsigned long long *d_checks_accum=nullptr;
    uint64_t *d_strideGx=nullptr;
    uint64_t *d_strideGy=nullptr;
    
    cudaMalloc(&d_start_scalars, threadsTotal * 4 * sizeof(uint64_t));
    cudaMalloc(&d_Px, threadsTotal * 4 * sizeof(uint64_t));
    cudaMalloc(&d_Py, threadsTotal * 4 * sizeof(uint64_t));
    cudaMalloc(&d_found_flag, sizeof(int));
    cudaMalloc(&d_found_result, sizeof(FoundResult));
    cudaMalloc(&d_checks_accum, sizeof(unsigned long long));
    
    {
        int zero = FOUND_NONE;
        unsigned long long zero64 = 0ull;
        cudaMemcpy(d_found_flag, &zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_checks_accum, &zero64, sizeof(unsigned long long), cudaMemcpyHostToDevice);
    }

    // ============================================================================
    // Precompute Window Point Table Into Global Memory - Runs Once At Startup
    // ============================================================================

    {
        cudaStream_t sPreLookUpTable;
        cudaStreamCreateWithFlags(&sPreLookUpTable, cudaStreamNonBlocking);

        int blocks_table = static_cast<int>(65536 / threadsPerBlock);

        for (int w = 0; w < 16; w++) {
            PrecomputeTableKernel<<<blocks_table, threadsPerBlock, 0, sPreLookUpTable>>>(w);
        }

        cudaStreamSynchronize(sPreLookUpTable);
        cudaStreamDestroy(sPreLookUpTable);
    }

    // ============================================================================
    // Precompute n*Stride*G In Global Memory - Runs Once At Startup
    // ============================================================================

    {
        uint64_t *d_stride_scalars=nullptr;

        cudaMalloc(&d_strideGx, (size_t)default_runtime_points_batch_size * 4 * sizeof(uint64_t));
        cudaMalloc(&d_strideGy, (size_t)default_runtime_points_batch_size * 4 * sizeof(uint64_t));
        cudaMalloc(&d_stride_scalars,(size_t)default_runtime_points_batch_size * 4 * sizeof(uint64_t));

        uint64_t* h_stride_inputs=nullptr;

        cudaHostAlloc((void**)&h_stride_inputs, (size_t)default_runtime_points_batch_size * 4 * sizeof(uint64_t), cudaHostAllocDefault);
        std::memset(h_stride_inputs, 0, (size_t)default_runtime_points_batch_size * 4 * sizeof(uint64_t));
        
        for (uint32_t n = 0; n < default_runtime_points_batch_size; ++n) {
            uint64_t multiplier = (uint64_t)(n + 1);
            uint64_t temp_result[4];
            Mul_256_by_64_host(default_stride_value, multiplier, temp_result);
            
            h_stride_inputs[(size_t)n*4 + 0] = temp_result[0];
            h_stride_inputs[(size_t)n*4 + 1] = temp_result[1];
            h_stride_inputs[(size_t)n*4 + 2] = temp_result[2];
            h_stride_inputs[(size_t)n*4 + 3] = temp_result[3];
        }
        
        cudaMemcpy(d_stride_scalars, h_stride_inputs, (size_t)default_runtime_points_batch_size * 4 * sizeof(uint64_t), cudaMemcpyHostToDevice);

        cudaStream_t sPreStrideTable; cudaStreamCreateWithFlags(&sPreStrideTable, cudaStreamNonBlocking);

        int blocks_scal = static_cast<int>(default_runtime_points_batch_size / threadsPerBlock);
        
        ScalarToPointKernel<<<blocks_scal, threadsPerBlock, 0, sPreStrideTable>>>(d_stride_scalars, d_strideGx, d_strideGy);

        cudaStreamSynchronize(sPreStrideTable);
        cudaMemcpyToSymbol(g_stride_x, &d_strideGx, sizeof(uint64_t*));
        cudaMemcpyToSymbol(g_stride_y, &d_strideGy, sizeof(uint64_t*));
        cudaStreamDestroy(sPreStrideTable);

        cudaFree(d_stride_scalars);
        cudaFreeHost(h_stride_inputs);
    }

    // ============================================================================
    // Setup Streams And Pinned Host Buffers
    // ============================================================================

    cudaStream_t streamKernel; cudaStreamCreateWithFlags(&streamKernel, cudaStreamNonBlocking);

    // ============================================================================
    // Initialize Timing And Metrics
    // ============================================================================

    auto t0 = std::chrono::high_resolution_clock::now();
    unsigned long long lastHashes = 0ull;

    long double total_keys_ld = ld_from_u256(range_len);

    double last_elapsed=0.0, last_mkeys=0.0;
    unsigned long long last_count=0ull;
    long double last_prog=0.0L;

    constexpr size_t FILTER_SIZE = 4;
    std::array<double, FILTER_SIZE> speed_history = {};
    size_t filter_pos = 0;
    auto last_update_time = t0;

    // ============================================================================
    // Helper Function: Render Status Line
    // ============================================================================

    double last_search_time = 0.0;
    double peak_mkeys = 0.0;

    auto render_status_line = [&](uint64_t epoch_idx){
        if (filter_pos > 1) {
            std::cout << "\033[8A";
        }

        uint64_t total_seconds = static_cast<uint64_t>(last_elapsed);
        uint64_t hours = total_seconds / 3600;
        uint64_t minutes = (total_seconds % 3600) / 60;
        uint64_t seconds = total_seconds % 60;
        
        std::string count_str = std::to_string(last_count);
        for (int i = static_cast<int>(count_str.length()) - 3; i > 0; i -= 3) {
            count_str.insert(i, ",");
        }

        double avg_mkeys = (last_elapsed > 0.0) ? 
                           ((double)last_count / last_elapsed / 1e6) : 0.0;

        std::ostringstream line1, line2, line3, line4;

        line1 << " | Live Kernel Speed: " << std::fixed << std::setprecision(2) << last_mkeys << " Mkeys/s"
              << " | Peak Kernel Speed: " << std::fixed << std::setprecision(2) << peak_mkeys << " Mkeys/s |";


        line2 << " | Kernel Finished in: " << std::fixed << std::setprecision(3) << last_search_time << "s"
              << " | Real Kernel Speed: " << std::fixed << std::setprecision(2) << ((last_search_time > 0.0) ? ((double)(threadsTotal * (default_runtime_points_batch_size * 2 + 1)) / last_search_time / 1e6) : 0.0) << " Mkeys/s |";


        line3 << " | Speed With Included Overhead: " << std::fixed << std::setprecision(2) << avg_mkeys << " Mkeys/s"
              << " | Efficiency: " << std::fixed << std::setprecision(1) << ((avg_mkeys > 0.0 && last_mkeys > 0.0) ? ((avg_mkeys / last_mkeys) * 100.0) : 0.0) << "%"
              << " / Loss: " << std::fixed << std::setprecision(1) << ((avg_mkeys > 0.0 && last_mkeys > 0.0) ? (100.0 - (avg_mkeys / last_mkeys) * 100.0) : 0.0) << "% |";


        line4 << " | Batch: " << (epoch_idx + 1)
              << " | Time: " << std::setfill('0') << std::setw(2) << hours << ":"
                             << std::setfill('0') << std::setw(2) << minutes << ":"
                             << std::setfill('0') << std::setw(2) << seconds
              << std::setfill(' ')
              << " | Count: " << count_str
              << " | Progress: " << std::fixed << std::setprecision(8) << (double)last_prog << " % |";


        std::cout << line1.str() << "\n\n" << line2.str() << "\n\n" << line3.str() << "\n\n" << line4.str() << "\n\n" << std::flush;
    };

    // ============================================================================
    // Build + Upload Section Boundaries Once
    // ============================================================================

    uint64_t *d_sec_start = nullptr, *d_sec_end = nullptr, *d_sec_len = nullptr;
    uint64_t *d_section_start_off = nullptr;

    std::vector<uint32_t> display_secs;
    std::vector<uint64_t> disp_start, disp_end;
    uint64_t first_sec_len[4] = {0, 0, 0, 0};

    build_and_upload_section_boundaries(
        range_start, range_end, section_size,
        default_range_divisions, threadsTotal,
        d_sec_start, d_sec_end, d_sec_len, d_section_start_off,
        display_secs, disp_start, disp_end, first_sec_len);

    const bool has_omitted = (default_range_divisions > 16);

    // ============================================================================
    // Build + Upload Steps Table Once
    // ============================================================================

    uint64_t *d_steps_table = nullptr;
    uint64_t steps_table_entries = 0;
    int steps_table_max_hex = 0;

    {
        std::vector<uint64_t> h_steps;
        generate_steps_table(first_sec_len, seed, h_steps,
                             steps_table_entries, steps_table_max_hex);

        if (!dump_steps_table("STEPS_TABLE.txt", h_steps,
                              steps_table_entries, steps_table_max_hex, seed)) {
            std::cerr << " Warning: could not write STEPS_TABLE.txt\n";
        }

        cudaMalloc(&d_steps_table,
                   (size_t)steps_table_entries * 4 * sizeof(uint64_t));
        cudaMemcpy(d_steps_table, h_steps.data(),
                   (size_t)steps_table_entries * 4 * sizeof(uint64_t),
                   cudaMemcpyHostToDevice);
        cudaMemcpyToSymbol(g_steps_table, &d_steps_table, sizeof(uint64_t*));
    }

    // ============================================================================
    // Thread Distribution + Sample Buffers (sized by displayed sections only)
    // ============================================================================

    uint64_t threads_per_section_base = threadsTotal / default_range_divisions;
    uint64_t thread_remainder         = threadsTotal % default_range_divisions;

    std::vector<SampleTriplet> section_samples(display_secs.size());
    std::vector<int> samples_count(display_secs.size(), 0);

// ============================================================================
// Main Epoch Loop: Pure Random Per Point Search
// ============================================================================

cudaEvent_t start, stop;
cudaEventCreate(&start);
cudaEventCreate(&stop);

for (uint64_t epoch_idx = 0; ; epoch_idx++) {

    clear_screen_full();

    std::cout << "\n= GPU Setup ============================================================================================================\n";
    std::cout << std::left << std::setw(20) << " Device" << " : " << prop.name << " (compute " << prop.major << "." << prop.minor << ")\n";
    std::cout << std::left << std::setw(20) << " SM" << " : " << prop.multiProcessorCount << "\n";
    std::cout << std::left << std::setw(20) << " Threads Per Block" << " : " << threadsPerBlock << "\n";
    std::cout << std::left << std::setw(20) << " Blocks" << " : " << static_cast<int>(threadsTotal/threadsPerBlock) << "\n";
    std::cout << std::left << std::setw(20) << " Point Batch Size" << " : " << default_runtime_points_batch_size << " (cap " << MAX_BATCH_SIZE << ")\n";
    std::cout << std::left << std::setw(20) << " Batches Per SM" << " : " << default_runtime_batches_per_sm << "\n";
    size_t freeB=0,totalB=0; cudaMemGetInfo(&freeB,&totalB);
    size_t usedB = totalB - freeB;
    std::cout << std::left << std::setw(20) << " Memory Utilization" << " : "
              << std::fixed << std::setprecision(1)
              << (totalB? (double)usedB*100.0/(double)totalB : 0.0) << "% ("
              << human_bytes((double)usedB) << " / " << human_bytes((double)totalB) << ")\n";
    std::cout << "= MAY THE ODDS BE EVER IN YOUR FAVOR ===================================================================================\n\n";

    std::cout << "= Search Parameters ====================================================================================================\n";
    if (use_pubkey_mode) {
        std::cout << std::left << std::setw(20) << " Target Pubkey" << " : " << uppercase_hex(pubkey_hex) << "\n";
    } else {
        std::cout << std::left << std::setw(20) << " Target Address" << " : " << address_base58 << "\n";
        std::cout << std::left << std::setw(20) << " Target Hash160" << " : " << hex_from_bytes(target_hash160, 20) << "\n";
    }
    std::cout << std::left << std::setw(20) << " Target Range"  << " : " << uppercase_hex(start_hex) << ":" << uppercase_hex(end_hex) << "\n";

    std::cout << std::left << std::setw(20) << " Mode" << " : Randomized Thread Initialization With Strided K-Interval sampling\n";
    std::cout << std::left << std::setw(20) << " Stride Value" << " : 0x" << format_u256_clean(default_stride_value) << "\n";
    std::cout << std::left << std::setw(20) << " Threads Per Batch" << " : " << threadsTotal << "\n";
    std::cout << std::left << std::setw(20) << " Keys Per Thread" << " : " << (default_runtime_points_batch_size * 2 + 1) << "\n";
    std::cout << "= MAY THE ODDS BE EVER IN YOUR FAVOR ===================================================================================\n\n";

    // ============================================================================
    // Display Sections Using Precomputed Values
    // ============================================================================
    
    std::cout << "= Range Sections =======================================================================================================\n";
    
    for (size_t k = 0; k < display_secs.size(); ++k) {
        const uint32_t sec = display_secs[k];

        if (has_omitted && k == 8) {
            std::cout << " ------------------------- [" << (default_range_divisions - 16)
                      << "] Middle Sections Omitted -------------------------\n";
        }

        uint64_t sec_start[4] = { disp_start[k * 4 + 0], disp_start[k * 4 + 1],
                                  disp_start[k * 4 + 2], disp_start[k * 4 + 3] };
        uint64_t sec_end[4]   = { disp_end[k * 4 + 0], disp_end[k * 4 + 1],
                                  disp_end[k * 4 + 2], disp_end[k * 4 + 3] };

        std::cout << " Section " << std::dec << (sec + 1) << " - "
                  << format_u256_clean(sec_start) << ":"
                  << format_u256_clean(sec_end) << "\n";
    }

    std::cout << "= MAY THE ODDS BE EVER IN YOUR FAVOR ===================================================================================\n\n";
  
    // ============================================================================
    // Reset Per-Epoch Sample State
    // ============================================================================

    std::fill(samples_count.begin(), samples_count.end(), 0);

    // ============================================================================
    // Calculate Thread Starting Positions
    // ============================================================================

    auto init_start = std::chrono::high_resolution_clock::now();

    CalculateScalarPositionKernel<<<static_cast<int>(threadsTotal / threadsPerBlock), threadsPerBlock, 0, streamKernel>>>(
            d_start_scalars,
            d_sec_start,
            d_sec_end,
            d_sec_len,
            d_section_start_off,
            default_range_divisions,
            threadsTotal,
            threads_per_section_base,
            thread_remainder,
            GOLDEN_STEP_STRIDE,
            seed,
            steps_table_entries,
            epoch_idx
        );

    // ============================================================================
    // Read Back Only The Display Sections Samples (First/Middle/Last Thread)
    // ============================================================================

    cudaStreamSynchronize(streamKernel);

    {
        const uint32_t D = default_range_divisions;
        uint64_t base_ts = threadsTotal / D;
        uint64_t rem_ts  = threadsTotal % D;

        auto read_one = [&](uint64_t global_t, uint64_t* dst) {
            cudaMemcpy(dst, &d_start_scalars[global_t * 4],
                       4 * sizeof(uint64_t), cudaMemcpyDeviceToHost);
        };

        for (size_t k = 0; k < display_secs.size(); ++k) {
            const uint32_t sec = display_secs[k];

            uint64_t threads_in_sec = base_ts + ((sec < rem_ts) ? 1ull : 0ull);
            if (threads_in_sec == 0) continue;

            uint64_t off0 = (uint64_t)sec * base_ts + ((sec < rem_ts) ? (uint64_t)sec : rem_ts);
            uint64_t last = threads_in_sec - 1;
            uint64_t mid  = (last + 1) / 2;

            read_one(off0, section_samples[k].first);
            samples_count[k] = 1;
            if (threads_in_sec >= 2) {
                read_one(off0 + mid, section_samples[k].middle);
                samples_count[k] = 2;
            }
            if (threads_in_sec >= 3) {
                read_one(off0 + last, section_samples[k].last);
                samples_count[k] = 3;
            }
        }
    }
    
    // ============================================================================
    // Display Thread Starting Points
    // ============================================================================

    std::cout << "= Thread Starting Positions Per Section (First, Middle, Last) ==========================================================\n";
    for (size_t k = 0; k < display_secs.size(); ++k) {
        const uint32_t sec = display_secs[k];

        if (has_omitted && k == 8) {
            std::cout << " ------------------------- [" << (default_range_divisions - 16)
                      << "] Middle Sections Omitted -------------------------\n";
        }

        if (samples_count[k] >= 1) {
            std::cout << " Section " << std::dec << (sec + 1)
                      << " - TF: " << format_u256_clean(section_samples[k].first);
            if (samples_count[k] >= 2)
                std::cout << ", TM: " << format_u256_clean(section_samples[k].middle);
            if (samples_count[k] >= 3)
                std::cout << ", TL: " << format_u256_clean(section_samples[k].last);
            std::cout << "\n";
        }
    }
    std::cout << "= MAY THE ODDS BE EVER IN YOUR FAVOR ===================================================================================\n\n";

    // ============================================================================
    // Thread Initialization Time
    // ============================================================================

    auto init_end = std::chrono::high_resolution_clock::now();
    double init_time = std::chrono::duration<double>(init_end - init_start).count();
    double gpu_speed = (init_time > 0.0) ? ((double)threadsTotal / init_time / 1e9) : 0.0;

    std::cout << "= Thread Initialization Time ===========================================================================================\n";
    std::cout << " GPU Computed Random Starting Positions in: " 
              << std::fixed << std::setprecision(3) << init_time << " Seconds"
              << " (" << std::fixed << std::setprecision(2) << gpu_speed << " Bkeys/s)\n";
    
    // ============================================================================
    // Copy Data To Device And Launch Kernel
    // ============================================================================

    cudaEventRecord(start, streamKernel);

    ScalarToPointKernel<<<static_cast<int>(threadsTotal/threadsPerBlock), threadsPerBlock, 
            0, streamKernel>>>(d_start_scalars, d_Px, d_Py);

    cudaEventRecord(stop, streamKernel);
    cudaEventSynchronize(stop);

    float kernel_time_ms = 0;
    cudaEventElapsedTime(&kernel_time_ms, start, stop);
    double kernel_time = kernel_time_ms / 1000.0;
    double gen_speed = (kernel_time > 0.0) ? ((double)threadsTotal / kernel_time / 1e6) : 0.0;

    std::cout << " GPU Computed Elliptic Curve Point Generation For Random Starting Positions in" 
              << ": " << std::fixed << std::setprecision(3) << kernel_time << " Seconds"
              << " (" << std::fixed << std::setprecision(2) << gen_speed << " Mkeys/s)\n";
    std::cout << "= MAY THE ODDS BE EVER IN YOUR FAVOR ===================================================================================\n\n";

    cudaEventRecord(start, streamKernel);
    
    if (use_pubkey_mode) {
        PubkeySearchKernel<<<static_cast<int>(threadsTotal/threadsPerBlock), threadsPerBlock, 0, streamKernel>>>(
            d_Px,
            d_Py,
            d_start_scalars,
            default_runtime_points_batch_size,
            d_found_flag,
            d_found_result,
            d_checks_accum
        );
    } else {
        AddressHashSearchKernel<<<static_cast<int>(threadsTotal/threadsPerBlock), threadsPerBlock, 0, streamKernel>>>(
            d_Px,
            d_Py,
            d_start_scalars,
            default_runtime_points_batch_size,
            d_found_flag,
            d_found_result,
            d_checks_accum
        );
    }

    cudaEventRecord(stop, streamKernel);

    // ============================================================================
    // Reset Speed Tracking After Kernel Launch - Before Monitor Loop
    // ============================================================================

    {
        unsigned long long current_accum = 0ull;
        cudaMemcpy(&current_accum, d_checks_accum, sizeof(unsigned long long),
                   cudaMemcpyDeviceToHost);
        lastHashes = current_accum;
    }

    last_update_time = std::chrono::high_resolution_clock::now();
    speed_history = {};
    filter_pos = 0;

    // ============================================================================
    // Monitor Kernel Execution And Display Stats
    // ============================================================================

    bool this_epoch_done = false;

    while (!this_epoch_done) {

        if (g_abort_requested) {
            std::cout << "\n Ctrl+C caught, waiting for GPU to finish current work...\n" << std::flush;
            cudaStreamSynchronize(streamKernel);
            this_epoch_done = true;
            break;
        }

        auto now = std::chrono::high_resolution_clock::now();
        double dt = std::chrono::duration<double>(now - last_update_time).count();

        if (dt >= 1.0) {
            unsigned long long h_hashes = 0ull;
            cudaMemcpy(&h_hashes, d_checks_accum, sizeof(unsigned long long),
                      cudaMemcpyDeviceToHost);

            double current_speed = (double)(h_hashes - lastHashes) / (dt * 1e6);

            speed_history[filter_pos % FILTER_SIZE] = current_speed;
            filter_pos++;

            double avg_speed = 0.0;
            size_t count = std::min(filter_pos, FILTER_SIZE);
            for (size_t i = 0; i < count; i++) {
                avg_speed += speed_history[(filter_pos - 1 - i) % FILTER_SIZE];
            }
            avg_speed /= count;

            last_mkeys   = avg_speed;
            if (last_mkeys > peak_mkeys) peak_mkeys = last_mkeys;
            last_elapsed = std::chrono::duration<double>(now - t0).count();
            last_prog    = total_keys_ld > 0.0L ?
                           ((long double)h_hashes / total_keys_ld) * 100.0L : 0.0L;
            if (last_prog > 100.0L) last_prog = 100.0L;

            last_count   = h_hashes;
            lastHashes   = h_hashes;
            last_update_time = now;

            render_status_line(epoch_idx);
        }

        cudaError_t qs = cudaStreamQuery(streamKernel);
        if (qs == cudaSuccess) {
            this_epoch_done = true;
        } else if (qs != cudaErrorNotReady) {
            cudaGetLastError();
            this_epoch_done = true;
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

    cudaEventSynchronize(stop);

    float search_time_ms = 0;
    cudaEventElapsedTime(&search_time_ms, start, stop);
    last_search_time = search_time_ms / 1000.0;

    render_status_line(epoch_idx);

    // ============================================================================
    // Check If Private Key Was Found
    // ============================================================================

    int h_found_flag = 0;
    cudaMemcpy(&h_found_flag, d_found_flag, sizeof(int), cudaMemcpyDeviceToHost);
    if (h_found_flag == FOUND_READY) {
        FoundResult host_result{};
        cudaMemcpy(&host_result, d_found_result, sizeof(FoundResult), cudaMemcpyDeviceToHost);
        std::cout << "====================================================== FOUND MATCH =====================================================\n";
        std::cout << " Private Key         : " << formatHex256(host_result.scalar) << "\n";

        std::cout << " Found via           : ";
        switch(host_result.found_case) {
            case 0: std::cout << "Check initial point\n"; break;
            case 1: std::cout << "P + (+Pi) -> Positive Point Addition\n"; break;
            case 2: std::cout << "P + (-Pi) -> Negative Point Addition\n"; break;
            default: std::cout << "Unknown\n";
        }
        
        std::cout << "====================================================== FOUND MATCH =====================================================\n";

        const std::string priv_hex = formatHex256(host_result.scalar);
        
        std::ofstream outfile("FOUND_ME_A_BITCOIN.txt", std::ios::app);
        if (outfile.is_open()) {
            outfile << "====================================================== FOUND MATCH =====================================================\n";
            outfile << "Private Key   : " << priv_hex << "\n";
            outfile << "Found via     : ";
            switch(host_result.found_case) {
                case 0: outfile << "Check initial point\n"; break;
                case 1: outfile << "P + (+Pi) -> Positive Point Addition\n"; break;
                case 2: outfile << "P + (-Pi) -> Negative Point Addition\n"; break;
                default: outfile << "Unknown\n";
            }
            outfile << "====================================================== FOUND MATCH =====================================================\n";
            outfile << "\n";
            outfile.close();
            std::cerr << " Result saved to FOUND_ME_A_BITCOIN.txt\n\n";
        }
        break;
    }

    if (g_abort_requested) break;
    
}

    // ============================================================================
    // Cleanup Resources
    // ============================================================================

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaFree(d_start_scalars);
    cudaFree(d_Px);
    cudaFree(d_Py);
    cudaFree(d_found_flag);
    cudaFree(d_found_result);
    cudaFree(d_checks_accum);

    cudaFree(d_strideGx);
    cudaFree(d_strideGy);

    cudaFree(d_sec_start);
    cudaFree(d_sec_end);
    cudaFree(d_sec_len);
    cudaFree(d_section_start_off);
    cudaFree(d_steps_table);

    cudaStreamDestroy(streamKernel);
    cudaDeviceReset();
    g_cleanup_done = true;
    return 0;
}
