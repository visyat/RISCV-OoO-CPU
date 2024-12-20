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
);
    reg [127:0] VALID_WAY_1;
    reg [18:0] TAG_WAY_1 [0:127];
    reg [511:0] DATA_WAY_1 [0:127];

    reg [127:0] VALID_WAY_2;
    reg [18:0] TAG_WAY_2 [0:127];
    reg [511:0] DATA_WAY_2 [0:127];

    reg [127:0] VALID_WAY_3;
    reg [18:0] TAG_WAY_3 [0:127];
    reg [511:0] DATA_WAY_3 [0:127];

    reg [127:0] VALID_WAY_4;
    reg [18:0] TAG_WAY_4 [0:127];
    reg [511:0] DATA_WAY_4 [0:127];

    integer i, j, k, m, n;

    reg found_1;
    reg found_2;
    reg found_3;
    reg found_4;

    reg [31:0] search_1;
    reg [31:0] search_2;
    reg [31:0] search_3;
    reg [31:0] search_4;
    
    always @(*) begin
        // search way 1 ...
        if (~rstn) begin
            VALID_WAY_1 = 'b0;
            for (i=0; i<128; i=i+1) begin
                TAG_WAY_1[i] = 'b0;
                DATA_WAY_1[i] = 'b0;
            end 
            search_1 = 'b0;
            found_1 = 'b0;
        end else begin
            if (memRead) begin
                if (TAG_WAY_1[address_in[12:6]] == address_in[31:13] && VALID_WAY_1[address_in[12:6]]) begin
                    found_1 = 'b1;
                    search_1 = {24'b0, DATA_WAY_1[address_in[12:6]][7:0]};
                end else begin
                    found_1 = 'b0;
                    search_1 = 'b0;
                end
            end 
        end
    end
    always @(*) begin
        // search way 2 ...
        if (~rstn) begin
            VALID_WAY_2 = 'b0;
            for (j=0; j<128; j=j+1) begin
                TAG_WAY_2[j] = 'b0;
                DATA_WAY_2[j] = 'b0;
            end 
            search_2 = 'b0;
            found_2 = 'b0;
        end else begin
            if (memRead) begin
                if (TAG_WAY_2[address_in[12:6]] == address_in[31:13] && VALID_WAY_2[address_in[12:6]]) begin
                    found_2 = 'b1;
                    search_2 = {24'b0, DATA_WAY_2[address_in[12:6]][7:0]};
                end else begin
                    found_2 = 'b0;
                    search_2 = 'b0;
                end
            end 
        end
    end
    always @(*) begin
        // search way 3 ...
        if (~rstn) begin
            VALID_WAY_3 = 'b0;
            for (k=0; k<128; k=k+1) begin
                TAG_WAY_3[k] = 'b0;
                DATA_WAY_3[k] = 'b0;
            end 
            search_3 = 'b0;
            found_3 = 'b0;
        end else begin
            if (memRead) begin
                if (TAG_WAY_3[address_in[12:6]] == address_in[31:13] && VALID_WAY_3[address_in[12:6]]) begin
                    found_3 = 'b1;
                    search_3 = {24'b0, DATA_WAY_3[address_in[12:6]][7:0]};
                end else begin
                    found_3 = 'b0;
                    search_3 = 'b0;
                end
            end 
        end
    end
    always @(*) begin
        // search way 4 ...
        if (~rstn) begin
            VALID_WAY_4 = 'b0;
            for (m=0; m<128; m=m+1) begin
                TAG_WAY_4[m] = 'b0;
                DATA_WAY_4[m] = 'b0;
            end 
            search_4 = 'b0;
            found_4 = 'b0;
        end else begin
            if (memRead) begin
                if (TAG_WAY_4[address_in[12:6]] == address_in[31:13] && VALID_WAY_4[address_in[12:6]]) begin
                    found_4 = 'b1;
                    search_4 = {24'b0, DATA_WAY_4[address_in[12:6]][7:0]};
                end else begin
                    found_4 = 'b0;
                    search_4 = 'b0;
                end
            end 
        end
    end

    always @(*) begin
        // output ... 
        if (~rstn) begin
            lw_data = 'b0;
            cacheMiss = 'b0;
        end else begin
            if (memRead) begin
                if (found_1) begin
                    lw_data = search_1;
                    cacheMiss = 'b0;
                end else if (found_2) begin
                    lw_data = search_2;
                    cacheMiss = 'b0;
                end else if (found_3) begin
                    lw_data = search_3;
                    cacheMiss = 'b0;
                end else if (found_4) begin
                    lw_data = search_4;
                    cacheMiss = 'b0;
                end else begin
                    lw_data = 'b0;
                    cacheMiss = 'b1;
                end
            end else if (memWrite) begin
                lw_data = 'b0;
                // find first way at the designated index that is available ...
                if (~VALID_WAY_1[address_in[12:6]]) begin
                    VALID_WAY_1[address_in[12:6]] = 1;
                    TAG_WAY_1[address_in[12:6]] = address_in[31:13];
                    if (storeSize) begin
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_4[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw[7:0];
                    end

                end else if (~VALID_WAY_2[address_in[12:6]]) begin
                    VALID_WAY_2[address_in[12:6]] = 1;
                    TAG_WAY_2[address_in[12:6]] = address_in[31:13];
                    if (storeSize) begin
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_4[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw[7:0];
                    end

                end else if (~VALID_WAY_3[address_in[12:6]]) begin
                    VALID_WAY_3[address_in[12:6]] = 1;
                    TAG_WAY_2[address_in[12:6]] = address_in[31:13];
                    if (storeSize) begin
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_4[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw[7:0];
                    end

                end else if (~VALID_WAY_4[address_in[12:6]]) begin
                    VALID_WAY_4[address_in[12:6]] = 1;
                    TAG_WAY_2[address_in[12:6]] = address_in[31:13];
                    if (storeSize) begin
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_4[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw[7:0];
                    end

                end else begin // need to evict a cache entry ... implement random eviction!
                    TAG_WAY_1[address_in[12:6]] = address_in[31:13];
                    if (storeSize) begin
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw;
                    end else begin
                        DATA_WAY_4[address_in[12:6]][15:8] = data_sw[15:8];
                        DATA_WAY_4[address_in[12:6]][7:0] = data_sw[7:0];
                    end
                end
                cacheMiss = 'b1;
            end
            if (fromLSQ) begin
                lw_data = 'b0;
                cacheMiss = 'b0;
            end
        end
    end
endmodule

