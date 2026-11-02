//////////////////////////////////////////////////////////////////////
//
// nist_aes_ecb_256.c
// Tests the ECB mode of AES 256 with the NIST test vectors
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
#include "ecbgfsbox256.h"
#include "ecbkeysbox256.h"
#include "ecbvartxt256.h"

//Test PASS and ERROR helpers:
// __attribute__((noinline, noreturn)) guarantees GCC creates dedicated,
// identifiable labels and PC addresses in the ELF symbol table.

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


//Main testing
void main() {
    uint32_t computed_data[4] = {0};


    //Test Encryption ECBGFSBOX256
    for (int i = 0; i < NUM_ECBGFSBOX256_ENCRYPT_VECTORS; i++) {
        aes_256_enc(ecbgfsbox256_encrypt_vectors[i].pt,
                    ecbgfsbox256_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbgfsbox256_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBGFSBOX256
    for (int i = 0; i < NUM_ECBGFSBOX256_DECRYPT_VECTORS; i++) {
        aes_256_dec(ecbgfsbox256_decrypt_vectors[i].ct,
                    ecbgfsbox256_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbgfsbox256_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Encryption ECBKEYSSBOX256
    for (int i = 0; i < NUM_ECBKEYSBOX256_ENCRYPT_VECTORS; i++) {
        aes_256_enc(ecbkeysbox256_encrypt_vectors[i].pt,
                    ecbkeysbox256_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbkeysbox256_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBKEYSSBOX256
    for (int i = 0; i < NUM_ECBKEYSBOX256_DECRYPT_VECTORS; i++) {
        aes_256_dec(ecbkeysbox256_decrypt_vectors[i].ct,
                    ecbkeysbox256_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbkeysbox256_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Encryption ECBVARTXT256
    for (int i = 0; i < NUM_ECBVARTXT256_ENCRYPT_VECTORS; i++) {
        aes_256_enc(ecbvartxt256_encrypt_vectors[i].pt,
                    ecbvartxt256_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbvartxt256_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBVARTXT256
    for (int i = 0; i < NUM_ECBVARTXT256_DECRYPT_VECTORS; i++) {
        aes_256_dec(ecbvartxt256_decrypt_vectors[i].ct,
                    ecbvartxt256_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbvartxt256_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    test_pass();
}