`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paige Larson
// 
// Create Date: 11/17/2024 12:47:31 PM
// Design Name: 
// Module Name: rename_tb
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


module rename_tb;
    // Testbench inputs
    reg [5:0] sr1; // Source register 1
    reg [5:0] sr2; // Source register 2
    reg [5:0] dr;  // Destination register
    
    // Testbench outputs
    wire [5:0] sr1_p; // Mapped source register 1
    wire [5:0] sr2_p; // Mapped source register 2
    wire [5:0] dr_p;  // Mapped destination register



    // Instantiate the rename module
    rename uut (
        .sr1(sr1),
        .sr2(sr2),
        .dr(dr),
        .sr1_p(sr1_p),
        .sr2_p(sr2_p),
        .dr_p(dr_p)


    );

    // Initialize and run test cases
    initial begin
        $display("Starting rename module testbench...");

        // Initialize inputs
        sr1 = 6'd1;
        sr2 = 6'd2;
        dr = 6'd3;

        // Apply first test
        #10;
        $display("Test 1 - Initial Rename:");
        $display("sr1 = %d, sr2 = %d, dr = %d", sr1, sr2, dr);
        $display("sr1_p = %d, sr2_p = %d, dr_p = %d", sr1_p, sr2_p, dr_p);

       
        sr1 = 6'd4;
        sr2 = 6'd3;
        dr = 6'd4;

        #10;
        $display("Test 2 - New Destination Register:");
        $display("sr1 = %d, sr2 = %d, dr = %d", sr1, sr2, dr);
        $display("sr1_p = %d, sr2_p = %d, dr_p = %d", sr1_p, sr2_p, dr_p);


        
        sr1 = 6'd5; // Check if original register mappings are preserved
        sr2 = 6'd2;
        dr = 6'd3;

        #10;
        $display("Test 3 - Re-use Source Registers:");
        $display("sr1 = %d, sr2 = %d, dr = %d", sr1, sr2, dr);
        $display("sr1_p = %d, sr2_p = %d, dr_p = %d", sr1_p, sr2_p, dr_p);

        
        sr1 = 6'd3;
        sr2 = 6'd9;
        dr = 6'd1;

        #10;
        $display("Test 4 - New Set of Registers:");
        $display("sr1 = %d, sr2 = %d, dr = %d", sr1, sr2, dr);
        $display("sr1_p = %d, sr2_p = %d, dr_p = %d", sr1_p, sr2_p, dr_p);

        // End simulation
        $display("Testbench complete.");
        $finish;
    end

endmodule
