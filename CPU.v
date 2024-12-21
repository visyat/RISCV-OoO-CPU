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
    wire [31:0] destReg_p_data_EX;
    
    // ARF ...
    wire [31:0] srcReg1_data_ARF_EX;
    wire [31:0] srcReg2_data_ARF_EX;

    // ROB ...
    wire [63:0] ROB_UIQ_issue_ready_EX;
    // wire reg0_ready_ROB_UIQ_EX;
    wire [5:0] reg0_ROB_UIQ_EX;
    wire [31:0] reg0_data_ROB_UIQ_EX;

    // wire reg1_ready_ROB_UIQ_EX;
    wire [5:0] reg1_ROB_UIQ_EX;
    wire [31:0] reg1_data_ROB_UIQ_EX;

    // wire reg2_ready_ROB_UIQ_EX;
    wire [5:0] reg2_ROB_UIQ_EX;
    wire [31:0] reg2_data_ROB_UIQ_EX;
    
    // UIQ ...
    wire stall_UIQ_EX;
    
    wire [31:0] PC_issue0_EX;
    wire [3:0] optype_issue0_EX;
    wire [1:0] aluNum_issue0_EX;
    wire [31:0] srcReg1_data_issue0_EX;
    wire [31:0] srcReg2_data_issue0_EX;
    wire [31:0] imm_issue0_EX;
    wire [5:0] destReg_issue0_EX;
    wire [5:0] ROBNum_issue0_EX;
    
    wire [31:0] PC_issue1_EX;
    wire [3:0] optype_issue1_EX;
    wire [1:0] aluNum_issue1_EX;
    wire [31:0] srcReg1_data_issue1_EX;
    wire [31:0] srcReg2_data_issue1_EX;
    wire [31:0] imm_issue1_EX;
    wire [5:0] destReg_issue1_EX;
    wire [5:0] ROBNum_issue1_EX;

    wire [31:0] PC_issue2_EX;
    wire [3:0] optype_issue2_EX;
    wire [1:0] aluNum_issue2_EX;
    wire [31:0] srcReg1_data_issue2_EX;
    wire [31:0] srcReg2_data_issue2_EX;
    wire [31:0] imm_issue2_EX;
    wire [5:0] destReg_issue2_EX;
    wire [5:0] ROBNum_issue2_EX;

    // ALU ...
    wire [31:0] aluOutput_ALU0_EX;
    wire ready_ALU0_EX;
    wire [31:0] PC_issue0_ALU_EX;
    wire [5:0] destReg_issue0_ALU_EX;
    wire [5:0] ROBNum_issue0_ALU_EX;
    
    wire [31:0] aluOutput_ALU1_EX;
    wire ready_ALU1_EX;
    wire [31:0] PC_issue1_ALU_EX;
    wire [5:0] destReg_issue1_ALU_EX;
    wire [5:0] ROBNum_issue1_ALU_EX;

    wire [31:0] aluOutput_ALU2_EX;
    wire ready_ALU2_EX;
    wire [31:0] PC_issue2_ALU_EX;
    wire [5:0] destReg_issue2_ALU_EX;
    wire [5:0] ROBNum_issue2_ALU_EX;
    wire [3:0] optype_issue2_ALU_EX;

    // MEM stage signals 
    // Pipeline ...
    wire [31:0] PC_issue0_MEM;
    wire [31:0] aluOutput_issue0_MEM;
    wire [5:0] destReg_issue0_MEM;
    wire [5:0] ROBNum_issue0_MEM;

    wire [31:0] PC_issue1_MEM;
    wire [31:0] aluOutput_issue1_MEM;
    wire [5:0] destReg_issue1_MEM;
    wire [5:0] ROBNum_issue1_MEM;

    wire [31:0] PC_issue2_MEM;
    wire [31:0] aluOutput_issue2_MEM;
    wire [5:0] destReg_issue2_MEM;
    wire [5:0] ROBNum_issue2_MEM;
    wire [3:0] optype_issue2_MEM;

    // LSQ ...
    wire [31:0] PC_LSQ_MEM;
    wire [5:0] ROBNum_LSQ_MEM;
    wire [5:0] destReg_LSQ_MEM;
    wire [31:0] lwData_LSQ_MEM;
    wire fromLSQ_MEM;

    wire [31:0] address_issue_LSQ_MEM;
    wire loadStore_issue_LSQ_MEM;
    wire storeSize_issue_LSQ_MEM;
    wire [31:0] swData_issue_LSQ_MEM;
    
    // Cache ...
    wire [31:0] lwData_cache_MEM;
    wire cacheMiss_MEM;

    // Data Memory ...
    wire [31:0] lwData_datamem_MEM;
    wire [31:0] PC_dataMem_MEM;
    wire [5:0] ROB_dataMem_MEM;

    // COMPLETE stage signals
    // Pipeline ...
    wire [31:0] PC_complete0_C; 
    wire [5:0] destReg_complete0_C;
    wire [31:0] destReg_data_complete0_C;
    wire [5:0] ROBNum_complete0_C;

    wire [31:0] PC_complete1_C; 
    wire [5:0] destReg_complete1_C;
    wire [31:0] destReg_data_complete1_C;
    wire [5:0] ROBNum_complete1_C;

    wire [31:0] PC_complete2_C; 
    wire [5:0] destReg_complete2_C;
    wire [31:0] destReg_data_complete2_C;
    wire [5:0] ROBNum_complete2_C;

    // ROB ...
    wire [63:0] renameRetire_ROB_C;

    wire retire1_ROB_C;
    wire [5:0] destReg1_ROB_C;
    wire [31:0] destReg1_data_ROB_C; 

    wire retire2_ROB_C;
    wire [5:0] destReg2_ROB_C;
    wire [31:0] destReg2_data_ROB_C; 

    wire [31:0] PC_retire1_ROB_LSQ_C;
    wire [31:0] PC_retire2_ROB_LSQ_C;

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
        .lwSw_out(lwSw_EX),
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
        .ROB_retire(renameRetire_ROB_C), // need to add retirement to rename module ...
        
        // outputs ...
        .sr1_p(srcReg1_p_EX),
        .sr2_p(srcReg2_p_EX),
        .dr_p(destReg_p_EX),
        .old_dr(oldDestReg_rename_EX),
        .stall(stall_rename_EX),
        .dr_p_data(destReg_p_data_EX)
    );

    //ROB interface ...
    reorder_buffer ROB(
        // inputs ..
        .clk(clk),
        .rstn(rstn),
        
        // dispatch ...
        .dr(destReg_p_EX),
        .old_dr(oldDestReg_rename_EX),
        .instr_PC(PC_EX),
        .opcode(opcode_EX),

        // retire ...
        .complete_pc_0(PC_complete0_C),
        .new_dr_data_0(destReg_data_complete0_C),

        .complete_pc_1(PC_complete1_C),
        .new_dr_data_1(destReg_data_complete1_C),

        .complete_pc_2(PC_complete2_C),
        .new_dr_data_2(destReg_data_complete2_C),

        .retire_rename(renameRetire_ROB_C), // for rename ...
        .stall(),

        // outputs ...
        // issue ready flags ...
        .issue_ready(ROB_UIQ_issue_ready_EX),

        // forward data from  completed instructions ...
        .src0_reg_ready(reg0_ROB_UIQ_EX),
        .src0_data_ready(reg0_data_ROB_UIQ_EX),

        .src1_reg_ready(reg1_ROB_UIQ_EX),
        .src1_data_ready(reg1_data_ROB_UIQ_EX),

        .src2_reg_ready(reg2_ROB_UIQ_EX),
        .src2_data_ready(reg2_data_ROB_UIQ_EX),
        
        // retire ...
        // write to ARF ...
        .retire1(retire1_ROB_C),
        .ARF_reg_1(destReg1_ROB_C),
        .ARF_data_1(destReg1_data_ROB_C),

        .retire2(retire2_ROB_C),
        .ARF_reg_2(destReg2_ROB_C),
        .ARF_data_2(destReg2_data_ROB_C),

        // deallocate in LSQ ...
        .pc_retire1(PC_retire1_ROB_LSQ_C),
        .pc_retire2(PC_retire2_ROB_LSQ_C)
    );

    ARF ARF (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        
        // reading rs1 and rs2 ...
        .read_srcReg1(srcReg1_p_EX),
        .read_srcReg2(srcReg2_p_EX),

        // retirement ... written from ROB ...
        .retire1(retire1_ROB_C),
        .write_addr1(destReg1_ROB_C),
        .write_data1(destReg1_data_ROB_C),

        .retire2(retire2_ROB_C),
        .write_addr2(destReg2_ROB_C),
        .write_data2(destReg2_data_ROB_C),

        // outputs ...
        .read_srcReg1_data(srcReg1_data_ARF_EX),
        .read_srcReg2_data(srcReg2_data_ARF_EX)
    );

    Unified_Issue_Queue UIQ (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .stall_in(1'b0), // need to indicate whether the processor has stalled prior ...
        .PC_in(PC_EX),
        .opcode_in(opcode_EX),
        .funct3_in(funct3_EX),
        .funct7_in(funct7_EX),
        .srcReg1_p_in(srcReg1_p_EX),
        .srcReg2_p_in(srcReg2_p_EX),
        .imm_in(imm_EX),
        .destReg_p_in(destReg_p_EX),
        .srcReg1_data_ARF_in(srcReg1_data_ARF_EX),
        .srcReg2_data_ARF_in(srcReg2_data_ARF_EX),

        // ready flags from ROB ...
        .ROB_issue_ready_in(ROB_UIQ_issue_ready_EX),
        .reg0_ROB_in(reg0_ROB_UIQ_EX),
        // .reg0_ready_ROB_in(reg0_ready_ROB_UIQ_EX),
        .reg0_data_ROB_in(reg0_data_ROB_UIQ_EX),
        
        .reg1_ROB_in(reg1_ROB_UIQ_EX),
        // .reg1_ready_ROB_in(reg1_ready_ROB_UIQ_EX),
        .reg1_data_ROB_in(reg1_data_ROB_UIQ_EX),

        .reg2_ROB_in(reg2_ROB_UIQ_EX),
        // .reg2_ready_ROB_in(reg2_ready_ROB_UIQ_EX),
        .reg2_data_ROB_in(reg2_data_ROB_UIQ_EX),
        .ROBNum_in(ROBNum_EX),

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
        .ROBNum_issue0(ROBNum_issue0_EX),

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
        .PC_in(PC_issue0_EX),
        .destReg_in(destReg_issue0_EX),
        .ROBNum_in(ROBNum_issue0_EX),
        .optype(optype_issue0_EX),
        .alu_number(aluNum_issue0_EX),
        .data_in_sr1(srcReg1_data_issue0_EX),
        .data_in_sr2(srcReg2_data_issue0_EX),
        .data_in_imm(imm_issue0_EX),

        // outputs ...
        .data_out_dr(aluOutput_ALU0_EX),
        .PC_out(PC_issue0_ALU_EX),
        .destReg_out(destReg_issue0_ALU_EX),
        .ROBNum_out(ROBNum_issue0_ALU_EX),
        .optype_out(),
        .FU_ready(ready_ALU0_EX)
    );
    ALU ALU1 (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .ALU_NO(2'd1),
        .PC_in(PC_issue1_EX),
        .destReg_in(destReg_issue1_EX),
        .ROBNum_in(ROBNum_issue1_EX),
        .optype(optype_issue1_EX),
        .alu_number(aluNum_issue1_EX),
        .data_in_sr1(srcReg1_data_issue1_EX),
        .data_in_sr2(srcReg2_data_issue1_EX),
        .data_in_imm(imm_issue1_EX),

        // outputs ...
        .data_out_dr(aluOutput_ALU1_EX),
        .PC_out(PC_issue1_ALU_EX),
        .destReg_out(destReg_issue1_ALU_EX),
        .ROBNum_out(ROBNum_issue1_ALU_EX),
        .optype_out(),
        .FU_ready(ready_ALU1_EX)
    );
    ALU ALU2 (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .ALU_NO(2'd2),
        .PC_in(PC_issue2_EX),
        .destReg_in(destReg_issue2_EX),
        .ROBNum_in(ROBNum_issue2_EX),
        .optype(optype_issue2_EX),
        .alu_number(aluNum_issue2_EX),
        .data_in_sr1(srcReg1_data_issue2_EX),
        .data_in_sr2(srcReg2_data_issue2_EX),
        .data_in_imm(imm_issue2_EX),

        // outputs ...
        .data_out_dr(aluOutput_ALU2_EX),
        .PC_out(PC_issue2_ALU_EX),
        .destReg_out(destReg_issue2_ALU_EX),
        .ROBNum_out(ROBNum_issue2_ALU_EX),
        .optype_out(optype_issue2_ALU_EX),
        .FU_ready(ready_ALU2_EX)
    );

    //MEM
    EX_MEM_Reg EX_MEM_Reg (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .PC_issue0_in(PC_issue0_ALU_EX),
        .aluOutput_issue0_in(aluOutput_ALU0_EX),
        .destReg_issue0_in(destReg_issue0_ALU_EX),
        .ROBNum_issue0_in(ROBNum_issue0_ALU_EX),

        .PC_issue1_in(PC_issue1_ALU_EX),
        .aluOutput_issue1_in(aluOutput_ALU1_EX),
        .destReg_issue1_in(destReg_issue1_ALU_EX),
        .ROBNum_issue1_in(ROBNum_issue1_ALU_EX),

        .PC_issue2_in(PC_issue2_ALU_EX),
        .aluOutput_issue2_in(aluOutput_ALU2_EX),
        .destReg_issue2_in(destReg_issue2_ALU_EX),
        .ROBNum_issue2_in(ROBNum_issue2_ALU_EX),
        .optype_issue2_in(optype_issue2_ALU_EX),
        
        // outputs ... 
        .PC_issue0_out(PC_issue0_MEM),
        .aluOutput_issue0_out(aluOutput_issue0_MEM),
        .destReg_issue0_out(destReg_issue0_MEM),
        .ROBNum_issue0_out(ROBNum_issue0_MEM),

        .PC_issue1_out(PC_issue1_MEM),
        .aluOutput_issue1_out(aluOutput_issue1_MEM),
        .destReg_issue1_out(destReg_issue1_MEM),
        .ROBNum_issue1_out(ROBNum_issue1_MEM),

        .PC_issue2_out(PC_issue2_MEM),
        .aluOutput_issue2_out(aluOutput_issue2_MEM),
        .destReg_issue2_out(destReg_issue2_MEM),
        .ROBNum_issue2_out(ROBNum_issue2_MEM),
        .optype_issue2_out(optype_issue2_MEM)
    );

    Load_Store_Queue LSQ(
        // inputs ...
        .clk(clk),
        .rstn(rstn),

        // from dispatch ...
        .pcDis(PC_EX),
        .memRead(memRead_EX),
        .memWrite(memWrite_EX),
        .storeSize(storeSize_EX),
        .swData(srcReg2_data_ARF_EX),
        
        // from LSU ...
        .pcLsu(PC_issue2_MEM),
        .addressLsu(aluOutput_issue2_MEM),
        .ROBNumLsu(ROBNum_issue2_MEM),
        .destRegLsu(destReg_issue2_MEM),

        // from retirement ...
        .pcRet1(PC_retire1_ROB_LSQ_C), // PENDING FROM ROB ...
        .pcRet2(PC_retire2_ROB_LSQ_C),
        
        // outputs ...
        .pcOut(PC_LSQ_MEM),
        .ROBNumOut(ROBNum_LSQ_MEM),
        .destRegOut(destReg_LSQ_MEM),
        
        // if retrieving data from a speculative store ...
        .lwData(lwData_LSQ_MEM),
        .fromLSQ(fromLSQ_MEM),

        // if issuing to memory ...
        .addressOut(address_issue_LSQ_MEM),
        .loadStore(loadStore_issue_LSQ_MEM),
        .storeSizeOut(storeSize_issue_LSQ_MEM),
        .swDataOut(swData_issue_LSQ_MEM),
        .complete()
    );

    Cache Cache (
        // inputs ...
        .clk(clk),
        .rstn(rstn),

        .PC_in(PC_LSQ_MEM),
        .address_in(address_issue_LSQ_MEM),
        .data_sw(swData_issue_LSQ_MEM),
        .memRead(~loadStore_issue_LSQ_MEM),
        .memWrite(loadStore_issue_LSQ_MEM),
        .storeSize(storeSize_issue_LSQ_MEM),
        .fromLSQ(fromLSQ_MEM),

        // outputs ...
        .lw_data(lwData_cache_MEM),
        .cacheMiss(cacheMiss_MEM)
    );
    dataMemory DataMemory (
        // inputs ...
        .clk(clk),
        .rstn(rstn),
        .PC_in(PC_LSQ_MEM),
        .ROB_in(ROBNum_LSQ_MEM),
        .address(address_issue_LSQ_MEM),
        .dataSw(swData_issue_LSQ_MEM),
        .memRead(~loadStore_issue_LSQ_MEM),
        .memWrite(loadStore_issue_LSQ_MEM),
        .storeSize(storeSize_issue_LSQ_MEM),
        .cacheMiss(cacheMiss_MEM),
        .fromLSQ(fromLSQ_MEM),

        // outputs ...
        .lwData(lwData_datamem_MEM),
        .PC_out(PC_dataMem_MEM),
        .ROB_out(ROB_dataMem_MEM)
    );

    //COMPLETE 
    MEM_C_Reg MEM_C_Reg (
        // inputs ...
        .clk(clk),
        .rstn(rstn),

        .PC_issue0_in(PC_issue0_MEM),
        .aluOutput_issue0_in(aluOutput_issue0_MEM),
        .destReg_issue0_in(destReg_issue0_MEM),
        .ROBNum_issue0_in(ROBNum_issue0_MEM),

        .PC_issue1_in(PC_issue1_MEM),
        .aluOutput_issue1_in(aluOutput_issue1_MEM),
        .destReg_issue1_in(destReg_issue1_MEM),
        .ROBNum_issue1_in(ROBNum_issue1_MEM),

        .PC_issue2_in(PC_issue2_MEM),
        .optype_issue2_in(optype_issue2_MEM),
        .aluOutput_issue2_in(aluOutput_issue2_MEM),
        .destReg_issue2_in(destReg_issue2_MEM),
        .ROBNum_issue2_in(ROBNum_issue2_MEM),

        .PC_issue_LSQ_in(PC_LSQ_MEM),
        .fromLSQ_in(fromLSQ_MEM), // control signals to determine LW source ...
        .cacheMiss_in(cacheMiss_MEM),
        .lwData_LSQ_in(lwData_LSQ_MEM),
        .lwData_cache_in(lwData_cache_MEM),
        .lwData_datamem_in(lwData_datamem_MEM),
        .destReg_issue_LSQ_in(destReg_LSQ_MEM),
        .ROBNum_issue_LSQ_in(ROBNum_LSQ_MEM),

        .PC_issue_dataMem_in(PC_dataMem_MEM),
        .ROBNum_issue_dataMem_in(ROB_dataMem_MEM),

        // outputs ...
        .PC_complete0_out(PC_complete0_C),
        .destReg_complete0_out(destReg_complete0_C),
        .destReg_data_complete0_out(destReg_data_complete0_C),
        .ROBNum_complete0_out(ROBNum_complete0_C),

        .PC_complete1_out(PC_complete1_C),
        .destReg_complete1_out(destReg_complete1_C),
        .destReg_data_complete1_out(destReg_data_complete1_C),
        .ROBNum_complete1_out(ROBNum_complete1_C),

        .PC_complete2_out(PC_complete2_C),
        .destReg_complete2_out(destReg_complete2_C),
        .destReg_data_complete2_out(destReg_data_complete2_C),
        .ROBNum_complete2_out(ROBNum_complete2_C)
    );
endmodule
