# RISC-V baremetal init.s
# This code is executed first.

.section .text.init
.globl entry
entry:

    la    sp, __sp   # set up the stack pointer, using a constant defined in the linker script.
  
    call  main          # call the main function if barebones assembly/C

end:
    j end               # loop when finished if there is no environment to return to.
