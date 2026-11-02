//////////////////////////////////////////////////////////////////////
//
// nist_aes_ecb_128.c
// Tests the ECB mode of AES 128 with the NIST test vectors
// Set AES function to be used with the #define MODE_***
//
// Author : Ryken Thompson
//////////////////////////////////////////////////////////////////////

#define MODE_RV32I
// #define MODE_RV32I_AES_CP
// #define MODE_RV32I_ZNKE_ZKND

//Include AES functions
#include "aes.h"

//Include test data, to be stored in rodata
#include "ecbgfsbox128.h"
#include "ecbkeysbox128.h"
#include "ecbvartxt128.h"

//Test PASS and ERROR helpers:
__attribute__((noinline, noreturn))
void test_error(uint32_t vector_idx, uint32_t word_idx) {
    // vector_idx is in register a0 (x10)
    // word_idx   is in register a1 (x11)
    while (1) {
        __asm__ volatile ("j ."); // Infinite branch loop to self: PC sticks here
    }
}

__attribute__((noinline, noreturn))
void test_pass(void) {
    while (1) {
        __asm__ volatile ("j ."); // Infinite branch loop on success
    }
}

//Main test vectors
void main() {
    uint32_t computed_data[4] = {0};

    //Test Encryption ECBGFSBOX128
    for (int i = 0; i < NUM_ECBGFSBOX128_ENCRYPT_VECTORS; i++) {
        aes_128_enc(ecbgfsbox128_encrypt_vectors[i].pt,
                    ecbgfsbox128_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbgfsbox128_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBGFSBOX128
    for (int i = 0; i < NUM_ECBGFSBOX128_DECRYPT_VECTORS; i++) {
        aes_128_dec(ecbgfsbox128_decrypt_vectors[i].ct,
                    ecbgfsbox128_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbgfsbox128_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Encryption ECBKEYSSBOX128
    for (int i = 0; i < NUM_ECBKEYSBOX128_ENCRYPT_VECTORS; i++) {
        aes_128_enc(ecbkeysbox128_encrypt_vectors[i].pt,
                    ecbkeysbox128_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbkeysbox128_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBKEYSSBOX128
    for (int i = 0; i < NUM_ECBKEYSBOX128_DECRYPT_VECTORS; i++) {
        aes_128_dec(ecbkeysbox128_decrypt_vectors[i].ct,
                    ecbkeysbox128_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbkeysbox128_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Encryption ECBVARTXT128
    for (int i = 0; i < NUM_ECBVARTXT128_ENCRYPT_VECTORS; i++) {
        aes_128_enc(ecbvartxt128_encrypt_vectors[i].pt,
                    ecbvartxt128_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbvartxt128_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBVARTXT128
    for (int i = 0; i < NUM_ECBVARTXT128_DECRYPT_VECTORS; i++) {
        aes_128_dec(ecbvartxt128_decrypt_vectors[i].ct,
                    ecbvartxt128_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbvartxt128_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    test_pass();
}