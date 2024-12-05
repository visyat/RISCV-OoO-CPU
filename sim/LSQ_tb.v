
`timescale 1ns/1ps

module LSQ_tb();
    reg clk;
    reg rstn;

    reg [31:0] pcDis;
    reg memRead;
    reg memWrite;
    reg [31:0] swData;
    
    reg [31:0] pcLsu;
    reg [31:0] addressLsu;
    
    reg [31:0] pcRet;
    reg retire;

    wire [31:0] pcOut;
    wire [31:0] addressOut;
    wire [31:0] lwData;
    wire loadStore;
    wire complete;

    LSQ LSQ_mod(
        .clk(clk),
        .rstn(rstn),
        .pcDis(pcDis),
        .memRead(memRead),
        .memWrite(memWrite),
        .swData(swData),
        .pcLsu(pcLsu),
        .addressLsu(addressLsu),
        .pcRet(pcRet),
        .retire(retire),
        .pcOut(pcOut),
        .addressOut(addressOut),
        .lwData(lwData),
        .loadStore(loadStore),
        .complete(complete)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;
    initial begin
            rstn = 1'b1;
        #20  rstn = 1'b0;
        #10  rstn = 1'b1;
    end

    initial begin
        // intialize all signals to 0 ...
        pcDis = 32'b0;
        memRead = 0;
        memWrite = 0;
        swData = 32'b0;
        pcLsu = 32'b0;
        addressLsu = 32'b0;
        pcRet = 32'b0;
        retire = 0;

        // dispatch first store instruction ... 
        #50;
        #10 begin
            pcDis = 32'h0001;
            memRead = 0;
            memWrite = 1;
            swData = 32'h1234;
        end

        // dispatch subsequent load instructions ... 
        #10 begin
            pcDis = 32'h0002;
            memRead = 1;
            memWrite = 0;
            swData = 32'b0;
        end
        #10 begin
            pcDis = 32'h0003;
            memRead = 1;
            memWrite = 0;
            swData = 32'b0;
        end

        // complete execution for store instruction ...
        #10 begin
            pcLsu = 32'h0001;
            addressLsu = 32'h0012;
        end

        // complete execution for load instructions ... 
        #10 begin
            pcLsu = 32'h0002;
            addressLsu = 32'h0012;
        end
        #10 begin
            pcLsu = 32'h0003;
            addressLsu = 32'h0024;
        end

        // retire first store instruction ...
        #10 begin
            pcRet =32'h0001;
            retire = 0;
        end
    end

endmodule
