module LSQ_tb;
    parameter ResetValue = 2'b00;
	parameter HalfCycle = 10;
	localparam Cycle = 2*HalfCycle;

    reg clk; 
    reg rstn;

    reg [31:0] pcDis;
    reg memRead;
    reg memWrite;
    reg storeSize;
    reg [31:0] swData;

    reg [31:0] pcLsu;
    reg [31:0] addressLsu;
    reg [5:0] ROBNumLsu;
    reg [5:0] destRegLsu;

    wire [31:0] pcOut;
    wire [5:0] ROBNumOut;
    wire [5:0] destRegOut;
    wire [31:0] addressOut;
    wire [31:0] lwData;
    wire fromLSQ; 
    wire loadStore;
    wire storeSizeOut; 
    wire [31:0] swDataOut;

    Load_Store_Queue LSQ (
        .clk(clk),
        .rstn(rstn),
        
        .pcDis(pcDis),
        .memRead(memRead),
        .memWrite(memWrite),
        .storeSize(storeSize),
        .swData(swData),

        .pcLsu(pcLsu),
        .addressLsu(addressLsu),
        .ROBNumLsu(ROBNumLsu),
        .destRegLsu(destRegLsu),

        .pcRet1(),
        .pcRet2(),

        .pcOut(pcOut),
        .ROBNumOut(ROBNumOut),
        .destRegOut(destRegOut),
        .addressOut(addressOut),
        .lwData(lwData),
        .fromLSQ(fromLSQ),
        .loadStore(loadStore),
        .storeSizeOut(storeSizeOut),
        .swDataOut(swDataOut),
        .complete()
    );

    initial begin
        #(2*Cycle) begin
            pcDis = 32'h10;
            store_data = 32'h23;
            memRead = 0;
            memWrite = 1;
            storeSize = 0;
        end
        #(2*Cycle) begin
            PC = 32'h14;
            store_data = 32'h46;
            memRead = 0;
            memWrite = 1;
            storeSize = 0;
        end
        #(2*Cycle) begin
            PC = 32'h18;
            store_data = 32'h0;
            memRead = 1;
            memWrite = 0;
            storeSize = 0;
        end
        #(2*Cycle) begin
            PC = 32'h1C;
            store_data = 32'h0;
            memRead = 1;
            memWrite = 0;
            storeSize = 0;
            fromLSQ = 0;
        end
        
        #(2*Cycle) begin
            pcDis = 32'h10;
            address = 32'h4;
        end
        #(2*Cycle) begin
            PC = 32'h14;
            address = 32'h8;
        end
        #(2*Cycle) begin
            PC = 32'h18;
            address = 32'h4;
        end
        #(2*Cycle) begin
            PC = 32'h1C;
            address = 32'h8;
        end

        #(5*Cycle) $stop;
    end

    initial clk = 1'b0;
    always #(HalfCycle) clk = ~clk;

    initial begin
            rstn = 1'b1;
        #1  rstn = 1'b0;
        #1  rstn = 1'b1;
    end
endmodule