`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Paige Larson
// 
// Create Date: 11/25/2024 02:30:50 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
//inputs: clk, restart
        // in an array for each instr: data from src1 and src2/imm, aluOp, which FU they go to 
input clk, 
input rstn,
input [31:0] data_in [2:0] [3:0],

//outputs: data for dest reg
output reg [31:0] data_out [2:0]
    );
    
    reg FU [2:0];
        
    integer i;
    always @(posedge clk or negedge rstn) begin
            if (~rstn)begin
                FU[0]=1'b0;
                FU[1]=1'b0;
                FU[2]=1'b0;
            end 
            else begin
                for (i=0; i<2; i=i+1) begin
                    if(FU[data_in[i][3]])begin
                        FU[data_in[i][3]]=1'b1;
                        //TODO: 
                        //run actual alu store in data_out[i]
                        
                            //huge switch statement to determine alu type via alu op
                            if(data_in[i][2]=)
                        
                        data_out[i]=31'b0;
                    end
                end
            end
    end
endmodule



