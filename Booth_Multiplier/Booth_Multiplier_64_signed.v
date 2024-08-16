module Booth_Multiplier_64_signed (
    input  wire [63:0] a_i,
    input  wire [63:0] b_i,
    input  wire        clk,
    output reg [127:0] result_o
);
    wire [65:0]  b_sext = {{2{b[63]}}, b};
    wire [65:0]  negative_b = ~b_sext + 1;

    wire [2:0]   booth2_operation [31:0];
   
    wire [127:0] pp_value       [0:31];
    wire [127:0] c42_out_s1     [0:15];
    wire [127:0] c42_out_s2     [0:7];
    wire [127:0] c42_out_s3     [0:3];
    wire [127:0] c42_out_s4     [0:1];
    wire [127:0] result;
    genvar i;

    reg [63:0] a, b; 

    //Booth Encoder level
    Booth2_Encoder BE_0(
        .ai({a[1:0],1'b0}),
        .operation(booth2_operation[0])
    );

    generate
        for( i = 1; i < 32; i = i + 1 ) begin: booth_encoder
            Booth2_Encoder BE(
                .ai(a[(2*i+1):(2*i-1)]),
                .operation(booth2_operation[i])
            );
        end
    endgenerate

    //Partial product generator level #PPG = 32
    generate
        for( i = 0; i < 32; i = i + 1 ) begin: partial_product_generator
            Partial_Product_Gen #(2*i) PPG(
                .operation(booth2_operation[i]),
                .bi(b_sext),
                .negative_bi(negative_b),
                .partial_product(pp_value[i])
            );
        end
    endgenerate

    //4-2 Compressor
    //stage1 32 -> 16 #c42 = 8
    generate
        for( i = 0; i < 8; i = i + 1 ) begin: compressor_42_s1
            compressor_42 c42(
                .data_in1(pp_value[4*i]),
                .data_in2(pp_value[4*i+1]),
                .data_in3(pp_value[4*i+2]),
                .data_in4(pp_value[4*i+3]),
                .data_out1(c42_out_s1[2*i]),
                .data_out2(c42_out_s1[2*i+1])
            );
        end
    endgenerate

    //stage2 16 -> 8 #c42 = 4
    generate
        for( i = 0; i < 4; i = i + 1 ) begin: compressor_42_s2
            compressor_42 c42(
                .data_in1(c42_out_s1[4*i]),
                .data_in2(c42_out_s1[4*i+1]),
                .data_in3(c42_out_s1[4*i+2]),
                .data_in4(c42_out_s1[4*i+3]),
                .data_out1(c42_out_s2[2*i]),
                .data_out2(c42_out_s2[2*i+1])
            );
        end
    endgenerate

    //stage3 8 -> 4 #c42 = 2
        generate
        for( i = 0; i < 2; i = i + 1 ) begin: compressor_42_s3
            compressor_42 c42(
                .data_in1(c42_out_s2[4*i]),
                .data_in2(c42_out_s2[4*i+1]),
                .data_in3(c42_out_s2[4*i+2]),
                .data_in4(c42_out_s2[4*i+3]),
                .data_out1(c42_out_s3[2*i]),
                .data_out2(c42_out_s3[2*i+1])
            );
        end
    endgenerate

    //stage4 4 -> 2 #c42 = 1
            compressor_42 c42(
                .data_in1(c42_out_s3[0]),
                .data_in2(c42_out_s3[1]),
                .data_in3(c42_out_s3[2]),
                .data_in4(c42_out_s3[3]),
                .data_out1(c42_out_s4[0]),
                .data_out2(c42_out_s4[1])
            );

    assign result = c42_out_s4[0] + c42_out_s4[1];

    always @(posedge clk) begin
        a <= a_i;
        b <= b_i;
        result_o <= result;
    end

endmodule