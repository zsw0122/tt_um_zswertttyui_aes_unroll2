module aes_round_final (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);
    wire [127:0] sb;
    wire [127:0] sr;

    aes_subbytes  u_subbytes (.state_in(state_in), .state_out(sb));
    aes_shiftrows u_shiftrows(.state_in(sb),       .state_out(sr));

    assign state_out = sr ^ round_key;
endmodule
