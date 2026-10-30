// Auto-generated from CFB8GFSbox128.rsp
#ifndef KAT_CFB8GFSBOX128_H
#define KAT_CFB8GFSBOX128_H

#include <stdint.h>

typedef struct {
    uint32_t count;
    uint32_t key[4];
    uint32_t iv[4];
    uint8_t pt;
    uint8_t ct;
} kat_cfb8gfsbox128_vector_t;

#define NUM_CFB8GFSBOX128_ENCRYPT_VECTORS 7
static const kat_cfb8gfsbox128_vector_t cfb8gfsbox128_encrypt_vectors[NUM_CFB8GFSBOX128_ENCRYPT_VECTORS] = {
    { .count = 0, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0xf34481ec, 0x3cc627ba, 0xcd5dc3fb, 0x08f273e6}, .pt = 0x00, .ct = 0x03 },
    { .count = 1, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x9798c464, 0x0bad75c7, 0xc3227db9, 0x10174e72}, .pt = 0x00, .ct = 0xa9 },
    { .count = 2, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x96ab5c2f, 0xf612d9df, 0xaae8c31f, 0x30c42168}, .pt = 0x00, .ct = 0xff },
    { .count = 3, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x6a118a87, 0x4519e64e, 0x9963798a, 0x503f1d35}, .pt = 0x00, .ct = 0xdc },
    { .count = 4, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0xcb9fceec, 0x81286ca3, 0xe989bd97, 0x9b0cb284}, .pt = 0x00, .ct = 0x92 },
    { .count = 5, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0xb26aeb18, 0x74e47ca8, 0x358ff223, 0x78f09144}, .pt = 0x00, .ct = 0x45 },
    { .count = 6, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x58c8e00b, 0x2631686d, 0x54eab84b, 0x91f0aca1}, .pt = 0x00, .ct = 0x08 },
};

#define NUM_CFB8GFSBOX128_DECRYPT_VECTORS 7
static const kat_cfb8gfsbox128_vector_t cfb8gfsbox128_decrypt_vectors[NUM_CFB8GFSBOX128_DECRYPT_VECTORS] = {
    { .count = 0, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0xf34481ec, 0x3cc627ba, 0xcd5dc3fb, 0x08f273e6}, .pt = 0x00, .ct = 0x03 },
    { .count = 1, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x9798c464, 0x0bad75c7, 0xc3227db9, 0x10174e72}, .pt = 0x00, .ct = 0xa9 },
    { .count = 2, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x96ab5c2f, 0xf612d9df, 0xaae8c31f, 0x30c42168}, .pt = 0x00, .ct = 0xff },
    { .count = 3, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x6a118a87, 0x4519e64e, 0x9963798a, 0x503f1d35}, .pt = 0x00, .ct = 0xdc },
    { .count = 4, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0xcb9fceec, 0x81286ca3, 0xe989bd97, 0x9b0cb284}, .pt = 0x00, .ct = 0x92 },
    { .count = 5, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0xb26aeb18, 0x74e47ca8, 0x358ff223, 0x78f09144}, .pt = 0x00, .ct = 0x45 },
    { .count = 6, .key = {0x00000000, 0x00000000, 0x00000000, 0x00000000}, .iv = {0x58c8e00b, 0x2631686d, 0x54eab84b, 0x91f0aca1}, .pt = 0x00, .ct = 0x08 },
};

#endif // KAT_CFB8GFSBOX128_H
