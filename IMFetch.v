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

    initial begin
        //load instructions to instrMem
        //can do manually or load from text file
    end

    always @(posedge clk) begin
        if (PC+4 < 1024) begin
            instr = {instrMem[PC],instrMem[PC+1],instrMem[PC+2],instrMem[PC+3]}
            stop = 0;
        end else begin
            instr = 32'b0;
            stop = 1;
        end
    end
endmodule