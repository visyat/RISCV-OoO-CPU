`timescale 1ns/1ps

/*
    * 1 read/write port – can only process one instruction at a time; if another instruction pending, must stall
    * memoryHierarchy needs to handle calling to cache first (returning in one cycle), if Miss -> call to DataMemory
*/
module dataMemory(
    clk,
    rstn,
    address, 
    dataSw,
    memRead,
    memWrite,
    storeSize,
    cacheMiss,
    lwData
);
    input clk;
    input rstn;

    input [31:0] address;
    input [31:0] dataSw;

    input memRead;
    input memWrite;
    input storeSize; // 0: Word (16 bit), 1: Byte (8 bit)
    input cacheMiss;
    
    output reg [31:0] lwData;

    reg [3:0] delay;
    reg [1023:0] DATAMEM [0:7]; 

    integer i;

    always @(posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < 1024; i++) begin
                DATAMEM[i] = 8'b0;
            end
            delay = 4'b0;
        end else begin
            if ((memRead || memWrite) && cacheMiss) begin
                if (delay < 10) begin
                    delay += 1;
                end else begin
                    if (memRead) begin
                        lwData = {16'b0, DATAMEM[address], DATAMEM[address+1]};
                    end
                    if (memWrite) begin
                        if (~storeSize) begin
                            DATAMEM[address] = dataSw[15:8];
                            DATAMEM[address+1] = dataSw[7:0];
                        end else
                            DATAMEM[address] = dataSw[7:0];
                    end
                    delay = 0;
                end
            end
        end
    end
endmodule