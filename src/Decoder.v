////////////////////////////////////////////////////////////////////////////////////////////
// Function: module for RISC-V Instruction Decoder
//
// Author: Yudong Zhou
//
// Create date: 11/13/2024
//
////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module Decoder (
    input  wire [31:0]      instruction,
    output reg  [6:0]       opcode,
    output reg  [2:0]       funct3,
    output reg  [6:0]       funct7,
    output reg  [6:0]       rs1,
    output reg  [6:0]       rs2,
    output reg  [6:0]       rd,
    output reg  [31:0]      imm
);

    always @(*) begin
        opcode  = instruction[6:0];
        funct3  = instruction[14:12];
        funct7  = instruction[31:25];
        rs1     = instruction[19:15];
        rs2     = instruction[24:20];
        rd      = instruction[11:7];

        case (opcode)
            7'b0010011, // I-type
            7'b0000011: // Load
                imm = {{20{instruction[31]}}, instruction[31:20]}; // sign-extend immediate
            7'b0100011: // Store
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // sign-extend immediate
            7'b0110111: // U-type
                imm = {instruction[31:12], 12'b0}; // left-shift immediate by 12
            default:
                imm = 32'b0;
        endcase
    end

endmodule