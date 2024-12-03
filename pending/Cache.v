/*
    • 4-way set associative cache
    • Cache Size = # of sets * # of ways * block size = 32 kB
    • Block Size = 64 bytes 
    • Num of Sets = 32768/(4*64) = 128
    • Address (32 bits) = Tag (19 bits) + Index (7 bits) + Offset (6 bits)
*/

module cache(
    input clk,
    input rstn,

    input [31:0] address, // TAG = address[31:13], INDEX = address[12:6], OFFSET = address[5:0]
    input loadStore, // 0 if load, 1 if store

    // output ...
    output reg cacheMiss,
    output [31:0] lwData
);
    // cache fields ...
    reg [18:0] TAG_STORE [127:0][3:0];
    reg [511:0] DATA_STORE [127:0][3:0];

    integer i,j;

    always @(posedge clk) begin
        if (~rstn) begin
            for (i=0; i<128; i++) begin
              for (j=0; j<4; j++) begin
                TAG_STORE[i][j] = 19'b0;
                DATA_STORE[i][j] = 512'b0;
              end
            end
        end else begin
            if (~loadStore) begin // if load ...
                // check for cache hit ... 
                // search all ways at TAG_STORE[index] for match
                // if yes ... load cache data at DATA_STORE[index][matched_way]
                // if no ... cache miss 
                    lwData = 32'b0;
                    cacheMiss = 1;

            end else begin // if store ...
                lwData = 32'b0;
                cacheMiss = 1; // write through ... have to write to Data Memory as well

                // copy store data to cache ... 
                // search through all ways at TAG_STORE[index] for free space
                // if yes ... store data at DATA_STORE[index][matched_way]
                // if no ... EVICT. select random way, store data at DATA_STORE[index][rand_way]
            end
        end
    end

endmodule