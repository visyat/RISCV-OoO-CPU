`timescale 1ns/1ps

module MEM_C_Reg (
    input           clk,
    input           rstn,
    input           from_lsq,
    input           mem_vaild,

    input [31:0]    lwData_from_LSQ_in,
    input [31:0]    lwData_from_MEM_in,
    input [31:0]    pc_from_LSU_in,
    input [31:0]    pc_from_MEM_in,
    input           FU_write_flag,
    input           FU_read_flag,
    input           FU_read_flag_MEM,

    output reg [31:0]   lwData_out,
    output reg [31:0]   pc_out,
    output reg          vaild_out,
    output reg          lsq_out,
    output reg          FU_write_flag_com,
    output reg          FU_read_flag_com,
    output reg          FU_read_flag_MEM_com
);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            lwData_out              <= 32'b0;
            pc_out                  <= 32'b0;
            vaild_out               <= 1'b0;
            lsq_out                 <= 1'b0;
            FU_write_flag_com       <= 1'b0;
            FU_read_flag_com        <= 1'b0;
            FU_read_flag_MEM_com    <= 1'b0;
        end
        else begin
            if (from_lsq) begin
                lwData_out          <= lwData_from_LSQ_in;
                pc_out              <= pc_from_LSU_in;
            end
            else if (mem_vaild) begin
                lwData_out          <= lwData_from_MEM_in;
                pc_out              <= pc_from_MEM_in;
            end
            vaild_out               <= mem_vaild;
            lsq_out                 <= from_lsq;
            FU_write_flag_com       <= FU_write_flag;
            FU_read_flag_com        <= FU_read_flag;
            FU_read_flag_MEM_com    <= FU_read_flag_MEM;
        end
    end

endmodule