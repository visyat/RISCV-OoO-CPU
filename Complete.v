`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Paige Larson
// 
// Create Date: 12/19/2024 07:30:19 PM
// Design Name: 
// Module Name: complete
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

module complete(
    input clk,
    input rstn,
    
    input [31:0] PC_complete0_out,
    input [5:0] destReg_complete0_out, 
    input [31:0] destReg_data_complete0_out,
    input [5:0] ROBNum_complete0_out, 

    input [31:0] PC_complete1_out,
    input [5:0] destReg_complete1_out, 
    input [31:0] destReg_data_complete1_out,
    input [5:0] ROBNum_complete1_out, 

    input [31:0] PC_complete2_out,
    input [5:0] destReg_complete2_out, 
    input [31:0] destReg_data_complete2_out,
    input [5:0] ROBNum_complete2_out, 
    
    
    
    output reg [31:0] complete_pc_0,
    output reg [31:0] complete_pc_1,
    output reg [31:0] complete_pc_2,
    
    output reg [31:0] new_dr_data_0,
    output reg [31:0] new_dr_data_1,
    output reg [31:0] new_dr_data_2,
    
    output reg [5:0] complete_dr_0,
    output reg [5:0] complete_dr_1,
    output reg [5:0] complete_dr_2,
    
    output reg [5:0] ROB_complete_0,
    output reg [5:0] ROB_complete_1.
    output reg [5:0] ROB_complete_2
    
    );
    
    always @(posedge clk) begin
        complete_pc_0 <= PC_complete0_out;
        complete_pc_1 <= PC_complete1_out;
        complete_pc_2 <= PC_complete2_out;  
        
        new_dr_data_0 <=destReg_data_complete0_out;
        new_dr_data_1 <=destReg_data_complete1_out;
        new_dr_data_2 <=destReg_data_complete2_out;
       
        complete_dr_0 <=destReg_complete0_out;
        complete_dr_1 <=destReg_complete1_out;
        complete_dr_2 <=destReg_complete2_out;
        
        ROB_complete_0 <=ROBNum_complete_0;
        ROB_complete_1 <=ROBNum_complete_1;
        ROB_complete_2 <=ROBNum_complete_2;
    end
    
    
    
    
endmodule
