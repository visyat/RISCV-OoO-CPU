
`timescale 1ns / 1ps

module ARF (
    input clk, 
    input rstn,
    
    input [5:0] ARF_map,
    input [5:0] current_dr,
    
    // can read 2 registers at the same time
    input [5:0] read_srcReg1,
    input [5:0] read_srcReg2,
    
    // can retire 2 instructions at the same time at max
    input retire1,
    input [5:0] write_addr1,
    input [31:0] write_data1,

    input retire2,
    input [5:0] write_addr2,
    input [31:0] write_data2,

    output reg [31:0] read_srcReg1_data,
    output reg [31:0] read_srcReg2_data
);

    reg [31:0] REGISTER_FILE [63:0];
    reg [6:0] pReg_mapped [31:0];
    reg [5:0] AtoP [31:0];
    integer i;
   
    integer p;
    

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i=0; i<64; i=i+1) begin
                REGISTER_FILE[i] <= 0;
            end
        end else begin
            if (retire1) begin 
                REGISTER_FILE[write_addr1] = write_data1;
            end
            if (retire2) begin
                REGISTER_FILE[write_addr2] = write_data2;
            end
        end
    end
    
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            read_srcReg1_data = 'b0;
            read_srcReg2_data = 'b0;
        end else begin
            read_srcReg1_data = REGISTER_FILE[read_srcReg1];
            read_srcReg2_data = REGISTER_FILE[read_srcReg2];
        end
    end
    
    integer a;
    always @(posedge clk) begin
      
        pReg_mapped[ARF_map]=current_dr; //pReg indexed at its proper aReg
        /*
        for (a=0; a<32; a=a+1) begin
            if() begin
            end
        end 
        */
    end 

endmodule