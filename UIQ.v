
`timescale 1ns / 1ps

module Unified_Issue_Queue (
    // inputs ...
    input clk,
    input rstn,

    // from dispatch ...
    input stall_in,
    // instruction ... 
    input [31:0] PC_in,
    input [6:0] opcode_in, 
    input [2:0] funct3_in,
    input [6:0] funct7_in, 
    // rename & ARF ...
    input [5:0] srcReg1_p_in,
    input [5:0] srcReg2_p_in, 
    input [31:0] imm_in,
    input [5:0] destReg_p_in,
    input [31:0] srcReg1_data_ARF_in,
    input [31:0] srcReg2_data_ARF_in,
    
    // ROB ...
    input [5:0] srcReg1_reg_ready_ROB_in,
    input srcReg1_ready_ROB_in,
    input [5:0] srcReg2_reg_ready_ROB_in,
    input srcReg2_ready_ROB_in,
    input [5:0] ROBNum_in,

    // from functional units ...
    // READY FLAGS FROM FUNCTIONAL UNITS ...
    input FU_ready_ALU0_in,
    input FU_ready_ALU1_in,
    input FU_ready_ALU2_in,

    // not sure what the purpose of these flags are ... when FU_ready == 1, FU_occ = 0 -> FU_ready = ~FU_occ?
    // input FU_occupied_ALU0_in;
    // input FU_occupied_ALU1_in;
    // input FU_occupied_ALU2_in;

    // outputs ...
    output reg stall_out,

    // issue no 1 ...
    output reg [31:0] PC_issue0,
    output reg [3:0] optype_issue0,
    output reg [1:0] aluNum_issue0,
    output reg [31:0] srcReg1_data_issue0,
    output reg [31:0] srcReg2_data_issue0,
    output reg [31:0] imm_issue0,
    output reg [5:0] destReg_issue0,
    output reg [5:0] ROBNum_issue0,

    // issue no 2 ...
    output reg [31:0] PC_issue1,
    output reg [3:0] optype_issue1,
    output reg [1:0] aluNum_issue1,
    output reg [31:0] srcReg1_data_issue1,
    output reg [31:0] srcReg2_data_issue1,
    output reg [31:0] imm_issue1,
    output reg [5:0] destReg_issue1,
    output reg [5:0] ROBNum_issue1,

    // issue no 3 ...
    output reg [31:0] PC_issue2,
    output reg [3:0] optype_issue2,
    output reg [1:0] aluNum_issue2,
    output reg [31:0] srcReg1_data_issue2,
    output reg [31:0] srcReg2_data_issue2,
    output reg [31:0] imm_issue2,
    output reg [5:0] destReg_issue2,
    output reg [5:0] ROBNum_issue2
);

    reg [63:0]  VALID;
    reg [31:0]  PC [63:0];
    reg [3:0]   OP [63:0];
    reg [5:0]   DESTREG [63:0];
    reg [5:0]   SRCREG1 [63:0];
    reg [31:0]  SRC1DATA [63:0];
    reg [63:0]  SRC1READY;
    reg [5:0]   SRCREG2 [63:0];
    reg [31:0]  SRC2DATA [63:0];
    reg [63:0]  SRC2READY;
    reg [31:0]  IMM [63:0];
    reg [1:0]   FU [63:0];
    reg [63:0]  FU_READY;
    reg [5:0]   ROB [63:0];

    integer i;
    integer j;
    integer k;
    reg [1:0] issued = 0;
    reg [2:0] fu_taken;
    reg [1:0] alu_round_robin = 0;
    reg inc_round_robin = 0;
    // reg [5:0] rob_round_robin = 0;

    // output group registers ...
    reg [31:0] PC_issue [2:0];
    reg [3:0] optype_issue [2:0];
    reg [1:0] aluNum_issue [2:0];
    reg [31:0] srcReg1_data_issue [2:0];
    reg [31:0] srcReg2_data_issue [2:0];
    reg [31:0] imm_issue [2:0];
    reg [5:0] destReg_issue [2:0];
    reg [5:0] ROBNum_issue [2:0];

    // operation parameter
    parameter ADD   =  4'd1;
    parameter ADDI  =  4'd2;
    parameter LUI   =  4'd3;
    parameter ORI   =  4'd4;
    parameter XOR   =  4'd5;
    parameter SRAI  =  4'd6;
    parameter LB    =  4'd7;
    parameter LW    =  4'd8;
    parameter SB    =  4'd9;
    parameter SW    =  4'd10;

    reg [3:0] op_type;
    always @(*) begin
        if (~rstn) begin
            op_type <= 4'd0;
        end
        else begin
            op_type = 4'd0;
            case (opcode_in)
                7'b0110011: begin // R-type
                    case (funct3_in)
                        3'b000: op_type = ADD;
                        3'b100: op_type = XOR;
                    endcase
                end
                7'b0010011: begin // I-type
                    case (funct3_in)
                        3'b000: op_type = ADDI;
                        3'b101: op_type = SRAI;
                        3'b110: op_type = ORI;
                    endcase
                end
                7'b0110111: op_type = LUI; // U-type
                7'b0000011: begin // Load
                    case (funct3_in)
                        3'b000: op_type = LB;
                        3'b010: op_type = LW;
                    endcase
                end
                7'b0100011: begin // Store
                    case (funct3_in)
                        3'b000: op_type = SB;
                        3'b010: op_type = SW;
                    endcase
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin // set UIQ entries to 0 at restart ...
            stall_out = 1'b0;
            VALID = 'b0;
            SRC1READY = 'b0;
            SRC2READY = 'b0;
            FU_READY = 'b0;
            for (i=0; i<64; i=i+1) begin
                PC[i] = 'b0;
                OP[i] = 'b0;
                DESTREG[i] = 'b0;
                SRCREG1[i] = 'b0;
                SRC1DATA[i] = 'b0;
                SRCREG2[i] = 'b0;
                SRC2DATA[i] = 'b0;
                IMM[i] = 'b0;
                FU[i] = 'b0;
                ROB[i] = 'b0;
            end
        end else begin
            if (~stall_in && op_type != 0) begin 
            // check first that a valid instruction is being entered and that processor is not stalled ...
                for (i=0; i<64; i=i+1) begin
                    if (~VALID[i]) begin // find the first invalid (vacant) entry ...
                        VALID[i] = 1'b1;
                        SRC1READY[i] = 1'b0;
                        SRC2READY[i] = 1'b0;
                        
                        // load dispatch data ...
                        PC[i] = PC_in;
                        OP[i] = op_type;
                        DESTREG[i] = destReg_p_in;
                        IMM[i] = imm_in;

                        SRCREG1[i] = srcReg1_p_in;
                        SRCREG2[i] = srcReg2_p_in;

                        if (srcReg1_ready_ROB_in) begin
                            SRC1READY[i] = 1'b1;
                            SRC1DATA[i] = srcReg1_data_ARF_in;
                        end
                        if (srcReg2_ready_ROB_in) begin
                            SRC2READY[i] = 1'b1;
                            SRC2DATA[i] = srcReg2_data_ARF_in;
                        end

                        // handling special cases: 
                        if (op_type == LUI) begin
                            SRC1READY[i]   = 1'b1;
                            SRC1DATA[i]    = 32'b0;
                        end
                        if ((op_type == LUI) || (op_type == ORI) || (op_type == SRAI) || (op_type == ADDI)|| (op_type == LW) || (op_type == LB)) begin
                            SRC2READY[i]   = 1'b1;
                            SRC2DATA[i]    = 32'b0;
                        end
                        
                        // assign functional units and ROB entries round robin ...
                        ROB[i] = ROBNum_in;
                        // ROB[i] = rob_round_robin;
                        if (op_type == LW || op_type == LB || op_type == SW || op_type == SB) begin
                            FU[i] = 2'd2;
                            inc_round_robin = 1'b0;
                            if (alu_round_robin == 2'd2) begin
                                alu_round_robin = 2'd0;
                            end
                        end else begin
                            FU[i] = alu_round_robin;
                            inc_round_robin = 1'b1;
                        end
                        
                        if (inc_round_robin) begin
                            alu_round_robin = alu_round_robin+1;
                            if (alu_round_robin == 2'd3) begin
                                alu_round_robin = 2'd0;
                            end
                        end
                        $display("PC: %0h ==> assigned to ALU: %0d", PC[i], FU[i]);
                        // rob_round_robin = rob_round_robin + 1;
                        // if (rob_round_robin == 'd64) begin
                        //     rob_round_robin = 'd0;
                        // end
                        // need to confirm that the FU is ready before issuing ...
                        i = 65; // break once entered ... 
                    end
                end
                if (i == 64) begin 
                    // stall if no open entries in RS ...
                    stall_out = 1'b1;
                end
            end
        end
    end
    
    // update with incoming signals from ROB and ALUs ...
    always @(*) begin
        for (j=0; j<64; j=j+1) begin
            if (VALID[j]) begin
                // check if allocated ALU unit is available ...
                if (FU[j] == 2'd0 && FU_ready_ALU0_in) begin
                    FU_READY[j] = 1'b1;
                end
                if (FU[j] == 2'd1 && FU_ready_ALU1_in) begin
                    FU_READY[j] = 1'b1;
                end
                if (FU[j] == 2'd2 && FU_ready_ALU2_in) begin
                    FU_READY[j] = 1'b1;
                end
                // add additional forwards from MEM and ALU ... 

                if (SRCREG1[j] == srcReg1_reg_ready_ROB_in && ~SRC1READY[j] && srcReg1_ready_ROB_in) begin
                    SRC1READY[j] = 1'b1;
                end
                if (SRCREG2[j] == srcReg2_reg_ready_ROB_in && ~SRC2READY[j] && srcReg2_ready_ROB_in) begin
                    SRC2READY[j] = 1'b1;
                end
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (k=0; k<3; k=k+1) begin
                PC_issue[k] = 'b0;
                optype_issue[k] = 'b0;
                aluNum_issue[k] = 'b0;
                srcReg1_data_issue[k] = 'b0;
                srcReg2_data_issue[k] = 'b0;
                imm_issue[k] = 'b0;
                destReg_issue[k] = 'b0;
                ROBNum_issue[k] = 'b0;
            end
            fu_taken = 'b0;
        end else begin
            issued = 0;
            fu_taken = 'b0;
            for (k=0; k<64; k=k+1) begin
                if(VALID[k])begin
                    $display("%0h, %0b, %0b, %0d, %0b, %0b", PC[k], SRC1READY[k], SRC2READY[k], FU[k], FU_READY[k], fu_taken[FU[k]]);
                end
                if (VALID[k] && SRC1READY[k] && SRC2READY[k] && FU_READY[k] && ~fu_taken[FU[k]]) begin
                    PC_issue[FU[k]] = PC[k];
                    optype_issue[FU[k]] = OP[k];
                    aluNum_issue[FU[k]] = FU[k];
                    srcReg1_data_issue[FU[k]] = SRC1DATA[k];
                    srcReg2_data_issue[FU[k]] = SRC2DATA[k];
                    imm_issue[FU[k]] = IMM[k];
                    destReg_issue[FU[k]] = DESTREG[k];
                    ROBNum_issue[FU[k]] = ROB[k];

                    VALID[k] = 1'b0;
                    fu_taken[FU[k]] = 1'b1;
                    if (issued == 2'd2) begin
                        k = 65; 
                    end else begin
                        issued = issued+1;
                    end 
                end
            end
            $display("/////////////////////////////////////////////////////////////////////////////////////////");
        end
        
        PC_issue0 = PC_issue[0];
        optype_issue0 = optype_issue[0];
        aluNum_issue0 = aluNum_issue[0];
        srcReg1_data_issue0 = srcReg1_data_issue[0];
        srcReg2_data_issue0 = srcReg2_data_issue[0];
        imm_issue0 = imm_issue[0];
        destReg_issue0 = destReg_issue[0];
        ROBNum_issue0 = ROBNum_issue[0];

        PC_issue1 = PC_issue[1];
        optype_issue1 = optype_issue[1];
        aluNum_issue1 = aluNum_issue[1];
        srcReg1_data_issue1 = srcReg1_data_issue[1];
        srcReg2_data_issue1 = srcReg2_data_issue[1];
        imm_issue1 = imm_issue[1];
        destReg_issue1 = destReg_issue[1];
        ROBNum_issue1 = ROBNum_issue[1];

        PC_issue2 = PC_issue[2];
        optype_issue2 = optype_issue[2];
        aluNum_issue2 = aluNum_issue[2];
        srcReg1_data_issue2 = srcReg1_data_issue[2];
        srcReg2_data_issue2 = srcReg2_data_issue[2];
        imm_issue2 = imm_issue[2];
        destReg_issue2 = destReg_issue[2];
        ROBNum_issue2 = ROBNum_issue[2];

    end

endmodule