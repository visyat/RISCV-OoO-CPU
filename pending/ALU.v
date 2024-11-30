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


module ALU(
//inputs: clk, restart
        // in an array for each instr: data from src1 and src2/imm, aluOp, which FU they go to 
input clk, 
input rstn,
input func7,
input func3,
input opcode,

input [31:0] data_in_sr1 [2:0],
input [31:0] data_in_sr2 [2:0],
input [31:0] data_in_imm [2:0],
input [5:0] dr_in [2:0],


//outputs: data for dest reg
output reg [31:0] data_out_dr [2:0],
output reg [5:0] dr_out [2:0],
output reg FU [2:0]





    );
    
    
        
    integer i;
    always @(*) begin
            if (~rstn)begin
                FU[0]=1'b0;
                FU[1]=1'b0;
                FU[2]=1'b0;
            end 
            else begin
                for (i=0; i<2; i=i+1) begin
                    if(FU[i]==1'b0)begin //if FU is available
                    
                        FU[i]=1'b1;                       
                        //huge switch statement to determine alu type via alu op
                        if(opcode==7'b0110011) begin //Rtype
                            if (func3==3'b000)begin
                                if (func7==7'b0000000)begin
                                    //ADD
                                    data_out_dr[i]=data_in_sr1[i]+data_in_sr2[i];
                                end
                                if (func7==7'b0100000)begin
                                    //SUB
                                    data_out_dr[i]=data_in_sr1[i]-data_in_sr2[i];
                                end
                            end
                            else if (func3==3'b001)begin
                                //SLL
                                display("unexpected instruction");
                            end
                            else if (func3==3'b010)begin
                                //SLT
                                display("unexpected instruction");
                            end
                            else if (func3==3'b011)begin
                                //SLTU
                                display("unexpected instruction");
                            end
                            else if (func3==3'b100)begin
                                //XOR
                                data_out_dr[i]=data_in_sr1[i] ^ data_in_sr2[i];
                            end
                            else if (func3==3'b101)begin
                                //SR
                                if (func7==7'b0000000)begin
                                    //SRL
                                    display("unexpected instruction");
                                end
                                if (func7==7'b0100000)begin
                                    //SRA
                                    display("unexpected instruction");
                                end
                            end
                            else if (func3==3'b110)begin
                                //OR
                                data_out_dr[i]=data_in_sr1[i] | data_in_sr2[i];
                            end
                            else if (func3==3'b111)begin
                                //AND
                                data_out_dr[i]=data_in_sr1[i] & data_in_sr2[i];
                            end
                        end
                        else if(opcode==7'b0010011) begin //Itype
                            if (func3==3'b000)begin
                                //ADDI
                                data_out_dr[i]=data_in_sr1[i]+data_in_imm[i];
                            end
                            else if (func3==3'b001)begin
                                //SLLI
                                display("unexpected instruction");
                            end
                            else if (func3==3'b010)begin
                                //SLTI
                                display("unexpected instruction");
                            end
                            else if (func3==3'b011)begin
                                //SLTIU
                                display("unexpected instruction");
                            end
                            else if (func3==3'b100)begin
                                //XORI
                                data_out_dr[i]=data_in_sr1[i] ^ data_in_imm[i];
                            end
                            else if (func3==3'b101)begin
                                //SR
                                if (func7==7'b0000000)begin
                                    //SRLI
                                    display("unexpected instruction");
                                end
                                if (func7==7'b0100000)begin
                                    //SRAI
                                    data_out_dr[i]=data_in_sr1[i]>>data_in_imm[i];
                                end
                            end 
                            else if (func3==3'b110)begin
                                //ORI
                                data_out_dr[i]=data_in_sr1[i] | data_in_imm[i];
                            end 
                            else if (func3==3'b1111)begin
                                //ANDI
                                data_out_dr[i]=data_in_sr1[i] & data_in_imm[i];
                            end
                        end
                        else if(opcode==7'b0110111) begin // Utype
                            //LUI
                            data_out_dr[i]=data_in_imm[i]<<12;
                        end
                        else if(opcode==7'b0000011 || opcode==7'b0110011) begin //load/store
                        //do nothing
                        end
                        
                        FU[i]=1'b0;
                        
                    end
                end
            end
    end
endmodule


