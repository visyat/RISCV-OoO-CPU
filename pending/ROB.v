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
    input               [5:0] old_dest_reg,
    input               [5:0] dest_reg,     
    input               complete,
    input               clk, 
    input [31 : 0]      PC,
    input               rstn,
    
    output reg [31:0] ROB [63:0] [4:0]
    
    );
    
    
    //to insert into ROB
    integer i;
    integer vals;
    
    always @(*) begin
        for (i = 0; i < 64; i = i + 1) begin
            if (ROB[i][0] == 1'b0) begin
                ROB[i][0]= 1'b1; //whether or not slot is taken
                ROB[i][1]= dest_reg; //dest reg
                ROB[i][1]= old_dest_reg; // old dest reg
                ROB[i][1]= PC; //pc
                ROB[i][1]= complete; //complete
                
                
                i=64;          // Stop further looping
            end
        end
    end
    
    
endmodule


/*
module reorder_buffer(
    input clk,
    input reset,
    
    // New instruction inputs
    input instruction_valid,
    input [5:0] dest_reg,
    input [31:0] value,
    input ready,
    
    // Commit control signal
    input commit,

    // Outputs for committing results
    output reg [5:0] commit_reg,
    output reg [31:0] commit_value,
    output reg commit_valid
);

    // Parameters
    parameter ROB_SIZE = 16;

    // Reorder Buffer Entry Structure
    typedef struct {
        reg [5:0] dest_reg;
        reg [31:0] value;
        reg ready;
        reg valid;
    } rob_entry;

    // Reorder Buffer Array
    rob_entry rob[ROB_SIZE-1:0];

    // Head and Tail pointers for circular buffer
    integer head, tail;

    // Reset and initialize the reorder buffer
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            head <= 0;
            tail <= 0;
            commit_valid <= 1'b0;
            commit_reg <= 6'd0;
            commit_value <= 32'd0;
            
            // Clear all entries in the reorder buffer
            for (i = 0; i < ROB_SIZE; i = i + 1) begin
                rob[i].valid <= 1'b0;
                rob[i].ready <= 1'b0;
            end
        end else begin
            // Add new instruction to the reorder buffer
            if (instruction_valid && (rob[tail].valid == 1'b0)) begin
                rob[tail].dest_reg <= dest_reg;
                rob[tail].value <= value;
                rob[tail].ready <= ready;
                rob[tail].valid <= 1'b1;
                tail <= (tail + 1) % ROB_SIZE;
            end
            
            // Commit an instruction if ready and `commit` signal is asserted
            if (commit && rob[head].valid && rob[head].ready) begin
                commit_reg <= rob[head].dest_reg;
                commit_value <= rob[head].value;
                commit_valid <= 1'b1;
                
                // Clear the entry and move the head pointer
                rob[head].valid <= 1'b0;
                rob[head].ready <= 1'b0;
                head <= (head + 1) % ROB_SIZE;
            end else begin
                commit_valid <= 1'b0;
            end
        end
    end
endmodule  
*/
