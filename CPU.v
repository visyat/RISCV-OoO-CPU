module CPU(
    clk
);
    input clk;
    //inputs
    wire [31:0] PC;
    wire [31:0] instr;
    wire stopReg;
    wire stop;

    //outputs
    wire [6:0] opcode;
    wire [2:0] funct3; 
    wire [6:0] funct7;
    wire [4:0] srcReg1;
    wire [4:0] srcReg2;
    wire [4:0] destReg;
    wire [31:0] imm; 
    wire [1:0] lwSw;
    wire [1:0] aluOp; 
    wire regWrite;
    wire aluSrc;
    wire branch;
    wire memRead;
    wire memWrite;
    wire memToReg;
    
    reg [5:0] sr1; // Source register 1
    reg [5:0] sr2; // Source register 2
    reg [5:0] dr;  // Destination register
    
    // Testbench outputs
    wire [5:0] sr1_p; // Mapped source register 1
    wire [5:0] sr2_p; // Mapped source register 2
    wire [5:0] dr_p;  // Mapped destination register
    wire s1_ready;    // Ready status for source 1
    wire s2_ready;    // Ready status for source 2

    reg [31:0] PC_reg;
    assign PC = PC_reg;
    
    instructionMemory instr_mem (
        .clk(clk),
        .PC(PC),
        .instr(instr),
        .stop(stopReg)
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
    rename uut (
        .sr1(sr1),
        .sr2(sr2),
        .dr(dr),
        .aluOp(aluOp),
        .imm(imm),
        .sr1_p(sr1_p),
        .sr2_p(sr2_p),
        .dr_p(dr_p),
        .s1_ready(s1_ready),
        .s2_ready(s2_ready)
        
        
    );
    
    initial begin
        PC_reg = 32'b0;
    end

    always @(posedge clk) begin
        if (!stop) begin
            // Fetching stage
            $display("Fetching ...");
            $display("Instruction: %0h", instr);

            // Decoding stage
            $display("Decoding ...");
            $display("Opcode: %0b, Funct3: %0b, Funct7: %0b, Rs1: %0b, Rs2: %0b, Rd: %0b ", opcode, funct3, funct7, srcReg1, srcReg2, destReg);

            // Renaming stage
            $display("Renaming ...");

            // Increment Program Counter
            PC_reg <= PC_reg + 4;
        end
    end

endmodule

