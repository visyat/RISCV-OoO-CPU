////////////////////////////////////////////////////////////////////////////////////////////
// Function: module for Architectural Register File of RISC-V Out-of-Order Processor
//
// Author: Yudong Zhou
//
// Create date: 11/25/2024
////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ARF #(
    parameter   AR_SIZE     =   7,      // Architectural Register size = 2^7 = 128 registers
    parameter   AR_ARRAY    =   128,    // AR number = 128
)(
    input                       rstn,
    // can read 2 instructions at the same time at max
    input [AR_SIZE - 1 : 0]     read_addr1,
    input [AR_SIZE - 1 : 0]     read_addr2,
    input                       read_en,
    // can retire 3 instructions at the same time at max
    input [AR_SIZE - 1 : 0]     write_addr1,
    input [31 : 0]              write_data1,
    input [AR_SIZE - 1 : 0]     write_addr2,
    input [31 : 0]              write_data2,
    input [AR_SIZE - 1 : 0]     write_addr3,
    input [31 : 0]              write_data3,
    input                       write_en,

    output reg [31 : 0]         read_data1,
    output reg [31 : 0]         read_data2,
);

    reg [31 : 0]    ar_file [AR_ARRAY - 1 : 0];
    integer         i;
    always @(*) begin
        if (~rstn) begin
            read_data1 <= 0;
            read_data2 <= 0;
            for (i = 0; i < AR_ARRAY; i = i + 1) begin
                ar_file[i] <= 0;
            end
        end
        else begin // might have problem for simutaneous read and write
            if (read_en) begin
                read_data1 <= ar_file[read_addr1];
                read_data2 <= ar_file[read_addr2];
            end
            if (write_en) begin
                ar_file[write_addr1] <= write_data1;
                ar_file[write_addr2] <= write_data2;
                ar_file[write_addr3] <= write_data3;
            end
        end
    end

endmodule
