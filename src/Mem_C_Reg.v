`timescale 1ns/1ps

module MEM_C_Reg (
    // inputs ...
    input clk,
    input rstn,

    input [31:0] PC_issue0_in,
    input [31:0] aluOutput_issue0_in,
    input [5:0] destReg_issue0_in,
    input [5:0] ROBNum_issue0_in,

    input [31:0] PC_issue1_in,
    input [31:0] aluOutput_issue1_in,
    input [5:0] destReg_issue1_in,
    input [5:0] ROBNum_issue1_in,

    input [31:0] PC_issue2_in,
    input [3:0] optype_issue2_in, 
    input [31:0] aluOutput_issue2_in,
    input [5:0] destReg_issue2_in,
    input [5:0] ROBNum_issue2_in,    

    input [31:0] PC_issue_LSQ_in,
    input loadStore_LSQ_in,
    input fromLSQ_in,
    input cacheMiss_in,
    input [31:0] lwData_LSQ_in,
    input [31:0] lwData_cache_in,
    input [31:0] lwData_datamem_in,
    input [5:0] destReg_issue_LSQ_in,
    input [5:0] ROBNum_issue_LSQ_in,

    input [31:0] PC_issue_dataMem_in,
    input [5:0] ROBNum_issue_dataMem_in, 

    // outputs ...
    output reg [31:0] PC_complete0_out,
    output reg [5:0] destReg_complete0_out, 
    output reg [31:0] destReg_data_complete0_out,
    output reg [5:0] ROBNum_complete0_out, 

    output reg [31:0] PC_complete1_out,
    output reg [5:0] destReg_complete1_out, 
    output reg [31:0] destReg_data_complete1_out,
    output reg [5:0] ROBNum_complete1_out, 

    output reg [31:0] PC_complete2_out,
    output reg [5:0] destReg_complete2_out, 
    output reg [31:0] destReg_data_complete2_out,
    output reg [5:0] ROBNum_complete2_out 
);
    reg [31:0] storeBuffer [0:15];
    integer i, j;

    // operation parameter
    parameter LB    =  4'd7;
    parameter LW    =  4'd8;
    parameter SB    =  4'd9;
    parameter SW    =  4'd10;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            PC_complete0_out = 'b0;
            destReg_complete0_out = 'b0;
            destReg_data_complete0_out = 'b0;
            ROBNum_complete0_out = 'b0;

            PC_complete1_out = 'b0;
            destReg_complete1_out = 'b0;
            destReg_data_complete1_out = 'b0;
            ROBNum_complete1_out = 'b0;

            PC_complete2_out = 'b0;
            destReg_complete2_out = 'b0;
            destReg_data_complete2_out = 'b0;
            ROBNum_complete2_out = 'b0;
        end else begin
            PC_complete0_out = PC_issue0_in;
            destReg_complete0_out = destReg_issue0_in;
            destReg_data_complete0_out = aluOutput_issue0_in;
            ROBNum_complete0_out = ROBNum_issue0_in;

            PC_complete1_out = PC_issue1_in;
            destReg_complete1_out = destReg_issue1_in;
            destReg_data_complete1_out = aluOutput_issue1_in;
            ROBNum_complete1_out = ROBNum_issue1_in;

            if (optype_issue2_in != LB && optype_issue2_in != LW && optype_issue2_in != SB && optype_issue2_in != SW) begin
                PC_complete2_out = PC_issue2_in;
                destReg_complete2_out = destReg_issue2_in;
                destReg_data_complete2_out = aluOutput_issue2_in;
                ROBNum_complete2_out = ROBNum_issue2_in;
            end
        end
    end
    always @(*) begin
        if (PC_issue_LSQ_in && ~loadStore_LSQ_in) begin
            PC_complete2_out = PC_issue_LSQ_in; 
            destReg_complete2_out = destReg_issue_LSQ_in;
            ROBNum_complete2_out = ROBNum_issue_LSQ_in;
            if (fromLSQ_in) begin
                destReg_data_complete2_out = lwData_LSQ_in;
            end else if (~cacheMiss_in) begin
                destReg_data_complete2_out = lwData_cache_in;
            end else begin
                destReg_data_complete2_out = lwData_datamem_in;
            end
        end
    end
    always @(*) begin
        if (PC_issue_dataMem_in) begin
            PC_complete2_out = PC_issue_dataMem_in;
            ROBNum_complete2_out = ROBNum_issue_dataMem_in;
            destReg_complete2_out = 'b0;
            destReg_data_complete2_out = 'b0;
        end
    end

endmodule