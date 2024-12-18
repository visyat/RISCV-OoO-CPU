`timescale 1ns / 1ps

module CPU(
    input   clk,
    input   rstn
);
    // IF stage signals 
    reg [31:0] PC_IF;
    wire [31:0] instr_IF;
    wire stop_IF;
    
    //ID stage signals 
    wire [31:0] PC_ID;
    wire [31:0] instr_ID;
    wire stop_ID;
    
    wire [6:0] opcode_ID;
    wire [2:0] funct3_ID; 
    wire [6:0] funct7_ID;
    wire [4:0] srcReg1_ID;
    wire [4:0] srcReg2_ID;
    wire [4:0] destReg_ID;
    wire [31:0] imm_ID;
    wire hasImm_ID;
    wire [1:0] lwSw_ID;
    wire [1:0] aluOp_ID;
    wire regWrite_ID;
    wire aluSrc_ID;
    wire branch_ID;
    wire memRead_ID;
    wire memWrite_ID;
    wire memToReg_ID;
    wire storeSize_ID;

    // EX stage signals
    //Pipeline
    wire [31:0] PC_EX; 
    wire [6:0] opcode_EX;
    wire [2:0] funct3_EX; 
    wire [6:0] funct7_EX;
    wire [4:0] srcReg1_EX;
    wire [4:0] srcReg2_EX;
    wire [4:0] destReg_EX;
    wire [31:0] imm_EX;
    wire hasImm_EX;
    wire [1:0] lwSw_EX;
    wire [1:0] aluOp_EX;
    wire regWrite_EX;
    wire aluSrc_EX;
    wire branch_EX;
    wire memRead_EX;
    wire memWrite_EX;
    wire memToReg_EX;
    wire storeSize_EX;

    /*
    REMAINDER OF EX STAGE: 
    * Rename
    * Reorder Buffer (ROB)
    * Architectural Register File (ARF)
    * Unified Issue Queue (UIQ) 
    */
    // Rename ...
    wire [5:0] srcReg1_p_EX; // renamed registers ...
    wire [5:0] srcReg2_p_EX;
    wire [5:0] destReg_p_EX;
    wire [5:0] oldDestReg_rename_EX;
    wire stall_rename_EX;
    
    // ARF ...
    wire [31:0] srcReg1_data_ARF_EX;
    wire [31:0] srcReg2_data_ARF_EX;

    // ROB ...
    wire srcReg1_ready_ROB_EX;
    wire srcReg2_ready_ROB_EX;

    // UIQ ...
    wire stall_UIQ_EX;
    
    wire [31:0] PC_issue0_EX;
    wire [3:0] optype_issue0_EX;
    wire [1:0] aluNum_issue0_EX;
    wire [31:0] srcReg1_data_issue0_EX;
    wire [31:0] srcReg2_data_issue0_EX;
    wire [31:0] imm_issue0_EX;
    wire [5:0] destReg_issue0_EX;
    wire [15:0] ROBNum_issue0_EX;
    
    wire [31:0] PC_issue1_EX;
    wire [3:0] optype_issue1_EX;
    wire [1:0] aluNum_issue1_EX;
    wire [31:0] srcReg1_data_issue1_EX;
    wire [31:0] srcReg2_data_issue1_EX;
    wire [31:0] imm_issue1_EX;
    wire [5:0] destReg_issue1_EX;
    wire [15:0] ROBNum_issue1_EX;

    wire [31:0] PC_issue2_EX;
    wire [3:0] optype_issue2_EX;
    wire [1:0] aluNum_issue2_EX;
    wire [31:0] srcReg1_data_issue2_EX;
    wire [31:0] srcReg2_data_issue2_EX;
    wire [31:0] imm_issue2_EX;
    wire [5:0] destReg_issue2_EX;
    wire [15:0] ROBNum_issue2_EX;

    // ALU ...
    wire [31:0] aluOutput_ALU0_EX;
    wire ready_ALU0_EX;
    
    wire [31:0] aluOutput_ALU1_EX;
    wire ready_ALU1_EX;

    wire [31:0] aluOutput_ALU2_EX;
    wire ready_ALU2_EX;

    // COMPLETE stage signals
    wire [31 : 0]   dr_data_0;
    wire [31 : 0]   complete_pc_0;
    wire [31 : 0]   dr_data_1;
    wire [31 : 0]   complete_pc_1;
    wire [31 : 0]   dr_data_2;
    wire [31 : 0]   complete_pc_2;
    wire [31 : 0]   dr_data_3;
    wire [31 : 0]   complete_pc_3;
    reg  [31 : 0]   dr_data_0_reg;
    reg  [31 : 0]   complete_pc_0_reg;
    reg  [31 : 0]   dr_data_1_reg;
    reg  [31 : 0]   complete_pc_1_reg;
    reg  [31 : 0]   dr_data_2_reg;
    reg  [31 : 0]   complete_pc_2_reg;
    reg  [31 : 0]   dr_data_3_reg;
    reg  [31 : 0]   complete_pc_3_reg;

    wire [5:0]      set_rob_reg_invaild;
    wire [5:0]      regout_from_lsu;
    wire [5:0]      regout_from_lsu2;
    wire [5:0]      regout_from_dm;
    reg             is_store_r;
    wire            is_store;   
    wire [31 : 0]   data_check;
    wire            FU_read_flag_MEM_com;

    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            PC_IF = 32'b0;
        end
        else begin
            PC_IF = PC_IF+ 4;
        end
    end
  
    //IF Stage
    instructionMemory InstrMem (
        // inputs ...
        .clk (clk), 
        .PC (PC_IF),
        .rstn (rstn), 
        
        //outputs
        .instr(instr_IF), 
        .stop(stop_IF)
    );

    //ID Stage
    IF_ID_Reg IF_ID_Reg(
        // inputs ...
        .clk (clk),
        .rstn(rstn),
        .PC_in(PC_IF),
        .inst_IF_in(instr_IF),
        .stop_in(stop_IF),

        // outputs ...
        .PC_out(PC_ID),
        .inst_ID_out(instr_ID),
        .stop_out(stop_ID)
    );

    decode Decode (
        // inputs ...
        .clk (clk),
        .rstn(rstn),
        .instr(instr_ID),
        
        // outputs ...
        .opcode(opcode_ID),
        .funct3(funct3_ID),
        .funct7(funct7_ID),
        .srcReg1(srcReg1_ID),
        .srcReg2(srcReg2_ID),
        .destReg(destReg_ID),
        .imm(imm_ID),
        .hasImm(hasImm_ID),
        .lwSw(lwSw_ID),
        .aluOp(aluOp_ID),
        .regWrite(regWrite_ID),
        .aluSrc(aluSrc_ID),
        .branch(branch_ID),
        .memRead(memRead_ID),
        .memWrite(memWrite_ID),
        .memToReg(memToReg_ID),
        .storeSize(storeSize_ID)
    );

    //EX
    ID_EX_Reg ID_EX_Reg (
        // input ...
        .clk(clk),
        .rstn(rstn),
        // add input to check if stalled at Rename, UIQ, ROB, or IM (stopped)
        // .stall_in(stall_Rename_EX || stall_UIQ_EX)
        .PC_in(PC_ID),
        .opcode_in(opcode_ID),
        .funct3_in(funct3_ID),
        .funct7_in(funct7_ID),
        .srcReg1_in(srcReg1_ID),
        .srcReg2_in(srcReg2_ID),
        .destReg_in(destReg_ID),
        .imm_in(imm_ID),
        .lwSw_in(lwSw_ID),
        .regWrite_in(regWrite_ID),
        .memRead_in(memRead_ID),
        .memWrite_in(memWrite_ID),
        .memToReg_in(memToReg_ID),
        .hasImm_in(hasImm_ID),
        .aluOp_in(aluOp_ID),
        .aluSrc_in(aluSrc_ID),
        .branch_in(branch_ID),
        .storeSize_in(storeSize_ID),
        
        // output ... 
        .PC_out(PC_EX),
        .aluOp_out(aluOp_EX),
        .aluSrc_out(aluSrc_EX),
        .branch_out(branch_EX),
        .hasImm_out(hasImm_EX),
        .opcode_out(opcode_EX),
        .funct3_out(funct3_EX),
        .funct7_out(funct7_EX),
        .srcReg1_out(srcReg1_EX),
        .srcReg2_out(srcReg2_EX),
        .destReg_out(destReg_EX),
        .imm_out(imm_EX),
        .lwSw_out(lsSw_EX),
        .regWrite_out(regWrite_EX),
        .memRead_out(memRead_EX),
        .memWrite_out(memWrite_EX),
        .memToReg_out(memToReg_EX),
        .storeSize_out(storeSize_EX)
        // .stalled()
        // add output state to check that the processor is not stalled ... 
    );
    rename Rename (
        // inputs ...
        .rstn(rstn),
        .sr1(srcReg1_EX),
        .sr2(srcReg2_EX),
        .dr(destReg_EX),
        .opcode(opcode_EX),
        .hasImm(hasImm_EX),
        .imm(imm_EX),
        .ROB_retire(), // need to add retirement to rename module ...
        
        // outputs ...
        .sr1_p(srcReg1_p_EX),
        .sr2_p(srcReg2_p_EX),
        .dr_p(destReg_p_EX),
        .old_dr(oldDestReg_rename_EX),
        .stall(stall_rename_EX)
    );

    // simplified ROB interface ...
    reorder_buffer ROB(
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .instr_PC_0(PC_EX),
        .old_dest_reg_0(oldDestReg_rename_EX),
        .dest_reg_0(destReg_p_EX),
        
        .dest_data_0(),
        .store_add_0(),
        .store_data_0(),

        .complete_pc_0(),
        .complete_pc_1(),
        .complete_pc_2(),
        .complete_pc_3(),
        .new_dr_data_0(),
        .new_dr_data_1(),
        .new_dr_data_2(),
        .new_dr_data_3(),
        .is_store(),
        .UIQ_input_invalid(),
        
        //outputs ...
        .ready_reg(),
        .retire_reg(),
        .stall(),
        .reg_update_ARF_1(),
        .reg_update_ARF_2(),
        .value_update_ARF_1(),
        .value_update_ARF_2(),
        .old_reg_1(),
        .old_reg_2(),

        .sr1_ready_flag(srcReg1_ready_ROB_EX),

        .sr1_reg_ready(),
        .sr2_reg_ready(),

        .sr2_ready_flag(srcReg2_ready_ROB_EX),

        .sr1_value_ready(),
        .sr2_value_ready(),
        .pc_retire_1(),
        .pc_retire_2()
    );

    ARF ARF (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        
        // reading rs1 and rs2 ...
        .read_addr1(srcReg1_p_EX),
        .read_addr2(srcReg2_p_EX),
        .read_en(1'b1), // if an instruction is dispatching ... stalled??
        
        // retiring instructions ...
        .write_en(1'b1),
        // retire 1 ...
        .write_addr1(),
        .write_data1(),
        // retire 2 ...
        .write_addr2(),
        .write_data2() 

        // outputs ...
        .read_data1(srcReg1_data_ARF_EX),
        .read_data2(srcReg2_data_ARF_EX)
    );

    Unified_Issue_Queue UIQ (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .stall_in(1'b0), // need to indicate whether the processor has stalled prior ...
        .PC_in(PC_EX),
        .opcode_in(opcode_EX),
        .funct3_in(funct3_EX),
        .funt7_in(funct7_EX),
        .srcReg1_p_in(srcReg1_p_EX),
        .srcReg2_p_in(srcReg2_p_EX),
        .imm_in(imm_EX),
        .destReg_p_in(destReg_p_EX),
        .srcReg1_data_ARF_in(srcReg1_data_ARF_EX),
        .srcReg2_data_ARF_in(srcReg2_data_ARF_EX),

        // ready flags from ROB ...
        .srcReg1_ready_ROB_in(1'b1),
        .srcReg2_ready_ROB_in(1'b1),

        // ready flags from functional units ...
        .FU_ready_ALU0_in(ready_ALU0_EX),
        .FU_ready_ALU1_in(ready_ALU1_EX),
        .FU_ready_ALU2_in(ready_ALU2_EX),

        // outputs ...
        .stall_out(stall_UIQ_EX),

        .PC_issue0(PC_issue0_EX),
        .optype_issue0(optype_issue0_EX),
        .aluNum_issue0(aluNum_issue0_EX),
        .srcReg1_data_issue0(srcReg1_data_issue0_EX),
        .srcReg2_data_issue0(srcReg2_data_issue0_EX),
        .imm_issue0(imm_issue0_EX),
        .destReg_issue0(destReg_issue0_EX),
        .ROBNum_issue0(ROBNum_issue1_EX),

        .PC_issue1(PC_issue1_EX),
        .optype_issue1(optype_issue1_EX),
        .aluNum_issue1(aluNum_issue1_EX),
        .srcReg1_data_issue1(srcReg1_data_issue1_EX),
        .srcReg2_data_issue1(srcReg2_data_issue1_EX),
        .imm_issue1(imm_issue1_EX),
        .destReg_issue1(destReg_issue1_EX),
        .ROBNum_issue1(ROBNum_issue1_EX),

        .PC_issue2(PC_issue2_EX),
        .optype_issue2(optype_issue2_EX),
        .aluNum_issue2(aluNum_issue2_EX),
        .srcReg1_data_issue2(srcReg1_data_issue2_EX),
        .srcReg2_data_issue2(srcReg2_data_issue2_EX),
        .imm_issue2(imm_issue2_EX),
        .destReg_issue2(destReg_issue2_EX),
        .ROBNum_issue2(ROBNum_issue2_EX)
    );

    ALU ALU0 (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .ALU_NO(2'd0),
        .optype(optype_issue0_EX),
        .alu_number(aluNum_issue0_EX),
        .data_in_sr1(srcReg1_data_issue0_EX),
        .data_in_sr2(srcReg2_data_issue0_EX),
        .data_in_imm(imm_issue0_EX),

        // outputs ...
        .data_out_dr(aluOutput_ALU0_EX),
        .FU_ready(ready_ALU0_EX)
    );
    ALU ALU1 (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .ALU_NO(2'd1),
        .optype(optype_issue1_EX),
        .alu_number(aluNum_issue1_EX),
        .data_in_sr1(srcReg1_data_issue1_EX),
        .data_in_sr2(srcReg2_data_issue1_EX),
        .data_in_imm(imm_issue1_EX),

        // outputs ...
        .data_out_dr(aluOutput_ALU1_EX),
        .FU_ready(ready_ALU1_EX)
    );
    ALU ALU2 (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .ALU_NO(2'd2),
        .optype(optype_issue2_EX),
        .alu_number(aluNum_issue2_EX),
        .data_in_sr1(srcReg1_data_issue2_EX),
        .data_in_sr2(srcReg2_data_issue2_EX),
        .data_in_imm(imm_issue2_EX),

        // outputs ...
        .data_out_dr(aluOutput_ALU2_EX),
        .FU_ready(ready_ALU2_EX)
    );

    //MEM
    
    //COMPLETE 
    /*
        always @(*) begin
            is_store_r = 1'b0;
            if(tunnel_MEM[0]) begin
                dr_data_0_reg= destReg_data_ALU0_MEM;
                complete_pc_0_reg = PC_issue0_MEM;
            end
            else begin
                dr_data_0_reg= 32'd1;
                complete_pc_0_reg= 32'd1;
            end

            if(tunnel_MEM[1]) begin
                dr_data_1_reg= destReg_data_ALU1_MEM;
                complete_pc_1_reg= PC_issue1_MEM;
            end
            else begin
                dr_data_1_reg = 32'd1;
                complete_pc_1_reg = 32'd1;
            end
            
            if(tunnel_MEM[2]) begin
                complete_pc_2_reg           = PC_issue2_MEM;
                if (FU_write_flag_com && ~FU_read_flag_MEM_com) begin
                    is_store_r= 1'b1;
                end
                else begin
                    dr_data_2_reg = destReg_data_ALU1_MEM;
                end
            end
            else begin
                dr_data_2_reg    = 32'd1;
                complete_pc_2_reg           = 32'd1;
            end

            if(fromLSQ_MEM) begin
                dr_data_3_reg    = load_data_DataMem_MEM;
                complete_pc_3_reg           = pc_ls_comp;
            end
            else begin
                dr_data_3_reg    = 32'd1;
                complete_pc_3_reg           = 32'd1;
            end
        end
        assign dr_data_0 = dr_data_0_reg;
        assign complete_pc_0        = complete_pc_0_reg;
        assign dr_data_1 = dr_data_1_reg;
        assign complete_pc_1        = complete_pc_1_reg;
        assign dr_data_2 = dr_data_2_reg;
        assign complete_pc_2        = complete_pc_2_reg;
        assign dr_data_3 = dr_data_3_reg;
        assign complete_pc_3        = complete_pc_3_reg; 
        assign is_store        = is_store_r;  
    */ 

endmodule
