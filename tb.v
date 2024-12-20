
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2024 11:05:50 PM
// Design Name: 
// Module Name: tb
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

`timescale 1ns/1ps

module CPU_tb ();
    // set up parameters
	parameter   ResetValue	    = 2'b00;
	parameter   HalfCycle		= 10;				//Half of the Clock Period is 5 ns
	localparam  Cycle		    = 2 * HalfCycle;	//The length of the entire Clock Period

    reg clk;
    reg rstn;

    initial begin
        #(10 * Cycle)   $stop;
    end

    // clock source
    initial clk = 1'b0;
    always #(HalfCycle) clk = ~clk;

    CPU cpu(
        .clk(clk),
        .rstn(rstn)
    );

    initial begin
            rstn = 1'b1;
        #1  rstn = 1'b0;
        #1  rstn = 1'b1;
    end
    
    

endmodule