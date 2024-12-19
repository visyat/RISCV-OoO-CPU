
`timescale 1ns/1ps

/*
Load-Store Queue:
+ ------------------------------------- +
| V | PC  | Op |   Address   | Data | I |
+ - | --- | -- | ----------- | ---- | - |
| 1 | 0x4 | S  | 0x1...      | .... | 0 |
| 1 | 0x8 | L  | 0x2...      |      | 0 | 
| 0 |     |    |             |      | 0 |
+ ------------------------------------- +
*/

module Load_Store_Queue (
    input clk, 
    input rstn,

    // from dispatch ... receives instruction address, whether read/write, and rs2 val if SW
    input [31:0] pcDis,
    input memRead,
    input memWrite,
    input storeSize,
    input [31:0] swData,

    // from LSU ... recieves instruction address (to match) & computed address: rs1+offset
    input [31:0] pcLsu,
    input [31:0] addressLsu,

    // from retirement ... deallocate space in LSQ
    input [31:0] pcRet1,
    input [31:0] pcRet2,

    // outputs ... issues instruction; completes LW instruction if store seen in LSQ
    output reg [31:0] pcOut,
    output reg [31:0] addressOut,
    output reg [31:0] lwData,
    output reg fromLSQ, 
    output reg loadStore, // 0 if load, 1 if store
    output reg storeSizeOut, 
    output reg [31:0] swDataOut,
    output reg complete // 1 if LW and data is found in LSQ
);
    
    // LSQ fields ...
    reg [15:0] VALID;
    reg [31:0] PC [15:0];
    reg [15:0] OP; // 0: load, 1: store
    reg [15:0] SIZE; // 0: word, 1: byte
    reg [31:0] ADDRESS [15:0];
    reg [31:0] LSQ_DATA [15:0];
    reg [15:0] ISSUED;

    integer i,j;
    
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin // on reset, set all LSQ entries to 0 ...
            VALID = 16'b0;
            OP = 16'b0;
            SIZE = 16'b0;
            ISSUED = 16'b0;
            for (i=0; i<16; i=i+1) begin
                PC[i] = 32'b0;
                ADDRESS[i] = 32'b0;
                LSQ_DATA[i] = 32'b0;
            end
            pcOut = 32'b0;
            addressOut = 32'b0;
            fromLSQ = 0;
            lwData = 32'b0;
            complete = 0;
        end else begin 
            // dispatch logic ... if read/write, reserve space in LSQ
            if (memRead || memWrite) begin
                for (i=0; i<16; i=i+1) begin
                    if (~VALID[i]) begin // find first vacant entry ...
                        VALID[i]=1;
                        PC[i]=pcDis;
                        SIZE[i]=storeSize;
                        OP[i] = memWrite; // 0 if load, 1 if store
                        if (memWrite) begin
                            LSQ_DATA[i] = swData;
                        end
                        i=16;
                    end
                end
            end

            // execution logic ... if update address in LSQ entry; if load, scan LSQ to find matching addresses, provide data for latest store
            for (i=0; i<16; i=i+1) begin
                if (PC[i] == pcLsu) begin
                    ADDRESS[i] = addressLsu;
                    j = i;
                    i=16;
                end
            end
            for (i=15; i>=0; i=i-1) begin
                if (ADDRESS[i] == ADDRESS[j]) begin
                    LSQ_DATA[j] = LSQ_DATA[i]; // populate LW data with the most recent store to the same address
                    i=-1;
                end
            end

            // issue logic ... complete loads if data exists, else issue most recent available instruction 
            for (i=0; i<16; i=i+1) begin
                if (VALID[i] && ~ISSUED[i] && ~OP[i] && LSQ_DATA[i] != 32'b0) begin
                    pcOut = PC[i];
                    addressOut = ADDRESS[i];
                    lwData = LSQ_DATA[i];
                    fromLSQ = 1;
                    complete = 1;
                    loadStore = 0;
                    storeSizeOut = SIZE[i];
                    swDataOut = 32'b0;
                    ISSUED[i] = 1;
                    i=16;
                end
            end
            for (i=0; i<16; i=i+1) begin
                if (~complete && VALID[i] && ~ISSUED[i]) begin
                    pcOut = PC[i];
                    addressOut = ADDRESS[i];
                    lwData = 32'b0;
                    fromLSQ = 0;
                    complete = 0;
                    loadStore = OP[i];
                    storeSizeOut = SIZE[i];
                    swDataOut = LSQ_DATA[i];
                    ISSUED[i] = 1;
                    i=16;
                end
            end

            // retirement logic ... deallocate LSQ entry
            for (i=0; i<16; i=i+1) begin
                if (pcRet1 == PC[i] || pcRet2 == PC[i]) begin
                    VALID[i] = 0;
                    PC[i] = 0;
                    OP[i] = 0;
                    SIZE[i] = 0;
                    ADDRESS[i] = 32'b0;
                    LSQ_DATA[i] = 32'b0;
                    ISSUED[i] = 0;
                    i=16;
                end
            end

        end
    end
endmodule