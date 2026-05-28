if {[file exists work]} {vdel -lib work -all}
vlib work
vlog ../src/*.v tb_tt_um_zswertttyui_aes_unroll2.v
vsim work.tb_tt_um_zswertttyui_aes_unroll2 +VECTORS=vectors.txt
add wave -divider "Tiny Tapeout IO"
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/ui_in
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/uo_out
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/uio_in
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/uio_out
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/uio_oe
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/clk
add wave sim:/tb_tt_um_zswertttyui_aes_unroll2/rst_n
add wave -divider "Test Counters"
add wave -radix unsigned sim:/tb_tt_um_zswertttyui_aes_unroll2/total_count
add wave -radix unsigned sim:/tb_tt_um_zswertttyui_aes_unroll2/pass_count
add wave -radix unsigned sim:/tb_tt_um_zswertttyui_aes_unroll2/fail_count
onfinish stop
run -all
