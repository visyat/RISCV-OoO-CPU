`timescale 1ns/1ps

module EX_MEM_Reg (
    input           clk,
    input           rstn,
    input [2 : 0]   tunnel_in,
    input [31 : 0]  rd_result_fu0_in,
    input [31 : 0]  pc_fu0_in,
    input [31 : 0]  rd_result_fu1_in,
    input [31 : 0]  pc_fu1_in,
    input [31 : 0]  rd_result_fu2_in,
    input [31 : 0]  pc_fu2_in,
    input [31:0]    pc_lsu_in,
    input [31:0]    result_lsu_in,
    input           op_write_in,
    input           op_read_in,
    input [3 : 0]   op_in,

    output reg [2 : 0]   tunnel_out,
    output reg [31 : 0]  rd_result_fu0_out,
    output reg [31 : 0]  pc_fu0_out,
    output reg [31 : 0]  rd_result_fu1_out,
    output reg [31 : 0]  pc_fu1_out,
    output reg [31 : 0]  rd_result_fu2_out,
    output reg [31 : 0]  pc_fu2_out,
    output reg [31:0]    pc_lsu_out,
    output reg [31:0]    result_lsu_out,
    output reg           op_write_out,
    output reg           op_read_out,
    output reg [3 : 0]   op_out
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            rd_result_fu0_out   <= 'd0;
            pc_fu0_out          <= 'd0;
            rd_result_fu1_out   <= 'd0;
            pc_fu1_out          <= 'd0;
            rd_result_fu2_out   <= 'd0;
            pc_fu2_out          <= 'd0;
            pc_lsu_out          <= 'd0;
            result_lsu_out      <= 'd0;
            //isLS_fu2_out        <= 'd0;
            op_write_out        <= 'd0;
            op_read_out         <= 'd0;
            op_out              <= 'd0;
            tunnel_out          <= 'd0;
        end
        else begin
            rd_result_fu0_out   <= rd_result_fu0_in;
            pc_fu0_out          <= pc_fu0_in;
            rd_result_fu1_out   <= rd_result_fu1_in;
            pc_fu1_out          <= pc_fu1_in;
            rd_result_fu2_out   <= rd_result_fu2_in;
            pc_fu2_out          <= pc_fu2_in;
            pc_lsu_out          <= pc_lsu_in;
            result_lsu_out      <= result_lsu_in;
            //isLS_fu2_out        <= isLS_fu2_in;
            op_write_out        <= op_write_in;
            op_read_out         <= op_read_in;
            op_out              <= op_in;
            tunnel_out          <= tunnel_in;
        end
    end

endmodule