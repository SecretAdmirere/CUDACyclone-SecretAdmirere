// CUDACyclone-SecretAdmirere
// Copyright (C) 2026 SecretAdmirere
//
// Portions of this file are derived from RCKangaroo
// (https://github.com/RetiredC/RCKangaroo)
// (c) 2024, RetiredCoder (RC), licensed under GPLv3.
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

#pragma once

// ============================================================================
// For PTX
// ============================================================================

#define add_32(res, a, b) asm volatile ("add.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define add_64(res, a, b) asm volatile ("add.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define add_cc_32(res, a, b) asm volatile ("add.cc.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define add_cc_64(res, a, b) asm volatile ("add.cc.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define addc_32(res, a, b) asm volatile ("addc.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define addc_64(res, a, b) asm volatile ("addc.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define addc_cc_32(res, a, b) asm volatile ("addc.cc.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define addc_cc_64(res, a, b) asm volatile ("addc.cc.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define sub_32(res, a, b) asm volatile ("sub.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define sub_64(res, a, b) asm volatile ("sub.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define sub_cc_32(res, a, b) asm volatile ("sub.cc.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define sub_cc_64(res, a, b) asm volatile ("sub.cc.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define subc_32(res, a, b) asm volatile ("subc.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define subc_64(res, a, b) asm volatile ("subc.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define subc_cc_32(res, a, b) asm volatile ("subc.cc.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define subc_cc_64(res, a, b) asm volatile ("subc.cc.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define mad_lo_32(res, a, b, c) asm volatile ("mad.lo.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define mad_lo_64(res, a, b, c) asm volatile ("mad.lo.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define mad_hi_32(res, a, b, c) asm volatile ("mad.hi.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define mad_hi_64(res, a, b, c) asm volatile ("mad.hi.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define mad_lo_cc_32(res, a, b, c) asm volatile ("mad.lo.cc.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define mad_lo_cc_64(res, a, b, c) asm volatile ("mad.lo.cc.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define mad_hi_cc_32(res, a, b, c) asm volatile ("mad.hi.cc.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define mad_hi_cc_64(res, a, b, c) asm volatile ("mad.hi.cc.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define madc_lo_32(res, a, b, c) asm volatile ("madc.lo.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define madc_lo_64(res, a, b, c) asm volatile ("madc.lo.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define madc_hi_32(res, a, b, c) asm volatile ("madc.hi.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define madc_hi_64(res, a, b, c) asm volatile ("madc.hi.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define madc_lo_cc_32(res, a, b, c) asm volatile ("madc.lo.cc.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define madc_lo_cc_64(res, a, b, c) asm volatile ("madc.lo.cc.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define madc_hi_cc_32(res, a, b, c) asm volatile ("madc.hi.cc.u32 %0, %1, %2, %3;" : "=r"(res) : "r"(a), "r"(b), "r"(c));
#define madc_hi_cc_64(res, a, b, c) asm volatile ("madc.hi.cc.u64 %0, %1, %2, %3;" : "=l"(res) : "l"(a), "l"(b), "l"(c));
#define mul_lo_32(res, a, b) asm volatile ("mul.lo.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define mul_lo_64(res, a, b) asm volatile ("mul.lo.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define mul_hi_32(res, a, b) asm volatile ("mul.hi.u32 %0, %1, %2;" : "=r"(res) : "r"(a), "r"(b));
#define mul_hi_64(res, a, b) asm volatile ("mul.hi.u64 %0, %1, %2;" : "=l"(res) : "l"(a), "l"(b));
#define mad_wide_32(res, a, b, c) asm volatile ("mad.wide.u32 %0, %1, %2, %3;" : "=l"(res) : "r"(a), "r"(b), "l"(c));
#define mul_wide_32(res, a, b) asm volatile ("mul.wide.u32 %0, %1, %2;" : "=l"(res) : "r"(a), "r"(b));

// ============================================================================
// For Helper Functions
// ============================================================================

__device__ __forceinline__ void Load_2x128(uint64_t* dst, const uint64_t* src) {
    asm ("ld.global.v2.u64 {%0, %1}, [%2];" : "=l"(dst[0]), "=l"(dst[1]) : "l"(src));
    asm ("ld.global.v2.u64 {%0, %1}, [%2+16];" : "=l"(dst[2]), "=l"(dst[3]) : "l"(src));
}

__device__ __forceinline__ void Load_2x128_NC(uint64_t* dst, const uint64_t* src) {
    asm ("ld.global.nc.v2.u64 {%0, %1}, [%2];" : "=l"(dst[0]), "=l"(dst[1]) : "l"(src));
    asm ("ld.global.nc.v2.u64 {%0, %1}, [%2+16];" : "=l"(dst[2]), "=l"(dst[3]) : "l"(src));
}

__device__ __forceinline__ void Store_2x128(uint64_t* dst, const uint64_t* src) {
    asm ("st.global.v2.u64 [%0], {%1, %2};" : : "l"(dst), "l"(src[0]), "l"(src[1]) : "memory");
    asm ("st.global.v2.u64 [%0+16], {%1, %2};" : : "l"(dst), "l"(src[2]), "l"(src[3]) : "memory");
}

__device__ __forceinline__ void Add_Stride(uint64_t* val1, uint64_t* val2) {
    add_cc_64(val1[0], val1[0], val2[0]);
    addc_cc_64(val1[1], val1[1], val2[1]);
    addc_cc_64(val1[2], val1[2], val2[2]);
    addc_64(val1[3], val1[3], val2[3]);
}

__device__ __forceinline__ void Sub_Stride(uint64_t* val1, uint64_t* val2) {
    sub_cc_64(val1[0], val1[0], val2[0]);
    subc_cc_64(val1[1], val1[1], val2[1]);
    subc_cc_64(val1[2], val1[2], val2[2]);
    subc_64(val1[3], val1[3], val2[3]);
}

__device__ __forceinline__ void Mul_256_by_64(uint64_t* res, uint64_t* val1, uint64_t val2) {
    uint64_t tmp[3];

    mul_lo_64(res[0], val1[0], val2);
    mul_hi_64(tmp[0], val1[0], val2);
    mul_lo_64(res[1], val1[1], val2);
    mul_hi_64(tmp[1], val1[1], val2);
    mul_lo_64(res[2], val1[2], val2);
    mul_hi_64(tmp[2], val1[2], val2);
    mul_lo_64(res[3], val1[3], val2);
    mul_hi_64(res[4], val1[3], val2);
    add_cc_64(res[1], res[1], tmp[0]);
    addc_cc_64(res[2], res[2], tmp[1]);
    addc_cc_64(res[3], res[3], tmp[2]);
    addc_64(res[4], res[4], 0ull);
}

// ============================================================================
// For ModNeg / ModSub / ModSqr / ModMult
// ============================================================================

__device__ __forceinline__ void ModNeg(uint64_t* res, uint64_t* val) {
    sub_cc_64(res[0], 0xFFFFFFFEFFFFFC2Full, val[0]);
    subc_cc_64(res[1], 0xFFFFFFFFFFFFFFFFull, val[1]);
    subc_cc_64(res[2], 0xFFFFFFFFFFFFFFFFull, val[2]);
    subc_64(res[3], 0xFFFFFFFFFFFFFFFFull, val[3]);
}

__device__ __forceinline__ void ModSub(uint64_t* res, uint64_t* val1, uint64_t* val2) {
    sub_cc_64(res[0], val1[0], val2[0]);
    subc_cc_64(res[1], val1[1], val2[1]);
    subc_cc_64(res[2], val1[2], val2[2]);
    subc_cc_64(res[3], val1[3], val2[3]);

    uint32_t carry;
    subc_32(carry, 0u, 0u);

    if (carry) { 
        add_cc_64(res[0], res[0], 0xFFFFFFFEFFFFFC2Full);
        addc_cc_64(res[1], res[1], 0xFFFFFFFFFFFFFFFFull);
        addc_cc_64(res[2], res[2], 0xFFFFFFFFFFFFFFFFull);
        addc_64(res[3], res[3], 0xFFFFFFFFFFFFFFFFull);
    }
}

__device__ __forceinline__ void ModSqr(uint64_t* res, uint64_t* val) {
    uint32_t* a = (uint32_t*)val;
    uint32_t out[16];
    uint64_t acc, ov, prod;

    mul_wide_32(acc, a[0], a[1]);
    out[0] = 0u;
    out[1] = (uint32_t)acc;
    acc >>= 32; ov = 0ull;

    mul_wide_32(prod, a[0], a[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[2] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], a[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], a[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[3] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], a[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], a[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[4] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], a[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], a[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], a[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[5] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], a[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], a[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], a[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[6] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], a[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], a[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], a[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[7] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[1], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], a[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], a[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[8] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[2], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], a[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], a[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[9] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[3], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], a[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[10] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[4], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], a[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[11] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[5], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[12] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[6], a[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[13] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32);

    out[14] = (uint32_t)acc;
    out[15] = 0u;

    out[15] = (out[15] << 1) | (out[14] >> 31);
    out[14] = (out[14] << 1) | (out[13] >> 31);
    out[13] = (out[13] << 1) | (out[12] >> 31);
    out[12] = (out[12] << 1) | (out[11] >> 31);
    out[11] = (out[11] << 1) | (out[10] >> 31);
    out[10] = (out[10] << 1) | (out[9] >> 31);
    out[9] = (out[9] << 1) | (out[8] >> 31);
    out[8] = (out[8] << 1) | (out[7] >> 31);
    out[7] = (out[7] << 1) | (out[6] >> 31);
    out[6] = (out[6] << 1) | (out[5] >> 31);
    out[5] = (out[5] << 1) | (out[4] >> 31);
    out[4] = (out[4] << 1) | (out[3] >> 31);
    out[3] = (out[3] << 1) | (out[2] >> 31);
    out[2] = (out[2] << 1) | (out[1] >> 31);
    out[1] = (out[1] << 1);

    mul_wide_32(acc, a[0], a[0]);
    add_cc_64(*(uint64_t*)(out+0), *(uint64_t*)(out+0), acc); 

    mul_wide_32(acc, a[1], a[1]);
    addc_cc_64(*(uint64_t*)(out+2), *(uint64_t*)(out+2), acc);

    mul_wide_32(acc, a[2], a[2]);
    addc_cc_64(*(uint64_t*)(out+4), *(uint64_t*)(out+4), acc);

    mul_wide_32(acc, a[3], a[3]);
    addc_cc_64(*(uint64_t*)(out+6), *(uint64_t*)(out+6), acc);

    mul_wide_32(acc, a[4], a[4]);
    addc_cc_64(*(uint64_t*)(out+8), *(uint64_t*)(out+8), acc);

    mul_wide_32(acc, a[5], a[5]);
    addc_cc_64(*(uint64_t*)(out+10), *(uint64_t*)(out+10), acc);

    mul_wide_32(acc, a[6], a[6]);
    addc_cc_64(*(uint64_t*)(out+12), *(uint64_t*)(out+12), acc);

    mul_wide_32(acc, a[7], a[7]);
    addc_64(*(uint64_t*)(out+14), *(uint64_t*)(out+14), acc);

    uint32_t* h = out + 8;
    uint32_t w0, w1, w2, w3, w4, w5, w6, w7;

    mul_wide_32(acc, h[0], 0x3D1u);
    add_64(acc, acc, (uint64_t)out[0]);
    w0 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[1], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[1]);
    add_64(acc, acc, (uint64_t)h[0]);
    w1 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[2], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[2]);
    add_64(acc, acc, (uint64_t)h[1]);
    w2 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[3], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[3]);
    add_64(acc, acc, (uint64_t)h[2]);
    w3 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[4], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[4]);
    add_64(acc, acc, (uint64_t)h[3]);
    w4 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[5], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[5]);
    add_64(acc, acc, (uint64_t)h[4]);
    w5 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[6], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[6]);
    add_64(acc, acc, (uint64_t)h[5]);
    w6 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[7], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[7]);
    add_64(acc, acc, (uint64_t)h[6]);
    w7 = (uint32_t)acc; acc >>= 32;

    add_64(acc, acc, (uint64_t)h[7]);

    out[0]=w0; out[1]=w1; out[2]=w2; out[3]=w3;
    out[4]=w4; out[5]=w5; out[6]=w6; out[7]=w7;

    uint64_t SL, SH;
    mul_lo_64(SL, acc, 0x1000003D1ULL);
    mul_hi_64(SH, acc, 0x1000003D1ULL);
    add_cc_64 (res[0], *(uint64_t*)(out+0), SL);
    addc_cc_64(res[1], *(uint64_t*)(out+2), SH);
    addc_cc_64(res[2], *(uint64_t*)(out+4), 0ULL);
    addc_64(res[3], *(uint64_t*)(out+6), 0ULL);
}

__device__ __forceinline__ void ModMult(uint64_t* res, uint64_t* val1, uint64_t* val2) {
    uint32_t* a = (uint32_t*)val1;
    uint32_t* b = (uint32_t*)val2;
    uint32_t out[16];
    uint64_t acc, ov, prod;

    mul_wide_32(acc, a[0], b[0]);
    out[0] = (uint32_t)acc;
    acc >>= 32; ov = 0ull;

    mul_wide_32(prod, a[0], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[1] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[2] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[3] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[4] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[5] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[6] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[0], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[1], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[0]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[7] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[1], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[2], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[1]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[8] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[2], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[3], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[2]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[9] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[3], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[4], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[3]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[10] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[4], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[5], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[4]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[11] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[5], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[6], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[5]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[12] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32); ov = 0ull;

    mul_wide_32(prod, a[6], b[7]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    mul_wide_32(prod, a[7], b[6]); add_cc_64(acc, acc, prod); addc_64(ov, ov, 0ull);
    out[13] = (uint32_t)acc;
    acc = (acc >> 32) + (ov << 32);

    mul_wide_32(prod, a[7], b[7]);
    add_cc_64(acc, acc, prod);
    out[14] = (uint32_t)acc;
    out[15] = (uint32_t)(acc >> 32);

    uint32_t* h = out + 8;
    uint32_t w0, w1, w2, w3, w4, w5, w6, w7;

    mul_wide_32(acc, h[0], 0x3D1u);
    add_64(acc, acc, (uint64_t)out[0]);
    w0 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[1], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[1]);
    add_64(acc, acc, (uint64_t)h[0]);
    w1 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[2], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[2]);
    add_64(acc, acc, (uint64_t)h[1]);
    w2 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[3], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[3]);
    add_64(acc, acc, (uint64_t)h[2]);
    w3 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[4], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[4]);
    add_64(acc, acc, (uint64_t)h[3]);
    w4 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[5], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[5]);
    add_64(acc, acc, (uint64_t)h[4]);
    w5 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[6], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[6]);
    add_64(acc, acc, (uint64_t)h[5]);
    w6 = (uint32_t)acc; acc >>= 32;

    mad_wide_32(acc, h[7], 0x3D1u, acc);
    add_64(acc, acc, (uint64_t)out[7]);
    add_64(acc, acc, (uint64_t)h[6]);
    w7 = (uint32_t)acc; acc >>= 32;

    add_64(acc, acc, (uint64_t)h[7]);

    out[0]=w0; out[1]=w1; out[2]=w2; out[3]=w3;
    out[4]=w4; out[5]=w5; out[6]=w6; out[7]=w7;

    uint64_t SL, SH;
    mul_lo_64(SL, acc, 0x1000003D1ULL);
    mul_hi_64(SH, acc, 0x1000003D1ULL);
    add_cc_64 (res[0], *(uint64_t*)(out+0), SL);
    addc_cc_64(res[1], *(uint64_t*)(out+2), SH);
    addc_cc_64(res[2], *(uint64_t*)(out+4), 0ULL);
    addc_64(res[3], *(uint64_t*)(out+6), 0ULL);
}

// ============================================================================
// For ModInv
// ============================================================================

#define APPLY_DIV_SHIFT() matrix[0] <<= index; matrix[1] <<= index; kbnt -= index; _val >>= index;  
#define DO_INV_STEP() {kbnt = -kbnt; int tmp = -_modp; _modp = _val; _val = tmp; tmp = -matrix[0];\
                       matrix[0] = matrix[2]; matrix[2] = tmp; tmp = -matrix[1]; matrix[1] = matrix[3]; matrix[3] = tmp;}

__device__ __forceinline__ void set_288_i32(uint32_t* res, int val) {
    res[0] = val;
    res[1] = (uint32_t)(val >> 31);
    res[2] = res[1];
    res[3] = res[1];
    res[4] = res[1];
    res[5] = res[1];
    res[6] = res[1];
    res[7] = res[1];
    res[8] = res[1];
}

__device__ __forceinline__ void shiftR_288_by_30(uint32_t* res) {
    res[0] = __funnelshift_r(res[0], res[1], 30);
    res[1] = __funnelshift_r(res[1], res[2], 30);
    res[2] = __funnelshift_r(res[2], res[3], 30);
    res[3] = __funnelshift_r(res[3], res[4], 30);
    res[4] = __funnelshift_r(res[4], res[5], 30);
    res[5] = __funnelshift_r(res[5], res[6], 30);
    res[6] = __funnelshift_r(res[6], res[7], 30);
    res[7] = __funnelshift_r(res[7], res[8], 30);
    res[8] = ((int)res[8]) >> 30;
}

__device__ __forceinline__ void add_288(uint32_t* res, uint32_t* val1, uint32_t* val2) {
    add_cc_32(res[0], val1[0], val2[0]);
    addc_cc_32(res[1], val1[1], val2[1]);
    addc_cc_32(res[2], val1[2], val2[2]);
    addc_cc_32(res[3], val1[3], val2[3]);
    addc_cc_32(res[4], val1[4], val2[4]);
    addc_cc_32(res[5], val1[5], val2[5]);
    addc_cc_32(res[6], val1[6], val2[6]);
    addc_cc_32(res[7], val1[7], val2[7]);
    addc_32(res[8], val1[8], val2[8]);
}

__device__ __forceinline__ void add_288_P(uint32_t* res) {
    add_cc_32(res[0], res[0], 0xFFFFFC2Fu);
    addc_cc_32(res[1], res[1], 0xFFFFFFFEu);
    addc_cc_32(res[2], res[2], 0xFFFFFFFFu);
    addc_cc_32(res[3], res[3], 0xFFFFFFFFu);
    addc_cc_32(res[4], res[4], 0xFFFFFFFFu);
    addc_cc_32(res[5], res[5], 0xFFFFFFFFu);
    addc_cc_32(res[6], res[6], 0xFFFFFFFFu);
    addc_cc_32(res[7], res[7], 0xFFFFFFFFu);
    addc_32(res[8], res[8], 0u);
}

__device__ __forceinline__ void neg_288(uint32_t* res) {
    sub_cc_32(res[0], 0u, res[0]);
    subc_cc_32(res[1], 0u, res[1]);
    subc_cc_32(res[2], 0u, res[2]);
    subc_cc_32(res[3], 0u, res[3]);
    subc_cc_32(res[4], 0u, res[4]);
    subc_cc_32(res[5], 0u, res[5]);
    subc_cc_32(res[6], 0u, res[6]);
    subc_cc_32(res[7], 0u, res[7]);
    subc_32(res[8], 0u, res[8]);
}

__device__ __forceinline__ void sub_288_P(uint32_t* res) {
    sub_cc_32(res[0], res[0], 0xFFFFFC2Fu);
    subc_cc_32(res[1], res[1], 0xFFFFFFFEu);
    subc_cc_32(res[2], res[2], 0xFFFFFFFFu);
    subc_cc_32(res[3], res[3], 0xFFFFFFFFu);
    subc_cc_32(res[4], res[4], 0xFFFFFFFFu);
    subc_cc_32(res[5], res[5], 0xFFFFFFFFu);
    subc_cc_32(res[6], res[6], 0xFFFFFFFFu);
    subc_cc_32(res[7], res[7], 0xFFFFFFFFu);
    subc_32(res[8], res[8], 0u);
}

__device__ __forceinline__ void mul_P_by_32(uint32_t* res, uint32_t val) {
    __align__(8) uint32_t tmp[3];

    mul_wide_32(*(uint64_t*)tmp, val, 0x000003D1u);
    add_cc_32(tmp[1], tmp[1], val);
    addc_32(tmp[2], 0u, 0u);

    sub_cc_32(res[0], 0u, tmp[0]);
    subc_cc_32(res[1], 0u, tmp[1]);
    subc_cc_32(res[2], 0u, tmp[2]);
    subc_cc_32(res[3], 0u, 0u);
    subc_cc_32(res[4], 0u, 0u);
    subc_cc_32(res[5], 0u, 0u);
    subc_cc_32(res[6], 0u, 0u);
    subc_cc_32(res[7], 0u, 0u);
    subc_32(res[8], val, 0u);
}

__device__ __forceinline__ void mul_288_by_i32(uint32_t* res, uint32_t* val288, int ival32) {
    uint32_t val32 = abs(ival32);
    uint64_t tmp64[4];
    uint32_t* tmp = (uint32_t*)tmp64;
    uint64_t* r32 = (uint64_t*)res;
    
    mul_wide_32(r32[0], val288[0], val32);
    mul_wide_32(r32[1], val288[2], val32);
    mul_wide_32(r32[2], val288[4], val32);
    mul_wide_32(r32[3], val288[6], val32);
    mul_wide_32(tmp64[0], val288[1], val32);
    mul_wide_32(tmp64[1], val288[3], val32);
    mul_wide_32(tmp64[2], val288[5], val32);
    mul_wide_32(tmp64[3], val288[7], val32);

    add_cc_32(res[1], res[1], tmp[0]);
    addc_cc_32(res[2], res[2], tmp[1]);
    addc_cc_32(res[3], res[3], tmp[2]);
    addc_cc_32(res[4], res[4], tmp[3]);
    addc_cc_32(res[5], res[5], tmp[4]);
    addc_cc_32(res[6], res[6], tmp[5]);
    addc_cc_32(res[7], res[7], tmp[6]);
    madc_lo_32(res[8], val288[8], val32, tmp[7]);

    if (ival32 < 0)
        neg_288(res);
}

__device__ __forceinline__ void ModInv(uint64_t* R) {
    uint32_t* res = (uint32_t*)R;
    int matrix[4], _val, _modp, index, cnt, mx, kbnt;
    __align__(8) uint32_t modp[9];
    __align__(8) uint32_t val[9];
    __align__(8) uint32_t a[9];
    __align__(8) uint32_t tmp[4][10];

    modp[0] = 0xFFFFFC2Fu;
    modp[1] = 0xFFFFFFFEu;
    modp[2] = 0xFFFFFFFFu;
    modp[3] = 0xFFFFFFFFu;
    modp[4] = 0xFFFFFFFFu;
    modp[5] = 0xFFFFFFFFu;
    modp[6] = 0xFFFFFFFFu;
    modp[7] = 0xFFFFFFFFu;
    modp[8] = 0u;

    res[8] = 0u;
    val[0] = res[0]; val[1] = res[1]; val[2] = res[2]; val[3] = res[3];
    val[4] = res[4]; val[5] = res[5]; val[6] = res[6]; val[7] = res[7];
    val[8] = 0u;

    matrix[0] = matrix[3] = 1;
    matrix[1] = matrix[2] = 0;
    kbnt = -1;
    _val = (int)res[0];
    _modp = (int)0xFFFFFC2Fu;
    index = __ffs(_val | 0x40000000u) - 1;
    APPLY_DIV_SHIFT();
    cnt = 30 - index;

    while (cnt > 0)
    {
        if (kbnt < 0)
            DO_INV_STEP();
        mx = max(31 - kbnt, 32 - cnt);
        int mul = (-_modp * _val) & 7;
        mul &= 0xFFFFFFFFu >> mx;
        _val += _modp * mul;
        matrix[2] += matrix[0] * mul;
        matrix[3] += matrix[1] * mul;
        index = __ffs(_val | (1 << cnt)) - 1;
        APPLY_DIV_SHIFT();
        cnt -= index;
    }

    mul_288_by_i32(tmp[0], modp, matrix[0]);
    mul_288_by_i32(tmp[1], val, matrix[1]);
    mul_288_by_i32(tmp[2], modp, matrix[2]);
    mul_288_by_i32(tmp[3], val, matrix[3]);
    add_288(modp, tmp[0], tmp[1]);
    shiftR_288_by_30(modp);
    add_288(val, tmp[2], tmp[3]);
    shiftR_288_by_30(val);
    set_288_i32(tmp[1], matrix[1]);
    set_288_i32(tmp[3], matrix[3]);
    mul_P_by_32(res, (tmp[1][0] * 0xD2253531u) & 0x3FFFFFFFu);
    add_288(res, res, tmp[1]);
    shiftR_288_by_30(res);
    mul_P_by_32(a, (tmp[3][0] * 0xD2253531u) & 0x3FFFFFFFu);
    add_288(a, a, tmp[3]);
    shiftR_288_by_30(a);

    while (1)
    {
        matrix[0] = matrix[3] = 1;
        matrix[1] = matrix[2] = 0;
        _val = val[0];
        _modp = modp[0];
        index = __ffs(_val | 0x40000000u) - 1;
        APPLY_DIV_SHIFT();
        cnt = 30 - index;

        while (cnt > 0)
        {
            if (kbnt < 0)
                DO_INV_STEP();
            mx = max(31 - kbnt, 32 - cnt);
            int mul = (-_modp * _val) & 7;
            mul &= 0xFFFFFFFFu >> mx;
            _val += _modp * mul;
            matrix[2] += matrix[0] * mul;
            matrix[3] += matrix[1] * mul;
            index = __ffs(_val | (1 << cnt)) - 1;
            APPLY_DIV_SHIFT();
            cnt -= index;
        }

        mul_288_by_i32(tmp[0], modp, matrix[0]);
        mul_288_by_i32(tmp[1], val, matrix[1]);
        mul_288_by_i32(tmp[2], modp, matrix[2]);
        mul_288_by_i32(tmp[3], val, matrix[3]);
        add_288(modp, tmp[0], tmp[1]);
        shiftR_288_by_30(modp);
        add_288(val, tmp[2], tmp[3]);
        shiftR_288_by_30(val);
        mul_288_by_i32(tmp[0], res, matrix[0]);
        mul_288_by_i32(tmp[1], a, matrix[1]);

        if ((val[0] | val[1] | val[2] | val[3] | val[4] | val[5] | val[6] | val[7]) == 0)
            break;

        mul_288_by_i32(tmp[2], res, matrix[2]);
        mul_288_by_i32(tmp[3], a, matrix[3]);
        mul_P_by_32(res, ((tmp[0][0] + tmp[1][0]) * 0xD2253531u) & 0x3FFFFFFFu);
        add_288(res, res, tmp[0]);
        add_288(res, res, tmp[1]);
        shiftR_288_by_30(res);
        mul_P_by_32(a, ((tmp[2][0] + tmp[3][0]) * 0xD2253531u) & 0x3FFFFFFFu);
        add_288(a, a, tmp[2]);
        add_288(a, a, tmp[3]);
        shiftR_288_by_30(a);
    }

    mul_P_by_32(res, ((tmp[0][0] + tmp[1][0]) * 0xD2253531u) & 0x3FFFFFFFu);
    add_288(res, res, tmp[0]);
    add_288(res, res, tmp[1]);
    shiftR_288_by_30(res);

    if ((int)modp[8] < 0)
        neg_288(res);
    while ((int)res[8] < 0)
        add_288_P(res);
    while ((int)res[8] > 0)
        sub_288_P(res);
}

// ============================================================================
// For CalculateScalarPositionKernel
// ============================================================================

__device__ uint64_t* g_steps_table;

__device__ __forceinline__ int cspk_cmp256(uint64_t* val1, uint64_t* val2) {
    #pragma unroll
    for (int i = 3; i >= 0; --i) {
        if (val1[i] != val2[i]) return (val1[i] > val2[i]) ? 1 : -1;
    }
    return 0;
}

__device__ __forceinline__ uint64_t cspk_mix64(uint64_t val1) {
    val1 += 0x9E3779B97F4A7C15ull;
    val1 = (val1 ^ (val1 >> 30)) * 0xBF58476D1CE4E5B9ull;
    val1 = (val1 ^ (val1 >> 27)) * 0x94D049BB133111EBull;
    return val1 ^ (val1 >> 31);
}

__device__ __forceinline__ int cspk_find_highest_bit_256(uint64_t* val1) {
    #pragma unroll
    for (int i = 3; i >= 0; --i) {
        if (val1[i] != 0ull) return i * 64 + (63 - __clzll(val1[i]));
    }
    return -1;
}

__device__ __forceinline__ void cspk_add256(uint64_t* val1, uint64_t* val2, uint64_t* res) {
    add_cc_64(res[0], val1[0], val2[0]);
    addc_cc_64(res[1], val1[1], val2[1]);
    addc_cc_64(res[2], val1[2], val2[2]);
    addc_64(res[3], val1[3], val2[3]);
}

__device__ __forceinline__ void cspk_sub256(uint64_t* val1, uint64_t* val2, uint64_t* res) {
    sub_cc_64(res[0], val1[0], val2[0]);
    subc_cc_64(res[1], val1[1], val2[1]);
    subc_cc_64(res[2], val1[2], val2[2]);
    subc_64(res[3], val1[3], val2[3]);
}

__device__ __forceinline__ void cspk_mod_256(uint64_t* val1, uint64_t* val2, uint64_t* res) {
    res[0]=res[1]=res[2]=res[3]=0ull;
    if ((val2[0] | val2[1] | val2[2] | val2[3]) == 0ull) return;
    if (cspk_cmp256(val1, val2) < 0) {
        res[0]=val1[0]; res[1]=val1[1]; res[2]=val1[2]; res[3]=val1[3];
        return;
    }
    int msb = cspk_find_highest_bit_256(val1);
    if (msb < 0) return;

    uint64_t rem[4] = {0,0,0,0};
    for (int i = msb; i >= 0; --i) {
        uint64_t db = (val1[i >> 6] >> (i & 63)) & 1ull;
        rem[3] = (rem[3] << 1) | (rem[2] >> 63);
        rem[2] = (rem[2] << 1) | (rem[1] >> 63);
        rem[1] = (rem[1] << 1) | (rem[0] >> 63);
        rem[0] = (rem[0] << 1) | db;

        uint64_t t0,t1,t2,t3; uint32_t borrow;
        sub_cc_64(t0, rem[0], val2[0]);
        subc_cc_64(t1, rem[1], val2[1]);
        subc_cc_64(t2, rem[2], val2[2]);
        subc_cc_64(t3, rem[3], val2[3]);
        subc_32(borrow, 0u, 0u);
        if (borrow == 0u) { rem[0]=t0; rem[1]=t1; rem[2]=t2; rem[3]=t3; }
    }
    res[0]=rem[0]; res[1]=rem[1]; res[2]=rem[2]; res[3]=rem[3];
}

__device__ __forceinline__ uint64_t cspk_step_index(
    uint64_t seed, uint64_t gid, uint64_t epoch, uint64_t entries)
{
    uint64_t h = cspk_mix64(seed ^ cspk_mix64(gid));
    h = cspk_mix64(h ^ cspk_mix64(epoch * 0x9E3779B97F4A7C15ull));
    return h % entries;
}

__launch_bounds__(256, 5)
__global__ void CalculateScalarPositionKernel(
    uint64_t* __restrict__ d_start_scalars,
    const uint64_t* __restrict__ d_sec_start,
    const uint64_t* __restrict__ d_sec_end,
    const uint64_t* __restrict__ d_sec_len,
    const uint64_t* __restrict__ d_section_start_off,
    uint32_t range_divisions,
    uint64_t threadsTotal,
    uint64_t threads_per_section_base,
    uint64_t thread_remainder,
    uint64_t thread_stride,
    uint64_t seed,
    uint64_t steps_table_entries,
    uint64_t epoch_idx
)
{
    uint64_t gid = (uint64_t)blockIdx.x * blockDim.x + threadIdx.x;

    uint64_t extra_section_threads = threads_per_section_base + 1ull;
    uint64_t threads_in_extra_secs = extra_section_threads * thread_remainder;

    uint32_t section_idx;
    if (gid < threads_in_extra_secs) {
        section_idx = (uint32_t)(gid / extra_section_threads);
    } else {
        uint64_t adjusted = gid - threads_in_extra_secs;
        section_idx = (uint32_t)(thread_remainder + (adjusted / threads_per_section_base));
    }
    if (section_idx >= range_divisions) section_idx = range_divisions - 1u;

    uint64_t sec_start[4], sec_end[4], sec_len[4];
    Load_2x128_NC(sec_start, &d_sec_start[(size_t)section_idx * 4]);
    Load_2x128_NC(sec_end, &d_sec_end[(size_t)section_idx * 4]);
    Load_2x128_NC(sec_len, &d_sec_len[(size_t)section_idx * 4]);

    uint64_t pos[4];

    if (epoch_idx == 0ull) {
        // ====================================================================
        // First epoch: deterministic spread across the section
        // ====================================================================
        uint64_t local_thread_pos = gid - d_section_start_off[section_idx];
        uint64_t off_lo = local_thread_pos * thread_stride;
        uint64_t off_hi = __umul64hi(local_thread_pos, thread_stride);
        uint64_t offset128[4] = { off_lo, off_hi, 0ull, 0ull };
        cspk_add256(sec_start, offset128, pos);
    } else {
        // ====================================================================
        // Later epochs: random lookup into the steps table
        // ====================================================================
        uint64_t cur[4], step[4];
        Load_2x128(cur, &d_start_scalars[gid * 4]);

        uint64_t idx = cspk_step_index(seed, gid, epoch_idx, steps_table_entries);
        Load_2x128_NC(step, &g_steps_table[idx * 4]);

        cspk_add256(cur, step, pos);
    }

    // ========================================================================
    // Wrap back into the section
    // ========================================================================
    if (cspk_cmp256(pos, sec_end) > 0) {
        cspk_sub256(pos, sec_len, pos);

        if (cspk_cmp256(pos, sec_end) > 0) {
            uint64_t offset[4], rem[4];
            cspk_sub256(pos, sec_start, offset);
            cspk_mod_256(offset, sec_len, rem);
            cspk_add256(sec_start, rem, pos);
        }
    }

    Store_2x128(&d_start_scalars[gid * 4], pos);
}

// ============================================================================
// For PrecomputeTableKernel and ScalarToPointKernel
// ============================================================================

__device__ __align__(16) uint64_t g_precomp_x[16ull * 65536 * 4];
__device__ __align__(16) uint64_t g_precomp_y[16ull * 65536 * 4];

__constant__ uint64_t c_wG_x[64] = {
    0x59F2815B16F81798ull, 0x029BFCDB2DCE28D9ull, 0x55A06295CE870B07ull, 0x79BE667EF9DCBBACull,
    0x526BAD8F83FF4640ull, 0x53441C7E55552FFEull, 0x99CEAC05B6262EE0ull, 0x363D90D447B00C9Cull,
    0xEFD7835B39A48DB0ull, 0x9F1215A29B3C03BFull, 0x2791D0A09B7BDE45ull, 0x100F44DA696E7167ull,
    0x57545CCC1A37B7C0ull, 0xEC08D0F7BB11069Full, 0xA6E000935EF22151ull, 0x53904FAA0B334CDDull,
    0x13B7E0E742D0E6BDull, 0xF774D163DB0F5E53ull, 0x82A2147C104D6ECBull, 0x3322D401243C4E25ull,
    0x2953CC8D2037FA2Dull, 0x043EC8F575BFDC43ull, 0x3D8348414BBF4103ull, 0xE5037DE0AFC1D8D4ull,
    0x32427E2840FB27B6ull, 0xC76E3DB2BE430576ull, 0x10F238AD61686AA5ull, 0xFEA74E3DBE778B1Bull,
    0x49150A564F676E03ull, 0xCEFFC73693E84EDDull, 0xEB0F6433571E8761ull, 0xB8DA94032A957518ull,
    0x1B7B444C9EC4C0DAull, 0xE88C5678723EA335ull, 0x9239C1AD981F162Eull, 0x8F68B9D2F63B5F33ull,
    0x3CF29EB3DE6B80EFull, 0x71CBCB967D79424Full, 0xD23540C223BCBDC5ull, 0xB6459E0EE3662EC8ull,
    0xCBFC99C8AC1F98CDull, 0x523489054D7F0308ull, 0xFAED8A9C1CC66021ull, 0x9C3919A84A474870ull,
    0xB09EDA9C06D903ACull, 0xD5F96274E5AD7E5Cull, 0x63729FD30E7AFD2Eull, 0x0928955EE637A844ull,
    0x7F3B58FA2120E2B3ull, 0x7A58FDCE7F47F9AAull, 0xE7BE4AE34CE6E521ull, 0xEAA649F21F51BDBAull,
    0x6D76A8793180EEF9ull, 0x8D0012209A28B977ull, 0x7E3ACEBB1AA07B12ull, 0xFA50C0F61D22E5F0ull,
    0x884FDFF09475B7BAull, 0xE039E730E4918B3Dull, 0x3D3E57EDF5018CDBull, 0x959396981943785Cull,
    0xBCD6303F6CAF666Bull, 0x7FFCFED3C4B1CE30ull, 0x62B6979AE817F463ull, 0x13464A57A78102AAull
};

__constant__ uint64_t c_wG_y[64] = {
    0x9C47D08FFB10D4B8ull, 0xFD17B448A6855419ull, 0x5DA4FBFC0E1108A8ull, 0x483ADA7726A3C465ull,
    0x62003C7F3BEE9DE9ull, 0x45B9A89008199ECBull, 0x953B445397F33631ull, 0x04E273ADFC732221ull,
    0x0FBD5CD62BC65A09ull, 0xB7FF4A18FF5195ACull, 0x2EC8F3300C090666ull, 0xCDD9E13192A00B77ull,
    0x9DCB096B022771C8ull, 0x13999981E1443469ull, 0x88C9ECCAC20D3C1Cull, 0x5BC087D0BC80106Dull,
    0x24F3A2E96C28B2A0ull, 0x2805F63EA2873AF6ull, 0xBFB019BC4DDAF9B7ull, 0x56E70797E9664EF5ull,
    0xE0E5DC841D755BDAull, 0xBD5F5B03EC481F10ull, 0xF9F98D09FB990BDDull, 0x4571534BAA94D3B5ull,
    0x701D3DB7F23CB96Full, 0x126B596B973F7B77ull, 0x7CF674DECCB6AF93ull, 0x6E0568DB9B0B1329ull,
    0x1488E4E74EFDF6E7ull, 0x92CC584D95FF3B51ull, 0xD7C99CC9762808B0ull, 0x2804DFA44805A1E4ull,
    0xF23CBF79501FFF82ull, 0xBBEA2CFE95510BFDull, 0xDE1D90C2B6BE215Dull, 0x662A9F2DBA063986ull,
    0xF30BF0B61A71BA45ull, 0xC4B3AE6D48E35B2Full, 0xE1DADF16E5661DB3ull, 0x067C876D06F3E06Dull,
    0xBE7E5E03D4FC599Dull, 0x905326F76C64C8E6ull, 0x584F044BF260E641ull, 0xDDB84F0F4A4DDD57ull,
    0xC5180E935BCD091Full, 0xAC3D26EFA8A8D83Full, 0x27B78A13093A95EEull, 0xC25621003D3F42A8ull,
    0xD47A5305BA5AD93Dull, 0x01A6B965F13F7E59ull, 0xC69A80F89879AA5Aull, 0xBE3279ED5BBBB03Aull,
    0x38CD8D7D3F4F2811ull, 0x5E683293A57A213Bull, 0xB72CD2872281A68Aull, 0x6B84C6922397EBA9ull,
    0xE9B8ABF87524F2FDull, 0x9C653F64C8709385ull, 0x8BA0386A4B9CD684ull, 0x2E7E552888C331DDull,
    0x3F495A907F6ECC27ull, 0x48F300A81D0942E1ull, 0xEF7E433453CCB0CAull, 0x69BE159004614580ull
};

__device__ __forceinline__ void FieldAdd(uint64_t* res, uint64_t* val1, uint64_t* val2) {
    uint64_t t0, t1, t2, t3;
    uint32_t carry;

    add_cc_64 (t0, val1[0], val2[0]);
    addc_cc_64(t1, val1[1], val2[1]);
    addc_cc_64(t2, val1[2], val2[2]);
    addc_cc_64(t3, val1[3], val2[3]);
    addc_32(carry, 0u, 0u);

    uint64_t r0, r1, r2, r3;
    uint32_t borrow;
    sub_cc_64 (r0, t0, 0xFFFFFFFEFFFFFC2Full);
    subc_cc_64(r1, t1, 0xFFFFFFFFFFFFFFFFull);
    subc_cc_64(r2, t2, 0xFFFFFFFFFFFFFFFFull);
    subc_cc_64(r3, t3, 0xFFFFFFFFFFFFFFFFull);
    subc_cc_32(borrow, carry, 0u);
    subc_32(borrow, 0u, 0u);

    res[0] = borrow ? t0 : r0;
    res[1] = borrow ? t1 : r1;
    res[2] = borrow ? t2 : r2;
    res[3] = borrow ? t3 : r3;
}

__device__ __forceinline__ void PointDoubleJacobian(uint64_t* RX, uint64_t* RY, uint64_t* RZ) {
    uint64_t X0=RX[0], X1=RX[1], X2=RX[2], X3=RX[3];
    uint64_t Y0=RY[0], Y1=RY[1], Y2=RY[2], Y3=RY[3];
    uint64_t Z0=RZ[0], Z1=RZ[1], Z2=RZ[2], Z3=RZ[3];
    uint64_t lX[4] = {X0,X1,X2,X3};
    uint64_t lY[4] = {Y0,Y1,Y2,Y3};
    uint64_t lZ[4] = {Z0,Z1,Z2,Z3};
    uint64_t A[4], B[4], C[4], D[4], E[4], t[4];

    ModSqr(A, lX);
    ModSqr(B, lY);
    ModSqr(C, B);

    FieldAdd(t, lX, B);
    ModSqr(t, t);
    ModSub(t, t, A);
    ModSub(t, t, C);
    FieldAdd(D, t, t);

    FieldAdd(E, A, A);
    FieldAdd(E, E, A);

    ModSqr(t, E);
    FieldAdd(RX, D, D);
    ModSub(RX, t, RX);

    ModSub(t, D, RX);
    ModMult(t, E, t);
    FieldAdd(C, C, C);
    FieldAdd(C, C, C);
    FieldAdd(C, C, C);
    ModSub(RY, t, C);

    ModMult(RZ, lY, lZ);
    FieldAdd(RZ, RZ, RZ);
}

__device__ __forceinline__ void PointAddJacobian(uint64_t* RX, uint64_t* RY, uint64_t* RZ, uint64_t* Qx, uint64_t* Qy) {
    uint64_t lX[4] = {RX[0],RX[1],RX[2],RX[3]};
    uint64_t lY[4] = {RY[0],RY[1],RY[2],RY[3]};
    uint64_t lZ[4] = {RZ[0],RZ[1],RZ[2],RZ[3]};
    uint64_t Z1Z1[4], U2[4], S2[4], H[4], HH[4], I[4], J[4], r[4], V[4], t[4];

    ModSqr(Z1Z1, lZ);
    ModMult(U2, Qx, Z1Z1);
    ModMult(t,  lZ, Z1Z1);
    ModMult(S2, Qy, t);
    ModSub(H, U2, lX);

    ModSqr(HH, H);
    FieldAdd(I, HH, HH);
    FieldAdd(I, I, I);
    ModMult(J, H, I);
    ModSub(r, S2, lY);
    FieldAdd(r, r, r);
    ModMult(V, lX, I);

    ModSqr(RX, r);
    ModSub(RX, RX, J);
    ModSub(RX, RX, V);
    ModSub(RX, RX, V);

    ModMult(t, lY, J);
    FieldAdd(t, t, t);
    ModSub(RY, V, RX);
    ModMult(RY, r, RY);
    ModSub(RY, RY, t);

    FieldAdd(RZ, lZ, H);
    ModSqr(RZ, RZ);
    ModSub(RZ, RZ, Z1Z1);
    ModSub(RZ, RZ, HH);
}

__launch_bounds__(256, 2)
__global__ void PrecomputeTableKernel(int window) {
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    if (j == 0) return;

    size_t base = ((size_t)window * 65536 + (size_t)j) * 4;

    int first = 31 - __clz(j);

    uint64_t RX[4], RY[4], RZ[4];
    RX[0]=c_wG_x[window*4+0]; RX[1]=c_wG_x[window*4+1];
    RX[2]=c_wG_x[window*4+2]; RX[3]=c_wG_x[window*4+3];
    RY[0]=c_wG_y[window*4+0]; RY[1]=c_wG_y[window*4+1];
    RY[2]=c_wG_y[window*4+2]; RY[3]=c_wG_y[window*4+3];
    RZ[0]=1ull; RZ[1]=0ull; RZ[2]=0ull; RZ[3]=0ull;

    uint64_t Qx[4], Qy[4];
    Qx[0]=c_wG_x[window*4+0]; Qx[1]=c_wG_x[window*4+1];
    Qx[2]=c_wG_x[window*4+2]; Qx[3]=c_wG_x[window*4+3];
    Qy[0]=c_wG_y[window*4+0]; Qy[1]=c_wG_y[window*4+1];
    Qy[2]=c_wG_y[window*4+2]; Qy[3]=c_wG_y[window*4+3];

    for (int bit = first - 1; bit >= 0; --bit) {
        PointDoubleJacobian(RX, RY, RZ);
        if ((j >> bit) & 1)
            PointAddJacobian(RX, RY, RZ, Qx, Qy);
    }

    uint64_t zInv[5], zInv2[4], zInv3[4];

    zInv[0]=RZ[0]; zInv[1]=RZ[1]; zInv[2]=RZ[2]; zInv[3]=RZ[3]; zInv[4]=0ull;
    ModInv(zInv);
    ModSqr(zInv2, zInv);
    ModMult(zInv3, zInv2, zInv);
    ModMult(RX, RX, zInv2);
    ModMult(RY, RY, zInv3);

    Store_2x128(&g_precomp_x[base], RX);
    Store_2x128(&g_precomp_y[base], RY);
}

__launch_bounds__(256, 2)
__global__ void ScalarToPointKernel(const uint64_t* __restrict__ scalars_in, uint64_t* __restrict__ outX, uint64_t* __restrict__ outY) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    uint64_t s[4];

    Load_2x128(s, scalars_in + (size_t)idx * 4);

    uint16_t w[16];
    w[0] = (uint16_t)(s[0]);
    w[1] = (uint16_t)(s[0] >> 16);
    w[2] = (uint16_t)(s[0] >> 32);
    w[3] = (uint16_t)(s[0] >> 48);
    w[4] = (uint16_t)(s[1]);
    w[5] = (uint16_t)(s[1] >> 16);
    w[6] = (uint16_t)(s[1] >> 32);
    w[7] = (uint16_t)(s[1] >> 48);
    w[8] = (uint16_t)(s[2]);
    w[9] = (uint16_t)(s[2] >> 16);
    w[10] = (uint16_t)(s[2] >> 32);
    w[11] = (uint16_t)(s[2] >> 48);
    w[12] = (uint16_t)(s[3]);
    w[13] = (uint16_t)(s[3] >> 16);
    w[14] = (uint16_t)(s[3] >> 32);
    w[15] = (uint16_t)(s[3] >> 48);

    int first = 15;
    while (first > 0 && w[first] == 0) --first;

    size_t entry = ((size_t)first * 65536 + (size_t)w[first]) * 4;

    uint64_t RX[4], RY[4], RZ[4];

    Load_2x128_NC(RX, g_precomp_x + entry);
    Load_2x128_NC(RY, g_precomp_y + entry);
    RZ[0]=1ull; RZ[1]=0ull; RZ[2]=0ull; RZ[3]=0ull;

    for (int i = first - 1; i >= 0; --i) {
        if (w[i] == 0) continue;
        size_t e = ((size_t)i * 65536 + (size_t)w[i]) * 4;

        uint64_t Qx[4], Qy[4];

        Load_2x128_NC(Qx, g_precomp_x + e);
        Load_2x128_NC(Qy, g_precomp_y + e);
        PointAddJacobian(RX, RY, RZ, Qx, Qy);
    }

    uint64_t zInv[5], zInv2[4], zInv3[4];
    
    zInv[0]=RZ[0]; zInv[1]=RZ[1]; zInv[2]=RZ[2]; zInv[3]=RZ[3]; zInv[4]=0ull;
    ModInv(zInv);
    ModSqr(zInv2, zInv);
    ModMult(zInv3, zInv2, zInv);
    ModMult(RX, RX, zInv2);
    ModMult(RY, RY, zInv3);
    Store_2x128(outX + (size_t)idx*4, RX);
    Store_2x128(outY + (size_t)idx*4, RY);
}
