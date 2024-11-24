///////////////////////////////////////////////////////////////////
// Function: module for pipeline register between ID and EX stage
//
// Author: Yudong Zhou
//
// Create date: 11/16/2024
///////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module ID_EX_Reg (
    input           clk,
    input           rstn,
    
    input           opcode_in,
    input           funct3_in,
    input           funct7_in,
    input [4:0]     srcReg1_in,
    input [4:0]     srcReg2_in,
    input [4:0]     destReg_in,
    input [31:0]    imm_in,
    input [1:0]     lwSw_in,
    //input [1:0]     aluOp_in,
    input           regWrite_in,
    //input           aluSrc_in,
    //input           branch_in,
    input           memRead_in,
    input           memWrite_in,
    input           memToReg_in,

    output          opcode_out,
    output          funct3_out,
    output          funct7_out,
    output [4:0]    srcReg1_out,
    output [4:0]    srcReg2_out,
    output [4:0]    destReg_out,
    output [31:0]   imm_out,
    output [1:0]    lwSw_out,
    //output [1:0]    aluOp_out,
    output          regWrite_out,
    //output          aluSrc_out,
    //output          branch_out,
    output          memRead_out,
    output          memWrite_out,
    output          memToReg_out    
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            opcode_out      <= 7'b0;
            funct3_out      <= 3'b0;
            funct7_out      <= 7'b0;
            srcReg1_out     <= 5'b0;
            srcReg2_out     <= 5'b0;
            destReg_out     <= 5'b0;
            imm_out         <= 32'b0;
            lwSw_out        <= 2'b0;
            //aluOp_out       <= 2'b0;
            regWrite_out    <= 1'b0;
            //aluSrc_out      <= 1'b0;
            //branch_out      <= 1'b0;
            memRead_out     <= 1'b0;
            memWrite_out    <= 1'b0;
            memToReg_out    <= 1'b0;
        end
        else begin
            opcode_out      <= opcode_in;
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;
            srcReg1_out     <= srcReg1_in;
            srcReg2_out     <= srcReg2_in;
            destReg_out     <= destReg_in;
            imm_out         <= imm_in;
            lwSw_out        <= lwSw_in;
            //aluOp_out       <= aluOp_in;
            regWrite_out    <= regWrite_in;
            //aluSrc_out      <= aluSrc_in;
            //branch_out      <= branch_in;
            memRead_out     <= memRead_in;
            memWrite_out    <= memWrite_in;
            memToReg_out    <= memToReg_in;
        end
    end

endmodule