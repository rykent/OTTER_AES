#! /bin/bash


#Start Tests
echo "Starting ECB_test 128 bit"
cp $PWD/../mem/nist_ecb128.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC_PASS=0x18 +PC_ERROR=0x10"

echo "Starting ECB_test 128 bit Zkne/Zknd extension"
cp $PWD/../mem/nist_ecb128_zkne.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC_PASS=0x18 +PC_ERROR=0x10"

echo "Starting ECB_test 192 bit"
cp $PWD/../mem/nist_ecb192.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC_PASS=0x18 +PC_ERROR=0x10"

echo "Starting ECB_test 192 bit Zkne/Zknd extension"
cp $PWD/../mem/nist_ecb192_zkne.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC_PASS=0x18 +PC_ERROR=0x10"

echo "Starting ECB_test 256 bit"
cp $PWD/../mem/nist_ecb256.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC_PASS=0x18 +PC_ERROR=0x10"

echo "Starting ECB_test 256 bit Zkne/Zknd extension"
cp $PWD/../mem/nist_ecb256_zkne.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC_PASS=0x18 +PC_ERROR=0x10"


#Parse Results

#Cleanup


wait

echo "All done"