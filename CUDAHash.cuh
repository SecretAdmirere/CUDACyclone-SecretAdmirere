// CUDACyclone-SecretAdmirere
// Copyright (C) 2026 SecretAdmirere
//
// Portions of this file are derived from VanitySearch
// (https://github.com/JeanLucPons/VanitySearch)
// Copyright (c) 2019 Jean Luc PONS, licensed under GPLv3.
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
// For Sha256
// ============================================================================

__device__ __constant__ uint32_t SHA256_K[64] = {
    0x428A2F98u,0x71374491u,0xB5C0FBCFu,0xE9B5DBA5u,0x3956C25Bu,0x59F111F1u,0x923F82A4u,0xAB1C5ED5u,
    0xD807AA98u,0x12835B01u,0x243185BEu,0x550C7DC3u,0x72BE5D74u,0x80DEB1FEu,0x9BDC06A7u,0xC19BF174u,
    0xE49B69C1u,0xEFBE4786u,0x0FC19DC6u,0x240CA1CCu,0x2DE92C6Fu,0x4A7484AAu,0x5CB0A9DCu,0x76F988DAu,
    0x983E5152u,0xA831C66Du,0xB00327C8u,0xBF597FC7u,0xC6E00BF3u,0xD5A79147u,0x06CA6351u,0x14292967u,
    0x27B70A85u,0x2E1B2138u,0x4D2C6DFCu,0x53380D13u,0x650A7354u,0x766A0ABBu,0x81C2C92Eu,0x92722C85u,
    0xA2BFE8A1u,0xA81A664Bu,0xC24B8B70u,0xC76C51A3u,0xD192E819u,0xD6990624u,0xF40E3585u,0x106AA070u,
    0x19A4C116u,0x1E376C08u,0x2748774Cu,0x34B0BCB5u,0x391C0CB3u,0x4ED8AA4Au,0x5B9CCA4Fu,0x682E6FF3u,
    0x748F82EEu,0x78A5636Fu,0x84C87814u,0x8CC70208u,0x90BEFFFAu,0xA4506CEBu,0xBEF9A3F7u,0xC67178F2u
};

__device__ __constant__ uint32_t SHA256_PAD[7] = {
    0xA50000u, 0x108u, 0x10420023u, 0x90BB1E3Cu,
    0x50C6645Bu, 0x3AC42E24u, 0xC19BF27Cu
};

__device__ __forceinline__ uint32_t S0(uint32_t x) {
    uint32_t y;
    asm volatile ("{\n\t"
        " .reg .u64 r1,r2,r3;\n\t"
        " cvt.u64.u32 r1, %1;\n\t"
        " mov.u64 r2, r1;\n\t"
        " shl.b64 r2, r2,32;\n\t"
        " or.b64  r1, r1,r2;\n\t"
        " shr.b64 r3, r1, 2;\n\t"
        " mov.u64 r2, r3;\n\t"
        " shr.b64 r3, r1, 13;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " shr.b64 r3, r1, 22;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " cvt.u32.u64 %0,r2;\n\t"
        "}\n\t"
        : "=r"(y) : "r"(x));
    return y;
}

__device__ __forceinline__ uint32_t S1(uint32_t x) {
    uint32_t y;
    asm volatile ("{\n\t"
        " .reg .u64 r1,r2,r3;\n\t"
        " cvt.u64.u32 r1, %1;\n\t"
        " mov.u64 r2, r1;\n\t"
        " shl.b64 r2, r2,32;\n\t"
        " or.b64  r1, r1,r2;\n\t"
        " shr.b64 r3, r1, 6;\n\t"
        " mov.u64 r2, r3;\n\t"
        " shr.b64 r3, r1, 11;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " shr.b64 r3, r1, 25;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " cvt.u32.u64 %0,r2;\n\t"
        "}\n\t"
        : "=r"(y) : "r"(x));
    return y;
}

__device__ __forceinline__ uint32_t s0(uint32_t x) {
    uint32_t y;
    asm volatile ("{\n\t"
        " .reg .u64 r1,r2,r3;\n\t"
        " cvt.u64.u32 r1, %1;\n\t"
        " mov.u64 r2, r1;\n\t"
        " shl.b64 r2, r2,32;\n\t"
        " or.b64  r1, r1,r2;\n\t"
        " shr.b64 r2, r2, 35;\n\t"
        " shr.b64 r3, r1, 18;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " shr.b64 r3, r1, 7;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " cvt.u32.u64 %0,r2;\n\t"
        "}\n\t"
        : "=r"(y) : "r"(x));
    return y;
}

__device__ __forceinline__ uint32_t s1(uint32_t x) {
    uint32_t y;
    asm volatile ("{\n\t"
        " .reg .u64 r1,r2,r3;\n\t"
        " cvt.u64.u32 r1, %1;\n\t"
        " mov.u64 r2, r1;\n\t"
        " shl.b64 r2, r2,32;\n\t"
        " or.b64  r1, r1,r2;\n\t"
        " shr.b64 r2, r2, 42;\n\t"
        " shr.b64 r3, r1, 19;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " shr.b64 r3, r1, 17;\n\t"
        " xor.b64 r2, r2, r3;\n\t"
        " cvt.u32.u64 %0,r2;\n\t"
        "}\n\t"
        : "=r"(y) : "r"(x));
    return y;
}

#define Maj(x, y, z) (((x ^ y) & (x ^ z)) ^ x)
#define  Ch(x, y, z) (z ^ (x & (y ^ z)))

#define S2Round(a, b, c, d, e, f, g, h, k, w)\
    t1 = h + S1(e) + Ch(e,f,g) + k + (w);\
    t2 = S0(a) + Maj(a,b,c);\
    d += t1;\
    h = t1 + t2;

#define S2Round_hk(a, b, c, d, e, f, g, h, hk, w)\
    t1 = (hk) + S1(e) + Ch(e,f,g) + (w);\
    t2 = S0(a) + Maj(a,b,c);\
    d += t1;\
    h = t1 + t2;\
 
#define S2Round_w0(a, b, c, d, e, f, g, h, k)\
    t1 = h + S1(e) + Ch(e,f,g) + (k);\
    t2 = S0(a) + Maj(a,b,c);\
    d += t1;\
    h = t1 + t2;\

#define WMIX_init() {\
w[0] += s0(w[1]);\
w[1] += SHA256_PAD[0] + s0(w[2]);\
w[2] += s1(w[0]) + s0(w[3]);\
w[3] += s1(w[1]) + s0(w[4]);\
w[4] += s1(w[2]) + s0(w[5]);\
w[5] += s1(w[3]) + s0(w[6]);\
w[6] += s1(w[4]) + SHA256_PAD[1] + s0(w[7]);\
w[7] += s1(w[5]) + w[0] + s0(w[8]);\
w[8] += s1(w[6]) + w[1];\
w[9] = s1(w[7]) + w[2];\
w[10] = s1(w[8]) + w[3];\
w[11] = s1(w[9]) + w[4];\
w[12] = s1(w[10]) + w[5];\
w[13] = s1(w[11]) + w[6];\
w[14] = s1(w[12]) + w[7] + SHA256_PAD[2];\
w[15] = SHA256_PAD[1] + s1(w[13]) + w[8] + s0(w[0]);\
}

#define WMIX() {\
w[0] += s1(w[14]) + w[9] + s0(w[1]);\
w[1] += s1(w[15]) + w[10] + s0(w[2]);\
w[2] += s1(w[0]) + w[11] + s0(w[3]);\
w[3] += s1(w[1]) + w[12] + s0(w[4]);\
w[4] += s1(w[2]) + w[13] + s0(w[5]);\
w[5] += s1(w[3]) + w[14] + s0(w[6]);\
w[6] += s1(w[4]) + w[15] + s0(w[7]);\
w[7] += s1(w[5]) + w[0] + s0(w[8]);\
w[8] += s1(w[6]) + w[1] + s0(w[9]);\
w[9] += s1(w[7]) + w[2] + s0(w[10]);\
w[10] += s1(w[8]) + w[3] + s0(w[11]);\
w[11] += s1(w[9]) + w[4] + s0(w[12]);\
w[12] += s1(w[10]) + w[5] + s0(w[13]);\
w[13] += s1(w[11]) + w[6] + s0(w[14]);\
w[14] += s1(w[12]) + w[7] + s0(w[15]);\
w[15] += s1(w[13]) + w[8] + s0(w[0]);\
}

#define SHA256_RND_PAD() {\
S2Round_hk(h, a, b, c, d, e, f, g, SHA256_PAD[3], w[1]);\
S2Round_hk(g, h, a, b, c, d, e, f, SHA256_PAD[4], w[2]);\
S2Round_hk(f, g, h, a, b, c, d, e, SHA256_PAD[5], w[3]);\
S2Round(e, f, g, h, a, b, c, d, SHA256_K[4], w[4]);\
S2Round(d, e, f, g, h, a, b, c, SHA256_K[5], w[5]);\
S2Round(c, d, e, f, g, h, a, b, SHA256_K[6], w[6]);\
S2Round(b, c, d, e, f, g, h, a, SHA256_K[7], w[7]);\
S2Round(a, b, c, d, e, f, g, h, SHA256_K[8], w[8]);\
S2Round_w0(h, a, b, c, d, e, f, g, SHA256_K[9]);\
S2Round_w0(g, h, a, b, c, d, e, f, SHA256_K[10]);\
S2Round_w0(f, g, h, a, b, c, d, e, SHA256_K[11]);\
S2Round_w0(e, f, g, h, a, b, c, d, SHA256_K[12]);\
S2Round_w0(d, e, f, g, h, a, b, c, SHA256_K[13]);\
S2Round_w0(c, d, e, f, g, h, a, b, SHA256_K[14]);\
S2Round_w0(b, c, d, e, f, g, h, a, SHA256_PAD[6]);\
}

#define SHA256_RND(k) {\
S2Round(a, b, c, d, e, f, g, h, SHA256_K[k], w[0]);\
S2Round(h, a, b, c, d, e, f, g, SHA256_K[k + 1], w[1]);\
S2Round(g, h, a, b, c, d, e, f, SHA256_K[k + 2], w[2]);\
S2Round(f, g, h, a, b, c, d, e, SHA256_K[k + 3], w[3]);\
S2Round(e, f, g, h, a, b, c, d, SHA256_K[k + 4], w[4]);\
S2Round(d, e, f, g, h, a, b, c, SHA256_K[k + 5], w[5]);\
S2Round(c, d, e, f, g, h, a, b, SHA256_K[k + 6], w[6]);\
S2Round(b, c, d, e, f, g, h, a, SHA256_K[k + 7], w[7]);\
S2Round(a, b, c, d, e, f, g, h, SHA256_K[k + 8], w[8]);\
S2Round(h, a, b, c, d, e, f, g, SHA256_K[k + 9], w[9]);\
S2Round(g, h, a, b, c, d, e, f, SHA256_K[k + 10], w[10]);\
S2Round(f, g, h, a, b, c, d, e, SHA256_K[k + 11], w[11]);\
S2Round(e, f, g, h, a, b, c, d, SHA256_K[k + 12], w[12]);\
S2Round(d, e, f, g, h, a, b, c, SHA256_K[k + 13], w[13]);\
S2Round(c, d, e, f, g, h, a, b, SHA256_K[k + 14], w[14]);\
S2Round(b, c, d, e, f, g, h, a, SHA256_K[k + 15], w[15]);\
}

__device__ __forceinline__ void SHA256Transform(uint32_t* w) {
    
    uint32_t t1;
    uint32_t t2;

    uint32_t a = 0x6a09e667u;
    uint32_t b = 0xbb67ae85u;
    uint32_t c = 0x3c6ef372u;
    uint32_t d = 0xa54ff53au;
    uint32_t e = 0x510e527fu;
    uint32_t f = 0x9b05688cu;
    uint32_t g = 0x1f83d9abu;
    uint32_t h = 0x5be0cd19u;

    t1  = 0xF377ED68u + w[0];
    d  += t1;
    h   = t1 + 0x08909AE5u;

    SHA256_RND_PAD();
    WMIX_init();
    SHA256_RND(16);
    WMIX();
    SHA256_RND(32);
    WMIX();
    SHA256_RND(48);

    w[0] = __byte_perm(0x6a09e667u + a, 0u, 0x0123u);
    w[1] = __byte_perm(0xbb67ae85u + b, 0u, 0x0123u);
    w[2] = __byte_perm(0x3c6ef372u + c, 0u, 0x0123u);
    w[3] = __byte_perm(0xa54ff53au + d, 0u, 0x0123u);
    w[4] = __byte_perm(0x510e527fu + e, 0u, 0x0123u);
    w[5] = __byte_perm(0x9b05688cu + f, 0u, 0x0123u);
    w[6] = __byte_perm(0x1f83d9abu + g, 0u, 0x0123u);
    w[7] = __byte_perm(0x5be0cd19u + h, 0u, 0x0123u);
}

// ============================================================================
// For RIPEMD160
// ============================================================================

__device__ __constant__ uint32_t RIPEMD_K[8] = {
    0x5A827999u, 0x6ED9EBA1u, 0x8F1BBCDCu, 0xA953FD4Eu,
    0x50A28BE6u, 0x5C4DD124u, 0x6D703EF3u, 0x7A6D76E9u
};

__device__ __constant__ uint32_t RIPEMD_K_DELIM[8] = {
    0x5A827A19u, 0x6ED9EC21u, 0x8F1BBD5Cu, 0xA953FDCEu,
    0x50A28C66u, 0x5C4DD1A4u, 0x6D703F73u, 0x7A6D7769u
};

__device__ __constant__ uint32_t RIPEMD_K_LEN[8] = {
    0x5A827A99u, 0x6ED9ECA1u, 0x8F1BBDDCu, 0xA953FE4Eu,
    0x50A28CE6u, 0x5C4DD224u, 0x6D703FF3u, 0x7A6D77E9u
};

__device__ __constant__ uint32_t RIPEMD_DELIM[2]  = {
    0x80u, 0xCE8A4602u
};

__device__ __constant__ uint32_t RIPEMD_LEN[2] = {
    256u,  0xC81A035Du
};

#define ROL(x,n) ((x>>(32-n))|(x<<n))
#define ROL10(x) ((x>>(22))|(x<<10))

#define f1(x, y, z) (x ^ y ^ z)
#define f2(x, y, z) (z ^ (x & (y ^ z)))
#define f3(x, y, z) ((x | ~y) ^ z)
#define f4(x, y, z) (y ^ (z & (x ^ y)))
#define f5(x, y, z) (x ^ (y | ~z))

#define RPRound_full(a,b,c,d,e,f,x,k,r)\
    t = a + f + x + k;\
    a = ROL(t, r) + e;\
    c = ROL10(c);\

#define RPRound_no_k(a,b,c,d,e,f,x,r)\
    t = a + f + x;\
    a = ROL(t, r) + e;\
    c = ROL10(c);\

#define RPRound_no_x(a,b,c,d,e,f,k,r)\
    t = a + f + k;\
    a = ROL(t, r) + e;\
    c = ROL10(c);\

#define RPRound_no_x_no_k(a,b,c,d,e,f,r)\
    t = a + f;\
    a = ROL(t, r) + e;\
    c = ROL10(c);\

#define RPRound_xk(a,b,c,d,e,f,xk,r)\
    t = a + f + xk;\
    a = ROL(t, r) + e;\
    c = ROL10(c);\

#define INIT_LEFT_ROUND(a, e, c)\
    t = RIPEMD_DELIM[1] + w[0];\
    a = ROL(t, 11u) + e;\
    c = ROL10(c);\

#define INIT_RIGHT_ROUND(a, e, c)\
    t = RIPEMD_LEN[1] + w[5];\
    a = ROL(t, 8u) + e;\
    c = ROL10(c);\

#define R11_0(a,b,c,d,e,r) RPRound_no_x_no_k(a, b, c, d, e, f1(b, c, d), r)
#define R21_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f2(b, c, d), RIPEMD_K[0], r)
#define R31_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f3(b, c, d), RIPEMD_K[1], r)
#define R41_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f4(b, c, d), RIPEMD_K[2], r)
#define R51_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f5(b, c, d), RIPEMD_K[3], r)
#define R12_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f5(b, c, d), RIPEMD_K[4], r)
#define R22_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f4(b, c, d), RIPEMD_K[5], r)
#define R32_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f3(b, c, d), RIPEMD_K[6], r)
#define R42_0(a,b,c,d,e,r) RPRound_no_x(a, b, c, d, e, f2(b, c, d), RIPEMD_K[7], r)
#define R52_0(a,b,c,d,e,r) RPRound_no_x_no_k(a, b, c, d, e, f1(b, c, d), r)

#define R11_1(a,b,c,d,e,x,r) RPRound_no_k(a, b, c, d, e, f1(b, c, d), x, r)
#define R21_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f2(b, c, d), x, RIPEMD_K[0], r)
#define R31_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f3(b, c, d), x, RIPEMD_K[1], r)
#define R41_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f4(b, c, d), x, RIPEMD_K[2], r)
#define R51_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f5(b, c, d), x, RIPEMD_K[3], r)
#define R12_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f5(b, c, d), x, RIPEMD_K[4], r)
#define R22_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f4(b, c, d), x, RIPEMD_K[5], r)
#define R32_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f3(b, c, d), x, RIPEMD_K[6], r)
#define R42_1(a,b,c,d,e,x,r) RPRound_full(a, b, c, d, e, f2(b, c, d), x, RIPEMD_K[7], r)
#define R52_1(a,b,c,d,e,x,r) RPRound_no_k(a, b, c, d, e, f1(b, c, d), x, r)

#define R12_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f5(b, c, d), xk, r)
#define R21_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f2(b, c, d), xk, r)
#define R22_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f4(b, c, d), xk, r)
#define R31_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f3(b, c, d), xk, r)
#define R32_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f3(b, c, d), xk, r)
#define R41_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f4(b, c, d), xk, r)
#define R42_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f2(b, c, d), xk, r)
#define R51_2(a,b,c,d,e,xk,r) RPRound_xk(a, b, c, d, e, f5(b, c, d), xk, r)

__device__ __forceinline__ void RIPEMD160Transform(const uint32_t *w, uint32_t out[5]) {

    uint32_t t;

    uint32_t a1 = 0x67452301u;                     uint32_t a2 = 0x67452301u;
    uint32_t b1 = 0xEFCDAB89u;                     uint32_t b2 = 0xEFCDAB89u;
    uint32_t c1 = 0x98BADCFEu;                     uint32_t c2 = 0x98BADCFEu;
    uint32_t d1 = 0x10325476u;                     uint32_t d2 = 0x10325476u;
    uint32_t e1 = 0xC3D2E1F0u;                     uint32_t e2 = 0xC3D2E1F0u;

    INIT_LEFT_ROUND(a1, e1, c1);                   INIT_RIGHT_ROUND(a2, e2, c2);
    
    R11_1(e1,a1,b1,c1,d1, w[1], 14u);              R12_2(e2,a2,b2,c2,d2, RIPEMD_K_LEN[4], 9u);
    R11_1(d1,e1,a1,b1,c1, w[2], 15u);              R12_1(d2,e2,a2,b2,c2, w[7],  9u);
    R11_1(c1,d1,e1,a1,b1, w[3], 12u);              R12_1(c2,d2,e2,a2,b2, w[0], 11u);
    R11_1(b1,c1,d1,e1,a1, w[4],  5u);              R12_0(b2,c2,d2,e2,a2,       13u);
    R11_1(a1,b1,c1,d1,e1, w[5],  8u);              R12_1(a2,b2,c2,d2,e2, w[2], 15u);
    R11_1(e1,a1,b1,c1,d1, w[6],  7u);              R12_0(e2,a2,b2,c2,d2,       15u);
    R11_1(d1,e1,a1,b1,c1, w[7],  9u);              R12_1(d2,e2,a2,b2,c2, w[4],  5u);
    R11_1(c1,d1,e1,a1,b1, RIPEMD_DELIM[0], 11u);   R12_0(c2,d2,e2,a2,b2,        7u);
    R11_0(b1,c1,d1,e1,a1,       13u);              R12_1(b2,c2,d2,e2,a2, w[6],  7u);
    R11_0(a1,b1,c1,d1,e1,       14u);              R12_0(a2,b2,c2,d2,e2,        8u);
    R11_0(e1,a1,b1,c1,d1,       15u);              R12_2(e2,a2,b2,c2,d2, RIPEMD_K_DELIM[4], 11u);
    R11_0(d1,e1,a1,b1,c1,        6u);              R12_1(d2,e2,a2,b2,c2, w[1], 14u);
    R11_0(c1,d1,e1,a1,b1,        7u);              R12_0(c2,d2,e2,a2,b2,       14u);
    R11_1(b1,c1,d1,e1,a1, RIPEMD_LEN[0], 9u);      R12_1(b2,c2,d2,e2,a2, w[3], 12u);
    R11_0(a1,b1,c1,d1,e1,        8u);              R12_0(a2,b2,c2,d2,e2,        6u);

    R21_1(e1,a1,b1,c1,d1, w[7],  7u);              R22_1(e2,a2,b2,c2,d2, w[6],  9u);
    R21_1(d1,e1,a1,b1,c1, w[4],  6u);              R22_0(d2,e2,a2,b2,c2,       13u);
    R21_0(c1,d1,e1,a1,b1,        8u);              R22_1(c2,d2,e2,a2,b2, w[3], 15u);
    R21_1(b1,c1,d1,e1,a1, w[1], 13u);              R22_1(b2,c2,d2,e2,a2, w[7],  7u);
    R21_0(a1,b1,c1,d1,e1,       11u);              R22_1(a2,b2,c2,d2,e2, w[0], 12u);
    R21_1(e1,a1,b1,c1,d1, w[6],  9u);              R22_0(e2,a2,b2,c2,d2,        8u);
    R21_0(d1,e1,a1,b1,c1,        7u);              R22_1(d2,e2,a2,b2,c2, w[5],  9u);
    R21_1(c1,d1,e1,a1,b1, w[3], 15u);              R22_0(c2,d2,e2,a2,b2,       11u);
    R21_0(b1,c1,d1,e1,a1,        7u);              R22_2(b2,c2,d2,e2,a2, RIPEMD_K_LEN[5], 7u);
    R21_1(a1,b1,c1,d1,e1, w[0], 12u);              R22_0(a2,b2,c2,d2,e2,        7u);
    R21_0(e1,a1,b1,c1,d1,       15u);              R22_2(e2,a2,b2,c2,d2, RIPEMD_K_DELIM[5], 12u);
    R21_1(d1,e1,a1,b1,c1, w[5],  9u);              R22_0(d2,e2,a2,b2,c2,        7u);
    R21_1(c1,d1,e1,a1,b1, w[2], 11u);              R22_1(c2,d2,e2,a2,b2, w[4],  6u);
    R21_2(b1,c1,d1,e1,a1, RIPEMD_K_LEN[0], 7u);    R22_0(b2,c2,d2,e2,a2,       15u);
    R21_0(a1,b1,c1,d1,e1,       13u);              R22_1(a2,b2,c2,d2,e2, w[1], 13u);
    R21_2(e1,a1,b1,c1,d1, RIPEMD_K_DELIM[0], 12u); R22_1(e2,a2,b2,c2,d2, w[2], 11u);

    R31_1(d1,e1,a1,b1,c1, w[3], 11u);              R32_0(d2,e2,a2,b2,c2,        9u);
    R31_0(c1,d1,e1,a1,b1,       13u);              R32_1(c2,d2,e2,a2,b2, w[5],  7u);
    R31_2(b1,c1,d1,e1,a1, RIPEMD_K_LEN[1], 6u);    R32_1(b2,c2,d2,e2,a2, w[1], 15u);
    R31_1(a1,b1,c1,d1,e1, w[4],  7u);              R32_1(a2,b2,c2,d2,e2, w[3], 11u);
    R31_0(e1,a1,b1,c1,d1,       14u);              R32_1(e2,a2,b2,c2,d2, w[7],  8u);
    R31_0(d1,e1,a1,b1,c1,        9u);              R32_2(d2,e2,a2,b2,c2, RIPEMD_K_LEN[6], 6u);
    R31_2(c1,d1,e1,a1,b1, RIPEMD_K_DELIM[1], 13u); R32_1(c2,d2,e2,a2,b2, w[6],  6u);
    R31_1(b1,c1,d1,e1,a1, w[1], 15u);              R32_0(b2,c2,d2,e2,a2,       14u);
    R31_1(a1,b1,c1,d1,e1, w[2], 14u);              R32_0(a2,b2,c2,d2,e2,       12u);
    R31_1(e1,a1,b1,c1,d1, w[7],  8u);              R32_2(e2,a2,b2,c2,d2, RIPEMD_K_DELIM[6], 13u);
    R31_1(d1,e1,a1,b1,c1, w[0], 13u);              R32_0(d2,e2,a2,b2,c2,        5u);
    R31_1(c1,d1,e1,a1,b1, w[6],  6u);              R32_1(c2,d2,e2,a2,b2, w[2], 14u);
    R31_0(b1,c1,d1,e1,a1,        5u);              R32_0(b2,c2,d2,e2,a2,       13u);
    R31_0(a1,b1,c1,d1,e1,       12u);              R32_1(a2,b2,c2,d2,e2, w[0], 13u);
    R31_1(e1,a1,b1,c1,d1, w[5],  7u);              R32_1(e2,a2,b2,c2,d2, w[4],  7u);
    R31_0(d1,e1,a1,b1,c1,        5u);              R32_0(d2,e2,a2,b2,c2,        5u);

    R41_1(c1,d1,e1,a1,b1, w[1], 11u);              R42_2(c2,d2,e2,a2,b2, RIPEMD_K_DELIM[7], 15u);
    R41_0(b1,c1,d1,e1,a1,       12u);              R42_1(b2,c2,d2,e2,a2, w[6],  5u);
    R41_0(a1,b1,c1,d1,e1,       14u);              R42_1(a2,b2,c2,d2,e2, w[4],  8u);
    R41_0(e1,a1,b1,c1,d1,       15u);              R42_1(e2,a2,b2,c2,d2, w[1], 11u);
    R41_1(d1,e1,a1,b1,c1, w[0], 14u);              R42_1(d2,e2,a2,b2,c2, w[3], 14u);
    R41_2(c1,d1,e1,a1,b1, RIPEMD_K_DELIM[2], 15u); R42_0(c2,d2,e2,a2,b2,       14u);
    R41_0(b1,c1,d1,e1,a1,        9u);              R42_0(b2,c2,d2,e2,a2,        6u);
    R41_1(a1,b1,c1,d1,e1, w[4],  8u);              R42_1(a2,b2,c2,d2,e2, w[0], 14u);
    R41_0(e1,a1,b1,c1,d1,        9u);              R42_1(e2,a2,b2,c2,d2, w[5],  6u);
    R41_1(d1,e1,a1,b1,c1, w[3], 14u);              R42_0(d2,e2,a2,b2,c2,        9u);
    R41_1(c1,d1,e1,a1,b1, w[7],  5u);              R42_1(c2,d2,e2,a2,b2, w[2], 12u);
    R41_0(b1,c1,d1,e1,a1,        6u);              R42_0(b2,c2,d2,e2,a2,        9u);
    R41_2(a1,b1,c1,d1,e1, RIPEMD_K_LEN[2], 8u);    R42_0(a2,b2,c2,d2,e2,       12u);
    R41_1(e1,a1,b1,c1,d1, w[5],  6u);              R42_1(e2,a2,b2,c2,d2, w[7],  5u);
    R41_1(d1,e1,a1,b1,c1, w[6],  5u);              R42_0(d2,e2,a2,b2,c2,       15u);
    R41_1(c1,d1,e1,a1,b1, w[2], 12u);              R42_2(c2,d2,e2,a2,b2, RIPEMD_K_LEN[7], 8u);

    R51_1(b1,c1,d1,e1,a1, w[4],  9u);              R52_0(b2,c2,d2,e2,a2,        8u);
    R51_1(a1,b1,c1,d1,e1, w[0], 15u);              R52_0(a2,b2,c2,d2,e2,        5u);
    R51_1(e1,a1,b1,c1,d1, w[5],  5u);              R52_0(e2,a2,b2,c2,d2,       12u);
    R51_0(d1,e1,a1,b1,c1,       11u);              R52_1(d2,e2,a2,b2,c2, w[4],  9u);
    R51_1(c1,d1,e1,a1,b1, w[7],  6u);              R52_1(c2,d2,e2,a2,b2, w[1], 12u);
    R51_0(b1,c1,d1,e1,a1,        8u);              R52_1(b2,c2,d2,e2,a2, w[5],  5u);
    R51_1(a1,b1,c1,d1,e1, w[2], 13u);              R52_1(a2,b2,c2,d2,e2, RIPEMD_DELIM[0], 14u);
    R51_0(e1,a1,b1,c1,d1,       12u);              R52_1(e2,a2,b2,c2,d2, w[7],  6u);
    R51_2(d1,e1,a1,b1,c1, RIPEMD_K_LEN[3], 5u);    R52_1(d2,e2,a2,b2,c2, w[6],  8u);
    R51_1(c1,d1,e1,a1,b1, w[1], 12u);              R52_1(c2,d2,e2,a2,b2, w[2], 13u);
    R51_1(b1,c1,d1,e1,a1, w[3], 13u);              R52_0(b2,c2,d2,e2,a2,        6u);
    R51_2(a1,b1,c1,d1,e1, RIPEMD_K_DELIM[3], 14u); R52_1(a2,b2,c2,d2,e2, RIPEMD_LEN[0], 5u);
    R51_0(e1,a1,b1,c1,d1,       11u);              R52_1(e2,a2,b2,c2,d2, w[0], 15u);
    R51_1(d1,e1,a1,b1,c1, w[6],  8u);              R52_1(d2,e2,a2,b2,c2, w[3], 13u);
    R51_0(c1,d1,e1,a1,b1,        5u);              R52_0(c2,d2,e2,a2,b2,       11u);
    R51_0(b1,c1,d1,e1,a1,        6u);              R52_0(b2,c2,d2,e2,a2,       11u);

    out[0] = c1 + d2;
    out[1] = d1 + e2;
    out[2] = e1 + a2;
    out[3] = a1 + b2;
    out[4] = b1 + c2;
}

// ============================================================================
// For GetHash160_Compressed
// ============================================================================

__device__ __forceinline__ void GetHash160_Compressed(uint8_t y_prefix, const uint64_t x_limbs[4], uint32_t out[5]) {

    const uint32_t* x32 = (const uint32_t*) x_limbs;

    uint32_t w[16];

    w[0] = __byte_perm(y_prefix, x32[7], 0x0765u);
    w[1] = __byte_perm(x32[7], x32[6], 0x0765u);
    w[2] = __byte_perm(x32[6], x32[5], 0x0765u);
    w[3] = __byte_perm(x32[5], x32[4], 0x0765u);
    w[4] = __byte_perm(x32[4], x32[3], 0x0765u);
    w[5] = __byte_perm(x32[3], x32[2], 0x0765u);
    w[6] = __byte_perm(x32[2], x32[1], 0x0765u);
    w[7] = __byte_perm(x32[1], x32[0], 0x0765u);
    w[8] = __byte_perm(x32[0], 0x80u, 0x0456u);

    SHA256Transform(w);

    RIPEMD160Transform(w, out);
}
