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
    wire storeSize_ID:

    // EX stage signals
    //Rename
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
    
    wire [15:0] ROB_num_EX;
    wire [5:0] srcReg1_p_EX;
    wire [5:0] srcReg2_p_EX;
    wire [5:0] destReg_p_EX;
    wire [5:0] oldDestReg_EX;
    wire stall_rename_EX;
    
    //ROB    
    wire [5:0] old_dest_reg_0_EX; 
    wire [5:0] dest_reg_0_EX;
    wire [31:0] dest_data_0_EX; 
    wire store_add_0_EX;
    wire store_data_0_EX;
    wire instr_PC_0_EX; 

    wire [31:0] complete_pc_0_EX;
    wire [31:0] complete_pc_1_EX;
    wire [31:0] complete_pc_2_EX;
    wire [31:0] complete_pc_3_EX;
    
    wire [31:0] new_dr_data_0_EX;
    wire [31:0] new_dr_data_1_EX;
    wire [31:0] new_dr_data_2_EX;
    wire [31:0] new_dr_data_3_EX;

    wire is_dispatching_EX;
    wire is_store;_EX
    wire [5:0] invalid_from_UIQ_EX;

    wire [63:0] retire_EX;
    wire [63:0] ready_EX;

    wire [5:0]    srcReg1_p_EX; //to arf
    wire [31:0]   srcReg1_ARF_data_EX; //to arf
    wire [31:0]   retire_pc1_EX;

    wire [5:0]    srcReg2_p_EX; //to arf
    wire [31:0]   srcReg2_ARF_data_EX; //to arf
    wire [31:0]   retire_pc2_EX;

    wire [5:0]    old_reg_1_EX;
    wire [5:0]    old_reg_2_EX;

    wire          src1_dis_ready_EX;   
    wire          src2_dis_ready_EX;
    wire [5:0]    src1_dis_reg_EX; 
    wire [5:0]    src2_dis_reg_EX;
    wire [31:0]   src1_dis_val_EX;
    wire [31:0]   src2_dis_val_EX;


    //ARF
    wire [31:0] srcReg1_ARF_data_EX;
    wire [31:0] srcReg2_ARF_data_EX;

    //Issue
    wire [31:0] PC_issue0_EX;
    wire [3:0] optype_issue0_EX;
    wire [5:0] srcReg1_issue0_EX;
    wire [5:0] srcReg2_issue0_EX;
    wire [5:0] destReg_issue0_EX;
    wire [31:0] srcReg1_value_issue0_EX;
    wire [31:0] srcReg2_value_issue0_EX;
    wire [31:0] imm_issue0_EX;
    wire [1:0] FU_number_out0_EX;

    wire [31:0] PC_issue1_EX;
    wire [3:0] optype_issue1_EX;
    wire [5:0] srcReg1_issue1_EX;
    wire [5:0] srcReg2_issue1_EX;
    wire [5:0] destReg_issue1_EX;
    wire [31:0] srcReg1_value_issue1_EX;
    wire [31:0] srcReg2_value_issue1_EX;
    wire [31:0] imm_issue1_EX;
    wire [1:0] FU_number_out1_EX;

    wire [31:0] PC_issue2_EX;
    wire [3:0] optype_issue2_EX;
    wire [5:0] srcReg1_issue2_EX;
    wire [5:0] srcReg2_issue2_EX;
    wire [5:0] destReg_issue2_EX;
    wire [31:0] srcReg1_value_issue2_EX;
    wire [31:0] srcReg2_value_issue2_EX;
    wire [31:0] imm_issue2_EX;
    wire [1:0] FU_number_out2_EX;

    wire [31:0] PC_issue_LSU_EX;
    wire [3:0] optype_issue_LSU_EX;
    wire [5:0] srcReg1_issue_LSU_EX;
    wire [5:0] srcReg2_issue_LSU_EX;
    wire [5:0] destReg_issue_LSU_EX;
    wire [31:0] srcReg1_value_issue_LSU_EX;
    wire [31:0] srcReg2_value_issue_LSU_EX;
    wire [31:0] imm_issue_LSU_EX;
    wire [1:0] FU_number_out2_EX;

    wire UIQ_no_issue;
    wire UIQ_stall;
    wire [3:0] UIQ_tunnel_out;

    //ALUs
    wire [3:0] optype_issue0_EX;
    wire [31:0] srcReg1_value_issue0_EX;
    wire [31:0] srcReg2_value_issue0_EX;
    wire [31:0] imm_issue0_EX;
    wire [5:0] destReg_issue0_EX;
    wire [31:0] destReg_data_ALU0_EX;
    wire [5:0] destReg_ALU0_EX;
    wire ALU0_ready;
    wire ALU0_occ;

    wire [3:0] optype_issue1_EX;
    wire [31:0] srcReg1_value_issue1_EX;
    wire [31:0] srcReg2_value_issue1_EX;
    wire [31:0] imm_issue1_EX;
    wire [5:0] destReg_issue1_EX;
    wire [31:0] destReg_data_ALU1_EX;
    wire [5:0] destReg_ALU1_EX;
    wire ALU1_ready;
    wire ALU1_occ;

    wire [3:0] optype_issue2_EX;
    wire [31:0] srcReg1_value_issue2_EX;
    wire [31:0] srcReg2_value_issue2_EX;
    wire [31:0] imm_issue2_EX;
    wire [5:0] destReg_issue2_EX;
    wire [31:0] destReg_data_ALU2_EX;
    wire [5:0] destReg_ALU2_EX;
    wire ALU2_ready;
    wire ALU2_occ;

    wire [3:0] optype_issue_LSU_EX;
    wire [31:0] srcReg1_value_issue_LSU_EX;
    wire [31:0] srcReg2_value_issue_LSU_EX;
    wire [31:0] imm_issue_LSU_EX;
    wire [5:0] destReg_issue_LSU_EX;
    wire [31:0] destReg_data_ALU_LSU_EX;
    wire [5:0] destReg_ALU_LSU_EX;
    wire LSU_ready;
    wire LSU_occ;

    // EX_MEM pipeline register signals
    wire [31 : 0]   rd_result_fu0_MEM;
    wire [31 : 0]   pc_fu0_MEM;
    wire [31 : 0]   rd_result_fu1_MEM;
    wire [31 : 0]   pc_fu1_MEM;
    wire [31 : 0]   rd_result_fu2_MEM;
    wire [31 : 0]   pc_fu2_MEM;
    wire            op_write_MEM;
    wire            op_read_MEM;
    wire [3 : 0]    mem_op;
    wire [2 : 0]    tunnel_MEM;

    //MEM stage signals 
    wire [3:0] tunnel_out_MEM;

    wire [31:0] PC_issue0_MEM;
    wire [31:0] destReg_data_ALU0_MEM;
    wire [31:0] PC_issue1_MEM;
    wire [31:0] destReg_data_ALU1_MEM;
    wire [31:0] PC_issue2_MEM;
    wire [31:0] destReg_data_ALU2_MEM;
    wire [31:0] PC_issue_LSU_MEM;
    wire [31:0] compute_address_LSU_MEM;
    
    wire [31:0] PC_LSQ_MEM;
    wire [31:0] address_LSQ_MEM;
    wire [31:0] load_data_LSQ_MEM;
    wire loadStore_LSQ_MEM;
    wire storeSize_LSQ_MEM;
    wire [31:0] swData_LSQ_MEM;
    wire fromLSQ_MEM;
    wire complete_LSQ_MEM;

    wire [31:0] load_data_DataMem_MEM;

    // MEM stage signals
    wire [31 : 0]   mem_addr_from_LSU;
    wire [31 : 0]   store_data_to_mem_from_LSU;
    wire [31 : 0]   load_data_to_comp_from_LSU;
    wire [31 : 0]   inst_pc_from_LSU;
    wire            write_en_from_LSU;
    wire            read_en_from_LSU;
    wire [3 : 0]    op_from_LSU;
    wire            load_data_from_lsq;
    wire [31 : 0]   inst_pc_from_mem;
    wire [31 : 0]   lwData_from_mem;
    wire            data_vaild_from_mem;

    // pipeline register between MEM and COMPLETE stage
    wire [31 : 0]   lwData_comp;
    wire [31 : 0]   pc_ls_comp;
    wire            vaild_comp;
    wire            lsq_comp;
    wire            FU_write_flag_com;
    wire            FU_read_flag_com;

    // COMPLETE stage signals
    wire [31 : 0]   rd_result_comp_0;
    wire [31 : 0]   pc_comp_0;
    wire [31 : 0]   rd_result_comp_1;
    wire [31 : 0]   pc_comp_1;
    wire [31 : 0]   rd_result_comp_2;
    wire [31 : 0]   pc_comp_2;
    wire [31 : 0]   rd_result_comp_3;
    wire [31 : 0]   pc_comp_3;
    reg  [31 : 0]   rd_result_comp_0_reg;
    reg  [31 : 0]   pc_comp_0_reg;
    reg  [31 : 0]   rd_result_comp_1_reg;
    reg  [31 : 0]   pc_comp_1_reg;
    reg  [31 : 0]   rd_result_comp_2_reg;
    reg  [31 : 0]   pc_comp_2_reg;
    reg  [31 : 0]   rd_result_comp_3_reg;
    reg  [31 : 0]   pc_comp_3_reg;

    wire [5:0]      set_rob_reg_invaild;
    wire [5:0]      regout_from_lsu;
    wire [5:0]      regout_from_lsu2;
    wire [5:0]      regout_from_dm;

    wire            has_stored;   
    wire [31 : 0]   data_check;
    wire            FU_read_flag_MEM_com;



    
    //IF Stage
    instructionMemory instr_mem(
        .clk (clk), 
        .PC (PC_IF),
        .rstn (rstn), 
        
        //outputs
        .instr(instr_IF), 
        .stop(stop_IF)
    );

    //ID Stage
    IF_ID_Reg IF_ID_pipe(
        .clk (clk),
        .rstn(rstn),
        
        .PC_in(PC_IF),
        .inst_IF_in(instr_IF),
        .stop_in(stop),

        .PC_out(PC_ID),
        .inst_ID_out(instr_ID),
        .stop_out(stop_ID)
    );

    decode decode_mod(
        .instr(instr_ID),
        .clk (clk),
        .rstn(rstn),
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

    //Ex
    ID_EX_Reg ID_EX_pipe (
        .clk(clk),
        .rstn(rstn),
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
    );
    rename rename_mod (
        .sr1(srcReg1_EX), 
        .sr2(srcReg2_EX),
        .dr(destReg_EX),
        .rstn(rstn),
        .opcode(opcode_EX),
        .hasImm(hasImm_EX),
        .imm(imm_EX),
        .ROB_num(ROB_num_EX),
        .sr1_p(srcReg1_p_EX),
        .sr2_p(srcReg2_p_EX),
        .dr_p(destReg_p_EX),
        .old_dr(oldDestReg_EX),
        .stall(stall_rename_EX)  
    );

    reorder_buffer ROB(
        .clk(clk),
        .rstn(rstn),
        .old_dest_reg_0(old_dest_reg_0_EX),//from rename      
        .dest_reg_0(dest_reg_0_EX),   //from rename
        .dest_data_0(dest_data_0_EX),  //from rename    
        .store_add_0(store_add_0_EX),  //from rename
        .store_data_0(store_data_0_EX), //from rename
        .instr_PC_0(instr_PC_0_EX),    //from rename    

        .complete_pc_0(complete_pc_0_EX), //TODO: FIX VARIABLE NAMES
        .complete_pc_1(complete_pc_1_EX),
        .complete_pc_2(complete_pc_2_EX),
        .complete_pc_3(complete_pc_3_EX),
        
        .new_dr_data_0(new_dr_data_0_EX), 
        .new_dr_data_1(new_dr_data_1_EX),
        .new_dr_data_2(new_dr_data_2_EX),
        .new_dr_data_3(new_dr_data_3_EX),

        .is_dispatching(is_dispatching_EX),
        .is_store(is_store_EX),
        .UIQ_input_invalid(invalid_from_UIQ_EX),

        .retire(retire_EX),
        .reg_update_ARF_1(srcReg1_p_EX),
        .reg_update_ARF_2(srcReg2_p_EX),
        .value_update_ARF_1(srcReg1_ARF_data_EX),
        .value_update_ARF_2(srcReg2_ARF_data_EX),
        .ready(ready_EX)

        .old_reg_1(old_reg_1_EX),
        .old_reg_2(old_reg_2_EX),

        .src1_ready_flag(src1_dis_ready_EX),    
        .src2_ready_flag(src2_dis_ready_EX),
        .sr1_reg_ready(src1_dis_reg_EX),   
        .sr2_reg_ready(src2_dis_reg_EX),
        .sr1_value_ready(src1_dis_val_EX),
        .sr2_value_ready(src2_dis_val_EX),

        .pc_retire_1(retire_pc1_EX),
        .pc_retire_2(retire_pc2_EX)
    );

    ARF ARF_mod(
        .clk(clk),
        .rstn(rstn),
        .read_addr1(srcReg1_p_EX),
        .read_addr2(srcReg2_p_EX),
        .read_en(1'b1),

        // from ROB ...
        .write_addr1(src1_dis_reg_EX),
        .write_data1(src1_dis_val_EX),
        .old_addr1(old_reg_1_EX)),
        .write_addr2(src2_dis_reg_EX),
        .write_data2(src2_dis_val_EX),
        .old_addr2(old_reg_2_EX),
        .write_en(1'b1),
        
        // output ...
        .read_data1(srcReg1_ARF_data_EX),
        .read_data2(srcReg2_ARF_data_EX)
    );

    Unified_Issue_Queue UIQ(
        .clk(clk),
        .rstn(rstn),

        // info from decode and rename ...
        .PC_in(PC_EX),
        .opcode_in(opcode_EX),
        .funct3_in(funct3_EX),
        .funct7_in(funct7_EX),
        .rs1_in(srcReg1_p_EX),
        .rs1_value_from_ARF_in(srcReg1_ARF_data_EX),
        .rs2_in(srcReg2_p_EX),
        .rs2_value_from_ARF_in(srcReg2_ARF_data_EX),
        .imm_value_in(imm_EX),
        .rd_in(destReg_p_EX),

        // info from ROB ...
        .rs1_ready_from_ROB_in(src1_dis_ready_EX),
        .rs2_ready_from_ROB_in(src2_dis_ready_EX),

        // info from ALU units ... 
        .fu_ready_from_FU_in(fu_ready_from_FU),

        .FU0_flag_in(ALU0_occ),
        .reg_tag_from_FU0_in(destReg_ALU0_EX),
        .reg_value_from_FU0_in(destReg_data_ALU0_EX),
        .FU1_flag_in(ALU1_occ),
        .reg_tag_from_FU1_in(destReg_ALU1_EX),
        .reg_value_from_FU1_in(destReg_data_ALU1_EX),
        .FU2_flag_in(ALU2_occ),
        .reg_tag_from_FU2_in(destReg_ALU2_EX),
        .reg_value_from_FU2_in(destReg_data_ALU2_EX),
        .LSU_flag_in(LSU_occ),
        .reg_tag_from_LSU_in(destReg_LSU_EX),

        // issue 1 ...
        .PC_out0(PC_issue0_EX),
        .optype_out0(optype_issue0_EX),
        .rs1_out0(srcReg1_issue0_EX),
        .rs2_out0(srcReg2_issue0_EX),
        .rd_out0(destReg_issue0_EX),
        .rs1_value_out0(srcReg1_value_issue0_EX),
        .rs2_value_out0(srcReg2_value_issue0_EX),
        .imm_value_out0(imm_issue0_EX),
        .fu_number_out0(FU_number_out0_EX),

        // issue 2 ...
        .PC_out1(PC_issue1_EX),
        .optype_out1(optype_issue1_EX),
        .rs1_out1(srcReg1_issue1_EX),
        .rs2_out1(srcReg2_issue1_EX),
        .rd_out1(destReg_issue1_EX),
        .rs1_value_out1(srcReg1_value_issue1_EX),
        .rs2_value_out1(srcReg2_value_issue1_EX),
        .imm_value_out1(imm_issue1_EX),
        .fu_number_out1(FU_number_out1_EX),

        // issue 3 ...
        .PC_out2(PC_issue2_EX),
        .optype_out2(optype_issue2_EX),
        .rs1_out2(srcReg1_issue2_EX),
        .rs2_out2(srcReg2_issue2_EX),
        .rd_out2(destReg_issue2_EX),
        .rs1_value_out2(srcReg1_value_issue2_EX),
        .rs2_value_out2(srcReg2_value_issue2_EX),
        .imm_value_out2(imm_issue2_EX),
        .fu_number_out2(FU_number_out2_EX),

        // issue 4 LSU ...
        .PC_out_LSU(PC_issue_LSU_EX),
        .optype_out_LSU(optype_issue_LSU_EX),
        .rs1_out_LSU(srcReg1_issue_LSU_EX),
        .rs2_out_LSU(srcReg2_issue_LSU_EX),
        .rd_out_LSU(destReg_issue_LSU_EX),
        .rs1_value_out_LSU(srcReg1_value_issue_LSU_EX),
        .rs2_value_out_LSU(srcReg2_value_issue_LSU_EX),
        .imm_value_out_LSU(imm_issue_LSU_EX),
        .fu_number_out_LSU(fu_number_out_LSU),

        // general output ...
        .no_issue_out(UIQ_no_issue),
        .stall_out(UIQ_stall),
        .tunnel_out(UIQ_tunnel_out)
    );

    //ALUs
    ALU alu0(
        .ALU_NO         (2'b00)
        .clk            (clk),
        .rstn           (rstn),
        .alu_number     (UIQ_tunnel_out),
        .optype         (optype_issue0_EX),
        .data_in_sr1    (srcReg1_value_issue0_EX),
        .data_in_sr2    (srcReg2_value_issue0_EX),
        .data_in_imm    (imm_issue0_EX),
        .dr_in          (destReg_issue0_EX),

        .data_out_dr    (destReg_data_ALU0_EX),
        .dr_out         (destReg_ALU0_EX),
        .FU_ready       (ALU0_ready),
        .FU_occ         (ALU0_occ)
    );
    ALU alu1(
        .ALU_NO         (2'b01)
        .clk            (clk),
        .rstn           (rstn),
        .alu_number     (UIQ_tunnel_out),
        .optype         (optype_issue1_EX),
        .data_in_sr1    (srcReg1_value_issue1_EX),
        .data_in_sr2    (srcReg2_value_issue1_EX),
        .data_in_imm    (imm_issue1_EX),
        .dr_in          (destReg_issue1_EX),

        .data_out_dr    (destReg_data_ALU1_EX),
        .dr_out         (destReg_ALU1_EX),
        .FU_ready       (ALU1_ready),
        .FU_occ         (ALU1_occ)
    );
    ALU alu2(
        .ALU_NO         (2'b10)
        .clk            (clk),
        .rstn           (rstn),
        .alu_number     (UIQ_tunnel_out),
        .optype         (optype_issue2_EX),
        .data_in_sr1    (srcReg1_value_issue2_EX),
        .data_in_sr2    (srcReg2_value_issue2_EX),
        .data_in_imm    (imm_issue2_EX),
        .dr_in          (destReg_issue2_EX),

        .data_out_dr    (destReg_data_ALU2_EX),
        .dr_out         (destReg_ALU2_EX),
        .FU_ready       (ALU2_ready),
        .FU_occ         (ALU2_occ)
    );
    ALU lsu(
        .ALU_NO         (2'b11)
        .clk            (clk),
        .rstn           (rstn),
        .alu_number     (UIQ_tunnel_out),
        .optype         (optype_issue_LSU_EX),
        .data_in_sr1    (srcReg1_value_issue_LSU_EX),
        .data_in_sr2    (srcReg2_value_issue_LSU_EX),
        .data_in_imm    (imm_issue_LSU_EX),
        .dr_in          (destReg_issue_LSU_EX),

        .data_out_dr    (compute_address_LSU_EX),
        .dr_out         (destReg_LSU_EX),
        .FU_ready       (LSU_ready),
        .FU_occ         (LSU_occ)
    );
    assign fu_ready_from_FU = {LSU_ready, FU_ready_alu2, FU_ready_alu1, FU_ready_alu0};

    //MEM
    EX_MEM_Reg EX_MEM_Reg_inst(
        .clk                (clk),
        .rstn               (rstn),
        .tunnel_in          (UIQ_tunnel_out),

        .rd_result_fu0_in   (destReg_data_ALU0_EX),
        .pc_fu0_in          (PC_issue0_EX),

        .rd_result_fu1_in   (destReg_data_ALU1_EX),
        .pc_fu1_in          (PC_issue1_EX),

        .rd_result_fu2_in   (destReg_data_ALU2_EX),
        .pc_fu2_in          (PC_issue2_EX),

        .result_lsu_in      (compute_address_LSU_EX),
        .pc_lsu_in          (PC_issue_LSU_EX),

        // .op_write_in        (FU_write_flag),
        // .op_read_in         (FU_read_flag),

        .tunnel_out         (tunnel_out_MEM),
        .rd_result_fu0_out  (destReg_data_ALU0_MEM),
        .pc_fu0_out         (PC_issue0_MEM),

        .rd_result_fu1_out  (destReg_data_ALU1_MEM),
        .pc_fu1_out         (PC_issue1_MEM),

        .rd_result_fu2_out  (destReg_data_ALU2_MEM),
        .pc_fu2_out         (PC_issue2_MEM),

        .result_lsu_out     (compute_address_LSU_MEM),
        .pc_lsu_out         (PC_issue_LSU_MEM),

        // .op_write_out       (op_write_MEM),
        // .op_read_out        (op_read_MEM),
        // .op_out             (mem_op)
    );

    // make some changes to LSQ to support SB in addition to SW ...
    LSQ LSQ_mod(
        .clk(clk), 
        .rstn(rstn),
        
        // from dispatch ...
        .pcDis(PC_EX),
        .memRead(memRead_EX),
        .memWrite(memRead_EX),
        .storeSize(storeSize_EX),
        .swData(srcReg2_ARF_data_EX),
        
        // from lsu ... 
        .pcLsu(PC_issue_LSU_MEM),
        .addressLsu(compute_address_LSU_MEM),
        
        // from retirement ...
        .pcRet1(retire_pc1_EX),
        .pcRet2(retire_pc2_EX),

        // outputs ...
        .pcOut(PC_LSQ_MEM),
        .addressOut(address_LSQ_MEM),
        .lwData(load_data_LSQ_MEM),
        .fromLSQ(fromLSQ_MEM),
        .loadStore(loadStore_LSQ_MEM),
        .storeSizeOut(storeSize_LSQ_MEM),
        .swDataOut(swData_LSQ_MEM),
        .complete(complete_LSQ_MEM)
    );

    //data memory may need some debugging and need to add cache ...
    dataMemory dataMem_mod(
        .clk(clk),
        .rstn(rstn),
        
        //inputs 
        .fromLSQ(fromLSQ_MEM),
        .address(address_LSQ_MEM), 
        .dataSw(swData_LSQ_MEM),
        .memRead(~loadStore_LSQ_MEM),
        .memWrite(loadStore_LSQ_MEM),
        .storeSize(storeSize_LSQ_MEM),
        .cacheMiss(1'b1),

        //outputs
        .lwData(load_data_DataMem_MEM)
    );

    //Complete

    ///////////////////////////////////////////////////////////////////////
    // pipeline register between MEM and COMPLETE stage
    MEM_C_Reg MEM_C_Reg_inst (   //TODO:ADJUST VARIABLE NAMES
        
        .clk                (clk),
        .rstn               (rstn),
        .from_lsq           (load_data_LSQ_MEM),
        .mem_vaild          (data_vaild_from_mem),

        .lwData_from_LSQ_in (load_data_LSQ_MEM),
        .lwData_from_MEM_in (load_data_DataMem_MEM),
        .pc_from_LSU_in     (PC_LSQ_MEM),
        //.pc_from_MEM_in     (inst_pc_from_mem),
        //.FU_write_flag      (FU_write_flag),
        //.FU_read_flag       (FU_read_flag),
        //.FU_read_flag_MEM   (op_read_MEM),

        .lwData_out         (load_data_DataMem_MEM),
        .pc_out             (pc_ls_comp),
        .vaild_out          (vaild_comp),
        .lsq_out            (lsq_comp),
        .FU_write_flag_com  (FU_write_flag_com),
        .FU_read_flag_com   (FU_read_flag_com),
        .FU_read_flag_MEM_com(FU_read_flag_MEM_com)


    //complete 
    always @(*) begin
        is_store_reg = 1'b0;
        if(tunnel_MEM[0]) begin
            rd_result_comp_0_reg    = rd_result_fu0_MEM;
            pc_comp_0_reg           = pc_fu0_MEM;
        end
        else begin
            rd_result_comp_0_reg    = 32'd1;
            pc_comp_0_reg           = 32'd1;
        end

        if(tunnel_MEM[1]) begin
            rd_result_comp_1_reg    = rd_result_fu1_MEM;
            pc_comp_1_reg           = pc_fu1_MEM;
        end
        else begin
            rd_result_comp_1_reg    = 32'd1;
            pc_comp_1_reg           = 32'd1;
        end
        
        if (~FU_read_flag_com) begin
            if(tunnel_MEM[2]) begin
                pc_comp_2_reg           = pc_fu2_MEM;
                if (FU_write_flag_com && ~FU_read_flag_MEM_com) begin
                    is_store_reg = 1'b1;
                end
                else begin
                    rd_result_comp_2_reg = rd_result_fu2_MEM;
                end
            end
            else begin
                rd_result_comp_2_reg    = 32'd1;
                pc_comp_2_reg           = 32'd1;
            end
        end

        if(vaild_comp || lsq_comp) begin
            rd_result_comp_3_reg    = lwData_comp;
            pc_comp_3_reg           = pc_ls_comp;
        end
        else begin
            rd_result_comp_3_reg    = 32'd1;
            pc_comp_3_reg           = 32'd1;
        end
    end

    assign rd_result_comp_0 = rd_result_comp_0_reg;
    assign pc_comp_0        = pc_comp_0_reg;
    assign rd_result_comp_1 = rd_result_comp_1_reg;
    assign pc_comp_1        = pc_comp_1_reg;
    assign rd_result_comp_2 = rd_result_comp_2_reg;
    assign pc_comp_2        = pc_comp_2_reg;
    assign rd_result_comp_3 = rd_result_comp_3_reg;
    assign pc_comp_3        = pc_comp_3_reg; 
    assign is_store         = is_store_reg;   

endmodule
