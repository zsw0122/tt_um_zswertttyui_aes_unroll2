module aes_mixcolumns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    aes_mixcolumns_one_column c0(.col_in(state_in[127:96]), .col_out(state_out[127:96]));
    aes_mixcolumns_one_column c1(.col_in(state_in[95:64]),  .col_out(state_out[95:64]));
    aes_mixcolumns_one_column c2(.col_in(state_in[63:32]),  .col_out(state_out[63:32]));
    aes_mixcolumns_one_column c3(.col_in(state_in[31:0]),   .col_out(state_out[31:0]));
endmodule
