`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paige Larson
// 
// Create Date: 11/25/2024 01:54:11 AM
// Design Name: 
// Module Name: reorder_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module reorder_buffer(
    input [1:0]         add_to_ROB,
    input [5:0]         old_dest_reg,
    input [5:0]         dest_reg,
    input [31:0]        dest_data,     
    input               complete,
    input               store_add,
    input               store_data,
    input               clk, 
    input [31:0]        PC,
    input               rstn,
    
    output reg [63:0]   ROB_reg_ready,
    output reg [1:0]    stall
    
    );

    // 1. multiple entries per cycle
    // 2. ROB_reg_ready determination
    // 3. signals like "complete", how to update
    
    reg [31:0] ROB [63:0] [7:0];

    // insert into ROB
    integer i;
    integer vals;
    
    always @(*) begin
        if (~rstn)begin
            for (i = 0; i < 64; i = i + 1) begin
                ROB[i][0] = 1'b0;    // whether or not slot is taken
                ROB[i][1] = 0;       // dest reg
                ROB[i][2] = 0;       // old dest reg
                ROB[i][3] = 0;       // current dest reg data
                ROB[i][4] = 0;       // store address in sw
                ROB[i][5] = 0;       // store imm val
                ROB[i][6] = 0;       // pc
                ROB[i][7] = 0;       // complete
            end
        end            
        else begin
            if(add_to_ROB == 1'b1) begin 
                for (i = 0; i < 64; i = i + 1) begin
                    if (ROB[i][0] == 1'b0) begin
                        ROB[i][0] = 1'b1; 
                        ROB[i][1] = dest_reg; 
                        ROB[i][2] = old_dest_reg;
                        ROB[i][3] = dest_data; 
                        ROB[i][4] = store_add; 
                        ROB[i][5] = store_data;
                        ROB[i][6] = PC; 
                        ROB[i][7] = complete;
                         
                        i = 65;         // Stop further looping
                    end
                end
                if (i == 65) begin
                    stall = 1'b1;       // stall if ROB is full
                end
            end
        end
    end

endmodule
