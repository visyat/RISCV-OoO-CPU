module instructionMemory (
    //inputs
    clk, 
    PC, 
    //outputs
    instr, 
    stop
);
    input clk;
    input [31:0] PC; 

    output reg [31:0] instr; 
    output reg stop;

    reg [7:0] instrMem [0:1023];
    reg [31:0] temp;
  	integer i;

    initial begin
      	for (i=0; i<1024; i++) begin
            instrMem[i] = 8'b0;
        end
      	$readmemh ("instructions.txt", instrMem);
        //assumes instructions in hex format; $readmemb for binary
    end

    always @(posedge clk) begin
        if (PC < 1024) begin
          temp[31:0] = {instrMem[PC+3], instrMem[PC+2], instrMem[PC+1],instrMem[PC]};
          if (temp == 32'b0) begin 
            instr = 32'b0;
            stop = 1;
          end else begin 
            instr[31:0] = temp[31:0];
            stop = 0;
          end
        end
    end
endmodule