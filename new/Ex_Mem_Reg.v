///////////////////////////////////////////////////////////////////
// Function: module for pipeline register between EX and MEM stage
//
// Author: Yudong Zhou
//
// Create date: 11/16/2024
///////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module EX_MEM_Reg (
    input           clk,
    input           rstn

    
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            
        end
        else begin
            
        end
    end

endmodule