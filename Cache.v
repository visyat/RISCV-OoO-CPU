`timescale 1ns/1ps

module Cache(
    input clk,
    input rstn,

    input [31:0] PC_in,
    input [31:0] address_in, // TAG: address[31:13], INDEX: address[12:6], OFFSET: address[5:0]
    input [31:0] data_sw,
    
    input memRead,
    input memWrite,
    input storeSize, // 0: Word (16 bit), 1: Byte (8 bit)
    input fromLSQ,

    output reg [31:0] lw_data,
    output reg cacheMiss

    // output reg [31:0] PC_out, 
    // output reg [31:0] address_out, 
    // output memRead_out,
    // output memWrite_out, 
    // output storeSize_out, 
    // output fromLSQ_out, 
);
    reg [18:0] TAG_WAY_1 [0:127];
    reg [511:0] DATA_WAY_1 [0:127];

    reg [18:0] TAG_WAY_2 [0:127];
    reg [511:0] DATA_WAY_2 [0:127];

    reg [18:0] TAG_WAY_3 [0:127];
    reg [511:0] DATA_WAY_3 [0:127];

    reg [18:0] TAG_WAY_4 [0:127];
    reg [511:0] DATA_WAY_4 [0:127];

    integer i;

    reg [511:0] search_1;
    reg [511:0] search_2;
    reg [511:0] search_3;
    reg [511:0] search_4;
    
    always @(posedge clk) begin
        // search way 1 ...
        if (~rstn) begin
            for (i=0; i<128; i=i+1) begin
                TAG_WAY_1[i] = 'b0;
                DATA_WAY_1[i] = 'b0;
            end 
            search_1 = 'b1;
        end else begin
            if (TAG_WAY_1[address_in[12:6]] == address_in[31:13]) begin
                if (memRead) begin
                    search_1 = {24'b0, DATA_WAY_1[address_in[12:6]][7:0]};
                end
                if (memWrite) begin
                    if (storeSize) begin
                        DATA_WAY_1[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_1[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_1[address_in[12:6]][7:0] = data_sw[7:0];
                    end
                    search_1 = 'b1;
                end
            end else begin
                search_1 = 'b1;
            end
        end
    end
    always @(posedge clk) begin
        // search way 2 ...
        if (~rstn) begin
            for (i=0; i<128; i=i+1) begin
                TAG_WAY_2[i] = 'b0;
                DATA_WAY_2[i] = 'b0;
            end 
            search_2 = 'b1;
        end else begin
            if (TAG_WAY_2[address_in[12:6]] == address_in[31:13]) begin
                if (memRead) begin
                    search_2 = {24'b0, DATA_WAY_2[address_in[12:6]][7:0]};
                end
                if (memWrite) begin
                    if (storeSize) begin
                        DATA_WAY_2[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_2[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_2[address_in[12:6]][7:0] = data_sw[7:0];
                    end
                    search_2 = 'b1;
                end
            end else begin
                search_2 = 'b1;
            end
        end
    end
    always @(posedge clk) begin
        // search way 3 ...
        if (~rstn) begin
            for (i=0; i<128; i=i+1) begin
                TAG_WAY_3[i] = 'b0;
                DATA_WAY_3[i] = 'b0;
            end 
            search_3 = 'b1;
        end else begin
            if (TAG_WAY_3[address_in[12:6]] == address_in[31:13]) begin
                if (memRead) begin
                    search_3 = {24'b0, DATA_WAY_3[address_in[12:6]][7:0]};
                end
                if (memWrite) begin
                    if (storeSize) begin
                        DATA_WAY_3[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_3[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_3[address_in[12:6]][7:0] = data_sw[7:0];
                    end
                    search_3 = 'b1;
                end
            end else begin
                search_3 = 'b0;
            end
        end
    end
    always @(posedge clk) begin
        // search way 4 ...
        if (~rstn) begin
            for (i=0; i<128; i=i+1) begin
                TAG_WAY_4[i] = 'b0;
                DATA_WAY_4[i] = 'b0;
            end 
            search_4 = 'b1;
        end else begin
            if (TAG_WAY_4[address_in[12:6]] == address_in[31:13]) begin
                if (memRead) begin
                    search_4 = {24'b0, DATA_WAY_4[address_in[12:6]][7:0]};
                end
                if (memWrite) begin
                    if (storeSize) begin
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_4[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw[7:0];
                    end
                    search_4 = 'b1;
                end
            end else begin
                search_4 = 'b1;
            end
        end
    end

    always @(posedge clk) begin
        // output ... 
        if (~rstn) begin
            // PC_out = 'b0;
            lw_data = 'b0;
            cacheMiss = 0;
            // address_out = 'b0;
            // memWrite_out = 0;
            // memRead_out = 0;
            // storeSize_out = 0;
            // fromLSQ_out = 0;
        end else begin
            // PC_out = PC_in;
            // address_out = address_in;
            // memWrite_out = memWrite;
            // memRead_out = memRead;
            // storeSize_out = storeSize;
            // fromLSQ_out = fromLSQ;

            if (search_1 != 'b1) begin
                lw_data = search_1;
                cacheMiss = 0;
            end else if (search_2 != 'b1) begin
                lw_data = search_1;
                cacheMiss = 0;
            end else if (search_3 != 'b1) begin
                lw_data = search_1;
                cacheMiss = 0;
            end else if (search_4 != 'b1) begin
                lw_data = search_1;
                cacheMiss = 0;
            end else begin
                lw_data = 'b0;
                cacheMiss = 1;
            end

            if (fromLSQ) begin
                lw_data = 'b0;
                cacheMiss = 0;
            end
        end
    end

endmodule