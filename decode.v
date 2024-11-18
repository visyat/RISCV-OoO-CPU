// Code your design here
module decode(
    //Input
    instr,
    clk,
    
    //Output: Source registers, destination registers, ALUOP, LW/SW Flag, Control Signals 
    opcode,
    funct3, 
    funct7, 
    srcReg1, // Src registers
    srcReg2,
    destReg, // Destination register
    imm, 
    lwSw, // Lw/sw flags 
    aluOp, // Control signals 
    regWrite,
    aluSrc,
    branch,
    memRead,
    memWrite,
    memToReg
);
    // COMPONENTS: 
    // 1. Extract Opcode, funct3, funct7 (distinguish instruction)
    // 2. Determine registers and control signals 
    // 3. Immediate Generator 

    input [31:0] instr;
    input clk;
    
    output reg [6:0] opcode;
    output reg [2:0] funct3; 
    output reg [6:0] funct7;
    output reg [4:0] srcReg1;
    output reg [4:0] srcReg2;
    output reg [4:0] destReg;
    output reg [31:0] imm; 
    output reg [1:0] lwSw; // [0: LW, 1: SW]
    output reg [1:0] aluOp; 
    output reg regWrite;
    output reg aluSrc;
    output reg branch;
    output reg memRead;
    output reg memWrite;
    output reg memToReg;

    reg [5:0] controlSignals;
    controller contMod (
        .instr(instr),
      	.clk(clk),
        .controlSignals(controlSignals),
        .aluOp(aluOp),
        .lwSw(lwSw)
    );
    immGen immMod (
        .instr(instr),
      	.clk(clk),
        .imm(imm)
    );

    always @(posedge clk) begin
        opcode = instr[6:0];
        funct3 = instr[14:12];
        funct7 = instr[31:25];
        destReg = instr[11:7];
        srcReg1 = instr[19:15];
        srcReg2 = instr[24:20];
        
        regWrite = controlSignals[5];
        aluSrc = controlSignals[4];
        branch = controlSignals[3];
        memRead = controlSignals[2];
        memWrite = controlSignals[1];
        memToReg = controlSignals[0];
    end

endmodule

module controller(
    instr,
    clk,
    controlSignals,
    aluOp,
    lwSw
);
    input [31:0] instr;
    input clk;

    output reg [5:0] controlSignals;
    output reg [1:0] aluOp;
    output reg [1:0] lwSw;

    reg [6:0] opcode;
    always @(posedge clk) begin
        opcode = instr[6:0];
        if (opcode == 7'b0110011) begin // R-type instruction
            controlSignals = 6'b100000;
            aluOp = 2'b10;
            lwSw = 2'b00;
        end else if (opcode == 7'b0010011) begin // I-type instruction
            controlSignals = 6'b110000;
            aluOp = 2'b10;
            lwSw = 2'b00;
        end else if (opcode == 7'b0000011) begin // Load instruction
            controlSignals = 6'b110101;
            aluOp = 2'b00;
            lwSw = 2'b10;
        end else if (opcode == 7'b0100011) begin // Store instruction
            controlSignals = 6'b010010;
            aluOp = 2'b00;
            lwSw = 2'b01;
        end else if (opcode == 7'b1100011) begin // Branch-type instruction
            controlSignals = 6'b001000;
            aluOp = 2'b01;
            lwSw = 2'b00;
        end else begin
            controlSignals = 6'b000000;
            aluOp = 2'b00;
            lwSw = 2'b00;
        end
    end
endmodule

module immGen (
    instr,
  	clk,
    imm
);
    input [31:0] instr;
    input clk;
    output reg [31:0] imm;

    reg [6:0] opcode;
    reg [11:0] nseImm; // without sign-extension
  
  	initial begin
      nseImm = 12'b0;
      imm = 32'b0;
    end

    always @(posedge clk) begin
        opcode = instr[6:0];
        if (opcode == 7'b0010011) begin // I-type instruction
          	nseImm[11:0] = instr[31:20];
        end else if (opcode == 7'b0000011) begin // Load instruction
          	nseImm[11:0] = instr[31:20];
        end else if (opcode == 7'b0100011) begin // Store instruction
          	nseImm[11:0] = {instr[31:25],instr[11:7]};
        end else if (opcode == 7'b1100011) begin // Branch-type instruction
          	nseImm[11:0] = {instr[31],instr[7],instr[30:25],instr[11:8]};
        end else begin
            nseImm = 12'b0;
        end
      imm[11:0] = nseImm[11:0];
      imm[31:12] = {20{nseImm[11]}};
    end
endmodule