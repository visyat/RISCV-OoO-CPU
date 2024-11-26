////////////////////////////////////////////////////////////////////////////////////////////
// Function: module for Unified_Issue_Queue of RISC-V Out-of-Order Processor
//
// Author: Yudong Zhou
//
// Create date: 11/9/2024
//
// RS implementation:
// | valid | Opeartion | Dest Reg | Src Reg1 | Src1 Ready | Src Reg2 | Src2 Ready | imm | FU# | ROB# |
//                                |  Data from ARF Reg1   |   Data from ARF Reg2  |
////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module Unified_Issue_Queue #(
    parameter   RS_SIZE     =   16,     // RS size  = 16 instructions
    parameter   AR_SIZE     =   7,      // Architectural Register size = 2^7 = 128 registers
    parameter   AR_ARRAY    =   128,    // AR number = 128
    parameter   FU_SIZE     =   2,      // FU size  = 2^2 >= 3 units
    parameter   FU_ARRAY    =   3,      // FU number = 3
    parameter   ISSUE_NUM   =   3       // can issue 3 instructions max at the same time
)(
    input                       clk,
    input                       rstn,   // negedge reset

    // decode info
    input [6 : 0]               opcode_in,
    input [2 : 0]               funct3_in,
    input [6 : 0]               funct7_in,

    // Rename & ARF info
    input [AR_SIZE - 1 : 0]     rs1_in, // register name after rename
    input [31 : 0]              rs1_value_from_ARF_in,
    input [AR_SIZE - 1 : 0]     rs2_in,
    input [31 : 0]              rs2_value_from_ARF_in,
    input [31 : 0]              imm_value_in,
    input [AR_SIZE - 1 : 0]     rd_in,

    input [AR_ARRAY : 0]        rs1_ready_from_ROB_in,
    input [AR_ARRAY : 0]        rs2_ready_from_ROB_in,
                                // if reg pi is ready, then rs_ready_from_ROB_in[i] = 1

    // forwarding logic
    input [FU_ARRAY - 1 : 0]    fu_ready_from_FU_in,     
                                // if FU NO.i is ready, then fu_ready_from_ROB_in[i-1] = 1
    input                       FU0_flag_in, // if FU0 is outputing value, then FU0_flag_in = 1
    input [AR_SIZE - 1 : 0]     reg_tag_from_FU0_in,   
    input [31 : 0]              reg_value_from_FU0_in,
    input                       FU1_flag_in,
    input [AR_SIZE - 1 : 0]     reg_tag_from_FU1_in,   
    input [31 : 0]              reg_value_from_FU1_in,
    input                       FU2_flag_in,
    input [AR_SIZE - 1 : 0]     reg_tag_from_FU2_in,   
    input [31 : 0]              reg_value_from_FU2_in,

    // whether dispatch
    //input                       en_dispatch_in,
    
    // output signals
    // issue NO.1
    output reg [AR_SIZE - 1 : 0]        rs1_out0,
    output reg [AR_SIZE - 1 : 0]        rs2_out0,
    output reg [AR_SIZE - 1 : 0]        rd_out0,
    output reg [31 : 0]                 rs1_value_out0,
    output reg [31 : 0]                 rs2_value_out0,
    output reg [31 : 0]                 imm_value_out0,
    output reg [FU_SIZE - 1 : 0]        fu_number_out0,  
    // issue NO.2
    output reg [AR_SIZE - 1 : 0]        rs1_out1,
    output reg [AR_SIZE - 1 : 0]        rs2_out1,
    output reg [AR_SIZE - 1 : 0]        rd_out1,
    output reg [31 : 0]                 rs1_value_out1,
    output reg [31 : 0]                 rs2_value_out1,
    output reg [31 : 0]                 imm_value_out1,
    output reg [FU_SIZE - 1 : 0]        fu_number_out1, 
    // issue NO.3
    output reg [AR_SIZE - 1 : 0]        rs1_out2,
    output reg [AR_SIZE - 1 : 0]        rs2_out2,
    output reg [AR_SIZE - 1 : 0]        rd_out2,
    output reg [31 : 0]                 rs1_value_out2,
    output reg [31 : 0]                 rs2_value_out2,
    output reg [31 : 0]                 imm_value_out2,
    output reg [FU_SIZE - 1 : 0]        fu_number_out2, 

    // control signals for next stage
    output reg                          no_issue_out, 
                                        // if no instruction can be issued, then no_issue_out = 1
    output reg                          stall_out,
    output reg [2 : 0]                  tunnel_out 
                                        // if tunnel(FU) i is used, then tunnel[i-1] = 1
);

    /////////////////////////////////////////////////////////////////

    // operation parameter
    parameter ADD   =  4'd1;
    parameter ADDI  =  4'd2;
    parameter LUI   =  4'd3;
    parameter ORI   =  4'd4;
    parameter XOR   =  4'd5;
    parameter SRAI  =  4'd6;
    parameter LB    =  4'd7;
    parameter LW    =  4'd8;
    parameter SB    =  4'd9;
    parameter SW    =  4'd10;

    /////////////////////////////////////////////////////////////////

    // operation info
    reg                         valid       [RS_SIZE - 1 : 0];
    reg [3 : 0]                 operation   [RS_SIZE - 1 : 0];

    // instruction info
    reg [AR_SIZE - 1 : 0]       dest_reg    [RS_SIZE - 1 : 0];
    reg [AR_SIZE - 1 : 0]       src_reg1    [RS_SIZE - 1 : 0];
    reg [31 : 0]                src1_data   [RS_SIZE - 1 : 0];
    reg                         src1_ready  [RS_SIZE - 1 : 0];
    reg [AR_SIZE - 1 : 0]       src_reg2    [RS_SIZE - 1 : 0];
    reg [31 : 0]                src2_data   [RS_SIZE - 1 : 0];
    reg                         src2_ready  [RS_SIZE - 1 : 0];
    reg [31 : 0]                imm         [RS_SIZE - 1 : 0];
    
    // FU info
    reg [FU_SIZE - 1 : 0]       fu_number   [RS_SIZE - 1 : 0];

    // initializations
    integer                     i               = 0;
    reg [1 : 0]                 fu_alu_round    = 0;

    // update ready signals
    integer                     k               = 0; 

    // output logic
    integer                     j               = 0;
    reg [1 : 0]                 issue_count     = 0;
    reg                         fu_taken        [FU_ARRAY - 1 : 0];

    reg [AR_SIZE - 1 : 0]       rs1_out         [2 : 0];
    reg [AR_SIZE - 1 : 0]       rs2_out         [2 : 0];
    reg [AR_SIZE - 1 : 0]       rd_out          [2 : 0];
    reg [31 : 0]                rs1_value_out   [2 : 0];
    reg [31 : 0]                rs2_value_out   [2 : 0];
    reg [31 : 0]                imm_value_out   [2 : 0];
    reg [FU_SIZE - 1 : 0]       fu_number_out   [2 : 0];

    /////////////////////////////////////////////////////////////////
    
    // operation judgement
    reg [3 : 0] op_type;
    always @(*) begin
        if (~rstn) begin
            op_type <= 4'd0;
        end
        else begin
            op_type = 4'd0;
            case (opcode_in)
                7'b0110011: begin // R-type
                    case (funct3_in)
                        3'b000: op_type = ADD;
                    endcase
                end
                7'b0010011: begin // I-type
                    case (funct3_in)
                        3'b000: op_type = ADDI;
                        3'b100: op_type = XOR;
                        3'b101: op_type = SRAI;
                        3'b110: op_type = ORI;
                    endcase
                end
                7'b0110111: op_type = LUI; // U-type
                7'b0000011: begin // Load
                    case (funct3_in)
                        3'b000: op_type = LB;
                        3'b010: op_type = LW;
                    endcase
                end
                7'b0100011: begin // Store
                    case (funct3_in)
                        3'b000: op_type = SB;
                        3'b010: op_type = SW;
                    endcase
                end
            endcase
        end
    end

    // initializations and dispatch in RS
    always @(posedge clk or negedge rstn) begin
        stall_out <= 1'b0;
        if (~rstn) begin
            for (i = 0; i < RS_SIZE; i = i + 1) begin
                valid[i]        <= 'b0;
                operation[i]    <= 'b0;
                dest_reg[i]     <= 'b0;
                src_reg1[i]     <= 'b0;
                src1_data[i]    <= 'b0;
                src1_ready[i]   <= 'b0;
                src_reg2[i]     <= 'b0;
                src2_data[i]    <= 'b0;
                src2_ready[i]   <= 'b0;
                imm[i]          <= 'b0;
                fu_number[i]    <= 'b0;
            end
        end
        else begin
            for (i = 0; i < RS_SIZE; i = i + 1) begin 
                if (~valid[i]) begin
                    valid[i]        <= 1'b1;
                    operation[i]    <= op_type;
                    dest_reg[i]     <= rd_in;

                    // put src1 data into RS
                    src_reg1[i]     <= rs1_in;
                    if(rs1_ready_from_ROB_in[rs1_in]) begin
                        src1_ready[i]   <= 1'b1;
                        src1_data[i]    <= rs1_value_from_ARF_in;
                    end

                    // put src2 data into RS
                    src_reg2[i]     <= rs2_in;
                    if(rs2_ready_from_ROB_in[rs2_in]) begin
                        src2_ready[i]   <= 1'b1;
                        src2_data[i]    <= rs2_value_from_ARF_in;
                    end

                    // put imm into RS
                    imm[i]          <= imm_value_in;

                    // round robin
                    fu_number[i]    <= fu_alu_round;
                    fu_alu_round    =  fu_alu_round + 1;
                    if (fu_alu_round == 2'd3)  fu_alu_round = 2'b0;    // stall if no FU is ready

                    // if already dispatched an instruction, break
                    i = RS_SIZE + 1; 
                end
            end
            if (i == RS_SIZE) stall_out <= 1'b1;    // stall if RS is full
        end
    end
    
    // update source_ready & source_data signals
    always @(posedge clk) begin
        for (k = 0; k < RS_SIZE; k = k + 1) begin
            if (valid[k]) begin
                if ((src_reg1[k] == reg_tag_from_FU0_in) && FU0_flag_in) begin
                    src1_ready[k] <= 1'b1;
                    src1_data[k]  <= reg_value_from_FU0_in;
                end
                else if ((src_reg1[k] == reg_tag_from_FU1_in) && FU1_flag_in) begin
                    src1_ready[k] <= 1'b1;
                    src1_data[k]  <= reg_value_from_FU1_in;
                end
                else if ((src_reg1[k] == reg_tag_from_FU2_in) && FU2_flag_in) begin
                    src1_ready[k] <= 1'b1;
                    src1_data[k]  <= reg_value_from_FU2_in;
                end

                if ((src_reg2[k] == reg_tag_from_FU0_in) && FU0_flag_in) begin
                    src2_ready[k] <= 1'b1;
                    src2_data[k]  <= reg_value_from_FU_in;
                end
                else if ((src_reg2[k] == reg_tag_from_FU1_in) && FU1_flag_in) begin
                    src2_ready[k] <= 1'b1;
                    src2_data[k]  <= reg_value_from_FU1_in;
                end
                else if ((src_reg2[k] == reg_tag_from_FU2_in) && FU2_flag_in) begin
                    src2_ready[k] <= 1'b1;
                    src2_data[k]  <= reg_value_from_FU2_in;
                end
            end
        end
    end

    // output issue signals to FU
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (j = 0; j < 3; j = j + 1) begin
                rs1_out[j]          <= 'b0;
                rs2_out[j]          <= 'b0;
                rd_out[j]           <= 'b0;
                rs1_value_out[j]    <= 'b0;
                rs2_value_out[j]    <= 'b0;
                imm_value_out[j]    <= 'b0;
                fu_number_out[j]    <= 'b0;
                tunnel_out[j]       <= 'b0;
            end
        end
        else begin
            // whether a fu is taken within this cycle
            for (j = 0; j < 3; j = j + 1) begin
                fu_taken[j]         = 0;
                tunnel_out[j]       = 0;
            end
            // issue_count reset
            issue_count         = 0;
            // no_issue_out reset
            no_issue_out        = 1;
            
            for (j = 0; j < RS_SIZE; j = j + 1) begin
                if (valid[j] && src1_ready[j] && src2_ready[j] && fu_ready_from_FU_in[fu_number[j]]
                    && (~fu_taken[fu_number[j]])) begin
                    // output signals
                    rs1_out[fu_number[j]]           = src_reg1[j];
                    rs2_out[fu_number[j]]           = src_reg2[j];
                    rd_out[fu_number[j]]            = dest_reg[j];
                    rs1_value_out[fu_number[j]]     = src1_data[j];
                    rs2_value_out[fu_number[j]]     = src2_data[j];
                    imm_value_out[fu_number[j]]     = imm[j];
                    fu_number_out[fu_number[j]]     = fu_number[j];
                    // clear RS
                    valid[j]                        <= 1'b0;
                    // select tunnel(FU)
                    tunnel_out[fu_number[j]]        <= 1;
                    // issue_count increase
                    issue_count                     = issue_count + 1;
                    // mark which FU as taken
                    fu_taken[fu_number[j]]          = 1;
                    // no need to stall
                    no_issue_out                    = 0;

                    // if already issued 3 instructions, break
                    if (issue_count == 2)           j = RS_SIZE + 1;
                end
            end
        end

        rs1_out0            <= rs1_out[0];
        rs2_out0            <= rs2_out[0];
        rd_out0             <= rd_out[0];
        rs1_value_out0      <= rs1_value_out[0];
        rs2_value_out0      <= rs2_value_out[0];
        imm_value_out0      <= imm_value_out[0];
        fu_number_out0      <= fu_number_out[0];

        rs1_out1            <= rs1_out[1];
        rs2_out1            <= rs2_out[1];
        rd_out1             <= rd_out[1];
        rs1_value_out1      <= rs1_value_out[1];
        rs2_value_out1      <= rs2_value_out[1];
        imm_value_out1      <= imm_value_out[1];
        fu_number_out1      <= fu_number_out[1];

        rs1_out2            <= rs1_out[2];
        rs2_out2            <= rs2_out[2];
        rd_out2             <= rd_out[2];
        rs1_value_out2      <= rs1_value_out[2];
        rs2_value_out2      <= rs2_value_out[2];
        imm_value_out2      <= imm_value_out[2];
        fu_number_out2      <= fu_number_out[2];
    end

endmodule
