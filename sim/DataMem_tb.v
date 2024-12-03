`timescale 1ns/1ps

module dataMem_tb;

    reg clk;
    reg rstn;
    reg [31:0] address;
    reg [31:0] dataSw;
    reg memRead;
    reg memWrite;
    reg storeSize;
    reg cacheMiss;

    wire [31:0] lwData;

    dataMemory dm_mod(
        .clk(clk),
        .rstn(rstn),
        .address(address), 
        .dataSw(dataSw),
        .memRead(memRead),
        .memWrite(memWrite),
        .storeSize(storeSize),
        .cacheMiss(cacheMiss),
        .lwData(lwData)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;
    initial begin
            rstn = 1'b1;
        #1  rstn = 1'b0;
        #1  rstn = 1'b1;
    end

    initial begin
        // initialize signals to 0 
        address = 32'b0;
        dataSw = 32'b0;
        memRead = 0;
        memWrite = 0;
        storeSize = 0;
        cacheMiss = 0;

        // store instruction ...
        #10 begin
            address = 32'h0001;
            dataSw = 32'h1234;
            memRead = 0;
            memWrite = 1;
            storeSize = 0;
            cacheMiss = 1;
        end

        // load instruction ...
        #10 begin
            address = 32'h0001;
            dataSw = 32'b0;
            memRead = 1;
            memWrite = 0;
            storeSize = 0;
            cacheMiss = 1;
        end
    end

endmodule