
`timescale 1ns / 1ps

module ARF #(
    parameter   AR_SIZE     =   6,      
    parameter   AR_ARRAY    =   64   
)(
    input                       clk, 
    input                       rstn,
    // can read 2 registers at the same time
    input [AR_SIZE - 1 : 0]     read_addr1,
    input [AR_SIZE - 1 : 0]     read_addr2,
    input                       read_en,
    // can retire 2 instructions at the same time at max
    input [AR_SIZE - 1 : 0]     write_addr1,
    input [31 : 0]              write_data1,
    input [5 : 0]               old_addr1,
    input [AR_SIZE - 1 : 0]     write_addr2,
    input [31 : 0]              write_data2,
    input [5 : 0]               old_addr2,
    input write_back,
    input retire1,
    input retire2,

    output reg [31 : 0]         read_data1,
    output reg [31 : 0]         read_data2
);

    reg [31 : 0]    ar_file [AR_ARRAY - 1 : 0];
    integer         i;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            read_data1 <= 0;
            read_data2 <= 0;
            for (i = 0; i < AR_ARRAY; i = i + 1) begin
                ar_file[i] <= 0;
            end
        end
        else begin
            if (write_back) begin
                if (retire1) begin 
                    ar_file[write_addr1] = write_data1;
                    $display("reg p%d = %05d,   renamed reg is p%d,   Cycle NO: %04d", old_addr1, write_data1, write_addr1, ($time-5)/10);
                end
                if (retire2) begin
                    ar_file[write_addr2] = write_data2;
                    $display("reg p%d = %05d,   renamed reg is p%d,   Cycle NO: %04d", old_addr2, write_data2, write_addr2, ($time-5)/10);
                end
                // every time there is a update to the ARF, print the updated reg and value
            end
        end
    end

    always @(*) begin
        if (read_en) begin
            read_data1 = ar_file[read_addr1];
            read_data2 = ar_file[read_addr2];
        end
    end

endmodule