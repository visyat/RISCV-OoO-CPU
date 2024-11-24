//sr1 and sr2 take a place in rat
//dr takes a space from the free pool but also the rat


module rename(
    //inputs: sr1, sr2, dr
    input [5 : 0]   sr1, 
    input [5 : 0]   sr2,
    input [5 : 0]   dr,
    input           rstn,
    
    //Output: Source registers, destination registers, ALUOP, LW/SW Flag, Control Signals 
    //output reg [31 : 0]     imm,
    output reg [15 : 0]     ROB_num,
    output reg [5 : 0]      sr1_p,
    output reg [5 : 0]      sr2_p,
    output reg [5 : 0]      dr_p,
    output reg [1 : 0]      aluOp,
    output reg [1 : 0]      FU,
    output reg              s1_ready,
    output reg              s2_ready
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
    //first is p-reg, second is availability

    reg [5:0] free_pool [31:0][1:0];

    // Register Alias Table (RAT) for mapping physical registers to logical registers
    
    reg [5:0] RAT [31:0][1:0];

    // Initialize free pool and RAT at the start
    integer i;
    always @(*) begin
        if (~rstn)begin
            for (i = 0; i < 32; i = i + 1) begin
                //col0 is if avail, col1 is p-reg 32-63
                free_pool[i][1] =(i+32);    // Physical register ID
                free_pool[i][0] = 1'b0;     // Mark as available
            end
            for (i = 0; i < 32; i = i + 1) begin
                //col0 is a-reg 0-31, col1 is p-reg 0-31
                RAT[i][0] = i; // Initialize all logical registers to physical register 0
                RAT[i][1] = 6'd63;
            end
        end
    end

    // Always block to handle renaming logic
    integer j;

    reg found_free;  // Control variable to stop loop early
    always @(*) begin
        if(~rstn) begin
            sr1_p       = 6'd0;
            sr2_p       = 6'd0;
            dr_p        = 5'd0;
            s1_ready    = 1'b1; // Assume ready 
            s2_ready    = 1'b1;
            aluOp       = 2'b00; // Default ALU operation
            //imm         = 32'd0; // Default immediate value
            FU          = 2'b00; // Default functional unit type
            ROB_num     = 16'd0; // Default ROB number
        end
        else begin
            //if RAT at sr1 is not already taken, take it
            if(RAT[sr1][1]==6'd63)begin
                RAT[sr1][1] = RAT[sr1][0];             // Update RAT with the new mapping for sr1`;  
                sr1_p =RAT[sr1][1] ;                   // Assign sr1 to newly assigned physical register
            end 
            //if another, dont set, take from that space
            else begin
                sr1_p=RAT[sr1][1];
            end

            //if RAT at sr2 is not already taken, take it
            if(RAT[sr2][1]==6'd63)begin
                RAT[sr2][1] = RAT[sr2][0];             // Update RAT with the new mapping for sr1`;  
                sr2_p =RAT[sr2][1] ;                   // Assign sr1 to newly assigned physical register
            end 
            //if another, dont set, take from that space
            else begin
                sr2_p=RAT[sr2][1];
            end
            
            // Find a free physical register for the destination
            found_free = 1'b0;
            for (j = 0; j < 32 && !found_free; j = j + 1) begin
                if (free_pool[j][0] == 1'b0) begin
                    dr_p = free_pool[j][1];     // Assign free physical register
                    free_pool[j][0] = 1'b1;     // Mark as used
                    RAT[dr][1] = dr_p;          // find line in rat with a-reg=dr, set p-reg to dr_p 
                    found_free = 1'b1;          // Stop further looping
                end
            end
        end
    end

endmodule