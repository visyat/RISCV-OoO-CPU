`timescale 1ns/1ps

module MEM_C_Reg (
    input           clk,
    input           rstn,
    input           from_lsq,
    
    input [31:0]    lwData_from_LSQ_in,
    input [31:0]    lwData_from_MEM_in,
    input [31:0]    pc_from_LSU_in,
    input [31:0]    pc_from_MEM_in,

    output reg [31:0]   lwData_out,
    output reg [31:0]   pc_out

);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            lwData_out              <= 32'b0;
            pc_out                  <= 32'b0;
        end
        else begin
            if (from_lsq) begin
                lwData_out          <= lwData_from_LSQ_in;
                pc_out              <= pc_from_LSU_in;
            end
            else begin
                lwData_out          <= lwData_from_MEM_in;
                pc_out              <= pc_from_MEM_in;
            end
        end
    end

endmodule