`timescale 1ns/1ps

/*
    * 1 read/write port - can only process one instruction at a time; if another instruction pending, must stall
    * memoryHierarchy needs to handle calling to cache first (returning in one cycle), if Miss -> call to DataMemory
*/
module dataMemory(
    input clk,
    input rstn,

    input [31:0] PC_in,
    input [31:0] address,
    input [31:0] dataSw,

    input memRead,
    input memWrite,
    input storeSize, // 0: Word (16 bit), 1: Byte (8 bit)
    input cacheMiss,
    input fromLSQ,
    
    output reg [31:0] lwData
    output reg [31:0] PC_out,
);

    reg [7:0] DATAMEM [0:1023];
    integer i, j;

    reg [31:0] PC_delay [0:9];
    reg [31:0] address_delay [0:9];
    reg [31:0] dataSw_delay [0:9];
    reg [9:0] memRead_delay;
    reg [9:0] memWrite_delay;
    reg [9:0] storeSize_delay;
    reg [9:0] cacheMiss_delay; 
    reg [9:0] fromLSQ_delay; 

    always @(posedge clk or negedge rstn) begin
        if (~rsnt) begin
            for (j=0; j<10; j=j+1) begin
                PC_delay[i] = 'b0;
                address_delay[i] = 'b0;
                dataSw_delay[i] = 'b0;
                memRead_delay[i] = 'b0;
                memWrite_delay[i] = 'b0;
                storeSize_delay[i] = 'b0;
                cacheMiss_delay[i] = 'b0; 
                fromLSQ_delay[i] = 'b0; 
            end
        end else begin
            for (j=0; j<9; j=j+1) begin
                PC_delay[i+1] = PC_delay[i];
                address_delay[i+1] = address_delay[i];
                dataSw_delay[i+1] = address_delay[i];
                memRead_delay[i+1] = memRead_delay[i];
                memWrite_delay[i+1] = memWrite_delay[i];
                storeSize_delay[i+1] = storeSize_delay[i];
                cacheMiss_delay[i+1] = cacheMiss_delay[i]; 
                fromLSQ_delay[i+1] = fromLSQ_delay[i];
            end
            PC_delay[0] = PC_in;
            address_delay[0] = address;
            dataSw_delay[0] = dataSw;
            memRead_delay[0] = memRead;
            memWrite_delay[0] = memWrite;
            storeSize_delay[0] = storeSize;
            cacheMiss_delay[0] = cacheMiss;
            fromLSQ_delay[0] = fromLSQ;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 1024; i=i+1) begin
                DATAMEM[i] = 8'b0;
            end
            lwData = 'b0;
            PC_out = 'b0;
        end else begin
            if ((memRead_delay[9] || memWrite_delay[9]) && cacheMiss_delay[9] && ~fromLSQ_delay[9]) begin
                if (memRead_delay[9]) begin
                    lwData = {16'b0, DATAMEM[address_delay[9]+1], DATAMEM[address_delay[9]]};
                end
                if (memWrite_delay[9]) begin
                    if (~storeSize_delay[9]) begin
                        DATAMEM[address_delay[9]+1] = dataSw_delay[9][15:8];
                        DATAMEM[address_delay[9]] = dataSw_delay[9][7:0];
                    end else
                        DATAMEM[address_delay[9]] = dataSw_delay[9][7:0];
                end
                PC_out = PC_delay[9];
            end
        end
    end
endmodule