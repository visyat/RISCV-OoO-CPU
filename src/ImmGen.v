module immGen (
    instr,
    rstn,
  	clk,
    imm
);
    input [31:0] instr;
    input rstn;
    input clk;
    output reg [31:0] imm;

    reg [6:0] opcode;
    reg [11:0] nseImm; // without sign-extension

    always @(*) begin
        if (~rstn)begin
            opcode      <= 7'b0;
            nseImm      <= 12'b0;
            imm         <= 32'b0;
        end
        else begin
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
    end
endmodule
