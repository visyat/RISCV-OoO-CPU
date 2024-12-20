
`timescale 1ns / 1ps

module ARF (
    input clk, 
    input rstn,
    
    // can read 2 registers at the same time
    input [5:0] read_srcReg1,
    input [5:0] read_srcReg2,
    
    // can retire 2 instructions at the same time at max
    input retire1,
    input [5:0] write_addr1,
    input [31:0] write_data1,

    input retire2,
    input [5:0] write_addr2,
    input [31:0] write_data2,

    output reg [31:0] read_srcReg1_data,
    output reg [31:0] read_srcReg1_data
);

    reg [31:0] REGISTER_FILE [63:0];
    integer i;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i=0; i<64; i=i+1) begin
                REGISTER_FILE[i] <= 0;
            end
        end else begin
            if (retire1) begin 
                REGISTER_FILE[write_addr1] = write_data1;
            end
            if (retire2) begin
                REGISTER_FILE[write_addr2] = write_data2;
            end
        end
    end
    
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            read_srcReg1_data = 'b0;
            read_srcReg2_data = 'b0;
        end else begin
            read_data1 = REGISTER_FILE[read_addr1];
            read_data2 = REGISTER_FILE[read_addr2];
        end
    end

endmodule