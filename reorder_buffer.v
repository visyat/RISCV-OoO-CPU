
`timescale 1ns / 1ps

module reorder_buffer (
    // inputs ...
    input clk, 
    input rstn,

    // adding ROB entry for each instruction ...
    input [31:0] PC_dispatch_in,
    input [5:0] destReg_in,
    input [5:0] oldDestReg_in, 

    // checking ready flags for source registers ...
    input [5:0] srcReg1_in,
    input [5:0] srcReg2_in, 

    // outputs ...
    output reg [5:0] ROBNum_out,
    output reg srcReg1_ready,
    output reg srcReg2_ready
);

    reg [63:0]  VALID;
    reg [5:0]   DESTREG [0:63];
    reg [5:0]   OLD_DESTREG [0:63];
    reg [31:0]  PC [0:63];
    reg [63:0]  COMPLETE; 

    reg [63:0] PREG_READY; 

    integer i;
    integer j;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            VALID = 'b0;
            COMPLETE = 'b0;
            PREG_READY = 'b1;
            for (i=0; i<64; i=i+1) begin
                DESTREG[i] = 'b0;
                OLD_DESTREG[i] = 'b0;
                PC[i] = 'b0;
            end
            ROBNum_out = 'b0;
        end else begin
            for (i=0; i<64; i=i+1) begin
                if (~VALID[i]) begin
                    VALID[i] = 1;
                    DESTREG[i] = destReg_in;
                    OLD_DESTREG[i] = oldDestReg_in;
                    PC[i] = PC_dispatch_in;
                    COMPLETE[i] = 'b0;

                    ROBNum_out = i;
                    i = 65;
                end
            end
        end
    end
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            srcReg1_ready = 0;
            srcReg2_ready = 0;
        end else begin
            for (j=0; j<64; j=j+1) begin
                if (VALID[j]) begin
                    // update saved ready signals ...
                    if (DESTREG[j] == srcReg1_in && srcReg1_in != 0 && ~COMPLETE[j]) begin
                        PREG_READY[srcReg1_in] = 0;
                    end
                    if (DESTREG[j] == srcReg2_in && srcReg2_in != 0 && ~COMPLETE[j]) begin
                        PREG_READY[srcReg2_in] = 0;
                    end
                end
            end
            srcReg1_ready = PREG_READY[srcReg1_in];
            srcReg2_ready = PREG_READY[srcReg2_in];
        end
    end

endmodule