import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge

@cocotb.test()
async def basic_count(dut):
    
    #Start Clock
    cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())

    #START TEST
    dut.BTNC.value = 1
    await Timer(600, "ns")
    dut.BTNC.value = 0
    dut.SWITCHES.value = 0


    cycles = 0
    instructions = 0

    PC_PASS = int(cocotb.plusargs["PC_PASS"], 0)
    PC_ERROR = int(cocotb.plusargs.get("PC_ERROR", "0x0"), 0)
    MAX_CYCLES = int(cocotb.plusargs.get("MAX_CYCLES", "12000000"))

    dut._log.info(f"Watching for PASS (0x{PC_PASS:x}) or ERROR (0x{PC_ERROR:x}) [Max Cycles: {MAX_CYCLES:,}]")

    while True:
        await RisingEdge(dut.clk_50)
        cycles += 1
        
        current_pc = int(dut.CPU.wb_pc.value)
        if current_pc != 0:
            instructions += 1

        # Periodic Heartbeat every 100,000 cycles (~every 1.5 seconds in cocotb)
        if cycles % 100000 == 0:
            dut._log.info(f"Progress: Cycles={cycles:,} | Insts={instructions:,} | Current PC=0x{current_pc:08x} | IPC={instructions/cycles:.2f}")

        # Safety Timeout to prevent infinite loops
        if cycles > MAX_CYCLES:
            dut._log.error(f"TIMEOUT: Exceeded {MAX_CYCLES:,} cycles! Current PC: 0x{current_pc:08x}")
            assert False, f"Simulation timeout at PC 0x{current_pc:08x}"

        if current_pc == PC_PASS:
            dut._log.info("======================================================")
            dut._log.info("  STATUS: TEST PASSED 100%!")
            dut._log.info(f"  Target PC reached : 0x{PC_PASS:x}")
            dut._log.info(f"  Total CPU Cycles  : {cycles}")
            dut._log.info(f"  IPC               : {instructions / cycles:.4f}")
            dut._log.info("======================================================")
            break
            
        elif current_pc == PC_ERROR and PC_ERROR != 0:
            # Look at a0 (x10) and a1 (x11) for vector index and word index
            failed_vec = int(dut.CPU.rf[10].value) if hasattr(dut.CPU, 'rf') else -1
            failed_word = int(dut.CPU.rf[11].value) if hasattr(dut.CPU, 'rf') else -1
            
            dut._log.error("======================================================")
            dut._log.error(f"  STATUS: TEST FAILED! Reached Error PC: 0x{PC_ERROR:x}")
            dut._log.error(f"  Failed at NIST vector: {failed_vec}, Word: {failed_word}")
            dut._log.error(f"  Cycles before failure: {cycles}")
            dut._log.error("======================================================")
            assert False, f"AES Test failed on vector {failed_vec}!"