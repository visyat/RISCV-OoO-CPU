`timescale 1ns / 1ps

// Code your design here
module decode(
    //Input
    input [31 : 0]          instr,
    input                   clk,
    input                   rstn,

    //Output: Source registers, destination registers, ALUOP, LW/SW Flag, Control Signals 
    output reg [6 : 0]      opcode,
    output reg [2 : 0]      funct3, 
    output reg [6 : 0]      funct7,
    output reg [4 : 0]      srcReg1,    // Src registers
    output reg [4 : 0]      srcReg2,
    output reg [4 : 0]      destReg,    // Destination register
    output reg [31 : 0]     imm,
    output reg              hasImm; 
    output reg [1 : 0]      lwSw,       // Lw/sw flags: [0: LW, 1: SW]
    output reg [1 : 0]      aluOp,      // Control signals 
    output reg              regWrite,
    output reg              aluSrc,
    output reg              branch,
    output reg              memRead,
    output reg              memWrite,
    output reg              memToReg
);
    // COMPONENTS: 
    // 1. Extract Opcode, funct3, funct7 (distinguish instruction)
    // 2. Determine registers and control signals 
    // 3. Immediate Generator 

    wire [6 : 0]    controlSignals;
    wire [1 : 0]    aluOp_wire;
    wire [1 : 0]    lwsw_wire;
    wire [31 :0]    imm_wire;
    
    controller contMod (
        .instr(instr),
      	.clk(clk),
        .controlSignals(controlSignals),
        .aluOp(aluOp_wire),
        .lwSw(lwsw_wire)
    );
    
    immGen immMod (
        .instr(instr),
      	.clk(clk),
        .rstn(rstn),
        .imm(imm_wire)
    );
    
    always @(*) begin
        if (~rstn)begin
            opcode      <= 7'b0;
            funct3      <= 3'b0;
            funct7      <= 7'b0;
            destReg     <= 5'b0;
            srcReg1     <= 5'b0;
            srcReg2     <= 5'b0;
            imm         <= 32'b0;
            hasImm      <= 1'b0;
            lwSw        <= 2'b0;
            aluOp       <= 2'b0;
            regWrite    <= 1'b0;
            aluSrc      <= 1'b0;
            branch      <= 1'b0;
            memRead     <= 1'b0;
            memWrite    <= 1'b0;
            memToReg    <= 1'b0;
        end
        else begin
            imm         <= imm_wire;
            lwSw        <= lwsw_wire;
            aluOp       <= aluOp_wire;

            opcode      = instr[6:0];
            funct3      <= instr[14:12];
            funct7      <= instr[31:25];

            srcReg1     <= instr[19:15];
            if (opcode == 7'b0000011) begin // Load instruction
                destReg     = instr[11:7];
                srcReg2     = 5'b0;
            end else if (opcode == 7'b0100011) begin // Store instruction
                destReg     = 5'b0;
                srcReg2     = instr[24:20];
            end else begin
                destReg     = instr[11:7];
                srcReg2     = instr[24:20];
            end
            
            hasImm      <= controlSignals[6];
            regWrite    <= controlSignals[5];
            aluSrc      <= controlSignals[4];
            branch      <= controlSignals[3];
            memRead     <= controlSignals[2];
            memWrite    <= controlSignals[1];
            memToReg    <= controlSignals[0];
        end
    end

endmodule



