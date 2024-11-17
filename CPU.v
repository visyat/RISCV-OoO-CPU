module CPU(
    clk
);
    input clk;
    reg [31:0] PC;

    reg [31:0] instr;
    reg stop;

    reg [6:0] opcode;
    reg [2:0] funct3; 
    reg [6:0] funct7;
    reg [4:0] srcReg1;
    reg [4:0] srcReg2;
    reg [4:0] destReg;
    reg [31:0] imm; 
    reg [1:0] lwSw;
    reg [1:0] aluOp; 
    reg regWrite;
    reg aluSrc;
    reg branch;
    reg memRead;
    reg memWrite;
    reg memToReg;

    instructionMemory instrMem_mod (
        .clk(clk),
        .PC(PC),
        .instr(instr),
        .stop(stop)
    );
    decode decode_mod(
        .instr(instr),
        .clk(clk),
        .opcode(opcode),
        .funct3(funct3), 
        .funct7(funct7), 
        .srcReg1(srcReg1),
        .srcReg2(srcReg2),
        .destReg(destReg),
        .imm(imm), 
        .lwSw(lwSw),
        .aluOp(aluOp),
        .regWrite(regWrite),
        .aluSrc(aluSrc),
        .branch(branch),
        .memRead(memRead),
        .memWrite(memWrite),
        .memToReg(memToReg)
    );
    initial begin
        PC = 32'b0;
    end

endmodule