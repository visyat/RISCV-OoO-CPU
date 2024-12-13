///////////////////////////////////////////////////////////////////
// Function: module for pipeline register between IF and ID stage
//
// Author: Yudong Zhou
//
// Create date: 11/16/2024
///////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module IF_ID_Reg (
    input           clk,
    input           rstn,
    
    input [31:0]    PC_in,
    input [31:0]    inst_IF_in,
    input           stop_in,

    output reg [31:0]   PC_out,
    output reg [31:0]   inst_ID_out,
    output reg          stop_out
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            inst_ID_out <= 32'b0;
            stop_out    <= 1'b0;
            PC_out <= 32'b0;
        end
        else begin
            inst_ID_out <= inst_IF_in;
            stop_out    <= stop_in;
            PC_out      <= PC_in;
        end
    end

endmodule
