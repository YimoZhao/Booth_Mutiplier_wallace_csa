module Booth2_Encoder (
    input  wire [2:0] ai         ,
    output reg [2:0] operation
);
    always@(*) begin
        case(ai)
            3'b000: operation =  0;    //no string of 1's
            3'b001: operation =  1;    //end of string of 1's
            3'b010: operation =  1;    //a string of 1's
            3'b011: operation =  2;    //end of string of 1's
            3'b100: operation = -2;    //beginning of string of 1's
            3'b101: operation = -1;    //-2B+B
            3'b110: operation = -1;    //beginning of string of 1's
            3'b111: operation =  0;    //center of string of 1's
        endcase
    end
    
endmodule