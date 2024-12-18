
`timescale 1ns / 1ps

module reorder_buffer(
    input               clk, 
    input               rstn,
    input [31:0]        instr_PC_0, 
    
    input [5:0]         old_dest_reg_0,
    input [5:0]         dest_reg_0,
    input [31:0]        dest_data_0,
    input               store_add_0,
    input               store_data_0,   

    input [31:0]        complete_pc_0,
    input [31:0]        complete_pc_1,
    input [31:0]        complete_pc_2,
    input [31:0]        complete_pc_3,
    
    input [31:0]        new_dr_data_0,
    input [31:0]        new_dr_data_1,
    input [31:0]        new_dr_data_2,
    input [31:0]        new_dr_data_3,
    input               is_store,
    input [5:0]         UIQ_input_invalid,
    
    output reg [63:0]   ready_reg,
    output reg [63:0]   retire_reg,
    output reg          stall,
    output reg [5:0]    reg_update_ARF_1,
    output reg [5:0]    reg_update_ARF_2,
    output reg [31:0]   value_update_ARF_1,
    output reg [31:0]   value_update_ARF_2,
    output reg [5:0]    old_reg_1,
    output reg [5:0]    old_reg_2,

    output reg          sr1_ready_flag,       
    output reg [5:0]    sr1_reg_ready,   // ROB update and broadcast to UIQ
    output reg [5:0]    sr2_reg_ready,
    output reg          sr2_ready_flag,
    output reg [31:0]   sr1_value_ready,
    output reg [31:0]   sr2_value_ready,

    output reg [31:0]   pc_retire_1,
    output reg [31:0]   pc_retire_2
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
    reg [6:0]  retire_pointer;
    reg [6:0]  place_pointer;

    // insert into ROB
    integer i;
    integer j;
    integer k;
    integer max_retire = 0;
    integer m;
    
    always @(posedge clk or negedge rstn) begin
        //reset ROB
        if (~rstn)begin
            for (i = 0; i < 64; i = i + 1) begin
                ROB[i][0] = 1'b0;    // whether or not slot is taken
                ROB[i][1] = 0;       // dest reg
                ROB[i][2] = 0;       // old dest reg
                ROB[i][3] = 0;       // current dest reg data
                ROB[i][4] = 0;       // store address in sw
                ROB[i][5] = 0;       // store imm val
                ROB[i][6] = 0;       // instr pc
                ROB[i][7] = 0;       // complete
                
                retire_reg[i] = 1'b0;    // retire buffer
                ready_reg[i]  = 1'b1;     // register ready array
            end
            
            retire_pointer      = 6'd0;
            place_pointer       = 6'd0;

            reg_update_ARF_1    = 6'b0;
            reg_update_ARF_2    = 6'b0;
            value_update_ARF_1  = 32'b0;
            value_update_ARF_2  = 32'b0;
            old_reg_1           = 6'b0;
            old_reg_2           = 6'b0;

            sr1_reg_ready            = 6'b0;
            sr2_reg_ready            = 6'b0;
            sr1_value_ready          = 32'b0;
            sr2_value_ready          = 32'b0;

            pc_retire_1         = 32'b0;
            pc_retire_2         = 32'b0;
        end            
        else begin
            stall = 1'b0;
            for (i = 0; i < 64; i = i + 1) begin
                retire_reg[i]=1'b0;      // initialize retire buffer every cycle
            end

            //adding something new to rob
            //if (is_dispatching) begin
            if(ROB[place_pointer][0] == 1'b0) begin
                ROB[place_pointer][0] <= 1'b1;           //valid
                ROB[place_pointer][1] <= dest_reg_0;     //dr
                ROB[place_pointer][2] <= old_dest_reg_0; //old dr
                ROB[place_pointer][3] <= dest_data_0;    //data at dr
                ROB[place_pointer][4] <= store_add_0;    //store address
                ROB[place_pointer][5] <= store_data_0;   //store data
                ROB[place_pointer][6] <= instr_PC_0;     //instr pc
                ROB[place_pointer][7] <= 1'b0;           //complete
                        
                place_pointer = place_pointer + 1;
                if (place_pointer > 63) begin
                    place_pointer = 0;
                end  
            end
            else begin
                stall <= 1'b1;
            end
            //end            
        end
    end

    // complete and retire
    always @(*) begin
        //set up complete and data arrays
        new_dr_data[0] = new_dr_data_0;
        new_dr_data[1] = new_dr_data_1;
        new_dr_data[2] = new_dr_data_2;
        new_dr_data[3] = new_dr_data_3;
        
        complete_pc[0] = complete_pc_0;
        complete_pc[1] = complete_pc_1;
        complete_pc[2] = complete_pc_2;
        complete_pc[3] = complete_pc_3;

        //complete and update data
        for (m = 0; m < 64; m = m + 1) begin
            if (ROB[m][0] == 1'b1) begin
                for(k = 0; k < 4; k = k + 1)begin
                    if ((ROB[m][6] == complete_pc[k]) && (ROB[m][0] == 1'b1))begin
                        ROB[m][7]  <= 1'b1;             //set to complete
                        ROB[m][3]  <= new_dr_data[k];   //update data
                    end
                end
            end
        end

        // free retire if in order
        // write back to ARF
        reg_update_ARF_1    = 6'b0;
        reg_update_ARF_2    = 6'b0;
        value_update_ARF_1  = 32'b0;
        value_update_ARF_2  = 32'b0;
        sr1_ready_flag = 1'b0;
        sr2_ready_flag = 1'b0;

        max_retire = 0;

        for (j = 0; j < 2; j = j + 1) begin //check to retire
            if (ROB[retire_pointer][0] == 1'b1) begin
                if((ROB[retire_pointer][7]==1'b1) && (max_retire == 0))begin
                    //retire in ROB and retire buffer
                    ready_reg[ROB[retire_pointer][1]]=1'b1;    //set reg as ready
                    retire_reg[ROB[retire_pointer][2]]=1'b1;   //retire old dr

                    ROB[retire_pointer][0] = 1'b0;           //set as invalid
                            
                    max_retire = 1;
                    
                    if (~is_store) begin
                        reg_update_ARF_1    = ROB[retire_pointer][1];
                        value_update_ARF_1  = ROB[retire_pointer][3];
                        old_reg_1           = ROB[retire_pointer][2];
                        sr1_ready_flag                = 1'b1;
                    end

                    retire_pointer = retire_pointer + 1;
                    if(retire_pointer > 63)begin
                        retire_pointer = 0;
                    end
                end
                else if((ROB[retire_pointer][7]==1'b1) && (max_retire == 1))begin
                    //retire in ROB and retire buffer
                    ready_reg[ROB[retire_pointer][1]]=1'b1;    //set reg as ready
                    retire_reg[ROB[retire_pointer][2]]=1'b1;   //retire old dr

                    ROB[retire_pointer][0] = 1'b0;           //set as invalid
                            
                    max_retire = 0;

                    if (~is_store) begin
                        reg_update_ARF_2    = ROB[retire_pointer][1];
                        value_update_ARF_2  = ROB[retire_pointer][3];
                        old_reg_2           = ROB[retire_pointer][2];
                        sr2_ready_flag                = 1'b1;
                    end
                    
                    retire_pointer = retire_pointer + 1;
                    if(retire_pointer > 63)begin
                        retire_pointer = 0;
                    end
                end       
            end
        end 

        if (sr1_ready_flag) begin
            sr1_reg_ready    = reg_update_ARF_1;
            sr1_value_ready  = value_update_ARF_1;
        end
        if (sr2_ready_flag) begin
            sr2_reg_ready    = reg_update_ARF_2;
            sr2_value_ready  = value_update_ARF_2;
        end
        
    end

    // this needs to be redone ...
    always @(UIQ_input_invalid) begin
        if(UIQ_input_invalid != 6'b0) begin
            ready_reg[UIQ_input_invalid] = 1'b0;
        end
    end

endmodule