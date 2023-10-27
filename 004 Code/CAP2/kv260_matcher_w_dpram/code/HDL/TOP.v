`timescale 1ns/100ps
module TOP #
(
    parameter integer CLOCK_FREQUENCY = 100_000_000,
    parameter integer OUTPUT_FREQUENCY = 2_000
)
(
    output wire o_fan
);

    localparam integer LFSR_WIDTH = 128;

    localparam integer MATCHER_NUM = 32;
    localparam integer INPUT_STREAM_WIDTH = 512;
    localparam integer DATA_WIDTH = 24;
    localparam integer COMPARE_WIDTH = 16;
    localparam integer FILTER_LENGTH = 32;

    wire fclk_100m;
    wire fclk_200m;

    wire reset_n;
    wire [7:0] pwm_width;

    wire [511:0] random_input_stream;
    wire data_valid;

    wire lfsr_init;
    wire lfsr_enable;

    wire [MATCHER_NUM-1:0] result_match;
    wire [MATCHER_NUM-1:0] result_valid;
    wire [MATCHER_NUM-1:0] shift_result_valid;
    wire [MATCHER_NUM-1:0] result_reset;

    wire matcher_mem_ce;
    wire [3:0] matcher_mem_we;
    wire [9:0] matcher_mem_addr;
    wire [31:0] matcher_mem_out;
    wire [31:0] matcher_mem_in;

    wire [11:0] ps_data_addr;
    wire ps_data_clk;
    wire [31:0] ps_data_din;
    wire [31:0] ps_data_dout;
    wire ps_data_en;
    wire ps_data_rst;
    wire [3:0] ps_data_we;

    PS_inst_wrapper PS_PS_inst (
        .BRAM_PORTA_0_addr(ps_data_addr),
        .BRAM_PORTA_0_clk(ps_data_clk),
        .BRAM_PORTA_0_din(ps_data_din),
        .BRAM_PORTA_0_dout(ps_data_dout),
        .BRAM_PORTA_0_en(ps_data_en),
        .BRAM_PORTA_0_rst(ps_data_rst),
        .BRAM_PORTA_0_we(ps_data_we),
        .pl_resetn0(reset_n),
        .pl_clk0(fclk_100m),
        .pl_clk1(fclk_200m)
    );

    true_dpram # (
        .DATA_WIDTH(32),
        .ADDR_WIDTH(10),
        .BYTE_WIDTH(8)
    ) matcher_memory (
        .i_a_clk(fclk_100m),
        .i_a_ce(ps_data_en),
        .i_a_we(ps_data_we),
        .i_a_addr(ps_data_addr[2+:10]),
        .o_a_data_out(ps_data_dout),
        .i_a_data_in(ps_data_din),

        .i_b_clk(fclk_200m),
        .i_b_ce(matcher_mem_ce),
        .i_b_we(matcher_mem_we),
        .i_b_addr(matcher_mem_addr),
        .o_b_data_out(matcher_mem_out),
        .i_b_data_in(matcher_mem_in)
    );

    MATCHING_CTRL # (
        .DATA_WIDTH(DATA_WIDTH),
        .MATCHER_NUM(MATCHER_NUM)
    ) matching_ctrl_inst (
        .i_fclk(fclk_200m),
        .i_reset_n(reset_n),

        .o_lfsr_init(lfsr_init),
        .o_lfsr_enable(lfsr_enable),

        .o_data_valid(data_valid),
        .i_result_match(result_match),
        .i_result_valid(result_valid),
        .i_shift_result_valid(shift_result_valid),
        .o_result_reset(result_reset),
        
        .o_matcher_mem_ce(matcher_mem_ce),
        .o_matcher_mem_we(matcher_mem_we),
        .o_matcher_mem_addr(matcher_mem_addr),
        .i_matcher_mem_out(matcher_mem_out),
        .o_matcher_mem_in(matcher_mem_in)
    );

    genvar i;
    for(i = 0; i < MATCHER_NUM; i = i + 1) begin
        matcher_top # (
            .INPUT_STREAM_WIDTH(INPUT_STREAM_WIDTH),
            .DATA_WIDTH(DATA_WIDTH),
            .COMPARE_WIDTH(COMPARE_WIDTH),
            .FILTER_LENGTH(FILTER_LENGTH),
            .FILTER_INDEX(i * FILTER_LENGTH)
        ) matcher_top_inst (
            .fclk(fclk_200m),
            .areset_n(reset_n),

            .input_stream(random_input_stream),
            .data_valid(data_valid),
            
            .result_match(result_match[i]),
            .result_valid(result_valid[i]),
            .result_data(),
            .shift_result_valid(shift_result_valid[i]),
            .result_reset(result_reset[i])
        );
    end
    

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_0 (
        .i_fclk(fclk_200m),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data(128'h00),

       .o_lfsr_data(random_input_stream[0+:128]),
        .o_lfsr_loop()
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_128 (
        .i_fclk(fclk_200m),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data({128{1'b1}}),

       .o_lfsr_data(random_input_stream[128+:128]),
        .o_lfsr_loop()
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_256 (
        .i_fclk(fclk_200m),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data({64{2'b10}}),

       .o_lfsr_data(random_input_stream[256+:128]),
        .o_lfsr_loop()
    );

    LFSR # (
        .BIT_WIDTH(LFSR_WIDTH)
    ) LFSR_384 (
        .i_fclk(fclk_200m),
        .i_enable(lfsr_enable),

        .i_seed_data_valied(lfsr_init),
        .i_seed_data({64{2'b01}}),

       .o_lfsr_data(random_input_stream[384+:128]),
        .o_lfsr_loop()
    );
    
    PWM # (
        .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
        .OUTPUT_FREQUENCY(OUTPUT_FREQUENCY)
    ) fan_pwm_inst (
        .i_fclk(fclk_200m),
        .i_reset_n(reset_n),
        .i_width(pwm_width),
        .o_pwm_out(o_fan)
    );

    assign pwm_width = 'd100;

endmodule
