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
    input               [1:0] add_to_ROB,
    input               [5:0] old_dest_reg,
    input               [5:0] dest_reg,
    input               [31:0] dest_data,     
    input               complete,
    input               store_add,
    input               store_data,
    input               clk, 
    input [31 : 0]      PC,
    input               rstn,
    
    output reg [31:0] ROB [63:0] [7:0], //64 rows of 8
    output reg [1:0] stall
    
    );
    
    
    //to insert into ROB
    integer i;
    integer vals;
    
    always @(*) begin
        if (~rstn)begin
            ROB[i][0]= 1'b0; //whether or not slot is taken
            ROB[i][1]= 0; //dest reg
            ROB[i][2]= 0; // old dest reg
            ROB[i][3]= 0; //current dest reg data
            ROB[i][4]= 0; //store address in sw
            ROB[i][5]= 0; //store imm val
            ROB[i][6]= 0; //pc
            ROB[i][7]= 0; //complete
            
            
            i=64;          // Stop further looping
        end            
        else begin
            if(add_to_ROB==1'b1) begin 
                for (i = 0; i < 64; i = i + 1) begin
                    if (ROB[i][0] == 1'b0) begin
                        ROB[i][0]= 1'b1; //whether or not slot is taken
                        ROB[i][1]= dest_reg; //dest reg
                        ROB[i][2]= old_dest_reg; // old dest reg
                        ROB[i][3]= dest_data; //current dest reg data
                        ROB[i][4]= store_add; //store address in sw
                        ROB[i][5]= store_data; //imm val
                        ROB[i][6]= PC; //pc
                        ROB[i][7]= complete; //complete
                        
                        
                        i=64;          // Stop further looping
                    end
                    else begin
                        stall=1'b1;
                    end
                end
            end
        end
    end
    
    
endmodule
