
// CUDACyclone-SecretAdmirere
// Copyright (C) 2026 SecretAdmirere
//
// Portions of this file are derived from CUDACyclone
// (https://github.com/Dookoo2/CUDACyclone)
// (c) 2025, Dookoo2.
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
// For Thread State Structure
// ============================================================================

struct SampleTriplet {
    uint64_t first[4];
    uint64_t middle[4];
    uint64_t last[4];
};

// ============================================================================
// For Graceful Exit Handler
// ============================================================================

static volatile bool g_abort_requested = false;
static volatile bool g_cleanup_done = false;

static BOOL WINAPI ConsoleCtrlHandler(DWORD dwCtrlType) {
    (void)dwCtrlType;
    g_abort_requested = true;
    while (!g_cleanup_done) Sleep(100);
    return TRUE;
}

// ============================================================================
// For Clear Screen
// ============================================================================

static inline void clear_screen_full() {
    system("cls");
    std::cout.flush();
}

// ============================================================================
// For Hex Formatting
// ============================================================================

static inline void u256_to_hex_buf(char* dst, const uint64_t v[4]) {
    static constexpr char H[] = "0123456789ABCDEF";
    for (int limb = 3; limb >= 0; --limb) {
        uint64_t w = v[limb];
        for (int b = 60; b >= 0; b -= 4)
            *dst++ = H[(w >> b) & 0xF];
    }
}

static inline std::string formatHex256(const uint64_t limbs[4]) {
    char buf[64];
    u256_to_hex_buf(buf, limbs);
    return std::string(buf, 64);
}

static inline std::string format_u256_clean(const uint64_t v[4]) {
    static constexpr char H[] = "0123456789ABCDEF";
    int highest = 3;
    while (highest > 0 && v[highest] == 0) --highest;
    if (v[highest] == 0) return "0";
    char buf[64];
    char* p = buf;
    uint64_t w = v[highest];
    int shift = 60;
    while (shift > 0 && ((w >> shift) & 0xF) == 0) shift -= 4;
    for (; shift >= 0; shift -= 4) *p++ = H[(w >> shift) & 0xF];
    for (int limb = highest - 1; limb >= 0; --limb) {
        w = v[limb];
        for (int b = 60; b >= 0; b -= 4) *p++ = H[(w >> b) & 0xF];
    }
    return std::string(buf, p);
}

static inline std::string formatCompressedPubHex(const uint64_t Rx[4], const uint64_t Ry[4]) {
    static constexpr char H[] = "0123456789ABCDEF";
    char buf[66];
    buf[0] = '0';
    buf[1] = (Ry[0] & 1ULL) ? '3' : '2';
    char* p = buf + 2;
    for (int limb = 3; limb >= 0; --limb) {
        uint64_t w = Rx[limb];
        for (int b = 60; b >= 0; b -= 4) *p++ = H[(w >> b) & 0xF];
    }
    return std::string(buf, 66);
}

static inline std::string hex_from_bytes(const uint8_t* d, size_t n) {
    static constexpr char H[] = "0123456789ABCDEF";
    char* buf = (char*)_alloca(n * 2);
    for (size_t i = 0; i < n; ++i) {
        buf[2*i] = H[d[i] >> 4];
        buf[2*i+1] = H[d[i] & 0xF];
    }
    return std::string(buf, n * 2);
}

static inline std::string uppercase_hex(std::string s) {
    for (char& c : s)
        if (c >= 'a' && c <= 'z') c -= 32;
    return s;
}

static inline void print_u256_hex(const char* lbl, const uint64_t v[4]) {
    char buf[64];
    u256_to_hex_buf(buf, v);
    std::cerr << lbl << ": 0x";
    std::cerr.write(buf, 64);
    std::cerr << '\n';
}

static inline std::string human_bytes(double bytes) {
    static const char* u[] = {"B","KB","MB","GB","TB","PB"};
    int k = 0;
    while (bytes >= 1024.0 && k < 5) { bytes /= 1024.0; ++k; }
    char buf[32];
    int len = std::snprintf(buf, sizeof(buf),
                            bytes < 10.0 ? "%.2f %s" : "%.1f %s",
                            bytes, u[k]);
    return std::string(buf, len);
}

static inline long double ld_from_u256(const uint64_t v[4]) {
    return std::ldexp((long double)v[3], 192)
         + std::ldexp((long double)v[2], 128)
         + std::ldexp((long double)v[1], 64)
         + (long double)v[0];
}

static inline bool hexToLE64(const std::string& h_in, uint64_t w[4]) {
    const char* h = h_in.c_str();
    size_t len = h_in.size();
    if (len >= 2 && h[0] == '0' && (h[1] == 'x' || h[1] == 'X')) { h += 2; len -= 2; }
    if (len == 0 || len > 64) return false;
    for (size_t i = 0; i < len; ++i) {
        char c = h[i];
        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')))
            return false;
    }
    w[0] = w[1] = w[2] = w[3] = 0ull;
    int pos = (int)len;
    for (int limb = 0; limb < 4 && pos > 0; ++limb) {
        const int take = (pos < 16) ? pos : 16;
        const char* start = h + pos - take;
        uint64_t val = 0;
        for (int i = 0; i < take; ++i) {
            char c = start[i];
            uint64_t nibble = (c >= '0' && c <= '9') ? (uint64_t)(c - '0')
                            : (c >= 'a' && c <= 'f') ? (uint64_t)(c - 'a' + 10)
                                                     : (uint64_t)(c - 'A' + 10);
            val = (val << 4) | nibble;
        }
        w[limb] = val;
        pos -= take;
    }
    return true;
}

// ============================================================================
// For Base58 Address Decode and (Hash160 - IV)
// ============================================================================

namespace host_sha256 {
    static constexpr uint32_t K[64] = {
        0x428A2F98u,0x71374491u,0xB5C0FBCFu,0xE9B5DBA5u,0x3956C25Bu,0x59F111F1u,0x923F82A4u,0xAB1C5ED5u,
        0xD807AA98u,0x12835B01u,0x243185BEu,0x550C7DC3u,0x72BE5D74u,0x80DEB1FEu,0x9BDC06A7u,0xC19BF174u,
        0xE49B69C1u,0xEFBE4786u,0x0FC19DC6u,0x240CA1CCu,0x2DE92C6Fu,0x4A7484AAu,0x5CB0A9DCu,0x76F988DAu,
        0x983E5152u,0xA831C66Du,0xB00327C8u,0xBF597FC7u,0xC6E00BF3u,0xD5A79147u,0x06CA6351u,0x14292967u,
        0x27B70A85u,0x2E1B2138u,0x4D2C6DFCu,0x53380D13u,0x650A7354u,0x766A0ABBu,0x81C2C92Eu,0x92722C85u,
        0xA2BFE8A1u,0xA81A664Bu,0xC24B8B70u,0xC76C51A3u,0xD192E819u,0xD6990624u,0xF40E3585u,0x106AA070u,
        0x19A4C116u,0x1E376C08u,0x2748774Cu,0x34B0BCB5u,0x391C0CB3u,0x4ED8AA4Au,0x5B9CCA4Fu,0x682E6FF3u,
        0x748F82EEu,0x78A5636Fu,0x84C87814u,0x8CC70208u,0x90BEFFFAu,0xA4506CEBu,0xBEF9A3F7u,0xC67178F2u
    };
    
    static inline uint32_t rotr(uint32_t x, uint32_t n){ return (x>>n) | (x<<(32u-n)); }
    static inline uint32_t Ch  (uint32_t x,uint32_t y,uint32_t z){ return (x & y) ^ (~x & z); }
    static inline uint32_t Maj (uint32_t x,uint32_t y,uint32_t z){ return (x & y) ^ (x & z) ^ (y & z); }
    static inline uint32_t BSIG0(uint32_t x){ return rotr(x,2) ^ rotr(x,13) ^ rotr(x,22); }
    static inline uint32_t BSIG1(uint32_t x){ return rotr(x,6) ^ rotr(x,11) ^ rotr(x,25); }
    static inline uint32_t SSIG0(uint32_t x){ return rotr(x,7) ^ rotr(x,18) ^ (x>>3); }
    static inline uint32_t SSIG1(uint32_t x){ return rotr(x,17)^ rotr(x,19) ^ (x>>10); }

    static void sha256(const uint8_t* data, size_t len, uint8_t out[32]) {
        uint32_t H[8] = {
            0x6a09e667u,0xbb67ae85u,0x3c6ef372u,0xa54ff53au,
            0x510e527fu,0x9b05688cu,0x1f83d9abu,0x5be0cd19u
        };

        uint8_t block[64] = {0};
        size_t n = len;

        auto process = [&](const uint8_t b[64]){
            uint32_t W[64];
            for (int i=0;i<16;++i){
                W[i] = ( (uint32_t)b[4*i+0]<<24 )|
                       ( (uint32_t)b[4*i+1]<<16 )|
                       ( (uint32_t)b[4*i+2]<<8  )|
                       ( (uint32_t)b[4*i+3]<<0  );
            }
            for (int t=16;t<64;++t)
                W[t] = SSIG1(W[t-2]) + W[t-7] + SSIG0(W[t-15]) + W[t-16];

            uint32_t a=H[0],b_=H[1],c=H[2],d=H[3],e=H[4],f=H[5],g=H[6],h=H[7];
            for (int t=0;t<64;++t){
                uint32_t T1 = h + BSIG1(e) + Ch(e,f,g) + K[t] + W[t];
                uint32_t T2 = BSIG0(a) + Maj(a,b_,c);
                h=g; g=f; f=e; e=d+T1; d=c; c=b_; b_=a; a=T1+T2;
            }
            H[0]+=a; H[1]+=b_; H[2]+=c; H[3]+=d; H[4]+=e; H[5]+=f; H[6]+=g; H[7]+=h;
        };

        std::memset(block, 0, 64);
        if (n) std::memcpy(block, data, n);
        block[n] = 0x80;
        uint64_t bitlen = (uint64_t)len * 8ull;
        block[63] = (uint8_t)(bitlen      );
        block[62] = (uint8_t)(bitlen >> 8 );
        block[61] = (uint8_t)(bitlen >> 16);
        block[60] = (uint8_t)(bitlen >> 24);
        block[59] = (uint8_t)(bitlen >> 32);
        block[58] = (uint8_t)(bitlen >> 40);
        block[57] = (uint8_t)(bitlen >> 48);
        block[56] = (uint8_t)(bitlen >> 56);
        process(block);

        for (int i=0;i<8;++i){
            out[4*i+0] = (uint8_t)(H[i] >> 24);
            out[4*i+1] = (uint8_t)(H[i] >> 16);
            out[4*i+2] = (uint8_t)(H[i] >> 8 );
            out[4*i+3] = (uint8_t)(H[i] >> 0 );
        }
    }
    static void sha256d(const uint8_t* data, size_t len, uint8_t out[32]){
        uint8_t tmp[32];
        sha256(data, len, tmp);
        sha256(tmp, 32, out);
    }
}

static inline bool base58_decode(const std::string& in, std::vector<uint8_t>& out) {
    static const char* ALPH = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
    static int8_t map[128];
    static bool inited=false;
    if (!inited){
        std::fill(std::begin(map), std::end(map), (int8_t)-1);
        for (int i=0;i<58;++i) map[(unsigned char)ALPH[i]] = (int8_t)i;
        inited=true;
    }
    if (in.empty()) return false;
    size_t zeros = 0;
    while (zeros < in.size() && in[zeros] == '1') ++zeros;

    std::vector<uint8_t> b256; b256.reserve(in.size()*733/1000 + 1);
    for (char ch : in) {
        unsigned char uc = (unsigned char)ch;
        if (uc >= 128 || map[uc] == -1) return false;
        int carry = map[uc];
        for (size_t j=0;j<b256.size();++j) {
            int x = (int)b256[j] * 58 + carry;
            b256[j] = (uint8_t)(x & 0xFF);
            carry = x >> 8;
        }
        while (carry) {
            b256.push_back((uint8_t)(carry & 0xFF));
            carry >>= 8;
        }
    }
    out.clear();
    out.resize(zeros, 0u);
    for (auto it=b256.rbegin(); it!=b256.rend(); ++it) out.push_back(*it);
    return true;
}

static inline bool decode_p2pkh_address(const std::string& addr, uint8_t out_hash160[20]) {
    if (addr.empty() || addr[0] != '1') return false;

    std::vector<uint8_t> raw;
    if (!base58_decode(addr, raw)) return false;
    if (raw.size() != 25) return false;
    if (raw[0] != 0x00) return false;

    uint8_t check[32];
    host_sha256::sha256d(raw.data(), 21, check);
    if ( !std::equal(check, check+4, raw.data()+21) ) return false;

    std::memcpy(out_hash160, raw.data()+1, 20);
    return true;
}

static const uint32_t RIPEMD160_IV[5] = {
    0xEFCDAB89u, 0x98BADCFEu, 0x10325476u, 0xC3D2E1F0u, 0x67452301u
};

static inline void subtract_ripemd_iv(uint8_t hash160[20]) {
    for (int i = 0; i < 5; ++i) {
        uint8_t* p = hash160 + 4 * i;
        uint32_t w =  (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
        w -= RIPEMD160_IV[i];
        p[0] = (uint8_t)(w);
        p[1] = (uint8_t)(w >> 8);
        p[2] = (uint8_t)(w >> 16);
        p[3] = (uint8_t)(w >> 24);
    }
}

// ============================================================================
// For Parse Compressed Public Key
// ============================================================================

static bool parse_compressed_pubkey(const std::string& hex, uint64_t Qx[4], uint64_t Qy[4]) {

    uint8_t pub[33];
    for (int i = 0; i < 33; ++i)
        pub[i] = (uint8_t)std::strtoul(hex.substr(i * 2, 2).c_str(), nullptr, 16);

    uint8_t prefix = pub[0];

    static const uint64_t P[4] = {
        0xFFFFFFFEFFFFFC2FULL, 0xFFFFFFFFFFFFFFFFULL,
        0xFFFFFFFFFFFFFFFFULL, 0xFFFFFFFFFFFFFFFFULL
    };

    static const uint64_t SQRT_EXP[4] = {
        0xFFFFFFFFBFFFFF0CULL, 0xFFFFFFFFFFFFFFFFULL,
        0xFFFFFFFFFFFFFFFFULL, 0x3FFFFFFFFFFFFFFFULL
    };

    uint64_t x[4] = {};
    for (int i = 0; i < 4; ++i)
        for (int j = 0; j < 8; ++j)
            x[i] |= ((uint64_t)pub[32 - i * 8 - j]) << (j * 8);

    auto cmp4 = [](const uint64_t a[4], const uint64_t b[4]) -> int {
        for (int i = 3; i >= 0; --i) {
            if (a[i] < b[i]) return -1;
            if (a[i] > b[i]) return  1;
        }
        return 0;
    };

    auto copy4 = [](uint64_t d[4], const uint64_t s[4]) {
        d[0]=s[0]; d[1]=s[1]; d[2]=s[2]; d[3]=s[3];
    };

    auto modadd = [&](uint64_t dst[4], const uint64_t a[4], const uint64_t b[4]) {
        uint64_t tmp[4]; unsigned char c = 0;
        c = _addcarry_u64(0, a[0], b[0], &tmp[0]);
        c = _addcarry_u64(c, a[1], b[1], &tmp[1]);
        c = _addcarry_u64(c, a[2], b[2], &tmp[2]);
        c = _addcarry_u64(c, a[3], b[3], &tmp[3]);
        if (c || cmp4(tmp, P) >= 0) {
            unsigned char b2 = 0;
            b2 = _subborrow_u64(0, tmp[0], P[0], &dst[0]);
            b2 = _subborrow_u64(b2, tmp[1], P[1], &dst[1]);
            b2 = _subborrow_u64(b2, tmp[2], P[2], &dst[2]);
                 _subborrow_u64(b2, tmp[3], P[3], &dst[3]);
        } else {
            dst[0]=tmp[0]; dst[1]=tmp[1]; dst[2]=tmp[2]; dst[3]=tmp[3];
        }
    };

    auto modmul = [&](uint64_t dst[4], const uint64_t a[4], const uint64_t b[4]) {
        uint64_t r[8] = {};

        for (int i = 0; i < 4; ++i) {
            for (int j = 0; j < 4; ++j) {
                uint64_t hi, lo = _umul128(a[i], b[j], &hi);
                unsigned char c = 0;
                c = _addcarry_u64(0, r[i+j], lo, &r[i+j]);
                c = _addcarry_u64(c, r[i+j+1], hi, &r[i+j+1]);

                for (int k = i+j+2; c && k < 8; ++k)
                    c = _addcarry_u64(c, r[k], 0, &r[k]);
            }
        }

        for (int pass = 0; pass < 2; ++pass) {
            uint64_t lo, hi;
            uint64_t acc[5] = {};

            for (int i = 0; i < 4; ++i) {
                lo = _umul128(r[4+i], 977ULL, &hi);
                unsigned char c = 0;
                c = _addcarry_u64(0, acc[i], lo, &acc[i]);
                c = _addcarry_u64(c, acc[i+1], hi, &acc[i+1]);

                uint64_t lo32 = r[4+i] << 32;
                uint64_t hi32 = r[4+i] >> 32;
                c = 0;
                c = _addcarry_u64(0, acc[i], lo32, &acc[i]);
                c = _addcarry_u64(c, acc[i+1], hi32, &acc[i+1]);
                if (c && i+2 <= 4) acc[i+2]++;

                r[4+i] = 0;
            }

            unsigned char c = 0;
            c = _addcarry_u64(0, r[0], acc[0], &r[0]);
            c = _addcarry_u64(c, r[1], acc[1], &r[1]);
            c = _addcarry_u64(c, r[2], acc[2], &r[2]);
            c = _addcarry_u64(c, r[3], acc[3], &r[3]);
            _addcarry_u64(c, r[4], acc[4], &r[4]);
        }

        unsigned char b2 = 0;
        uint64_t tmp[4];
        b2 = _subborrow_u64(0, r[0], P[0], &tmp[0]);
        b2 = _subborrow_u64(b2, r[1], P[1], &tmp[1]);
        b2 = _subborrow_u64(b2, r[2], P[2], &tmp[2]);
        b2 = _subborrow_u64(b2, r[3], P[3], &tmp[3]);
        if (!b2 && r[4] == 0) {
            dst[0]=tmp[0]; dst[1]=tmp[1]; dst[2]=tmp[2]; dst[3]=tmp[3];
        } else {
            dst[0]=r[0]; dst[1]=r[1]; dst[2]=r[2]; dst[3]=r[3];
        }
    };

    auto modsqr = [&](uint64_t dst[4], const uint64_t a[4]) {
        modmul(dst, a, a);
    };

    auto modpow = [&](uint64_t dst[4], const uint64_t base[4], const uint64_t exp[4]) {
        uint64_t result[4] = {1,0,0,0};
        uint64_t b[4]; copy4(b, base);
        for (int w = 3; w >= 0; --w) {
            for (int bit = 63; bit >= 0; --bit) {
                uint64_t sq[4]; modsqr(sq, result); copy4(result, sq);
                if ((exp[w] >> bit) & 1ULL) {
                    uint64_t mul[4]; modmul(mul, result, b); copy4(result, mul);
                }
            }
        }
        copy4(dst, result);
    };

    uint64_t x2[4], x3[4], rhs[4], seven[4] = {7,0,0,0};
    modsqr(x2, x);
    modmul(x3, x2, x);
    modadd(rhs, x3, seven);

    uint64_t y[4];
    modpow(y, rhs, SQRT_EXP);

    bool y_odd = (y[0] & 1ULL) != 0;
    bool want_odd = (prefix == 0x03);
    if (y_odd != want_odd) {
        uint64_t neg[4]; unsigned char br = 0;
        br = _subborrow_u64(0,  P[0], y[0], &neg[0]);
        br = _subborrow_u64(br, P[1], y[1], &neg[1]);
        br = _subborrow_u64(br, P[2], y[2], &neg[2]);
             _subborrow_u64(br, P[3], y[3], &neg[3]);
        copy4(y, neg);
    }
    copy4(Qx, x);
    copy4(Qy, y);
    return true;
}

// ============================================================================
// For Utility Functions
// ============================================================================

static inline void divmod_256_by_u64(const uint64_t value[4], uint64_t divisor,
                                     uint64_t quotient[4], uint64_t &remainder) {
    remainder = 0ull;
    for (int i = 3; i >= 0; --i) {
        unsigned __int64 rem = (unsigned __int64)remainder;
        unsigned __int64 q = _udiv128(rem, (unsigned __int64)value[i],
                                     (unsigned __int64)divisor, (unsigned __int64*)&rem);
        quotient[i] = (uint64_t)q;
        remainder = (uint64_t)rem;
    }
}

static inline int cmp256(const uint64_t a[4], const uint64_t b[4]) {
    for (int i = 3; i >= 0; --i) {
        if (a[i] != b[i]) return (a[i] > b[i]) ? 1 : -1;
    }
    return 0;
}

static inline void add256_u64(const uint64_t a[4], uint64_t b, uint64_t out[4]) {
    unsigned char c = 0;
    c = _addcarry_u64(0, a[0], b, &out[0]);
    c = _addcarry_u64(c, a[1], 0ull, &out[1]);
    c = _addcarry_u64(c, a[2], 0ull, &out[2]);
    _addcarry_u64(c, a[3], 0ull, &out[3]);
}

static inline void add256(const uint64_t a[4], const uint64_t b[4], uint64_t out[4]) {
    unsigned char c = 0;
    c = _addcarry_u64(0, a[0], b[0], &out[0]);
    c = _addcarry_u64(c, a[1], b[1], &out[1]);
    c = _addcarry_u64(c, a[2], b[2], &out[2]);
    _addcarry_u64(c, a[3], b[3], &out[3]);
}

static inline void sub256(const uint64_t a[4], const uint64_t b[4], uint64_t out[4]) {
    unsigned char br = 0;
    br = _subborrow_u64(0, a[0], b[0], &out[0]);
    br = _subborrow_u64(br, a[1], b[1], &out[1]);
    br = _subborrow_u64(br, a[2], b[2], &out[2]);
    _subborrow_u64(br, a[3], b[3], &out[3]);
}

static inline void Mul_256_by_64_host(const uint64_t a[4], uint64_t b, uint64_t result[4]) {
    uint64_t carry = 0;
    for (int i = 0; i < 4; i++) {
        uint64_t lo, hi;
        lo = _umul128(a[i], b, &hi);
        unsigned char c = _addcarry_u64(0, lo, carry, &result[i]);
        carry = hi + c;
    }
}

static inline uint64_t mix64(uint64_t x) {
    x += 0x9E3779B97F4A7C15ull;
    x = (x ^ (x >> 30)) * 0xBF58476D1CE4E5B9ull;
    x = (x ^ (x >> 27)) * 0x94D049BB133111EBull;
    return x ^ (x >> 31);
}

// ============================================================================
// For Generate High-Entropy Seed From Multiple Sources
// ============================================================================

static inline uint64_t generate_high_entropy_seed(const cudaDeviceProp& prop) {
    uint64_t seed = 0;

    HCRYPTPROV hProv = 0;
    if (CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT | CRYPT_SILENT)) {
        CryptGenRandom(hProv, sizeof(seed), (BYTE*)&seed);
        CryptReleaseContext(hProv, 0);
    }
    seed = mix64(seed);

    seed ^= (uint64_t)std::chrono::high_resolution_clock::now().time_since_epoch().count();
    seed = mix64(seed);

    seed ^= ((uint64_t)prop.pciDomainID << 48) | ((uint64_t)prop.pciBusID << 32) | ((uint64_t)prop.pciDeviceID << 16);
    seed = mix64(seed);

    seed ^= (uint64_t)std::hash<std::thread::id>{}(std::this_thread::get_id());
    seed = mix64(seed);

    seed ^= __rdtsc();
    seed = mix64(seed);

    seed ^= (uint64_t)std::chrono::high_resolution_clock::now().time_since_epoch().count();
    seed = mix64(seed);

    return seed;
}

// ============================================================================
// For Build + Upload Section Boundaries In Chunks
// ============================================================================

static inline void build_and_upload_section_boundaries(
    const uint64_t range_start[4],
    const uint64_t range_end[4],
    const uint64_t section_size[4],
    uint32_t range_divisions,
    uint64_t threadsTotal,
    uint64_t*& d_sec_start,
    uint64_t*& d_sec_end,
    uint64_t*& d_sec_len,
    uint64_t*& d_section_start_off,
    std::vector<uint32_t>& display_secs,
    std::vector<uint64_t>& disp_start,
    std::vector<uint64_t>& disp_end,
    uint64_t first_sec_len[4],
    uint32_t chunk_size = 65536)
{
    const uint32_t D = range_divisions;
    const uint64_t base_ts = threadsTotal / D;
    const uint64_t rem_ts = threadsTotal % D;
    static const uint64_t ONE[4] = {1, 0, 0, 0};

    display_secs.clear();
    for (uint32_t sec = 0; sec < D; ++sec) {
        if (sec < 8 || sec >= D - 8) display_secs.push_back(sec);
    }
    disp_start.assign(display_secs.size() * 4, 0ull);
    disp_end.assign(display_secs.size() * 4, 0ull);
    for (int i = 0; i < 4; ++i) first_sec_len[i] = 0ull;

    cudaMalloc(&d_sec_start, (size_t)D * 4 * sizeof(uint64_t));
    cudaMalloc(&d_sec_end, (size_t)D * 4 * sizeof(uint64_t));
    cudaMalloc(&d_sec_len, (size_t)D * 4 * sizeof(uint64_t));
    cudaMalloc(&d_section_start_off, (size_t)D * sizeof(uint64_t));

    if (chunk_size == 0) chunk_size = 65536;
    const uint32_t CHUNK = (chunk_size < D) ? chunk_size : D;

    std::vector<uint64_t> c_start((size_t)CHUNK * 4);
    std::vector<uint64_t> c_end((size_t)CHUNK * 4);
    std::vector<uint64_t> c_len((size_t)CHUNK * 4);
    std::vector<uint64_t> c_off(CHUNK);

    for (uint32_t base = 0; base < D; base += CHUNK) {
        const uint32_t n = (D - base < CHUNK) ? (D - base) : CHUNK;

        for (uint32_t j = 0; j < n; ++j) {
            const uint32_t sec = base + j;

            uint64_t offset[4];
            Mul_256_by_64_host(section_size, (uint64_t)sec, offset);

            uint64_t sec_start[4];
            add256(range_start, offset, sec_start);

            uint64_t sec_end[4];
            add256(sec_start, section_size, sec_end);
            sub256(sec_end, ONE, sec_end);

            if (cmp256(sec_end, range_end) > 0) {
                sec_end[0] = range_end[0];
                sec_end[1] = range_end[1];
                sec_end[2] = range_end[2];
                sec_end[3] = range_end[3];
            }

            uint64_t len[4];
            sub256(sec_end, sec_start, len);
            add256_u64(len, 1ull, len);

            for (int i = 0; i < 4; ++i) {
                c_start[(size_t)j * 4 + i] = sec_start[i];
                c_end  [(size_t)j * 4 + i] = sec_end[i];
                c_len  [(size_t)j * 4 + i] = len[i];
            }

            c_off[j] = (uint64_t)sec * base_ts + ((sec < rem_ts) ? (uint64_t)sec : rem_ts);

            if (sec == 0) {
                for (int i = 0; i < 4; ++i) first_sec_len[i] = len[i];
            }

            if (sec < 8 || sec >= D - 8) {
                for (size_t k = 0; k < display_secs.size(); ++k) {
                    if (display_secs[k] == sec) {
                        for (int i = 0; i < 4; ++i) {
                            disp_start[k * 4 + i] = sec_start[i];
                            disp_end  [k * 4 + i] = sec_end[i];
                        }
                        break;
                    }
                }
            }
        }

        cudaMemcpy(d_sec_start + (size_t)base * 4, c_start.data(),
                   (size_t)n * 4 * sizeof(uint64_t), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sec_end + (size_t)base * 4, c_end.data(),
                   (size_t)n * 4 * sizeof(uint64_t), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sec_len + (size_t)base * 4, c_len.data(),
                   (size_t)n * 4 * sizeof(uint64_t), cudaMemcpyHostToDevice);
        cudaMemcpy(d_section_start_off + base, c_off.data(),
                   (size_t)n * sizeof(uint64_t), cudaMemcpyHostToDevice);
    }
}

// ============================================================================
// For Steps Table Generation
// ============================================================================

static inline int msb_index_256(const uint64_t v[4]) {
    for (int limb = 3; limb >= 0; --limb) {
        if (v[limb] != 0ull) {
            uint64_t w = v[limb];
            int b = 63;
            while (((w >> b) & 1ull) == 0ull) --b;
            return limb * 64 + b;
        }
    }
    return -1;
}

static inline int derive_max_step_hex(const uint64_t sec_len[4]) {
    int msb = msb_index_256(sec_len);
    if (msb < 0) return 1;
    int max_hex = msb / 4;
    if (max_hex < 1) max_hex = 1;
    if (max_hex > 63) max_hex = 63;
    return max_hex;
}

static inline void generate_steps_table(
    const uint64_t sec_len[4],
    uint64_t table_seed,
    std::vector<uint64_t>& out,
    uint64_t& out_entries,
    int& out_max_hex)
{
    // ========================================================================
    // TABLE SIZE - EDIT THIS NUMBER TO GENERATE MORE OR FEWER STEPS
    // ========================================================================
    const uint64_t N = 65536;
    // ========================================================================

    const int min_hex = 1;
    const int max_hex = derive_max_step_hex(sec_len);
    const int buckets = max_hex - min_hex + 1;

    out.assign((size_t)N * 4, 0ull);

    for (uint64_t i = 0; i < N; ++i) {

        const int L = min_hex + (int)(i % (uint64_t)buckets);
        const int target_bits = L * 4;

        uint64_t s = mix64(table_seed ^ (i * 0x9E3779B97F4A7C15ull));

        uint64_t step[4];
        step[0] = mix64(s);
        step[1] = mix64(s ^ 0x1111111111111111ull);
        step[2] = mix64(s ^ 0x2222222222222222ull);
        step[3] = mix64(s ^ 0x3333333333333333ull);

        const int keep_words = target_bits >> 6;
        const int keep_bits  = target_bits & 63;
        for (int w = 0; w < 4; ++w) {
            if (w > keep_words || (w == keep_words && keep_bits == 0)) {
                step[w] = 0ull;
            } else if (w == keep_words) {
                step[w] &= ((1ull << keep_bits) - 1ull);
            }
        }

        const int top_shift = target_bits - 4;
        const int tw = top_shift >> 6;
        const int tb = top_shift & 63;
        if (((step[tw] >> tb) & 0xFull) == 0ull) {
            const uint64_t fill = 1ull + (mix64(s ^ 0xA5A5A5A5A5A5A5A5ull) % 15ull);
            step[tw] |= (fill << tb);
        }

        out[(size_t)i * 4 + 0] = step[0];
        out[(size_t)i * 4 + 1] = step[1];
        out[(size_t)i * 4 + 2] = step[2];
        out[(size_t)i * 4 + 3] = step[3];
    }

    out_entries = N;
    out_max_hex = max_hex;
}

static inline bool dump_steps_table(
    const char* filename,
    const std::vector<uint64_t>& table,
    uint64_t entries,
    int max_hex,
    uint64_t table_seed)
{
    std::ofstream f(filename);
    if (!f) return false;

    f << "# ============================================================\n";
    f << "# Steps Table\n";
    f << "# Entries    : " << entries << "\n";
    f << "# Lengths    : 1 .. " << max_hex << " hex chars\n";
    f << "# Table Seed : " << std::hex << std::uppercase << table_seed
      << std::nouppercase << std::dec << "\n";
    f << "# ============================================================\n";

    std::vector<uint64_t> counts((size_t)max_hex + 2, 0ull);
    for (uint64_t i = 0; i < entries; ++i) {
        size_t len = format_u256_clean(&table[(size_t)i * 4]).length();
        if (len < counts.size()) counts[len]++;
    }
    for (int L = 1; L <= max_hex; ++L) {
        f << "# len " << std::setw(2) << L << " : " << counts[L] << " entries\n";
    }
    f << "# ============================================================\n";

    for (uint64_t i = 0; i < entries; ++i) {
        std::string h = format_u256_clean(&table[(size_t)i * 4]);
        f << "[" << std::setw(6) << std::setfill('0') << i << std::setfill(' ') << "] "
          << "len=" << std::setw(2) << std::setfill('0') << h.length() << std::setfill(' ')
          << "  " << h << "\n";
    }

    f.close();
    return true;
}