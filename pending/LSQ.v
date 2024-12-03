/*
Load-Store Queue:
* Size = 16 instructions
+ --------------------------------- +
| V | PC  | Op |   Address   | Data |
+ - | --- | -- | ----------- | ---- |
| 1 | 0x4 | S  | 0x1...      | .... |
| 1 | 0x8 | L  | 0x2...      |      |
| 0 |     |    |             |      |
| 0 |     |    |             |      |
| 0 |     |    |             |      |
| 0 |     |    |             |      |
+ --------------------------------- +
*/
/*
Nader OH: 
    * LSU helps fix RAW data hazards 
    * LSU is just a functional unit that is responsible for computing the address -> not a separate thing
    * Reads that read from speculative stores read from the latest read to the same address -> complete but don't retire 
    * Retire in-order 
    * Data memory can just be an array, doesn't have to implement more complex memory details
    * LSQ can use PC to map LSQ entries to addresses computed by the ALU 
*/

module LSQ(
    input clk, 
    input rstn,

    // from dispatch ... receives instruction address, whether read/write, and rs2 val if SW
    input [31:0] pcDis,
    input memRead,
    input memWrite,
    input swData,

    // from LSU ... recieves instruction address (to match) & computed address: rs1+offset
    input [31:0] pcLsu,
    input [31:0] addressLsu,

    // from retirement ... deallocate space in LSQ
    input [31:0] pcRet,

    // outputs ... issues instruction; completes LW instruction if store seen in LSQ
    output reg [31:0] pcOut,
    output reg [31:0] addressOut,
    output reg [31:0] lwData,
    output reg complete // 1 if LW and data is found in LSQ
);
    
    // LSQ fields ...
    reg [15:0] VALID;
    reg [15:0] PC [31:0];
    reg [15:0] OP; // 0: read, 1: write
    reg [15:0] ADDRESS [31:0];
    reg [15:0] LSQ_DATA [31:0];

    integer i;

    always @(posedge clk) begin
        if (~rstn) begin // on reset, set all LSQ entries to 0 ...
            VALID = 16'b0;
            OP = 16'b0;
            for (i=0; i<16; i++) begin
                PC[i] = 32'b0;
                ADDRESS[i] = 32'b0;
                LSQ_DATA[i] = 32'b0;
            end
            pcOut = 32'b0;
            addressOut = 32'b0;
            lwData = 32'b0;
        end else begin 
            // dispatch logic ... if read/write, reserve space in LSQ


            // execution logic ... if store, update address & data in LSQ entry; if read, scan LSQ to find matching addresses, provide data for latest write


            // issue logic ... complete reads if data exists, else issue most recent available instruction 


            // retirement logic ... deallocate LSQ entry
            

        end
    end
endmodule