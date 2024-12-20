
`timescale 1ns / 1ps

module reorder_buffer(
    input clk, 
    input rstn,
    
    input src1,
    input src2,
    
    input dr,
    input old_dr,
    input dr_data,
    input store_reg,
    input store_data,
    input instr_PC,
    
    input store_instr,
    
    input [31:0] complete_pc_0,
    input [31:0] complete_pc_1,
    input [31:0] complete_pc_2,
    input [31:0] complete_pc_3,
    
    input [31:0] new_dr_data_0,
    input [31:0] new_dr_data_1,
    input [31:0] new_dr_data_2,
    input [31:0] new_dr_data_3,
    
    output reg [63:0] issue_ready,
    output reg [63:0] retire,
    output reg stall,
    
    output reg src1_ready,
    output reg src2_ready,
    output reg src1_reg_ready,
    output reg src2_reg_ready,
    

    output reg [5:0] ARF_reg_1,
    output reg [5:0] ARF_data_1,
    output reg [5:0] ARF_reg_2,
    output reg [5:0] ARF_data_2
);

    // 1. multiple entries per cycle
    // 2. ROB_reg_ready determination
    // 3. signals like "complete", how to update
    
    //cases in which ROB needs to update:
    //  1: we add one item into the ROB, mark as 1 in retire (dispatch stage) 
    //  2: we add more than one item into the ROB (dispatch stage)
    //  3: update complete when complete, set 0 in retire (complete stage)
    //  4: remove entire line from ROB (retire)
    
    //general plan
        //whenever anything is renamed (2 at a time max) add a row in ROB
        
        //when an instr leaves ALU, we send its info back and check its cpu. Match it with its ROB row, set complete to 1, update data, and set retire at the dr to 0
        
        //go through ROB, starting from top, if complete=1 and all prior lines are retired, set reg is ready to 1
    
    
    
    
    
    
    
    
    
    
    reg [31:0] ROB [63:0] [7:0];
    reg [31:0] new_dr_data [3:0];
    reg [31:0] complete_pc [3:0];
    
    reg retire_head;
    reg ROB_head;
    
    integer i;
    integer j;
    integer k;
    
    
    
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
    
    always @(*) begin
        if(~rstn)begin
            for(i=0; i<64; i=i+1) begin
                ROB[i][0] = 1'b0;    // whether or not slot is taken
                ROB[i][1] = 0;       // dest reg
                ROB[i][2] = 0;       // old dest reg
                ROB[i][3] = 0;       // current dest reg data
                ROB[i][4] = 0;       // store address in sw
                ROB[i][5] = 0;       // store imm val
                ROB[i][6] = 0;       // instr pc
                ROB[i][7] = 0;       // complete
                
                retire[i] = 1'b0;    // retire buffer
                issue_ready[i]  = 1'b1;     // register ready array           
            end
            
            retire_head = 6'd0;
            ROB_head = 6'd0;
            src1_ready = 1'b0;
            src2_ready = 1'b0;
        end
        else begin
            stall=1'b0;
        end
    end
    
    //ADD TO ROB    
    always @(posedge clk) begin
        if(ROB[ROB_head][0]==1'b0) begin
            ROB[ROB_head][0] <= 1'b1; //valid
            ROB[ROB_head][1] <= dr; //dr
            ROB[ROB_head][2] <= old_dr; //old_dr
            ROB[ROB_head][3] <= dr_data; //dr_data
            ROB[ROB_head][4] <= store_reg; //store_reg
            ROB[ROB_head][5] <= store_data; //store_data
            ROB[ROB_head][6] <= instr_PC; //instr_PC
            ROB[ROB_head][7] <= 1'b0; //complete
            
            issue_ready[dr] <= 1'b0;
            
            ROB_head= ROB_head+1;
            if(ROB_head > 63) begin
                stall=1'b0;
            end
        end
    end
    
    //COMPLETE AND SET READY FOR ISSUE
    always @(*) begin
        new_dr_data[0] <= new_dr_data_0;
        new_dr_data[1] <= new_dr_data_1;
        new_dr_data[2] <= new_dr_data_2;
        new_dr_data[3] <= new_dr_data_3;
        
        complete_pc[0] <= complete_pc_0;
        complete_pc[1] <= complete_pc_1;
        complete_pc[2] <= complete_pc_2;
        complete_pc[3] <= complete_pc_3; 
        
        //SET COMPLETE
        for (j=0; j<64; j=j+1) begin
            if(ROB[j][0] == 1'b1) begin
                for(k=0; k<4; k=k+1) begin
                    if( ROB[j][6] == complete_pc[k]) begin
                        ROB[j][7] <=1'b1; //set complete
                        ROB[j][3] <= new_dr_data[k]; //write data to rob
                    end
                end
            end
        end
        
        //SET SRC1 and SRC2 READY FOR ISSUE
        if(~store_instr) begin
            if(issue_ready[src1] == 1'b1) begin
                src1_ready <= 1'b1;
                src1_reg_ready <=src1;
            end
            if(issue_ready[src2] == 1'b1) begin
                src2_ready <= 1'b1;
                src2_reg_ready <=src2;
            end
        end
        else begin
            src2_ready <= 1'b1;
            if(issue_ready[src1] == 1'b1) begin
                src1_ready <= 1'b1;
            end
        end
        
    end
    
    //RETIRE
    
    always @(posedge clk) begin
        ARF_reg_1 = 5'b0;
        ARF_data_1 = 32'b0;
        ARF_reg_2 = 5'b0;
        ARF_data_2 = 32'b0; 
        
        //first retire if possible
        if(ROB[retire_head][7] == 1'b1) begin
            //output to ARF
            if(~store_instr) begin
                ARF_reg_1 = ROB[retire_head][1];
                ARF_data_1 = ROB[retire_head][3];
                
                retire[ROB[retire_head][2]] <= 1'b0;

            end
            else begin
                ARF_reg_1 = ROB[retire_head][4];
                ARF_data_1 = ROB[retire_head][5];
                
                retire[ROB[retire_head][2]] <= 1'b0;
            end
            
            //retire ROB line
            ROB[retire_head][0] = 1'b0;    // whether or not slot is taken
            ROB[retire_head][1] = 0;       // dest reg
            ROB[retire_head][2] = 0;       // old dest reg
            ROB[retire_head][3] = 0;       // current dest reg data
            ROB[retire_head][4] = 0;       // store address in sw
            ROB[retire_head][5] = 0;       // store imm val
            ROB[retire_head][6] = 0;       // instr pc
            ROB[retire_head][7] = 0;       // complete
            
            retire_head =  retire_head+1;
            if(retire_head > 63) begin
                retire_head <= 1'b0;
            end
            
              
            //second retire if possible
            if(ROB[retire_head][7] == 1'b1) begin
                //output to ARF
                if(~store_instr) begin
                    ARF_reg_2 = ROB[retire_head][1];
                    ARF_data_2 = ROB[retire_head][3];
                    
                    //TODO: add in freeing old_dr?? or current dr??
                end
                else begin
                    ARF_reg_2 = ROB[retire_head][4];
                    ARF_data_2 = ROB[retire_head][5];
                    
                    //TODO: add in freeing old_dr?? or current dr??
                end
                
                //retire ROB line
                ROB[retire_head][0] = 1'b0;    // whether or not slot is taken
                ROB[retire_head][1] = 0;       // dest reg
                ROB[retire_head][2] = 0;       // old dest reg
                ROB[retire_head][3] = 0;       // current dest reg data
                ROB[retire_head][4] = 0;       // store address in sw
                ROB[retire_head][5] = 0;       // store imm val
                ROB[retire_head][6] = 0;       // instr pc
                ROB[retire_head][7] = 0;       // complete
                
                retire_head =  retire_head+1;
                if(retire_head > 63) begin
                    retire_head <= 1'b0;
                end
            end
            
        end
        
    end
    
    

endmodule