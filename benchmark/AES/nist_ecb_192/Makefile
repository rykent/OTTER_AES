# the name of the program we're going to build
PROJECT = ecb_192
# build directory
BUILD = build

# source files
C_FILES := $(wildcard *.c)
AS_FILES := $(wildcard *.s)
ASP_FILES := $(wildcard *.S)

# object files
C_OBJ_FILES := $(patsubst %.c,build/%.o,$(C_FILES)) build/aes.o
AS_OBJ_FILES := $(patsubst %.s,build/%.o,$(AS_FILES))
ASP_OBJ_FILES := $(patsubst %.S,build/%.o,$(ASP_FILES))

# settings for the compilers
RISCV_PREFIX = riscv64-elf-
CC = $(RISCV_PREFIX)gcc
LD = $(RISCV_PREFIX)ld
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump

TARGET_ARCH =  -march=rv32i -mabi=ilp32
ifneq ($(C_FILES),)
CCFLAGS = -O3 $(TARGET_ARCH) -ffunction-sections -fdata-sections -g
else
CCFLAGS = -O0 $(TARGET_ARCH)
endif
#-fno-builtin
#-mstrict-align
#-static -static-libgcc -nostdlib
#-S   #flag for getting assembly output directly

# Lists of rules: the name of a file, followed by the files it depends on.
# When typing 'make' not followed by a rule name, the first rule is followed.  This rule depends on
# everything, causing all the parts to be built

all: dirs $(BUILD)/mem.txt $(BUILD)/$(PROJECT).dump

# how to build a .o file from a .c file
$(BUILD)/%.o: %.c
	$(CC) -c -o $@ $< $(CCFLAGS) 

build/aes.o: ../aes.c | dirs
	$(CC) -c -o $@ $< $(CCFLAGS) -I.. 

# how to build a .o file from a .s file
$(BUILD)/%.o: %.s
	$(CC) -c -o $@ $< $(CCFLAGS)

# how to build a .o file from a .S file
$(BUILD)/%.o: %.S
	$(CC) -c -o $@ $< $(CCFLAGS)

# link with gcc
$(BUILD)/$(PROJECT).elf: ${AS_OBJ_FILES} ${C_OBJ_FILES} ${ASP_OBJ_FILES}
	$(CC) -o $@ $^ -T link.ld -nostdlib -nostartfiles -Wl,--gc-sections $(TARGET_ARCH) -lgcc

$(BUILD)/$(PROJECT).dump: $(BUILD)/$(PROJECT).elf
	$(OBJDUMP) -d -S -l $< > $@
#-d (dissasemble)
#-s (all sections)
#no-show-raw_insn
#-l line numbers
# -S    (shows the c code intermixed with assembly)

# extract the binary data from data and text sections to get a binary image of memory
$(BUILD)/mem.bin: $(BUILD)/$(PROJECT).elf
	$(OBJCOPY) -O binary --only-section=.data* --only-section=.text* $< $@

# convert to an ASCII hex file for OTTER memory
$(BUILD)/mem.txt: $(BUILD)/mem.bin
	hexdump -v -e '"%08x\n"' $< > $@

# make software project folder
dirs:
	mkdir -p $(BUILD)

# 'clean' rule: delete all the files so we can start afresh
clean:
	rm -rf $(BUILD)

print-%  : ; @echo $* = $($*)
