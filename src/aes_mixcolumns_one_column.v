module aes_mixcolumns_one_column (
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);
    wire [7:0] s0, s1, s2, s3;
    wire [7:0] m0, m1, m2, m3;

    assign s0 = col_in[31:24];
    assign s1 = col_in[23:16];
    assign s2 = col_in[15:8];
    assign s3 = col_in[7:0];

    assign m0 = xtime(s0) ^ (xtime(s1) ^ s1) ^ s2 ^ s3;
    assign m1 = s0 ^ xtime(s1) ^ (xtime(s2) ^ s2) ^ s3;
    assign m2 = s0 ^ s1 ^ xtime(s2) ^ (xtime(s3) ^ s3);
    assign m3 = (xtime(s0) ^ s0) ^ s1 ^ s2 ^ xtime(s3);

    assign col_out = {m0, m1, m2, m3};

    function [7:0] xtime;
        input [7:0] b;
        begin
            if (b[7] == 1'b1)
                xtime = (b << 1) ^ 8'h1b;
            else
                xtime = (b << 1);
        end
    endfunction
endmodule
