`timescale 1ns/100ps
module data_mem_wrapper # 
(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 10,
    parameter integer BYTE_WIDTH = 8
)
(
    input wire i_a_clk,
    input wire i_a_ce,
    input wire [DATA_WIDTH/BYTE_WIDTH-1:0] i_a_we,
    input wire [ADDR_WIDTH-1:0] i_a_addr,
    output wire [DATA_WIDTH-1:0] o_a_data_out,
    input wire [DATA_WIDTH-1:0] i_a_data_in,

    input wire i_b_clk,
    input wire i_b_ce,
    input wire [DATA_WIDTH/BYTE_WIDTH-1:0] i_b_we,
    input wire [ADDR_WIDTH-1:0] i_b_addr,
    output wire [DATA_WIDTH-1:0] o_b_data_out,
    input wire [DATA_WIDTH-1:0] i_b_data_in,

    input wire [31:0] i_match_count_result,
    input wire [31:0] i_pass_count_result,
    input wire [31:0] i_filter_count_result,
    output wire [7:0] o_pwm_width,
    output wire o_counter_reset,
    output wire risc_v_resetn
);

    localparam integer  ADDR_MATCH_COUNT = 'h200,
                        ADDR_PASS_COUNT = 'h201,
                        ADDR_FILTER_COUNT = 'h202,
                        ADDR_PWM_WIDTH = 'h203,
                        ADDR_COUNTER_RESET = 'h204,
                        ADDR_CORE_RESET = 'h205;

    wire _i_a_clk;
    wire _i_a_ce;
    wire [DATA_WIDTH/BYTE_WIDTH-1:0] _i_a_we;
    wire [ADDR_WIDTH-1:0] _i_a_addr;
    wire [DATA_WIDTH-1:0] _o_a_data_out;
    wire [DATA_WIDTH-1:0] _i_a_data_in;

    wire _i_b_clk;
    wire _i_b_ce;
    wire [DATA_WIDTH/BYTE_WIDTH-1:0] _i_b_we;
    wire [ADDR_WIDTH-1:0] _i_b_addr;
    wire [DATA_WIDTH-1:0] _o_b_data_out;
    wire [DATA_WIDTH-1:0] _i_b_data_in;

    reg [31:0] _i_match_count_result_a;
    reg [31:0] _i_pass_count_result_a;
    reg [31:0] _i_filter_count_result_a;

    reg [31:0] _i_match_count_result_b;
    reg [31:0] _i_pass_count_result_b;
    reg [31:0] _i_filter_count_result_b;

    reg [7:0] _o_pwm_width_a;
    reg _o_counter_reset_a;
    reg _risc_v_resetn_a;

    reg [7:0] _o_pwm_width_b;
    reg _o_counter_reset_b;
    reg _risc_v_resetn_b;

    always @(posedge i_a_clk) begin
        if(i_a_ce) begin
            if(i_a_we[0]) begin
                case(i_a_addr)
                    ADDR_PWM_WIDTH: _o_pwm_width_a <= i_a_data_in[0+:8];
                    ADDR_COUNTER_RESET: _o_counter_reset_a <= i_a_data_in[0+:1];
                    ADDR_CORE_RESET: _risc_v_resetn_a <= i_a_data_in[0+:1];
                endcase
            end
        end
        _i_match_count_result_a <= i_match_count_result;
        _i_pass_count_result_a <= i_pass_count_result;
        _i_filter_count_result_a <= i_filter_count_result;
    end

    assign _i_a_clk = i_a_clk;
    assign _i_a_ce = (i_a_addr < ADDR_MATCH_COUNT) ? i_a_ce : 1'b0;
    assign _i_a_we = (i_a_addr < ADDR_MATCH_COUNT) ? i_a_we : 'h0;
    assign _i_a_addr = i_a_addr;
    assign _i_a_data_in = i_a_data_in;
    assign o_a_data_out =   i_a_addr == ADDR_MATCH_COUNT ? _i_match_count_result_a :
                            i_a_addr == ADDR_PASS_COUNT ? _i_pass_count_result_a :
                            i_a_addr == ADDR_FILTER_COUNT ? _i_filter_count_result_a :
                            i_a_addr == ADDR_PWM_WIDTH ? {{24{1'b0}}, o_pwm_width} :
                            i_a_addr == ADDR_COUNTER_RESET ? {{31{1'b0}}, o_counter_reset} :
                            i_a_addr == ADDR_CORE_RESET ? {{31{1'b0}}, risc_v_resetn} : _o_a_data_out;

    always @(posedge i_b_clk) begin
        if(i_b_ce) begin
            if(i_b_we[0]) begin
                case(i_b_addr)
                    ADDR_PWM_WIDTH: _o_pwm_width_b <= i_b_data_in[0+:8];
                    ADDR_COUNTER_RESET: _o_counter_reset_b <= i_b_data_in[0+:1];
                    ADDR_CORE_RESET: _risc_v_resetn_b <= i_b_data_in[0+:1];
                endcase
            end
        end
        _i_match_count_result_b <= i_match_count_result;
        _i_pass_count_result_b <= i_pass_count_result;
        _i_filter_count_result_b <= i_filter_count_result;
    end

    assign _i_b_clk = i_b_clk;
    assign _i_b_ce = (i_b_addr < ADDR_MATCH_COUNT) ? i_b_ce : 1'b0;
    assign _i_b_we = (i_b_addr < ADDR_MATCH_COUNT) ? i_b_we : 'h0;
    assign _i_b_addr = i_b_addr;
    assign _i_b_data_in = i_b_data_in;
    assign o_b_data_out =   i_b_addr == ADDR_MATCH_COUNT ? _i_match_count_result_b :
                            i_b_addr == ADDR_PASS_COUNT ? _i_pass_count_result_b :
                            i_b_addr == ADDR_FILTER_COUNT ? _i_filter_count_result_b :
                            i_b_addr == ADDR_PWM_WIDTH ? {{24{1'b0}}, o_pwm_width} :
                            i_b_addr == ADDR_COUNTER_RESET ? {{31{1'b0}}, o_counter_reset} :
                            i_b_addr == ADDR_CORE_RESET ? {{31{1'b0}}, risc_v_resetn} : _o_b_data_out;
    
    assign o_pwm_width = _o_pwm_width_b;
    assign o_counter_reset = _o_counter_reset_a;
    assign risc_v_resetn = _risc_v_resetn_b;

    true_dpram # (
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .BYTE_WIDTH(BYTE_WIDTH)
    ) data_memory (
        .i_a_clk(_i_a_clk),
        .i_a_ce(_i_a_ce),
        .i_a_we(_i_a_we),
        .i_a_addr(_i_a_addr),
        .o_a_data_out(_o_a_data_out),
        .i_a_data_in(_i_a_data_in),

        .i_b_clk(_i_b_clk),
        .i_b_ce(_i_b_ce),
        .i_b_we(_i_b_we),
        .i_b_addr(_i_b_addr),
        .o_b_data_out(_o_b_data_out),
        .i_b_data_in(_i_b_data_in)
    );


endmodule
