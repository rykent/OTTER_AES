#ifndef AES_H
#define AES_H

#define uint32_t unsigned long
#define uint16_t unsigned short
#define uint8_t  unsigned char

#define int32_t  signed long
#define int16_t  signed short
#define int8_t   signed char

#define size_t   unsigned long


void aes_128_enc(const uint32_t in[4], const uint32_t key[4], uint32_t out[4]);
void aes_192_enc(const uint32_t in[4], const uint32_t key[6], uint32_t out[4]); 
void aes_256_enc(const uint32_t in[4], const uint32_t key[8], uint32_t out[4]);

#endif