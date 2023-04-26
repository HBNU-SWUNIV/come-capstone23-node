vlib work
vlog MATCHER.v MATCHER_tb.v MATCHER_W.v
vsim work.MATCHER_tb

add wave -divider system_input
add wave /MATCHER_tb/clk
add wave /MATCHER_tb/reset_n

add wave -divider data_stream
add wave -radix hexadecimal /MATCHER_tb/data_stream
add wave /MATCHER_tb/stream_enable

add wave -divider matcher_state
add wave -radix hexadecimal /MATCHER_tb/matcher_inst/mem_list
add wave -radix hexadecimal /MATCHER_tb/matcher_inst/match_array
add wave -radix hexadecimal /MATCHER_tb/matcher_inst/match_shift

add wave -divider result
add wave -radix hexadecimal /MATCHER_tb/result
add wave /MATCHER_tb/result_enable

run -all