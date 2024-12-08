`timescale 1ns / 1ps

module reorder_buffer_tb;
    // Inputs
    reg [5:0] old_dest_reg_0;
    reg [5:0] dest_reg_0;
    reg [31:0] dest_data_0;
    reg store_add_0;
    reg store_data_0;
    reg instr_PC_0;
    reg [31:0] complete_pc_0;
    reg [31:0] complete_pc_1;
    reg [31:0] complete_pc_2;
    reg [31:0] complete_pc_3;
    reg [31:0] new_dr_data_0;
    reg [31:0] new_dr_data_1;
    reg [31:0] new_dr_data_2;
    reg [31:0] new_dr_data_3;
    reg clk;
    reg [31:0] PC;
    reg rstn;

    // Outputs
    wire [5:0] out_add_1;
    wire [31:0] out_data_1;
    wire [5:0] out_add_2;
    wire [31:0] out_data_2;
    wire [1:0] stall;

    // Instantiate the Unit Under Test (UUT)
    reorder_buffer uut (
        .old_dest_reg_0(old_dest_reg_0),
        .dest_reg_0(dest_reg_0),
        .dest_data_0(dest_data_0),
        .store_add_0(store_add_0),
        .store_data_0(store_data_0),
        .instr_PC_0(instr_PC_0),
        .complete_pc_0(complete_pc_0),
        .complete_pc_1(complete_pc_1),
        .complete_pc_2(complete_pc_2),
        .complete_pc_3(complete_pc_3),
        .new_dr_data_0(new_dr_data_0),
        .new_dr_data_1(new_dr_data_1),
        .new_dr_data_2(new_dr_data_2),
        .new_dr_data_3(new_dr_data_3),
        .clk(clk),
        .PC(PC),
        .rstn(rstn),
        .out_add_1(out_add_1),
        .out_data_1(out_data_1),
        .out_add_2(out_add_2),
        .out_data_2(out_data_2),
        .stall(stall)
    );

    // Clock generation
        initial clk = 1'b0;
    always #5 clk = ~clk;
    initial begin
            rstn = 1'b1;
        #20  rstn = 1'b0;
        #10  rstn = 1'b1;
    end
    // Testbench logic
    initial begin
        // Initialize inputs
        clk = 0;
        rstn = 0;
        old_dest_reg_0 = 0;
        dest_reg_0 = 0;
        dest_data_0 = 0;
        store_add_0 = 0;
        store_data_0 = 0;
        instr_PC_0 = 0;
        complete_pc_0 = 0;
        complete_pc_1 = 0;
        complete_pc_2 = 0;
        complete_pc_3 = 0;
        new_dr_data_0 = 0;
        new_dr_data_1 = 0;
        new_dr_data_2 = 0;
        new_dr_data_3 = 0;
        PC = 0;

        // Apply reset
        #10 rstn = 1;

        // Add a new instruction to the reorder buffer
        #10 dest_reg_0 = 6'd1;
            old_dest_reg_0 = 6'd0;
            dest_data_0 = 32'h24;
            instr_PC_0 = 1;
        #10 dest_reg_0 = 6'd2;
            old_dest_reg_0 = 6'd1;
            dest_data_0 = 32'h32;
            instr_PC_0 = 1;

        // Mark instructions as complete
        #10 complete_pc_0 = 1;
            new_dr_data_0 = 32'h11;

        // Retire instructions
        #10 complete_pc_1 = 2;
            new_dr_data_1 = 32'h13;

        // Observe outputs
        #50;

        // Finish simulation
        $stop;
    end
endmodule
