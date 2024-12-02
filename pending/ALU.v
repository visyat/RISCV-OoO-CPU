`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Paige Larson
// 
// Create Date: 11/25/2024 02:30:50 AM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU #(
    parameter ALU_NO = 0
)(
    // inputs: clk, restart
    // in an array for each instr: data from src1 and src2/imm, aluOp, which FU they go to 
    input           clk, 
    input           rstn,
    input [2:0]     alu_number,
    input           func7,
    input           func3,
    input           opcode,

    input [31:0]    data_in_sr1,
    input [31:0]    data_in_sr2,
    input [31:0]    data_in_imm,
    input [5:0]     dr_in,

    //outputs: data for dest reg
    output reg [31:0]   data_out_dr,
    output reg [5:0]    dr_out,
    output reg          FU_ready
);
        
    always @(*) begin
        if (~rstn) begin
            data_out_dr = 32'b0;
            dr_out      = 6'b0;
            FU_ready    = 1'b1;
        end 
        else begin
            if (alu_number[ALU_NO] == 1) begin
                dr_out = dr_in;
                FU_ready = 1'b0;                       
                //huge switch statement to determine alu type via alu op
                if(opcode==7'b0110011) begin //Rtype
                    if (func3 == 3'b000)begin
                        if (func7 == 7'b0000000)begin
                            //ADD
                            data_out_dr = data_in_sr1 + data_in_sr2;
                        end
                    end
                    else if (func3 == 3'b100)begin
                        //XOR
                        data_out_dr = data_in_sr1 ^ data_in_sr2;
                    end
                end
                else if(opcode == 7'b0010011) begin //Itype
                    if (func3 == 3'b000)begin
                        //ADDI
                        data_out_dr = data_in_sr1 + data_in_imm;
                    end
                    else if (func3 == 3'b101)begin
                        if (func7 == 7'b0100000)begin
                            //SRAI
                            data_out_dr = data_in_sr1 >> data_in_imm;
                        end
                    end 
                    else if (func3 == 3'b110)begin
                        //ORI
                        data_out_dr = data_in_sr1 | data_in_imm;
                    end 
                end
                else if(opcode == 7'b0110111) begin // Utype
                    //LUI
                    data_out_dr = data_in_imm << 12;
                end
                else if((opcode == 7'b0000011) || (opcode==7'b0110011)) begin //load/store

                end
                FU_ready = 1'b1;
            end 
        end
    end

endmodule
