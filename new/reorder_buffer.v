
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Paige Larson
// 
// Create Date: 11/25/2024 01:54:11 AM
// Design Name: 
// Module Name: reorder_buffer
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
`timescale 1ns / 1ps


module reorder_buffer(
    input [5:0]         old_dest_reg_0,       //from rename      
    input [5:0]         dest_reg_0,           //from rename
    input [31:0]        dest_data_0,          //from rename    
    input               store_add_0,          //from rename
    input               store_data_0,         //from rename
    input               instr_PC_0,            //from rename    

    
    input [31:0]        complete_pc_0,
    input [31:0]        complete_pc_1,
    input [31:0]        complete_pc_2,
    input [31:0]        complete_pc_3,
    
    input [31:0]        new_dr_data_0,
    input [31:0]        new_dr_data_1,
    input [31:0]        new_dr_data_2,
    input [31:0]        new_dr_data_3,
    
    input               clk, 
    input [31:0]        PC,
    input               rstn,
    
    
    
    output reg [5:0]    out_add_1,
    output reg [31:0]   out_data_1,
    output reg [5:0]    out_add_2,
    output reg [31:0]   out_data_2,
    output reg [1:0]    stall
    
    
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

    reg        retire [63:0];
    reg [31:0] ROB [63:0] [7:0];
    reg [31:0] new_dr_data [3:0];
    reg [31:0] complete_pc [3:0];

    // insert into ROB
    integer i;
    integer j;
    integer k;
    integer max_retire;
    integer vals;
    
    always @(posedge clk) begin
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
                
                retire[i]=1'b0;      //return buffer
                
                out_add_1=0;
                out_data_1=0;
                out_add_2=0;
                out_data_2=0;
            end
            
            //set up complete and data arrays
            new_dr_data[0] = new_dr_data_0;
            new_dr_data[1] = new_dr_data_1;
            new_dr_data[2] = new_dr_data_2;
            new_dr_data[3] = new_dr_data_3;
            
            complete_pc[0] = complete_pc_0;
            complete_pc[1] = complete_pc_1;
            complete_pc[2] = complete_pc_2;
            complete_pc[3] = complete_pc_3;
            
        end            
        else begin
            //adding something new to rob
            for (i = 0; i < 64; i = i + 1) begin //place first new instr
                if (ROB[i][0] == 1'b0) begin
                    ROB[i][0] = 1'b1;           //valid
                    ROB[i][1] = dest_reg_0;     //dr
                    ROB[i][2] = old_dest_reg_0; //old dr
                    ROB[i][3] = dest_data_0;    //data at dr
                    ROB[i][4] = store_add_0;    //store address
                    ROB[i][5] = store_data_0;   //store data
                    ROB[i][6] = instr_PC_0;     //instr pc
                    ROB[i][7] = 1'b0;           //complete
                    
                    retire[dest_reg_0]=1'b1;    //update r to occupied/not retired
                     
                    i = 64;         // Stop further looping
                end
                else if(i==64) begin
                    stall=1'b1;
                end
            end
            
            //complete and update data
            for(k=0; k<4; k=k+1)begin
                if(complete_pc[k]!=0 && new_dr_data[k]!=0) begin
                    for (i = 0; i < 64; i = i + 1) begin
                        if(ROB[i][0]==1'b1) begin
                            if(ROB[i][6]==complete_pc[k])begin
                                ROB[i][7]=1'b1;             //set to complete
                                ROB[i][3]=new_dr_data[k];   // update data
                            end
                        end
                    end
                end
            end
            
            //free retire if in order
            
            //if row is first populated row, check if complete
                //if complete, retire rob row and dr in retire buffer
                    //see if next populated row is complete
                        //if so, retire that row too
                        //if not, exit 
                //if not complete, exit
            max_retire=0;
            for (i = 0; i < 64; i = i + 1) begin //check to retire
                if (ROB[i][1] == 1'b1) begin
                    if(ROB[i][7]==1'b1)begin
                        //writeback logic
                        if(out_add_1==0)begin
                            out_add_1=ROB[i][1];
                            out_data_1=ROB[i][3];
                        end
                        else begin
                            out_add_2=ROB[i][1];
                            out_data_2=ROB[i][3];
                        end 
                        
                        //retire in ROB and retire buffer
                        retire[ROB[i][1]]=1'b0; 
                         
                        ROB[i][0] = 1'b0;           //valid
                        ROB[i][1] = 0;     //dr
                        ROB[i][2] = 0; //old dr
                        ROB[i][3] = 0;    //data at dr
                        ROB[i][4] = 0;    //store address
                        ROB[i][5] = 0;   //store data
                        ROB[i][6] = 0;     //instr pc
                        ROB[i][7] = 1'b0;           //complete
                             
                        max_retire=max_retire+1;
                    end
                    else begin
                        i=64;
                    end            
                end
                 
                if(max_retire>=2)begin //not retiring more than two instr per cycle
                    i=64; 
                end
            end
            
            
        end
    end

endmodule