
module CPU(
    input   clk,
    input   rstn
);
    
    // IF stage signals
    wire [31 : 0]   PC;
    reg [31 : 0]    PC_reg;
    wire [31 : 0]   instr_IF;
    wire            stop_IF;

    // ID stage signals
    wire [31 : 0]   instr_ID;
    wire            stop_ID;

    wire [6 : 0]    opcode_ID;
    wire [2 : 0]    funct3_ID; 
    wire [6 : 0]    funct7_ID;
    wire [4 : 0]    srcReg1_ID;
    wire [4 : 0]    srcReg2_ID;
    wire [4 : 0]    destReg_ID;
    wire [31 : 0]   imm_ID;
    wire [1 : 0]    lwSw_ID;
    wire [1 : 0]    aluOp_ID; 
    wire            regWrite_ID;
    wire            aluSrc_ID;
    wire            branch_ID;
    wire            memRead_ID;
    wire            memWrite_ID;
    wire            memToReg_ID;
    wire            hasImm_ID;
    
    // EX stage signals
    wire [6 : 0]    opcode_EX;
    wire [2 : 0]    funct3_EX; 
    wire [6 : 0]    funct7_EX;
    wire [4 : 0]    srcReg1_EX;
    wire [4 : 0]    srcReg2_EX;
    wire [4 : 0]    destReg_EX;
    wire [31 : 0]   imm_EX;
    wire [1 : 0]    lwSw_EX;
    wire            regWrite_EX;
    wire            memRead_EX;
    wire            memWrite_EX;
    wire            memToReg_EX;
    wire            hasImm_EX;

    wire [5 : 0]    p_srcReg1_EX;
    wire [5 : 0]    p_srcReg2_EX;
    wire [5 : 0]    p_destReg_EX;
    wire            stall_Rename_EX;

    
///////////////////////////////////////////////////////////////////////
//  Fetch Stage
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            PC_reg = 32'b0;
        end
        else begin
            PC_reg = PC_reg + 4;
        end
    end
    assign PC = PC_reg;

    instructionMemory instr_mem (
        .clk            (clk),
        .PC             (PC),
        .rstn           (rstn),
        .instr          (instr_IF),
        .stop           (stop_IF)
    );

///////////////////////////////////////////////////////////////////////
//  Pipeline Registers between Fetch and Decode
    IF_ID_Reg IF_ID_Reg (
        .clk            (clk),
        .rstn           (rstn),
        .inst_IF_in     (instr_IF),
        .stop_in        (stop_IF),
        .inst_ID_out    (instr_ID),
        .stop_out       (stop_ID)
    );
    
///////////////////////////////////////////////////////////////////////
//  Decode Stage
    decode decode_mod(
        .instr          (instr_ID),
        .clk            (clk),
        .rstn           (rstn),
        .opcode         (opcode_ID),
        .funct3         (funct3_ID), 
        .funct7         (funct7_ID), 
        .srcReg1        (srcReg1_ID),
        .srcReg2        (srcReg2_ID),
        .destReg        (destReg_ID),
        .hasImm         (hasImm_ID),
        .imm            (imm_ID), 
        .lwSw           (lwSw_ID),
        .aluOp          (aluOp_ID),
        .regWrite       (regWrite_ID),
        .aluSrc         (aluSrc_ID),
        .branch         (branch_ID),
        .memRead        (memRead_ID),
        .memWrite       (memWrite_ID),
        .memToReg       (memToReg_ID)
    );

///////////////////////////////////////////////////////////////////////
//  Pipeline Registers between Decode and Execution
    ID_EX_Reg ID_EX_Reg (
        .clk            (clk),
        .rstn           (rstn),
        .opcode_in      (opcode_ID),
        .funct3_in      (funct3_ID),
        .funct7_in      (funct7_ID),
        .srcReg1_in     (srcReg1_ID),
        .srcReg2_in     (srcReg2_ID),
        .destReg_in     (destReg_ID),
        .imm_in         (imm_ID),
        .hasImm_in      (hasImm_ID),
        .lwSw_in        (lwSw_ID),
        //.aluOp_in       (aluOp_ID),
        .regWrite_in    (regWrite_ID),
        //.aluSrc_in      (aluSrc_ID),
        //.branch_in      (branch_ID),
        .memRead_in     (memRead_ID),
        .memWrite_in    (memWrite_ID),
        .memToReg_in    (memToReg_ID),
        .opcode_out     (opcode_EX),
        .funct3_out     (funct3_EX),
        .funct7_out     (funct7_EX),
        .srcReg1_out    (srcReg1_EX),
        .srcReg2_out    (srcReg2_EX),
        .destReg_out    (destReg_EX),
        .imm_out        (imm_EX),
        .lwSw_out       (lwSw_EX),
        //.aluOp_out      (aluOp_EX),
        .regWrite_out   (regWrite_EX),
        //.aluSrc_out     (aluSrc_EX),
        //.branch_out     (branch_EX),
        .memRead_out    (memRead_EX),
        .memWrite_out   (memWrite_EX),
        .memToReg_out   (memToReg_EX),
        .hasImm_out     (hasImm_EX)
    );

///////////////////////////////////////////////////////////////////////
//  Rename Process
    rename rename_inst (
        .rstn           (rstn),
        .opcode         (opcode_EX),
        .imm            (imm_EX),
        .sr1            (srcReg1_EX),
        .sr2            (srcReg2_EX),
        .dr             (destReg_EX),
        .hasImm         (hasImm_EX),
        .sr1_p          (p_srcReg1_EX),
        .sr2_p          (p_srcReg2_EX),
        .dr_p           (p_destReg_EX),
        .ROB_num        (),
        .stall          (stall_Rename_EX),
        .old_dr         ()
    );

///////////////////////////////////////////////////////////////////////
//  Unified Issue Queue
    reg [64 : 0] ROB_temp;
    integer i;
    always @(negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 65; i = i + 1) begin
                ROB_temp[i] = 1'b1;
            end
        end
    end

    Unified_Issue_Queue UIQ (
        .clk                    (clk),
        .rstn                   (rstn),
        .opcode_in              (opcode_EX),
        .funct3_in              (funct3_EX),
        .funct7_in              (funct7_EX),
        .rs1_in                 (p_srcReg1_EX),
        .rs1_value_from_ARF_in  ('b0),
        .rs2_in                 (p_srcReg2_EX),
        .rs2_value_from_ARF_in  ('b0),
        .imm_value_in           (imm_EX),
        .rd_in                  (p_destReg_EX),
        .rs1_ready_from_ROB_in  (ROB_temp),
        .rs2_ready_from_ROB_in  (ROB_temp),
        .fu_ready_from_FU_in    (),
        .FU0_flag_in            (),
        .reg_tag_from_FU0_in    (),
        .reg_value_from_FU0_in  (),
        .FU1_flag_in            (),
        .reg_tag_from_FU1_in    (),
        .reg_value_from_FU1_in  (),
        .FU2_flag_in            (),
        .reg_tag_from_FU2_in    (),
        .reg_value_from_FU2_in  (),

        .rs1_out0               (),
        .rs2_out0               (),
        .rd_out0                (),
        .rs1_value_out0         (),
        .rs2_value_out0         (),
        .imm_value_out0         (),
        .fu_number_out0         (),
        .rs1_out1               (),
        .rs2_out1               (),
        .rd_out1                (),
        .rs1_value_out1         (),
        .rs2_value_out1         (),
        .imm_value_out1         (),
        .fu_number_out1         (),
        .rs1_out2               (),
        .rs2_out2               (),
        .rd_out2                (),
        .rs1_value_out2         (),
        .rs2_value_out2         (),
        .imm_value_out2         (),
        .fu_number_out2         (),

        .no_issue_out           (),
        .stall_out              (),
        .tunnel_out             ()
    );






endmodule
