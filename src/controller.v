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
    always @(*) begin
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