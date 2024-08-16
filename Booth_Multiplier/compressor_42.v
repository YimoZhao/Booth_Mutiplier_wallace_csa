module compressor_42 (
    input  wire [127:0] data_in1,
    input  wire [127:0] data_in2,
    input  wire [127:0] data_in3,
    input  wire [127:0] data_in4,
    output wire [127:0] data_out1,
    output wire [127:0] data_out2
);
    wire [127:0] temp0, carry0;
    wire [127:0] temp1, carry1;

    carry_save_adder csa0(
        .a(data_in1),
        .b(data_in2),
        .c(data_in3),
        .temp(temp0),
        .carry(carry0)
    );

    carry_save_adder csa1(
        .a(temp0),
        .b(carry0),
        .c(data_in4),
        .temp(temp1),
        .carry(carry1)
    );

    assign data_out1 = temp1;
    assign data_out2 = carry1;
    
endmodule

module carry_save_adder (
    input  wire [127:0] a,
    input  wire [127:0] b,
    input  wire [127:0] c,
    output wire [127:0] temp,
    output wire [127:0] carry
);
    assign temp  = a ^ b ^ c;
    assign carry = ((a & b) | (a & c) | (b & c)) << 1;
endmodule