module Partial_Product_Gen #(
    parameter shamt = 0
) (
    input  wire [2  :0] operation        ,
    input  wire [65 :0] bi               ,
    input  wire [65 :0] negative_bi      ,
    output wire [127:0] partial_product
);
    reg [65:0] partial_product_reg;

    always@(*)begin
        case(operation)
            //-2
            3'b110: partial_product_reg = negative_bi << 1;
            //-1
            3'b111: partial_product_reg = negative_bi;
            //0
            3'b000: partial_product_reg = 128'b0;
            //1
            3'b001: partial_product_reg = bi;
            //2
            3'b010: partial_product_reg = bi << 1;
        endcase
    end
    //sext 65 >> 127
    assign partial_product = {{62{partial_product_reg[65]}}, partial_product_reg} << shamt;

endmodule