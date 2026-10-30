import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge

@cocotb.test()
async def basic_count(dut):

    #PC to search for
    PC_END = int(cocotb.plusargs["PC"], 0)
    
    #Start Clock
    cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())

    #START TEST
    dut.BTNC.value = 1
    await Timer(600, "ns")
    dut.BTNC.value = 0
    dut.SWITCHES.value = 0


    cycles = 0
    instructions = 0


    dut._log.info("Starting Program")
    while dut.CPU.wb_pc.value != PC_END:
        await RisingEdge(dut.clk_50)

        cycles += 1

        #Only increment instr count on non-bubble instr
        if int(dut.CPU.wb_pc.value) != 0:
            instructions += 1
    

    if (cycles > 0):
        ipc = instructions / cycles
    else:
        ipc = 0.0

    dut._log.info("======================================================")
    dut._log.info(f"  Target PC reached : 0x{PC_END:x}")
    dut._log.info(f"  Total CPU Cycles  : {cycles}")
    dut._log.info(f"  Retired Insts     : {instructions}")
    dut._log.info(f"  IPC               : {ipc:.4f} inst/cycle")
    dut._log.info("======================================================")
