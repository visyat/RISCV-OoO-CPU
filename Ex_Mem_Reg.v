`timescale 1ns/1ps

module EX_MEM_Reg (
    // inputs ...
    input clk,
    input rstn,

    // issue 1 ...
    input [31:0] PC_issue0_in,
    input [31:0] aluOutput_issue0_in,
    input [5:0] destReg_issue0_in,
    input [5:0] ROBNum_issue0_in,

    // issue 2 ...
    input [31:0] PC_issue1_in,
    input [31:0] aluOutput_issue1_in,
    input [5:0] destReg_issue1_in,
    input [5:0] ROBNum_issue1_in,
    
    // issue 3 ... possible LW/SW instructions 
    input [31:0] PC_issue2_in,
    input [31:0] aluOutput_issue2_in,
    input [5:0] destReg_issue2_in,
    input [5:0] ROBNum_issue2_in,

    // outputs ...
    // issue 1 ...
    output reg [31:0] PC_issue0_out,
    output reg [31:0] aluOutput_issue0_out,
    output reg [5:0] destReg_issue0_out,
    output reg [5:0] ROBNum_issue0_out,

    // issue 2 ...
    output reg [31:0] PC_issue1_out,
    output reg [31:0] aluOutput_issue1_out,
    output reg [5:0] destReg_issue1_out,
    output reg [5:0] ROBNum_issue1_out,

    // issue 3 ...
    output reg [31:0] PC_issue2_out,
    output reg [31:0] aluOutput_issue2_out,
    output reg [5:0] destReg_issue2_out,
    output reg [5:0] ROBNum_issue2_out
);
    
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            PC_issue0_out = 'b0;
            aluOutput_issue0_out = 'b0;
            destReg_issue0_out = 'b0;
            ROBNum_issue0_out = 'b0;

            PC_issue1_out = 'b0;
            aluOutput_issue1_out = 'b0;
            destReg_issue1_out = 'b0;
            ROBNum_issue1_out = 'b0;

            PC_issue2_out = 'b0;
            aluOutput_issue2_out = 'b0;
            destReg_issue2_out = 'b0;
            ROBNum_issue2_out = 'b0;

            PC_issue_LSQ_out = 'b0;
            address_LSQ_out = 'b0;
            destReg_lw_LSQ_out = 'b0;
            ROBNum_issue_LSQ_out = 'b0;
        end else begin
            PC_issue0_out = PC_issue0_in;
            aluOutput_issue0_out = aluOutput_issue0_in;
            destReg_issue0_out = destReg_issue0_in;
            ROBNum_issue0_out = ROBNum_issue0_in;

            PC_issue1_out = PC_issue1_in;
            aluOutput_issue1_out = aluOutput_issue1_in;
            destReg_issue1_out = destReg_issue1_in;
            ROBNum_issue1_out = ROBNum_issue1_in;

            PC_issue2_out = PC_issue2_in;
            aluOutput_issue2_out = aluOutput_issue2_in;
            destReg_issue2_out = destReg_issue2_in;
            ROBNum_issue2_out = ROBNum_issue2_in;
        end
    end

endmodule