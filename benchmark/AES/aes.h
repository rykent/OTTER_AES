#ifndef AES_H
#define AES_H

#include <stdint.h>
#include <stddef.h>

void aes_128_enc(const uint32_t in[4], const uint32_t key[4], uint32_t out[4]);
void aes_192_enc(const uint32_t in[4], const uint32_t key[6], uint32_t out[4]); 
void aes_256_enc(const uint32_t in[4], const uint32_t key[8], uint32_t out[4]);

void aes_128_dec(const uint32_t in[4], const uint32_t key[4], uint32_t out[4]);
void aes_192_dec(const uint32_t in[4], const uint32_t key[6], uint32_t out[4]); 
void aes_256_dec(const uint32_t in[4], const uint32_t key[8], uint32_t out[4]);

#endif