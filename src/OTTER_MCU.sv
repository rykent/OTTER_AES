`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/30/2023 10:49:26 AM
// Design Name: OTTER MCU
// Module Name: OTTER_MCU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input RST,
    input INTR,
    input CLK,
    input [31:0] IOBUS_IN,
    output IOBUS_WR,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR
    );
    
    struct packed {
        logic [31:0] npc;
        logic [31:0] pc;
    } IF_ID_r;

    struct packed {
        logic [31:0] npc;
        logic [31:0] pc;
        logic [31:0] instr;
        logic regWrite;
        logic memWrite;
        logic memRead2;
        logic [3:0] alu_fun;
        logic [1:0] alu_srcA;
        logic [1:0] alu_srcB;
        logic [1:0] rf_wr_sel;
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] imm;
        logic csr_we;
        logic mret_exec;
    } ID_EX_r;

    struct packed {
        logic [31:0] pc;
        logic [31:0] npc;
        logic [1:0] memSize;
        logic memSign;
        logic regWrite;
        logic memWrite;
        logic memRead2;
        logic [1:0] rf_wr_sel;
        logic [31:0] rs2_data;
        logic [4:0] rd_addr;
        logic [31:0] alu_res;
        logic [31:0] csr_rd;
    } EX_MEM_r;

    struct packed {
        logic [31:0] pc;
        logic [31:0] npc;
        logic regWrite;
        logic memWrite;
        logic [31:0] rs2_data;
        logic [1:0] memSize;
        logic memSign;
        logic [1:0] rf_wr_sel;
        logic [4:0]  rd_addr;
        logic [31:0] alu_res;
        logic [31:0] csr_rd;
    } MEM_WB_r;



    //**************************************************************************
    // * Fetch (Instruction Memory) Stage
    // *************************************************************************

    logic [2:0] pc_source;

    logic pcWrite;

    logic [31:0] pc_din;
    logic [31:0] pc_w;
    logic [31:0] npc_w;
    logic [31:0] instr_w;

    logic [31:0] jalr_addr;
    logic [31:0] branch_addr;
    logic [31:0] jal_addr;

    assign npc_w = pc_w + 4;


    always_ff @(posedge CLK) begin
        if(RST) begin
            IF_ID_r <= 0;
        end 
        else if (stall) begin
            IF_ID_r <= IF_ID_r;
        end
        else if (flush) begin
            IF_ID_r <= 0;
        end
        else begin
            IF_ID_r.pc <= pc_w;
            IF_ID_r.npc <= npc_w;
        end
    end

    mux_3bit_sel PC_MUX (
        .A  (npc_w),
        .B  (jalr_addr),
        .C  (branch_addr),
        .D  (jal_addr), 
        .E  (MTVEC_w),
        .F  (MEPC_w),
        .sel(pc_source), 
        .O  (pc_din)
    );

    PC PC0 (
        .CLK     (CLK), 
        .PC_WRITE(pcWrite),
        .PC_RST  (RST), 
        .PC_DIN  (pc_din), 
        .PC_COUNT(pc_w)
    );


    Memory OTTER_MEM (
        .MEM_CLK  (CLK),
        .MEM_RDEN1(pcWrite),
        .MEM_RDEN2(EX_MEM_r.memRead2),
        .MEM_WE2  (EX_MEM_r.memWrite),
        .MEM_ADDR1(pc_w[15:2]),
        .MEM_ADDR2(EX_MEM_r.alu_res),
        .MEM_DIN2 (EX_MEM_r.rs2_data),
        .MEM_SIZE (EX_MEM_r.memSize),
        .MEM_SIGN (EX_MEM_r.memSign),
        .FLUSH    (flush),
        .IO_IN    (IOBUS_IN),
        .IO_WR    (IOBUS_WR),
        .MEM_DOUT1(instr_w),
        .MEM_DOUT2(dout2_w)
    );
    
    //**************************************************************************
    // * Decode (Register File) stage
    // *************************************************************************

    logic [31:0] rs1_data_w;
    logic [31:0] rs2_data_w;

    logic [31:0] rs1_data_new_w;
    logic [31:0] rs2_data_new_w;

    logic [31:0] alu_srcA_data_w;
    logic [31:0] alu_srcB_data_w;
    

    logic [1:0] alu_srcA_w;
    logic [1:0] alu_srcB_w;
    logic [3:0] alu_fun_w;
    logic [1:0] rf_wr_sel_w;

    logic memRead1;
    logic stall;
    logic flush;

    logic memRead2_w;
    logic regWrite_w;
    logic memWrite_w;
    logic csr_we_w;
    logic mret_exec_w;

    logic [31:0] imm_w;
    

    always_ff @(posedge CLK) begin
        if(RST | stall) begin
             ID_EX_r <= 0;
        end
        else begin
            ID_EX_r.pc <= IF_ID_r.pc;
            ID_EX_r.npc <= IF_ID_r.npc;
            ID_EX_r.instr <= instr_w;
            ID_EX_r.regWrite <= regWrite_w;
            ID_EX_r.memWrite <= memWrite_w;
            ID_EX_r.memRead2 <= memRead2_w;
            ID_EX_r.alu_fun <= alu_fun_w;
            ID_EX_r.alu_srcA <= alu_srcA_w;
            ID_EX_r.alu_srcB <= alu_srcB_w;
            ID_EX_r.rf_wr_sel <= rf_wr_sel_w;
            ID_EX_r.rs1_data <= rs1_data_new_w;
            ID_EX_r.rs2_data <= rs2_data_new_w;
            ID_EX_r.imm <= imm_w;
            ID_EX_r.mret_exec <= mret_exec_w;
            ID_EX_r.csr_we <= csr_we_w;
        end
    end

    RF OTTER_RF (
        .CLK    (CLK),
        .RF_ADR1(instr_w[19:15]),
        .RF_ADR2(instr_w[24:20]),
        .RF_WA  (MEM_WB_r.rd_addr),
        .RF_WD  (rf_wd_w),
        .RF_EN  (MEM_WB_r.regWrite),
        .RF_RS1 (rs1_data_w),
        .RF_RS2 (rs2_data_w)
    );

    CU_DCDR DECODER (
        .rf_wr_sel(rf_wr_sel_w),
        .alu_srcA (alu_srcA_w),
        .alu_srcB (alu_srcB_w),
        .alu_fun  (alu_fun_w),
        .opcode   (instr_w[6:0]),
        .funct3   (instr_w[14:12]),
        .funct7   (instr_w[30]),
        .memRead2 (memRead2_w),
        .memWrite (memWrite_w),
        .regWrite (regWrite_w),
        .csr_WE   (csr_we_w),
        .memRead1 (memRead1),
        .mret_exec (mret_exec_w)
    );

    IMMED_GEN IMM (
        .INSTRUCT(instr_w),
        .IMM(imm_w)
    );

    hazard_detection_unit HAZARD_DETECT (
        .id_ex_rd      (ID_EX_r.instr[11:7]),
        .ex_mem_rd      (EX_MEM_r.rd_addr),
        .instr         (instr_w),
        .pcWrite       (pcWrite),
        .id_ex_regWrite (ID_EX_r.regWrite),
        .id_ex_memRead2(ID_EX_r.memRead2),
        .ex_mem_memRead2(EX_MEM_r.memRead2),
        .stall         (stall)
    );

    BRANCH_ADDR_GEN TARGET_GEN (
        .IMM(imm_w),
        .PC    (IF_ID_r.pc),
        .RS1   (rs1_data_new_w),
        .JAL   (jal_addr),
        .BRANCH(branch_addr),
        .JALR  (jalr_addr)
    );

    BRANCH_COND_GEN BRANCH_COND_GEN0 (
        .RS1   (rs1_data_new_w),
        .RS2   (rs2_data_new_w),
        .INSTR   (instr_w), 
        .INTR    (INTR & MSTATUS_w[3]),
        .stall    (stall),
        .pcSource(pc_source),
        .int_taken(int_taken),
        .mret_exec(0),
        .flush    (flush)
    );


    mux_2bit_sel ID_FORWARDC_MUX (
        .A  (rs1_data_w),
        .B  (EX_MEM_r.alu_res),
        .C  (rf_wd_w),
        .D  (0),
        .sel(forwardC_sel),
        .O  (rs1_data_new_w)
    );

    mux_2bit_sel ID_FORWARDD_MUX (
        .A  (rs2_data_w),
        .B  (EX_MEM_r.alu_res),
        .C  (rf_wd_w),
        .D  (0),
        .sel(forwardD_sel),
        .O  (rs2_data_new_w)
    );


    //**************************************************************************
    // * Execute (ALU) Stage
    // *************************************************************************


    logic [31:0] alu_res_w;

    logic [31:0] alu_srcA_fw;
    logic [31:0] alu_srcB_fw;

    logic [1:0] forwardA_sel;
    logic [1:0] forwardB_sel;
    logic [1:0] forwardC_sel;
    logic [1:0] forwardD_sel;

    logic [31:0] csr_rd_w;
    logic [31:0] MSTATUS_w;
    logic [31:0] MEPC_w;
    logic [31:0] MTVEC_w;
    logic int_taken;
    logic csr_we;

    always_ff @(posedge CLK) begin
        if(RST) begin
             EX_MEM_r <= 0;
        end else begin
            EX_MEM_r.pc <= ID_EX_r.pc;
            EX_MEM_r.npc <= ID_EX_r.npc;
            EX_MEM_r.memSize <= ID_EX_r.instr[13:12];
            EX_MEM_r.memSign <= ID_EX_r.instr[14];
            EX_MEM_r.regWrite <= ID_EX_r.regWrite;
            EX_MEM_r.memWrite <= ID_EX_r.memWrite;
            EX_MEM_r.memRead2 <= ID_EX_r.memRead2;
            EX_MEM_r.rf_wr_sel <= ID_EX_r.rf_wr_sel;
            EX_MEM_r.rd_addr <= ID_EX_r.instr[11:7];
            EX_MEM_r.rs2_data <= alu_srcB_fw;
            EX_MEM_r.alu_res <= alu_res_w;
            EX_MEM_r.csr_rd <= csr_rd_w;
            
        end
    end


    mux_2bit_sel ALU_SRCA_FORWARD_MUX (
        .A  (ID_EX_r.rs1_data),
        .B  (rf_wd_w),
        .C  (EX_MEM_r.alu_res),
        .D  (0),
        .sel(forwardA_sel),
        .O  (alu_srcA_fw)
    );

    mux_2bit_sel ALU_SRCB_FORWARD_MUX (
        .A  (ID_EX_r.rs2_data),
        .B  (rf_wd_w),
        .C  (EX_MEM_r.alu_res),
        .D  (0),
        .sel(forwardB_sel),
        .O  (alu_srcB_fw)
    );


    mux_2bit_sel ALU_SRCA_MUX (
        .A  (alu_srcA_fw),
        .B  (ID_EX_r.imm),
        .C  (~alu_srcA_fw),
        .D  (0),
        .sel(ID_EX_r.alu_srcA),
        .O  (alu_srcA_data_w)
    );


    mux_2bit_sel ALU_SRCB_MUX (
        .A  (alu_srcB_fw),
        .B  (ID_EX_r.imm),
        .C  (ID_EX_r.pc), 
        .D  (csr_rd_w),
        .sel(ID_EX_r.alu_srcB), 
        .O  (alu_srcB_data_w)
    );

    forwarding FORWARD_UNIT (
        .id_ex_rs1      (ID_EX_r.instr[19:15]),
        .id_ex_rs2      (ID_EX_r.instr[24:20]),
        .if_id_rs1      (instr_w[19:15]),
        .if_id_rs2      (instr_w[24:20]),
        .ex_mem_rd      (EX_MEM_r.rd_addr),
        .ex_mem_regWrite(EX_MEM_r.regWrite),
        .mem_wb_regWrite(MEM_WB_r.regWrite),
        .mem_wb_rd      (MEM_WB_r.rd_addr),
        .forwardA_sel   (forwardA_sel),
        .forwardB_sel   (forwardB_sel),
        .forwardC_sel   (forwardC_sel),
        .forwardD_sel   (forwardD_sel)
    );


    ALU ALU0 (
        .srcA   (alu_srcA_data_w),
        .srcB   (alu_srcB_data_w),
        .ALU_FUN(ID_EX_r.alu_fun),
        .RESULT (alu_res_w)
    );


    CSR CSR0 (
        .PC       (ID_EX_r.pc),
        .RST      (RST),
        .clk      (CLK),
        .mret_exec(mret_exec),
        .INT_TAKEN(int_taken),
        .ADDR     (ID_EX_r.instr[31:20]),
        .WR_EN    (csr_we),
        .WD       (alu_res_w),
        .RD       (csr_rd_w),
        .MSTATUS  (MSTATUS_w),
        .MEPC     (MEPC_w),
        .MTVEC    (MTVEC_w)
    );

    //**************************************************************************
    // * Memory (Data Memory) stage
    // *************************************************************************


    logic [31:0] dout2_w;


    assign IOBUS_OUT = EX_MEM_r.rs2_data;
    assign IOBUS_ADDR = EX_MEM_r.alu_res;

    always_ff @(posedge CLK) begin
        if(RST) begin
            MEM_WB_r <= 0;
        end else begin
            MEM_WB_r.pc <= EX_MEM_r.pc;
            MEM_WB_r.npc <= EX_MEM_r.npc;
            MEM_WB_r.rs2_data <= EX_MEM_r.rs2_data;
            MEM_WB_r.memWrite <= EX_MEM_r.memWrite;
            MEM_WB_r.regWrite <= EX_MEM_r.regWrite;
            MEM_WB_r.rf_wr_sel <= EX_MEM_r.rf_wr_sel;
            MEM_WB_r.memSize <= EX_MEM_r.memSize;
            MEM_WB_r.memSign <= EX_MEM_r.memSign;
            MEM_WB_r.alu_res <= EX_MEM_r.alu_res;
            MEM_WB_r.rd_addr <= EX_MEM_r.rd_addr;
            MEM_WB_r.csr_rd <= EX_MEM_r.csr_rd;
        end
    end

    logic [31:0] wb_pc;
    assign wb_pc = MEM_WB_r.pc;


    //**************************************************************************
    // * Write (Write Back) stage
    // *************************************************************************


    logic [31:0] rf_wd_w;


    mux_2bit_sel RF_WR_MUX (
        .A  (MEM_WB_r.npc),
        .B  (MEM_WB_r.csr_rd),
        .C  (dout2_w),
        .D  (MEM_WB_r.alu_res),
        .sel(MEM_WB_r.rf_wr_sel),
        .O  (rf_wd_w)
    );


endmodule