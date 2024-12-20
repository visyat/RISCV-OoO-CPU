
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
    input [5:0] ROBNumLsu,
    input [5:0] destRegLsu,

    // from retirement ... deallocate space in LSQ
    input [31:0] pcRet1,
    input [31:0] pcRet2,

    // outputs ... issues instruction; completes LW instruction if store seen in LSQ
    output reg [31:0] pcOut,
    output reg [5:0] ROBNumOut,
    output reg [5:0] destRegOut,
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
    reg [15:0] ADDR_LOADED;
    reg [31:0] ADDRESS [15:0];
    reg [31:0] LSQ_DATA [15:0];
    reg [15:0] ISSUED;

    reg [5:0] ROBNUM [15:0];
    reg [5:0] DESTREG [15:0];

    integer i, j, k, m;
    reg [3:0] index = 0;

    always @(*) begin // initialize LSQ entries, reserve entries on dispatch ...
        if (~rstn) begin // on reset, set all LSQ entries to 0 ...
            VALID = 16'b0;
            OP = 16'b0;
            SIZE = 16'b0;
            ISSUED = 16'b0;
            ADDR_LOADED = 16'b0;
            for (i=0; i<16; i=i+1) begin
                PC[i] = 32'b0;
                ADDRESS[i] = 32'b0;
                LSQ_DATA[i] = 32'b0;
                ROBNUM[i] = 'b0;
                DESTREG[i] = 'b0;
            end
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
        end
    end

    always @(*) begin // handle broadcasted addresses ...
        if (pcLsu && addressLsu) begin
            for (j=0; j<16; j=j+1) begin
                if (PC[j] == pcLsu) begin
                    ADDRESS[j] = addressLsu;
                    ADDR_LOADED[j] = 1;
                    ROBNUM[j] = ROBNumLsu;
                    DESTREG[j] = destRegLsu;
                    index = j;
                    j = 17;
                end
            end
             // execution logic ... if update address in LSQ entry; if load, scan LSQ to find matching addresses, provide data for latest store
             if (~OP[index]) begin
                 for (j=15; j>=0; j=j-1) begin
                     if (ADDRESS[index] == ADDRESS[j] && j != index) begin
                         LSQ_DATA[index] = LSQ_DATA[j]; // populate LW data with the most recent store to the same address
                         j = -1;
                     end
                 end
             end 
        end
    end
    always @(*) begin // handle broadcasted retirement instructions ...
        // retirement logic ... deallocate LSQ entry
        for (k=0; k<16; k=k+1) begin
            if (pcRet1 == PC[k] || pcRet2 == PC[k]) begin
                VALID[k] = 0;
                PC[k] = 0;
                OP[k] = 0;
                SIZE[k] = 0;
                ADDRESS[k] = 32'b0;
                ADDR_LOADED[k] = 0;
                ROBNUM[k] = 'b0;
                DESTREG[k] = 'b0;
                LSQ_DATA[k] = 32'b0;
                ISSUED[k] = 0;
                k=16;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin // handle issue logic ...
        if (~rstn) begin
            pcOut = 'b0;
            addressOut = 'b0;
            lwData = 'b0;
            fromLSQ = 'b0;
            loadStore = 'b0;
            storeSizeOut = 'b0;
            ROBNumOut = 'b0;
            destRegOut = 'b0;
            swDataOut = 'b0;
            complete = 'b0;
        end else begin
            fromLSQ = 'b0;
            // issue logic ... complete loads if data exists, else issue most recent available instruction 
            for (m=0; m<16; m=m+1) begin
                if (VALID[m] && ~ISSUED[m] && ~OP[m] && LSQ_DATA[m] != 32'b0 && ADDR_LOADED[m]) begin
                    pcOut = PC[m];
                    addressOut = ADDRESS[m];
                    lwData = LSQ_DATA[m];
                    fromLSQ = 1;
                    loadStore = 0;
                    storeSizeOut = SIZE[m];
                    ROBNumOut = ROBNUM[m];
                    destRegOut = DESTREG[m];
                    swDataOut = 32'b0;
                    ISSUED[m] = 1;
                    m=16;
                end
            end
            if (~fromLSQ) begin
                for (m=0; m<16; m=m+1) begin
                    if (VALID[m] && ~ISSUED[m] && ADDR_LOADED[m]) begin
                        pcOut = PC[m];
                        addressOut = ADDRESS[m];
                        ROBNumOut = ROBNUM[m];
                        destRegOut = DESTREG[m];
                        lwData = 'b0;
                        fromLSQ = 0;
                        loadStore = OP[m];
                        storeSizeOut = SIZE[m];
                        swDataOut = LSQ_DATA[m];
                        ISSUED[m] = 1;
                        m=16;
                    end
                end
            end
        end
    end

endmodule