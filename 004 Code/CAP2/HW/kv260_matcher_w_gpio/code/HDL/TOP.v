`timescale 1ns/100ps
module TOP #
(
    parameter integer CLOCK_FREQUENCY = 100_000_000,
    parameter integer OUTPUT_FREQUENCY = 1_000
)
(
    output wire o_fan,
    output wire o_lfsr_enable,//port1
    output wire o_result_match,//port3
    output wire o_result_valid,//port2
    output wire o_shift_result_valid//port4
);

    localparam integer LFSR_WIDTH = 128;

    localparam integer INPUT_STREAM_WIDTH = 512;
    localparam integer DATA_WIDTH = 24;
    localparam integer COMPARE_WIDTH = 16;
    localparam integer FILTER_LENGTH = 1024;

    wire fclk;
    wire reset_n;
    wire [31:0] match_count_result;
    wire [31:0] pass_count_result;
    wire [31:0] filter_count_result;
    wire [7:0] pwm_width;
    wire [7:0]GPIO_3_tri_o;

    wire [511:0] random_input_stream;
    wire lfsr_init;
    wire lfsr_enable;

    wire [3:0] loop;

    wire data_valid;
    wire result_match;
    wire result_valid;
    wire [DATA_WIDTH-1:0] result_data;
    wire shift_result_valid;
    wire result_reset;

    assign o_lfsr_enable = lfsr_enable;
    assign o_result_match = result_match;
    assign o_result_valid = result_valid;
    assign o_shift_result_valid = shift_result_valid;

    PS_inst_wrapper PS_PS_inst (
        .GPIO_0_tri_i(match_count_result),
        .GPIO_1_tri_i(pass_count_result),
        .GPIO_2_tri_i(filter_count_result),
        .GPIO_3_tri_o(GPIO_3_tri_o),
        .pl_clk0(fclk),
        .pl_resetn0(reset_n)
    );

    MATCHING_CTRL # (
        .FILTER_LENGTH(FILTER_LENGTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) matching_ctrl_inst (
        .i_fclk(fclk),
        .i_reset_n(reset_n),

        .o_lfsr_init(lfsr_init),
        .o_lfsr_enable(lfsr_enable),
        .i_loop_done(loop),

        .o_data_valid(data_valid),
        .i_result_match(result_match),
        .i_result_valid(result_valid),
        .i_result_data(result_data),
        .i_shift_result_valid(shift_result_valid),
        .o_result_reset(result_reset),

        .i_counter_reset(GPIO_3_tri_o[0+:1]),
        
        .match_count_result(match_count_result),
        .pass_count_result(pass_count_result),
        .filter_count_result(filter_count_result)
    );

    matcher_top # (
        .INPUT_STREAM_WIDTH(INPUT_STREAM_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .COMPARE_WIDTH(COMPARE_WIDTH),
        .FILTER_LENGTH(FILTER_LENGTH)
    ) matcher_top_inst (
        .fclk(fclk),
        .areset_n(reset_n),

        .input_stream(random_input_stream),
        .data_valid(data_valid),
        
        .result_match(result_match),
        .result_valid(result_valid),
        .result_data(result_data),
        .shift_result_valid(shift_result_valid),
        .result_reset(result_reset)
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_0 (
        .i_fclk(fclk),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data(128'h00),

       .o_lfsr_data(random_input_stream[0+:128]),
        .o_lfsr_loop(loop[0+:1])
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_128 (
        .i_fclk(fclk),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data({128{1'b1}}),

       .o_lfsr_data(random_input_stream[128+:128]),
        .o_lfsr_loop(loop[1+:1])
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_256 (
        .i_fclk(fclk),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data({64{2'b10}}),

       .o_lfsr_data(random_input_stream[256+:128]),
        .o_lfsr_loop(loop[2+:1])
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_384 (
        .i_fclk(fclk),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data({64{2'b01}}),

       .o_lfsr_data(random_input_stream[384+:128]),
        .o_lfsr_loop(loop[3+:1])
    );
    
    PWM # (
        .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
        .OUTPUT_FREQUENCY(OUTPUT_FREQUENCY)
    ) fan_pwm_inst (
        .i_fclk(fclk),
        .i_reset_n(reset_n),
        .i_width(pwm_width),
        .o_pwm_out(o_fan)
    );


    assign pwm_width = 100;

endmodule
