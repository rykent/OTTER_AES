//////////////////////////////////////////////////////////////////////
//
// aes.c
// Implements encrypting and decypting functions for AES 128, 192, 256
// according to the specifications in NIST FIPS 197
// implements AES using software only in RV32I instructions
//
// Author : Ryken Thompson
//////////////////////////////////////////////////////////////////////

#include "aes.h"

//Only one of these should be defined at a time
#define MODE_RV32I
// #define MODE_RV32I_ZNKE_ZKND
// #define MODE_RV32I_AES_CP


//AES round constants
static const uint32_t round_const[10] = {
    0x01000000, 0x02000000, 0x04000000, 0x08000000, 0x10000000,
    0x20000000, 0x40000000, 0x80000000, 0x1b000000, 0x36000000
};

//AES SBOX Lookup Table
static const uint8_t sbox[256] = {
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
};

//AES inverse SBOX Lookup Table
static const uint8_t inv_sbox[256] = {
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
};


static inline uint32_t rot_word(uint32_t word) {
    return (word << 8) | (word >> 24);
}

static inline uint32_t sub_word(uint32_t word) {
    return ((uint32_t)sbox[(word >> 24)       ] << 24) |
           ((uint32_t)sbox[(word >> 16) & 0xFF] << 16) |
           ((uint32_t)sbox[(word >>  8) & 0xFF] <<  8) |
           ((uint32_t)sbox[ word        & 0xFF]);
}

void key_expansion(const uint32_t *key, uint32_t *w, int Nk) {
    int Nr = Nk + 6;

    for (int i = 0; i < Nk; i++) {
        w[i] = key[i];
    }

    int round_const_idx = 0;
    for (int i = Nk; i < 4*(Nr+1); i++) {
        uint32_t tmp = w[i-1];
        if ((i % Nk) == 0) {
            tmp = sub_word(rot_word(tmp)) ^ round_const[round_const_idx++];
        } else if ((Nk > 6) && ((i % Nk) == 4)) {
            tmp = sub_word(tmp);
        }
        w[i] = w[i - Nk] ^ tmp;
    }
}

static inline void add_round_key(uint8_t state[4][4], uint32_t *w, int round) {
    for (int c = 0; c < 4; c++) {
        uint32_t word = w[(4*round) + c];
        state[0][c] = state[0][c] ^ (uint8_t)(word >> 24);
        state[1][c] = state[1][c] ^ (uint8_t)(word >> 16);
        state[2][c] = state[2][c] ^ (uint8_t)(word >> 8);
        state[3][c] = state[3][c] ^ (uint8_t)(word);
    }
}

//AES SUBBYTES() function
static inline void sub_bytes(uint8_t state[4][4]) {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++){
            state[i][j] = sbox[state[i][j]];
        }
    }
}

static inline void shift_rows(uint8_t state[4][4]) {
    uint8_t tmp = state[1][0];
    state[1][0] = state[1][1];
    state[1][1] = state[1][2];
    state[1][2] = state[1][3];
    state[1][3] = tmp;

    tmp = state[2][0];
    state[2][0] = state[2][2];
    state[2][2] = tmp;
    tmp = state[2][1];
    state[2][1] = state[2][3];
    state[2][3] = tmp;

    tmp = state[3][3];
    state[3][3] = state[3][2];
    state[3][2] = state[3][1];
    state[3][1] = state[3][0];
    state[3][0] = tmp;
}

// Multiplication in 
static inline uint8_t xtime(uint8_t x) {
    return (uint8_t)((x << 1) ^ ((x & 0x80) ? 0x1b : 0x00));
}

static inline void mix_cols(uint8_t state[4][4]) {
    for (int i = 0; i < 4; i++) {
        uint8_t a = state[0][i];
        uint8_t b = state[1][i];
        uint8_t c = state[2][i];
        uint8_t d = state[3][i];
        uint8_t u = a ^ b ^ c ^ d;
        
        state[0][i] ^= u ^ xtime(a ^ b);
        state[1][i] ^= u ^ xtime(b ^ c);
        state[2][i] ^= u ^ xtime(c ^ d);
        state[3][i] ^= u ^ xtime(d ^ a);
    }
}

void aes_cipher(const uint32_t in[4], uint32_t *w, int Nr, uint32_t out[4]) {
    uint8_t state[4][4];

    //Copy in to state
    for (int i = 0; i < 4; i++) {
        state[0][i] = (uint8_t)(in[i] >> 24);
        state[1][i] = (uint8_t)(in[i] >> 16);
        state[2][i] = (uint8_t)(in[i] >> 8);
        state[3][i] = (uint8_t)(in[i]);
    }

    int round = 0;
    add_round_key(state, w, round);
    round++;
    for (; round < Nr; round++) {
        sub_bytes(state);
        shift_rows(state);
        mix_cols(state);
        add_round_key(state, w, round);
    }

    sub_bytes(state);
    shift_rows(state);
    add_round_key(state, w, round);

    //Copy state to out
    for (int i = 0; i < 4; i++) {
        out[i] = ((uint32_t)(state[0][i] << 24) |
                    (uint32_t)(state[1][i] << 16) |
                    (uint32_t)(state[2][i] << 8)  |
                    (uint32_t)(state[3][i]));
    }
}


//Encrypt Functions

void aes_128_enc(const uint32_t in[4], const uint32_t key[4], uint32_t out[4]) {
    uint32_t w[44];
    key_expansion(key, w, 4);
    aes_cipher(in, w, 10, out);
}

void aes_192_enc(const uint32_t in[4], const uint32_t key[6], uint32_t out[4]) {
    uint32_t w[52];
    key_expansion(key, w, 6);
    aes_cipher(in, w, 12, out);
}

void aes_256_enc(const uint32_t in[4], const uint32_t key[8], uint32_t out[4]) {
    uint32_t w[60];
    key_expansion(key, w, 8);
    aes_cipher(in, w, 14, out);
}

//Inverse Cipher support functions

void inv_shift_rows(uint8_t state[4][4]) {
    uint8_t tmp = state[1][3];
    state[1][3] = state[1][2];
    state[1][2] = state[1][1];
    state[1][1] = state[1][0];
    state[1][0] = tmp;

    tmp = state[2][0];
    state[2][0] = state[2][2];
    state[2][2] = tmp;
    tmp = state[2][1];
    state[2][1] = state[2][3];
    state[2][3] = tmp;

    tmp = state[3][0];
    state[3][0] = state[3][1];
    state[3][1] = state[3][2];
    state[3][2] = state[3][3];
    state[3][3] = tmp;
}

void inv_sub_bytes(uint8_t state[4][4]) {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++){
            state[i][j] = inv_sbox[state[i][j]];
        }
    }
}

void inv_mix_cols(uint8_t state[4][4]) {
    for (int i = 0; i < 4; i++) {
        uint8_t a = state[0][i];
        uint8_t b = state[1][i];
        uint8_t c = state[2][i];
        uint8_t d = state[3][i];
        uint8_t u = xtime(xtime(a ^ c));
        uint8_t v = xtime(xtime(b ^ d));
        state[0][i] ^= u;
        state[1][i] ^= v;
        state[2][i] ^= u;
        state[3][i] ^= v;
    }
    mix_cols(state);
}

void aes_inv_cipher(const uint32_t in[4], uint32_t *w, int Nr, uint32_t out[4]) {
    uint8_t state[4][4];

    //Copy in to state
    for (int i = 0; i < 4; i++) {
        state[0][i] = (uint8_t)(in[i] >> 24);
        state[1][i] = (uint8_t)(in[i] >> 16);
        state[2][i] = (uint8_t)(in[i] >> 8);
        state[3][i] = (uint8_t)(in[i]);
    }

    add_round_key(state, w, round);
    for (int round = Nr - 1; round > 0; round--) {
        inv_shift_rows(state);
        inv_sub_bytes(state);
        add_round_key(state, w, round);
        inv_mix_cols(state);
    }

    inv_shift_rows(state);
    inv_sub_bytes(state);
    add_round_key(state, w, round);

    //Copy state to out
    for (int i = 0; i < 4; i++) {
        out[i] = ((uint32_t)(state[0][i] << 24) |
                    (uint32_t)(state[1][i] << 16) |
                    (uint32_t)(state[2][i] << 8)  |
                    (uint32_t)(state[3][i]));
    }
}

//Decrypt Functions

void aes_128_dec(const uint32_t in[4], const uint32_t key[4], uint32_t out[4]) {
    uint32_t w[44];
    key_expansion(key, w, 4);
    aes_inv_cipher(in, w, 10, out);
}

void aes_192_dec(const uint32_t in[4], const uint32_t key[6], uint32_t out[4]) {
    uint32_t w[52];
    key_expansion(key, w, 6);
    aes_inv_cipher(in, w, 12, out);
}

void aes_256_dec(const uint32_t in[4], const uint32_t key[8], uint32_t out[4]) {
    uint32_t w[60];
    key_expansion(key, w, 8);
    aes_inv_cipher(in, w, 14, out);
}