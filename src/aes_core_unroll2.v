module aes_core_unroll2 (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output reg          busy,
    output reg          done,
    output reg  [127:0] ciphertext
);
    reg [127:0] state;
    reg [127:0] round_key;
    reg [3:0]   round;  // 1, 3, 5, 7, 9

    wire [3:0] round_plus_one = round + 4'd1;

    wire [127:0] key1;
    wire [127:0] key2;
    wire [127:0] state_after_round1;
    wire [127:0] state_after_round2_normal;
    wire [127:0] state_after_round2_final;

    aes_key_expand u_key_expand1(
        .round(round),
        .key_in(round_key),
        .key_out(key1)
    );

    aes_key_expand u_key_expand2(
        .round(round_plus_one),
        .key_in(key1),
        .key_out(key2)
    );

    aes_round_normal u_round1(
        .state_in(state),
        .round_key(key1),
        .state_out(state_after_round1)
    );

    aes_round_normal u_round2_normal(
        .state_in(state_after_round1),
        .round_key(key2),
        .state_out(state_after_round2_normal)
    );

    aes_round_final u_round2_final(
        .state_in(state_after_round1),
        .round_key(key2),
        .state_out(state_after_round2_final)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= 128'd0;
            round_key  <= 128'd0;
            round      <= 4'd0;
            busy       <= 1'b0;
            done       <= 1'b0;
            ciphertext <= 128'd0;
        end else begin
            if (start && !busy) begin
                // Initial AddRoundKey.
                state      <= plaintext ^ key;
                round_key  <= key;
                round      <= 4'd1;
                busy       <= 1'b1;
                done       <= 1'b0;
                ciphertext <= 128'd0;
            end else if (busy) begin
                if (round < 4'd9) begin
                    state     <= state_after_round2_normal;
                    round_key <= key2;
                    round     <= round + 4'd2;
                end else begin
                    // Round 9 is normal. Round 10 is final and omits MixColumns.
                    state      <= state_after_round2_final;
                    round_key  <= key2;
                    ciphertext <= state_after_round2_final;
                    round      <= 4'd0;
                    busy       <= 1'b0;
                    done       <= 1'b1;
                end
            end
        end
    end
endmodule
