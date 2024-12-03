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

1. After Dispatch, reserve space in LSQ indicating load/store -> wait for address from LSU
2. At Retirement, deallocate space in LSQ
3. On Write, write to Store Queue 
4. On Read, check Store Queue ==> if there, safe to go to read from DataMem
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
    clk,
    rstn, 
    
    // from Dispatch ...
    memRead,
    memWrite,
    PCDis,
    swData,

    // from LSU ...
    PCLsu,
    lsuValid,
    address,

    // from memory hierarchy ...
    // addressMem,
    // dataMem,

    // outputs ...
    PCOut,
    lwData,

    stall,
    noIssueOut,
    issueOut,
    callMem // for load instructions with data (from stores) alr known, don't need to query from memory
);
    // Inputs
    input clk;
    input rstn;

    input memRead;
    input memWrite;
    input [31:0] PCDis;
    input [31:0] swData;

    input [31:0] PCLsu;
    input lsuValid;
    input [9:0] addressLsu;

    // input [9:0] addressMem;
    // input [7:0] dataMem;

    // Outputs
    output [31:0] PCOut;
    output [7:0] lwData;

    output stall;
    output noIssueOut;
    output issueOut;
    
    // LSQ fields 
    reg [15:0] valid; // 0: Invalid, 1: Valid
    reg [15:0] PC [0:31];
    reg [15:0] op; // 0: Read, 1: Write
    reg [15:0] address [0:9];
    reg [15:0] data [0:7];

    integer i;
    integer j;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            valid <= 16'b0;
            op <= 16'b0;
            for (i=0; i<16; i+=1) begin
                address[i] <= 10'b0;
                data[i] <= 8'b0;
            end
        end else begin
            if (memRead || memWrite) begin // Load or Store instruction being passed from dispatch
                // allocate new entry in LSQ
                for (i=0; i<16; i+=1) begin
                    if (valid[i] == 0) begin
                        j=i;
                        break;
                    end
                end
                valid[j] = 1;
                PC[j] = PCDis;
                op[j] = memWrite && (~memRead);
                if (memWrite) begin // speculative store
                    data[j] = swData[7:0];
                end
            end
            if (lsuValid) begin // LSU is passing address for SW/LW instruction
                for (i=0; i<16; i+=1) begin
                    if (valid[i] == 1 && PC[i] == PCLsu) begin
                        j=i;
                        break
                    end
                end
                address[j] = addressLsu; // load address to LSQ entry with matching PC 

                // handle speculative stores ...
            end
        end
    end
endmodule