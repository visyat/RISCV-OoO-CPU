
`timescale 1ns / 1ps

module reorder_buffer(
    // input ...
    input clk, 
    input rstn,
    
    // dispatch ... 
    input [5:0] dr,
    input [5:0] old_dr,
    input [31:0] instr_PC,
    input [6:0] opcode,
    
    // recieve instructions from complete ...
    input [31:0] complete_pc_0,
    input [31:0] new_dr_data_0,

    input [31:0] complete_pc_1,
    input [31:0] new_dr_data_1,

    input [31:0] complete_pc_2,
    input [31:0] new_dr_data_2,
    
    // outputs ...
    output reg stall,
    
    // on complete, forward updated register data to UIQ ...
    output reg [5:0] src0_reg_ready,
    output reg [31:0] src0_data_ready,
    
    output reg [5:0] src1_reg_ready,
    output reg [31:0] src1_data_ready,
    
    output reg [5:0] src2_reg_ready,
    output reg [31:0] src2_data_ready,
    
    // send updated ready flags to UIQ ... 
    output reg [63:0] issue_ready,

    // retire ... 
    output reg [63:0] retire_rename, // to rename ...
    //write data to ARF ...
    output reg retire1,
    output reg [5:0] ARF_reg_1,
    output reg [31:0] ARF_data_1,

    output reg retire2,
    output reg [5:0] ARF_reg_2,
    output reg [31:0] ARF_data_2,
    
    // send retired instructions to LSQ to deallocate entries ...
    output reg [31:0] pc_retire1,
    output reg [31:0] pc_retire2
);

    reg [31:0] ROB [63:0] [7:0];

    reg [63:0] VALID;
    reg [63:0] ISSUED;
    reg [5:0] DESTREG [63:0]; 
    reg [5:0] OLD_DESTREG [63:0];
    reg [31:0] DESTREG_DATA [63:0];
    reg [31:0] PC [63:0];
    reg [63:0] COMPLETE; 
    
    // group retire registers ...
    reg [1:0] retireSignals;
    reg [5:0] ARF_reg [1:0];
    reg [31:0] ARF_data [1:0];
    reg [31:0] pc_retire [1:0];
    integer retire_count = 0;
    
    integer i, j, k;
    
    //THINGS TO DO
    //1. ADD TO ROB: When something is renamed, take that info and put it into ROB
        //If a store, ROB is valid, store reg, imm val, instr pc, and complete status
        //otherwise, ROB is valid, dest reg, old dest reg, dest data, instr pc, and complete status
    //2. COMPLETE: When a complete reg pc is received, check that pc against the rob and when found, set to complete
    //3. SET REG AS READY FOR ISSUE: if an instruction is marked as complete, set its ready flag to 1
        //a reg is ready if it is either not in ROB or if it is, if its completed
        //use ready reg to manage this, should be ready by default and set to not ready if in ROB and not complete 
    //4. RETIRE: If we have two instructions in order that are completed, we can free them from ROB and rename
        //send values to arf to keep track?? CHECK ON THIS
    
    // on dispatch ... add new ROB entry 
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            VALID = 'b0;
            COMPLETE = 'b0;
            ISSUED = 'b0;
            for (i=0; i<64; i=i+1) begin
                DESTREG[i] = 'b0;
                OLD_DESTREG[i] = 'b0;
                DESTREG_DATA[i] = 'b0;
                PC[i] = 'b0;
                issue_ready[i] = 1'b1;
            end
        end else begin
            for (i=0; i<64; i=i+1) begin
                if (~VALID[i]) begin
                    VALID[i] = 1'b1;
                    DESTREG[i] = dr;
                    OLD_DESTREG[i] = old_dr;
                    retire_rename[OLD_DESTREG[i]] = 1'b0;
                    DESTREG_DATA[i] = 'b0;
                    PC[i] = instr_PC;
                    ISSUED[i] = 1'b0;
                    COMPLETE[i] = 1'b0;
                    issue_ready[dr] = 1'b0;
                    i = 65;
                end
            end
        end
    end
    
    // handling complete ... forwarding issue signals and register data to UIQ ...
    always @(*) begin
        // updating ROB entries ...
        if (~rstn) begin
            src0_reg_ready = 'b0;
            src0_data_ready = 'b0;

            src1_reg_ready = 'b0;
            src1_data_ready = 'b0;

            src2_reg_ready = 'b0;
            src2_data_ready = 'b0;

        end else begin
            for (j=0; j<64; j=j+1) begin
                if (VALID[j] && ~COMPLETE[j]) begin
                    if (PC[j] == complete_pc_0) begin
                        COMPLETE[j] = 1'b1;
                        DESTREG_DATA[j] = new_dr_data_0;

                        // forwarding destReg data and ready signals to UIQ ... can be done separately as well ...
                        // are the forwarded data ports being overwritten? 
                        src0_reg_ready = DESTREG[j];
                        src0_data_ready = DESTREG_DATA[j];
                        issue_ready[DESTREG[j]] = 1'b1;
                        // ISSUED[j] = 1'b1;

                    end else if (PC[j] == complete_pc_1) begin
                        COMPLETE[j] = 1'b1;
                        DESTREG_DATA[j] = new_dr_data_1;

                        src1_reg_ready = DESTREG[j];
                        src1_data_ready = DESTREG_DATA[j];
                        issue_ready[DESTREG[j]] = 1'b1;
                        // ISSUED[j] = 1'b1;

                    end else if (PC[j] == complete_pc_2) begin
                        COMPLETE[j] = 1'b1;
                        DESTREG_DATA[j] = new_dr_data_2;

                        src2_reg_ready = DESTREG[j];
                        src2_data_ready = DESTREG_DATA[j];
                        issue_ready[DESTREG[j]] = 1'b1;
                        // ISSUED[j] = 1'b1;
                    end
                end
            end
        end 
    end
    
    //RETIRE
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            retire_rename = 'b0;
            for (k=0; k<2; k=k+1) begin
                retireSignals[k] = 'b0;
                ARF_data[k] = 'b0;
                ARF_reg[k] = 'b0;
            end
        end else begin
            for (k=0; k<64; k=k+1) begin
                if (VALID[k] && COMPLETE[k]) begin
                    retireSignals[retire_count] = 1'b1;
                    ARF_reg[retire_count] = DESTREG[k];
                    ARF_data[retire_count] = DESTREG_DATA[k];
                    pc_retire[retire_count] = PC[k];
                    retire_rename[OLD_DESTREG[k]] = 1'b1;
                    
                    VALID[k] = 1'b0;
                    COMPLETE[k] = 1'b0;

                    retire_count = retire_count+1;
                    if (retire_count == 2) begin
                        k=65;
                        retire_count = 0;
                    end
                end
            end
        end 
        retire1 = retireSignals[0];
        ARF_reg_1 = ARF_reg[0];
        ARF_data_1 = ARF_data[0];
        pc_retire1 = pc_retire[0];

        retire2 = retireSignals[1];
        ARF_reg_2 = ARF_reg[1];
        ARF_data_2 = ARF_data[1];
        pc_retire2 = pc_retire[1];
        
    end
endmodule