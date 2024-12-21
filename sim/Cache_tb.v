module cache_tb;
    parameter ResetValue = 2'b00;
	parameter HalfCycle = 10;
	localparam Cycle = 2*HalfCycle;
    
    reg clk;
    reg rstn;
    reg [31:0] PC;
    reg [31:0] address;
    reg [31:0] store_data;
    reg memRead;
    reg memWrite;
    reg storeSize;
    reg fromLSQ;

    wire [31:0] load_data;
    wire cacheMiss; 

    Cache Cache (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .PC_in(PC),
        .address_in(address),
        .data_sw(store_data),
        .memRead(memRead),
        .memWrite(memWrite),
        .storeSize(storeSize),
        .fromLSQ(fromLSQ),

        // outputs ...
        .lw_data(load_data),
        .cacheMiss(cacheMiss)
    );

    initial begin
        #(2*Cycle) begin
            PC = 32'h10;
            address = 32'h4;
            store_data = 32'h23;
            memRead = 0;
            memWrite = 1;
            storeSize = 0;
            fromLSQ = 0;
        end
        #(2*Cycle) begin
            PC = 32'h14;
            address = 32'h8;
            store_data = 32'h46;
            memRead = 0;
            memWrite = 1;
            storeSize = 0;
            fromLSQ = 0;
        end
        #(2*Cycle) begin
            PC = 32'h18;
            address = 32'h4;
            store_data = 32'h0;
            memRead = 1;
            memWrite = 0;
            storeSize = 0;
            fromLSQ = 0;
        end
        #(2*Cycle) begin
            PC = 32'h1C;
            address = 32'h8;
            store_data = 32'h0;
            memRead = 1;
            memWrite = 0;
            storeSize = 0;
            fromLSQ = 0;
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