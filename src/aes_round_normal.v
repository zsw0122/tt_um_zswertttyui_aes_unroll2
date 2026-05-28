module aes_round_normal (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);
    wire [127:0] sb;
    wire [127:0] sr;
    wire [127:0] mc;

    aes_subbytes  u_subbytes (.state_in(state_in), .state_out(sb));
    aes_shiftrows u_shiftrows(.state_in(sb),       .state_out(sr));
    aes_mixcolumns u_mix    (.state_in(sr),        .state_out(mc));

    assign state_out = mc ^ round_key;
endmodule
