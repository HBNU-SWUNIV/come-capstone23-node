`timescale 1ns/100ps
module TOP #
(
    parameter integer CLOCK_FREQUENCY = 100_000_000,
    parameter integer OUTPUT_FREQUENCY = 2_000
)
(
    output wire o_fan
    //output wire o_jb_enable//port1
    //output wire o_result_match,//port3
    //output wire o_result_valid,//port2
    //output wire o_shift_result_valid//port4
);

    localparam integer LFSR_WIDTH = 128;

    localparam integer INPUT_STREAM_WIDTH = 512;
    localparam integer DATA_WIDTH = 24;
    localparam integer COMPARE_WIDTH = 16;
    localparam integer FILTER_LENGTH = 1024;

    localparam integer RISC_V_MEM_DATA_WIDTH = 32;
    localparam integer RISC_V_MEM_ADDR_WIDTH = 10;
    localparam integer RISC_V_BYTE_WIDTH = 8;

    wire fclk;
    wire reset_n;
    wire [31:0] match_count_result;
    wire [31:0] pass_count_result;
    wire [31:0] filter_count_result;
    wire [7:0] pwm_width;
    wire counter_reset;
    wire risc_v_resetn;

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

    wire instruction_mem_ce;
    wire [3:0] instruction_mem_we;
    wire [9:0] instruction_mem_addr;
    wire [31:0] instruction_mem_d;
    wire [31:0] instruction_mem_q;

    wire data_mem_ce;
    wire [3:0] data_mem_we;
    wire [9:0] data_mem_addr;
    wire [31:0] data_mem_d;
    wire [31:0] data_mem_q;

    wire [11:0]DATA_MEM_addr;
    wire DATA_MEM_clk;
    wire [31:0]DATA_MEM_din;
    wire [31:0]DATA_MEM_dout;
    wire DATA_MEM_en;
    wire DATA_MEM_rst;
    wire [3:0]DATA_MEM_we;

    wire [11:0]INSTRUCTION_MEM_addr;
    wire INSTRUCTION_MEM_clk;
    wire [31:0]INSTRUCTION_MEM_din;
    wire [31:0]INSTRUCTION_MEM_dout;
    wire INSTRUCTION_MEM_en;
    wire INSTRUCTION_MEM_rst;
    wire [3:0]INSTRUCTION_MEM_we;
    /*
    PS_inst_wrapper_tb PS_PS_inst (
        .BRAM_PORTA_0_addr(DATA_MEM_addr),
        .BRAM_PORTA_0_clk(DATA_MEM_clk),
        .BRAM_PORTA_0_din(DATA_MEM_din),
        .BRAM_PORTA_0_dout(DATA_MEM_dout),
        .BRAM_PORTA_0_en(DATA_MEM_en),
        .BRAM_PORTA_0_rst(DATA_MEM_rst),
        .BRAM_PORTA_0_we(DATA_MEM_we),
        .BRAM_PORTA_1_addr(INSTRUCTION_MEM_addr),
        .BRAM_PORTA_1_clk(INSTRUCTION_MEM_clk),
        .BRAM_PORTA_1_din(INSTRUCTION_MEM_din),
        .BRAM_PORTA_1_dout(INSTRUCTION_MEM_dout),
        .BRAM_PORTA_1_en(INSTRUCTION_MEM_en),
        .BRAM_PORTA_1_rst(INSTRUCTION_MEM_rst),
        .BRAM_PORTA_1_we(INSTRUCTION_MEM_we),
        .pl_resetn0(reset_n),
        .pl_clk0(fclk)
    );
    */
    PS_inst_wrapper PS_PS_inst (
        .BRAM_PORTA_0_addr(DATA_MEM_addr),
        .BRAM_PORTA_0_clk(DATA_MEM_clk),
        .BRAM_PORTA_0_din(DATA_MEM_din),
        .BRAM_PORTA_0_dout(DATA_MEM_dout),
        .BRAM_PORTA_0_en(DATA_MEM_en),
        .BRAM_PORTA_0_rst(DATA_MEM_rst),
        .BRAM_PORTA_0_we(DATA_MEM_we),
        .BRAM_PORTA_1_addr(INSTRUCTION_MEM_addr),
        .BRAM_PORTA_1_clk(INSTRUCTION_MEM_clk),
        .BRAM_PORTA_1_din(INSTRUCTION_MEM_din),
        .BRAM_PORTA_1_dout(INSTRUCTION_MEM_dout),
        .BRAM_PORTA_1_en(INSTRUCTION_MEM_en),
        .BRAM_PORTA_1_rst(INSTRUCTION_MEM_rst),
        .BRAM_PORTA_1_we(INSTRUCTION_MEM_we),
        .pl_resetn0(reset_n),
        .pl_clk0(fclk)
    );
    

    risc_v_core risc_v_core_inst (
        .clk(fclk),
        .reset_n(risc_v_resetn),

        .instruction_mem_ce(instruction_mem_ce),
        .instruction_mem_we(instruction_mem_we),
        .instruction_mem_addr(instruction_mem_addr),
        .instruction_mem_d(instruction_mem_d),
        .instruction_mem_q(instruction_mem_q),

        .data_mem_ce(data_mem_ce),
        .data_mem_we(data_mem_we),
        .data_mem_addr(data_mem_addr),
        .data_mem_d(data_mem_d),
        .data_mem_q(data_mem_q),
        .o_jb_enable(o_jb_enable)
    );  

    true_dpram # (
        .DATA_WIDTH(RISC_V_MEM_DATA_WIDTH),
        .ADDR_WIDTH(RISC_V_MEM_ADDR_WIDTH),
        .BYTE_WIDTH(RISC_V_BYTE_WIDTH)
    ) instruction_memory (
        .i_a_clk(fclk),
        .i_a_ce(instruction_mem_ce),
        .i_a_we(instruction_mem_we),
        .i_a_addr(instruction_mem_addr),
        .o_a_data_out(instruction_mem_q),
        .i_a_data_in(instruction_mem_d),

        .i_b_clk(INSTRUCTION_MEM_clk),
        .i_b_ce(INSTRUCTION_MEM_en),
        .i_b_we(INSTRUCTION_MEM_we),
        .i_b_addr(INSTRUCTION_MEM_addr[2+:RISC_V_MEM_ADDR_WIDTH]),
        .o_b_data_out(INSTRUCTION_MEM_dout),
        .i_b_data_in(INSTRUCTION_MEM_din)
    );

    data_mem_wrapper # (
        .DATA_WIDTH(RISC_V_MEM_DATA_WIDTH),
        .ADDR_WIDTH(RISC_V_MEM_ADDR_WIDTH),
        .BYTE_WIDTH(RISC_V_BYTE_WIDTH)
    ) data_mem_wrapper_inst (
        .i_a_clk(fclk),
        .i_a_ce(data_mem_ce),
        .i_a_we(data_mem_we),
        .i_a_addr(data_mem_addr),
        .o_a_data_out(data_mem_q),
        .i_a_data_in(data_mem_d),

        .i_b_clk(DATA_MEM_clk),
        .i_b_ce(DATA_MEM_en),
        .i_b_we(DATA_MEM_we),
        .i_b_addr(DATA_MEM_addr[2+:RISC_V_MEM_ADDR_WIDTH]),
        .o_b_data_out(DATA_MEM_dout),
        .i_b_data_in(DATA_MEM_din),

        .i_match_count_result(match_count_result),
        .i_pass_count_result(pass_count_result),
        .i_filter_count_result(filter_count_result),
        .o_pwm_width(pwm_width),
        .o_counter_reset(counter_reset),
        .risc_v_resetn(risc_v_resetn)
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

        .i_counter_reset(counter_reset),
        
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

    //assign o_result_match = result_match;
    //assign o_result_valid = result_valid;
    //assign o_shift_result_valid = shift_result_valid;

endmodule
