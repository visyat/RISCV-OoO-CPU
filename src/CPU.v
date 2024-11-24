`timescale 1ns / 1ps

module CPU(
    input   clk,
    input   rstn
);
    
    // IF stage signals
    wire [31 : 0]   PC;
    reg [31 : 0]    PC_reg;
    wire [31 : 0]   instr_IF;
    wire            stop_IF;

    // ID stage signals
    wire [31 : 0]   instr_ID;
    wire            stop_ID;

    wire [6 : 0]    opcode_ID;
    wire [2 : 0]    funct3_ID; 
    wire [6 : 0]    funct7_ID;
    wire [4 : 0]    srcReg1_ID;
    wire [4 : 0]    srcReg2_ID;
    wire [4 : 0]    destReg_ID;
    wire [31 : 0]   imm_ID;
    wire [1 : 0]    lwSw_ID;
    wire [1 : 0]    aluOp_ID; 
    wire            regWrite_ID;
    wire            aluSrc_ID;
    wire            branch_ID;
    wire            memRead_ID;
    wire            memWrite_ID;
    wire            memToReg_ID;
    
    reg [5 : 0]     sr1; // Source register 1
    reg [5 : 0]     sr2; // Source register 2
    reg [5 : 0]     dr;  // Destination register
    
    // Testbench outputs
    wire [5 : 0]    sr1_p; // Mapped source register 1
    wire [5 : 0]    sr2_p; // Mapped source register 2
    wire [5 : 0]    dr_p;  // Mapped destination register
    wire            s1_ready; // Ready status for source 1
    wire            s2_ready; // Ready status for source 2
    
///////////////////////////////////////////////////////////////////////
//  Fetch Stage
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            PC_reg = 32'b0;
        end
        else begin
            PC_reg = PC_reg + 4;
        end
    end
    assign PC = PC_reg;

    instructionMemory instr_mem (
        .clk(clk),
        .PC(PC),
        .rstn(rstn),
        .instr(instr_IF),
        .stop(stop_IF)
    );

///////////////////////////////////////////////////////////////////////
//  Pipeline Registers between Fetch and Decode
    IF_ID_Reg IF_ID_Reg (
        .clk(clk),
        .rstn(rstn),
        .inst_IF_in(instr_IF),
        .stop_in(stop_IF),
        .inst_ID_out(instr_ID),
        .stop_out(stop_ID)
    );
    
///////////////////////////////////////////////////////////////////////
//  Decode Stage
    decode decode_mod(
        .instr(instr_ID),
        .clk(clk),
        .rstn(rstn),
        .opcode(opcode_ID),
        .funct3(funct3_ID), 
        .funct7(funct7_ID), 
        .srcReg1(srcReg1_ID),
        .srcReg2(srcReg2_ID),
        .destReg(destReg_ID),
        .imm(imm_ID), 
        .lwSw(lwSw_ID),
        .aluOp(aluOp_ID),
        .regWrite(regWrite_ID),
        .aluSrc(aluSrc_ID),
        .branch(branch_ID),
        .memRead(memRead_ID),
        .memWrite(memWrite_ID),
        .memToReg(memToReg_ID)
    );

///////////////////////////////////////////////////////////////////////
//  Execution Stage
    rename uut (
        .rstn(rstn),
        .sr1(sr1),
        .sr2(sr2),
        .dr(dr),
        .aluOp(aluOp),
        //.imm(imm),
        .sr1_p(sr1_p),
        .sr2_p(sr2_p),
        .dr_p(dr_p),
        .s1_ready(s1_ready),
        .s2_ready(s2_ready),
        .FU(),
        .ROB_num()
    );

endmodule