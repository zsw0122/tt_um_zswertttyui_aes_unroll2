`timescale 1ns/1ps

module tb_tt_um_zswertttyui_aes_unroll2;
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg        ena;
    reg        clk;
    reg        rst_n;

    integer fd;
    integer status;
    integer total_count;
    integer pass_count;
    integer fail_count;
    integer i;
    reg [1023:0] vector_file;
    reg [127:0] key_vec;
    reg [127:0] pt_vec;
    reg [127:0] ct_exp;
    reg [127:0] ct_got;

    tt_um_zswertttyui_aes_unroll2 dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    function [7:0] get_byte;
        input [127:0] data;
        input integer index;
        begin
            get_byte = data[127 - index*8 -: 8];
        end
    endfunction

    task pulse_control;
        input integer bit_index;
        begin
            uio_in[bit_index] = 1'b1;
            @(posedge clk);
            #1;
            uio_in[bit_index] = 1'b0;
            @(posedge clk);
            #1;
        end
    endtask

    task load_16_key_bytes;
        input [127:0] k;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                ui_in = get_byte(k, i);
                pulse_control(0);
            end
        end
    endtask

    task load_16_plaintext_bytes;
        input [127:0] p;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                ui_in = get_byte(p, i);
                pulse_control(1);
            end
        end
    endtask

    task read_16_ciphertext_bytes;
        output [127:0] c;
        begin
            c = 128'd0;
            for (i = 0; i < 16; i = i + 1) begin
                @(negedge clk);
                c = {c[119:0], uo_out};
                if (i < 15)
                    pulse_control(3);
            end
        end
    endtask

    task run_one_vector;
        input [127:0] k;
        input [127:0] p;
        input [127:0] expected;
        begin
            // Reset before each vector so the byte counters start from zero.
            rst_n = 1'b0;
            ui_in = 8'd0;
            uio_in = 8'd0;
            repeat (4) @(posedge clk);
            rst_n = 1'b1;
            repeat (2) @(posedge clk);

            load_16_key_bytes(k);
            load_16_plaintext_bytes(p);

            // Start AES encryption.
            pulse_control(2);
            wait (uio_out[5] == 1'b1);  // done status
            repeat (2) @(posedge clk);

            read_16_ciphertext_bytes(ct_got);

            total_count = total_count + 1;
            if (ct_got === expected) begin
                pass_count = pass_count + 1;
                $display("PASS vector %0d: key=%032h plaintext=%032h ciphertext=%032h", total_count, k, p, ct_got);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL vector %0d", total_count);
                $display("  key       = %032h", k);
                $display("  plaintext = %032h", p);
                $display("  expected  = %032h", expected);
                $display("  got       = %032h", ct_got);
            end
        end
    endtask

    initial begin
        ena = 1'b1;
        ui_in = 8'd0;
        uio_in = 8'd0;
        rst_n = 1'b0;
        total_count = 0;
        pass_count = 0;
        fail_count = 0;

        if (!$value$plusargs("VECTORS=%s", vector_file)) begin
            vector_file = "vectors.txt";
        end

        fd = $fopen(vector_file, "r");
        if (fd == 0) begin
            $display("ERROR: Cannot open vector file: %0s", vector_file);
            $finish;
        end

        while (!$feof(fd)) begin
            status = $fscanf(fd, "%h %h %h", key_vec, pt_vec, ct_exp);
            if (status == 3) begin
                run_one_vector(key_vec, pt_vec, ct_exp);
            end
        end
        $fclose(fd);

        $display("SUMMARY: total=%0d pass=%0d fail=%0d", total_count, pass_count, fail_count);
        if (fail_count == 0 && total_count > 0)
            $display("ALL TINY TAPEOUT WRAPPER AES-128 TEST VECTORS PASSED");
        else
            $display("TINY TAPEOUT WRAPPER AES-128 TEST FAILED");
        $finish;
    end
endmodule
