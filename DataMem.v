module dataMemory(
    clk, 
    address, 
    memRead,
    memWrite,
    writeData,
    readData
);
    input clk;
    input [31:0] address;
    input memRead; 
    input memWrite;
    input [31:0] writeData;

    output reg [31:0] readData;

    reg [7:0] dataMem [0:1023];
    integer i;

    initial begin
        for (i=0; i<1024; i++) begin
            dataMem[i] = 8'b0;
        end
    end

    always @(posedge clk) begin
        if (memRead == 1) begin
          	readData[31:0] = {dataMem[address],dataMem[address+1],dataMem[address+2],dataMem[address+3]};
        end else begin
            readData = 32'b0;
        end

        if (memWrite == 1) begin
            dataMem[address] = writeData[31:24];
            dataMem[address+1] = writeData[23:16];
            dataMem[address+2] = writeData[15:8];
            dataMem[address+3] = writeData[7:0];
        end
    end
endmodule