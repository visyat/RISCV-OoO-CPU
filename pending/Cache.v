/*
    * Size: 32 kB
    * 4-way set associative cache 
    * Address (32 bits) = Tag (16 bits) + Index (12 bits) + Offset (4 bits)
    * 16 bytes per block 
    * 4096 sets 
    * Random eviction & Write-through 
*/
module cache(
    clk,
    rstn,
    address,
    dataSw,
    memRead,
    memWrite,
    storeSize,
    lwData,
    cacheMiss
);
    input clk;
    input rstn;

    input [31:0] address;
    input [31:0] dataSw;

    input memRead;
    input memWrite;
    input storeSize;

    output cacheMiss;
    output [31:0] lwData;

    reg [4095:0] TAG [3:0][14:0]; // tag store ... 4096 sets/4 ways/15 bit tags
    reg [4095:0] DATA [3:0][127:0]; // data store ... 4096 sets/4 ways/128 bits per block

    integer i;
    integer j; 

    reg [15:0] addr_tag;
    reg [11:0] addr_ind;
    reg [3:0] addr_off;
    reg [2:0] way_match;

    always @(posedge clk) begin
        if (~rstn) begin
            for (i=0; i<4095; i++) begin
                for (j=0; j<4; j++) begin
                    TAG[i][j] = 15'b0;
                end
            end
            for (i=0; i<4095; i++) begin
                for (j=0; j<4; j++) begin
                    DATA[i][j] = 128'b0;
                end
            end
            addr_tag = 16'b0;
            addr_ind = 12'b0;
            addr_off = 4'b0;
            way_match = 3'b1;

        end else begin
            // search for cache hit ...
            addr_off = address[3:0];
            addr_ind = address[15:4];
            addr_tag = address[31:16];

            for (i=0; i<4; i++) begin
                if (addr_tag == TAG[addr_ind][i])
                    way_match = i;
            end
            if (way_match != 3'b1) begin // cache hit ...

            end

        end
    end

endmodule