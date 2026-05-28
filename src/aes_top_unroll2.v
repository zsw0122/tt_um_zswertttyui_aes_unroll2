module aes_top_unroll2 (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output wire         busy,
    output wire         done,
    output wire [127:0] ciphertext
);
    aes_core_unroll2 u_core(
        .clk(clk),
        .reset(reset),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .busy(busy),
        .done(done),
        .ciphertext(ciphertext)
    );
endmodule
