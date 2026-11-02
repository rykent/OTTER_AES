//////////////////////////////////////////////////////////////////////
//
// nist_aes_ecb_192.c
// Tests the ECB mode of AES 192 with the NIST test vectors
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
#include "ecbgfsbox192.h"
#include "ecbkeysbox192.h"
#include "ecbvartxt192.h"

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


    //Test Encryption ECBGFSBOX192
    for (int i = 0; i < NUM_ECBGFSBOX192_ENCRYPT_VECTORS; i++) {
        aes_192_enc(ecbgfsbox192_encrypt_vectors[i].pt,
                    ecbgfsbox192_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbgfsbox192_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBGFSBOX192
    for (int i = 0; i < NUM_ECBGFSBOX192_DECRYPT_VECTORS; i++) {
        aes_192_dec(ecbgfsbox192_decrypt_vectors[i].ct,
                    ecbgfsbox192_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbgfsbox192_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Encryption ECBKEYSSBOX192
    for (int i = 0; i < NUM_ECBKEYSBOX192_ENCRYPT_VECTORS; i++) {
        aes_192_enc(ecbkeysbox192_encrypt_vectors[i].pt,
                    ecbkeysbox192_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbkeysbox192_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBKEYSSBOX192
    for (int i = 0; i < NUM_ECBKEYSBOX192_DECRYPT_VECTORS; i++) {
        aes_192_dec(ecbkeysbox192_decrypt_vectors[i].ct,
                    ecbkeysbox192_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbkeysbox192_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Encryption ECBVARTXT192
    for (int i = 0; i < NUM_ECBVARTXT192_ENCRYPT_VECTORS; i++) {
        aes_192_enc(ecbvartxt192_encrypt_vectors[i].pt,
                    ecbvartxt192_encrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbvartxt192_encrypt_vectors[i].ct[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    //Test Decryption ECBVARTXT192
    for (int i = 0; i < NUM_ECBVARTXT192_DECRYPT_VECTORS; i++) {
        aes_192_dec(ecbvartxt192_decrypt_vectors[i].ct,
                    ecbvartxt192_decrypt_vectors[i].key,
                    computed_data);
        for (int j = 0; j < 4; j++){
            if (computed_data[j] != ecbvartxt192_decrypt_vectors[i].pt[j])
                test_error(i, j); //TEST failed, jump to fail loop
        }
    }

    test_pass();
}