module aes_key_expand (
    input  wire [3:0]   round,
    input  wire [127:0] key_in,
    output wire [127:0] key_out
);
    wire [31:0] w0 = key_in[127:96];
    wire [31:0] w1 = key_in[95:64];
    wire [31:0] w2 = key_in[63:32];
    wire [31:0] w3 = key_in[31:0];

    wire [7:0] rot0 = w3[23:16];
    wire [7:0] rot1 = w3[15:8];
    wire [7:0] rot2 = w3[7:0];
    wire [7:0] rot3 = w3[31:24];

    wire [7:0] sb0, sb1, sb2, sb3;
    aes_sbox s0(.in(rot0), .out(sb0));
    aes_sbox s1(.in(rot1), .out(sb1));
    aes_sbox s2(.in(rot2), .out(sb2));
    aes_sbox s3(.in(rot3), .out(sb3));

    wire [31:0] g_word = {sb0 ^ rcon(round), sb1, sb2, sb3};
    wire [31:0] w4 = w0 ^ g_word;
    wire [31:0] w5 = w1 ^ w4;
    wire [31:0] w6 = w2 ^ w5;
    wire [31:0] w7 = w3 ^ w6;

    assign key_out = {w4, w5, w6, w7};

    function [7:0] rcon;
        input [3:0] r;
        begin
            case (r)
                4'd1:  rcon = 8'h01;
                4'd2:  rcon = 8'h02;
                4'd3:  rcon = 8'h04;
                4'd4:  rcon = 8'h08;
                4'd5:  rcon = 8'h10;
                4'd6:  rcon = 8'h20;
                4'd7:  rcon = 8'h40;
                4'd8:  rcon = 8'h80;
                4'd9:  rcon = 8'h1b;
                4'd10: rcon = 8'h36;
                default: rcon = 8'h00;
            endcase
        end
    endfunction
endmodule
