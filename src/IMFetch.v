`timescale 1ns / 1ps

module instructionMemory (
    //inputs
    input               clk, 
    input [31 : 0]      PC,
    input               rstn, 
    //outputs
    output reg [31 : 0] instr, 
    output reg          stop
);    

    reg [7 : 0]   instrMem [0 : 1023];
    reg [31 : 0]  temp;
  	integer i;

    always @(posedge clk or negedge rstn) begin
        if (~rstn)begin
            for (i = 0; i < 1024; i = i + 1) begin
                instrMem[i] = 8'b0;
            end
            stop  = 0;
            instr = 32'b0;
        end
        else begin
            $readmemh ("demo.txt", instrMem);
            //assumes instructions in hex format; $readmemb for binary
            if (PC < 1024) begin
                temp[31:0] = {instrMem[PC+3], instrMem[PC+2], instrMem[PC+1],instrMem[PC]};
                if (temp == 32'b0) begin 
                    instr = 32'b0;
                    stop  = 1;
                end 
                else begin 
                    instr[31:0] = temp[31:0];     
                    stop = 0;
                end
            end
        end
    end 
        
endmodule
