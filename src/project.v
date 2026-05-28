/*
 * Tiny Tapeout wrapper for the AES-128 2-round unrolled design.
 *
 * Byte-serial interface because Tiny Tapeout does not provide enough pins
 * for direct 128-bit key/plaintext/ciphertext buses.
 *
 * Pin plan:
 *   ui_in[7:0]  : input byte for key/plaintext loading
 *   uio_in[0]   : pulse high for one clk to load one key byte
 *   uio_in[1]   : pulse high for one clk to load one plaintext byte
 *   uio_in[2]   : pulse high for one clk to start encryption
 *   uio_in[3]   : pulse high for one clk to advance ciphertext output byte
 *   uo_out[7:0] : selected ciphertext byte output
 *   uio_out[4]  : busy status
 *   uio_out[5]  : done status
 *   uio_out[6]  : key_ready status, 16 key bytes loaded
 *   uio_out[7]  : plaintext_ready status, 16 plaintext bytes loaded
 */
module tt_um_zswertttyui_aes_unroll2 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    reg  [127:0] key_reg;
    reg  [127:0] plaintext_reg;
    reg  [127:0] ciphertext_reg;
    reg  [4:0]   key_count;
    reg  [4:0]   plaintext_count;
    reg  [3:0]   read_index;
    reg  [7:0]   uio_in_d;
    reg          aes_start;
    reg          aes_done_d;

    wire         reset = ~rst_n;
    wire         aes_busy;
    wire         aes_done;
    wire [127:0] aes_ciphertext;

    wire load_key_edge       = uio_in[0] & ~uio_in_d[0];
    wire load_plaintext_edge = uio_in[1] & ~uio_in_d[1];
    wire start_edge          = uio_in[2] & ~uio_in_d[2];
    wire read_next_edge      = uio_in[3] & ~uio_in_d[3];

    wire key_ready       = (key_count == 5'd16);
    wire plaintext_ready = (plaintext_count == 5'd16);

    aes_top_unroll2 u_aes (
        .clk(clk),
        .reset(reset),
        .start(aes_start),
        .plaintext(plaintext_reg),
        .key(key_reg),
        .busy(aes_busy),
        .done(aes_done),
        .ciphertext(aes_ciphertext)
    );

    function [7:0] select_byte;
        input [127:0] data;
        input [3:0] index;
        begin
            case (index)
                4'd0:  select_byte = data[127:120];
                4'd1:  select_byte = data[119:112];
                4'd2:  select_byte = data[111:104];
                4'd3:  select_byte = data[103:96];
                4'd4:  select_byte = data[95:88];
                4'd5:  select_byte = data[87:80];
                4'd6:  select_byte = data[79:72];
                4'd7:  select_byte = data[71:64];
                4'd8:  select_byte = data[63:56];
                4'd9:  select_byte = data[55:48];
                4'd10: select_byte = data[47:40];
                4'd11: select_byte = data[39:32];
                4'd12: select_byte = data[31:24];
                4'd13: select_byte = data[23:16];
                4'd14: select_byte = data[15:8];
                4'd15: select_byte = data[7:0];
                default: select_byte = 8'h00;
            endcase
        end
    endfunction

    assign uo_out = select_byte(ciphertext_reg, read_index);

    // uio[3:0] are input controls; uio[7:4] are output status pins.
    assign uio_oe  = 8'b1111_0000;
    assign uio_out = {plaintext_ready, key_ready, aes_done, aes_busy, 4'b0000};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_reg         <= 128'd0;
            plaintext_reg   <= 128'd0;
            ciphertext_reg  <= 128'd0;
            key_count       <= 5'd0;
            plaintext_count <= 5'd0;
            read_index      <= 4'd0;
            uio_in_d        <= 8'd0;
            aes_start       <= 1'b0;
            aes_done_d      <= 1'b0;
        end else begin
            uio_in_d   <= uio_in;
            aes_start  <= 1'b0;
            aes_done_d <= aes_done;

            // Load bytes MSB first. After 16 pulses, key_reg/plaintext_reg match
            // the normal 128-bit hexadecimal order used by AES test vectors.
            if (load_key_edge) begin
                if (key_count >= 5'd16) begin
                    key_reg   <= {120'd0, ui_in};
                    key_count <= 5'd1;
                end else begin
                    key_reg   <= {key_reg[119:0], ui_in};
                    key_count <= key_count + 5'd1;
                end
            end

            if (load_plaintext_edge) begin
                if (plaintext_count >= 5'd16) begin
                    plaintext_reg   <= {120'd0, ui_in};
                    plaintext_count <= 5'd1;
                end else begin
                    plaintext_reg   <= {plaintext_reg[119:0], ui_in};
                    plaintext_count <= plaintext_count + 5'd1;
                end
            end

            if (start_edge && key_ready && plaintext_ready && !aes_busy) begin
                aes_start  <= 1'b1;
                read_index <= 4'd0;
            end

            if (aes_done && !aes_done_d) begin
                ciphertext_reg <= aes_ciphertext;
                read_index     <= 4'd0;
            end

            if (read_next_edge && aes_done) begin
                if (read_index < 4'd15)
                    read_index <= read_index + 4'd1;
            end
        end
    end

    // Prevent unused input warnings.
    wire _unused = &{ena, uio_in[7:4], 1'b0};
endmodule
