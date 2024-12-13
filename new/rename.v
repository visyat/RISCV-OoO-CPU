//sr1 and sr2 take a place in rat
//dr takes a space from the free pool but also the rat
//Author: Paige Larson

module rename(
    //inputs: sr1, sr2, dr
    input [4 : 0]   sr1, 
    input [4 : 0]   sr2,
    input [4 : 0]   dr,
    input           rstn,
    input [6 : 0]   opcode,
    input           hasImm,
    input [31 : 0]  imm,
    
    //Output: Source registers, destination registers
    //output reg [31 : 0]     imm,
    output reg [15 : 0]     ROB_num,
    output reg [5 : 0]      sr1_p,
    output reg [5 : 0]      sr2_p,
    output reg [5 : 0]      dr_p,
    output reg [5 : 0]      old_dr,
    output reg              stall  
);

    // TODO: 
    // 1. create a free pool with 16 physical registers and a way to tell if they are allocated or not.
    // 2. dest reg to be assigned a new pReg from free pool.
    // 3. use RAT to find the right pReg for each source reg.
    // 4. output: populate reservation station with new value.   
    
    //plan:
    //create free pool
    //each time rename is called, 
        //take the first free element (with the identifying value of 0 instead of 1) and set the value 
        //at that index to dr1 and mark as used.
        //go through free pool checking for which of the first values match the original address, then 
        //set sr1_p and sr2_p to that address.
   
    // Free pool for physical registers: Each entry has [0] for reg number and [1] for availability (1 = available, 0 = in use)
    // first is p-reg, second is availability
    reg [5:0] free_pool [31:0][1:0];

    // Register Alias Table (RAT) for mapping physical registers to logical registers
    // [6'd63] for not used
    reg [5:0] RAT [31:0][1:0];

    // register array for store the old number of the physical register, reserve 5 places for each logical register
    reg [6:0] old_regnum [31:0][4:0];

    // Initialize free pool and RAT at the start
    integer i;

    // Always block to handle renaming logic
    integer j;
    integer old_index;

    always @(*) begin
        if(~rstn) begin
            sr1_p       = 6'd0;
            sr2_p       = 6'd0;
            dr_p        = 6'd0;
            ROB_num     = 16'd0;   // Default ROB number
            stall       = 1'b0;    // Default no stall
            
            for (i = 0; i < 32; i = i + 1) begin
                //col0 is if avail, col1 is p-reg 0-31
                free_pool[i][1] = i + 32;   // REGISTER ID (Physical register ID)
                free_pool[i][0] = 1'b0;     // Mark as available
            end
            for (i = 0; i < 32; i = i + 1) begin
                //col0 is a-reg 0-31, col1 is p-reg 0-31
                RAT[i][0] = i;    //ARTIFICIAL REGISTER ID
                RAT[i][1] = i;    //PHYSICAL REGISTER ID
            end
            for (i = 0; i < 32; i = i + 1) begin
                //col0 is a-reg 0-31, col1 is p-reg 0-31
                old_regnum[i][0] = 64;    //init as 64 for empty, since p-reg are 0-63
                old_regnum[i][1] = 64;    //init as 64 for empty, since p-reg are 0-63
                old_regnum[i][2] = 64;    //init as 64 for empty, since p-reg are 0-63
                old_regnum[i][3] = 64;    //init as 64 for empty, since p-reg are 0-63
                old_regnum[i][4] = 64;    //init as 64 for empty, since p-reg are 0-63
                
            end

           
        end
        else 
            begin
            sr1_p = RAT[sr1][1]; //assign to whatever p-reg is in RAT
            
            if(hasImm == 1'b0)begin          
            sr2_p = RAT[sr2][1]; //assign to whatever p-reg is in RAT             
            end
            else begin
            sr2_p=imm;
            end
            // Find a free physical register for the destination register

            if(opcode != 7'b0100011 && opcode!=7'b0000000)begin
                for (j = 0; j < 32; j = j + 1) begin
                    if (free_pool[j][0] == 1'b0) begin
                        if(dr == 5'd0)begin
                            dr_p = 6'd0;
                        end
                        else begin
                            dr_p = free_pool[j][1];     // Assign free physical register
                            free_pool[j][0] = 1'b1;     // Mark as used
                        end
                        
                        // set the old number of the physical register
                        for (old_index = 0; old_index < 5; old_index = old_index + 1) begin
                            if (old_regnum[dr][old_index] == 64) begin
                                old_regnum[dr][old_index] = RAT[dr][1]; 
                                old_index = 5;      // Stop further looping
                            end
                        end
                        // old_regnum: 0 is the oldest, ->4 is the most recent
                        // ***need to pay attention in the RETIRE STAGE*** (add a pointer to the oldest one??)
                        // LET'S HOPE NONE OF THE OLD REGISTERS NUMBER WOULD EXTEND OUR SPACES (WHICH IS 5 NOW)
                        old_dr=RAT[dr][1];
                        RAT[dr][1] = dr_p;          // find line in rat with a-reg=dr, set p-reg to dr_p 
                        j=33;          // Stop further looping
                    end
                end
            end
            else begin // S_type or NOP
                dr_p=RAT[dr][1];
                old_dr=64;
            end
            
                if (j == 32) stall <= 1'b1;         // Stall if no free physical register is found
                else         stall <= 1'b0;
               
        end
        //$display("sr1P: %b, src2P: %b, destP: %b ", sr1_p, sr2_p, dr_p);
        //$display("finish rename");
    end

endmodule