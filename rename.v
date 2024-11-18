
module rename(
    //inputs: sr1, sr2, dr
    sr1, sr2, dr,
    
    //Output: Source registers, destination registers, ALUOP, LW/SW Flag, Control Signals 
    sr1_p, // Src registers
    sr2_p,
    dr_p,
    aluOp,
    s1_ready,
    s2_ready,
    imm,
    FU,
    ROB_num
);

    input [5:0] sr1;
    input [5:0] sr2;
    input [5:0] dr;
    
    output reg [31:0] imm;
    output reg [15:0] ROB_num;
    output reg [5:0] sr1_p;
    output reg [5:0] sr2_p;
    output reg [5:0] dr_p; 
    output reg [1:0] aluOp; 
    output reg [1:0] FU;
    output reg s1_ready;
    output reg s2_ready;
    
   

    // TODO: 
    // 1. create a free pool with 16 physical registers and a way to tell if they are allocated or not
    // 2. dest reg to be assigned a new pReg from free pool
    // 3. use RAT to find the right pReg for each source reg
    // 4. output: populate reservation station with new value   
    
    //plan:
    //create free pool
    //each time rename is called, 
        //take the first free element (with the identifying value of 0 instead of 1) and set the value at that index to dr1 and mark as used
        //go through free pool checking for which of the first values match the original address, then set sr1_p and sr2_p to that address
   
   
   
    // Free pool for physical registers: Each entry has [0] for reg number and [1] for availability (1 = available, 0 = in use)
    reg [5:0] free_pool [15:0][1:0];

    // Register Alias Table (RAT) for mapping physical registers to logical registers
    reg [5:0] RAT [63:0];

    // Initialize free pool and RAT at the start
    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            free_pool[i][0] = i;    // Physical register ID
            free_pool[i][1] = 1'b1; // Mark as available
        end
        for (i = 0; i < 64; i = i + 1) begin
            RAT[i] = 6'd0; // Initialize all logical registers to physical register 0 (or another default if desired)
        end
    end

    // Always block to handle renaming logic
    integer j;
    reg found_free;  // Control variable to stop loop early
    always @(*) begin

        // Default outputs to avoid latches
        sr1_p = RAT[sr1];
        sr2_p = RAT[sr2];
        dr_p = 6'd0;
        s1_ready = 1'b1; // Assume ready (can modify as needed for specific logic)
        s2_ready = 1'b1;
        aluOp = 2'b00;   // Default ALU operation
        imm = 32'd0;     // Default immediate value
        FU = 2'b00;      // Default functional unit type
        ROB_num = 16'd0; // Default ROB number

        // Find a free physical register for the destination
        found_free = 1'b0;
        for (j = 0; j < 16 && !found_free; j = j + 1) begin
            if (free_pool[j][1] == 1'b1) begin
                dr_p = free_pool[j][0];     // Assign free physical register
                free_pool[j][1] = 1'b0;     // Mark as used
                RAT[dr] = dr_p;             // Update RAT with the new mapping for `dr`
                found_free = 1'b1;          // Stop further looping
            end
        end
    end
endmodule