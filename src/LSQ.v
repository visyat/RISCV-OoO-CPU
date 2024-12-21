
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
    input [5:0] storeRegister,
    input [31:0] swData,

    // from LSU ... recieves instruction address (to match) & computed address: rs1+offset
    input [31:0] pcLsu,
    input [31:0] addressLsu,
    input [5:0] ROBNumLsu,
    input [5:0] destRegLsu,

    // from ROB ... update store data from written registers 
    input [5:0] reg0_ROB_in,
    input [31:0] reg0_data_ROB_in,

    input [5:0] reg1_ROB_in,
    input [31:0] reg1_data_ROB_in,

    input [5:0] reg2_ROB_in,
    input [31:0] reg2_data_ROB_in,

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
    reg [5:0]  STORE_REGISTER [15:0];
    reg [31:0] LSQ_DATA [15:0];
    reg [15:0] ISSUED;

    reg [5:0] ROBNUM [15:0];
    reg [5:0] DESTREG [15:0];

    integer i, j, k, m, n, p;
    integer i2, j2 = 0;
    reg [3:0] index = 0;
    reg duplicate = 0;

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
                STORE_REGISTER[i] = 'b0;
                LSQ_DATA[i] = 32'b0;
                ROBNUM[i] = 'b0;
                DESTREG[i] = 'b0;
            end
        end else begin
            // dispatch logic ... if read/write, reserve space in LSQ
            duplicate = 1'b0;
            for (i=0; i<16; i=i+1) begin
                if (VALID[i] && PC[i] == pcDis) begin
                    duplicate = 1'b1;
                end
            end
            if (~duplicate && (memRead || memWrite)) begin
                for (i=0; i<16; i=i+1) begin
                    if (~VALID[i]) begin // find first vacant entry ...
                        VALID[i]=1;
                        PC[i]=pcDis;
                        SIZE[i]=storeSize;
                        OP[i] = memWrite; // 0 if load, 1 if store
                        if (memWrite) begin
                            LSQ_DATA[i] = swData;
                            STORE_REGISTER[i] = storeRegister;
                        end
                        i=16;
                    end
                end
            end
        end
    end
    // handle broadcasted store data updates from ROB ...
    always @(*) begin
        for (n=0; n<16; n=n+1) begin
            if (VALID[n] && ~ISSUED[n]) begin
                if (STORE_REGISTER[n] == reg0_ROB_in) begin
                    LSQ_DATA[n] = reg0_data_ROB_in;
                end
                if (STORE_REGISTER[n] == reg1_ROB_in) begin
                    LSQ_DATA[n] = reg1_data_ROB_in;
                end
                if (STORE_REGISTER[n] == reg2_ROB_in) begin
                    LSQ_DATA[n] = reg2_data_ROB_in;
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
        end
    end
    always @(*) begin
        for (i2=0; i2<16; i2=i2+1) begin
            if (VALID[i2] && ~OP[i2] && ~ISSUED[i2]) begin
                for (j2=0; j2<16; j2=j2+1) begin
                    if (OP[j2] && ADDRESS[j2] == ADDRESS[i2]) begin
                        LSQ_DATA[i2] = LSQ_DATA[j2];
                    end
                end
            end
        end
    end 
    always @(*) begin // handle broadcasted retirement instructions ...
        // retirement logic ... deallocate LSQ entry
        for (k=0; k<16; k=k+1) begin
            if (pcRet1 == PC[k]) begin
                VALID[k] = 0;
                PC[k] = 'b0;
                OP[k] = 0;
                SIZE[k] = 0;
                ADDRESS[k] = 32'b0;
                ADDR_LOADED[k] = 0;
                ROBNUM[k] = 'b0;
                DESTREG[k] = 'b0;
                LSQ_DATA[k] = 32'b0;
                STORE_REGISTER[k] = 'b0;
                ISSUED[k] = 0;
                k=16;
            end
        end
    end
    always @(*) begin // handle broadcasted retirement instructions ...
        // retirement logic ... deallocate LSQ entry
        for (p=0; p<16; p=p+1) begin
            if (pcRet2 == PC[p]) begin
                VALID[p] = 0;
                PC[p] = 'b0;
                OP[p] = 0;
                SIZE[p] = 0;
                ADDRESS[p] = 32'b0;
                ADDR_LOADED[p] = 0;
                ROBNUM[p] = 'b0;
                DESTREG[p] = 'b0;
                LSQ_DATA[p] = 32'b0;
                STORE_REGISTER[p] = 'b0;
                ISSUED[p] = 0;
                p=16;
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
                            
            for (m=0; m<16; m=m+1) begin
                if (VALID[m]) begin
                    $display("PC: %0h, Store: %0b, Address: %0d, StoreData: %0d ==> Issued: %0b", PC[m], OP[m], ADDRESS[m], LSQ_DATA[m], ISSUED[m]);
                end
            end
            $display("/////////////////////////////////////////////////////////////////////////////////////////");
            
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
                    if (VALID[m] && ~ISSUED[m] && ADDR_LOADED[m] && LSQ_DATA[m] != 32'b0) begin
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