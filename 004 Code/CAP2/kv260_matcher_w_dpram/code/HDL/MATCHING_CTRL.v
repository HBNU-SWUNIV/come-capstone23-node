`timescale 1ns/100ps
module MATCHING_CTRL #
(
    parameter integer DATA_WIDTH = 64,
    parameter integer MATCHER_NUM = 1
)
(
    input wire i_fclk,
    input wire i_reset_n,

    output wire o_lfsr_init,
    output wire o_lfsr_enable,

    output wire o_data_valid,
    input wire [MATCHER_NUM-1:0] i_result_match,
    input wire [MATCHER_NUM-1:0] i_result_valid,
    input wire [MATCHER_NUM-1:0] i_shift_result_valid,
    output wire [MATCHER_NUM-1:0] o_result_reset,

    output wire o_matcher_mem_ce,
    output wire [3:0] o_matcher_mem_we,
    output wire [9:0] o_matcher_mem_addr,
    input wire [31:0] i_matcher_mem_out,
    output wire [31:0] o_matcher_mem_in
);

    parameter integer   ADDR_RESET = 'h01,
                        ADDR_MATCH = 'h02,
                        ADDR_PASS = 'h03,
                        ADDR_FILTER = 'h04;

    localparam integer  STATE_LFSR_INIT = 'h0,
                        STATE_RAND_DATA_SET = 'h1,
                        STATE_CHECK_RESET = 'h2,
                        STATE_WAIT = 'h3,
                        STATE_SAVE_MATCH = 'h4,
                        STATE_SAVE_PASS = 'h5,
                        STATE_SAVE_FILTER = 'h6;

    reg [7:0] cur_state, next_state;

    reg r_lfsr_init;
    reg r_lfsr_enable;
    reg r_data_valid;
    reg r_matcher_mem_ce;
    reg [3:0] r_matcher_mem_we;
    reg [9:0] r_matcher_mem_addr;
    reg [31:0] r_matcher_mem_in;

    reg [31:0] r_match_count [MATCHER_NUM-1:0];
    reg [31:0] r_pass_count [MATCHER_NUM-1:0];
    reg [31:0] r_filter_count [MATCHER_NUM-1:0];

    always @(posedge i_fclk) begin
        if(!i_reset_n) begin
            cur_state <= STATE_LFSR_INIT;
        end else begin
            cur_state <= next_state;
        end
    end

    always @(*) begin
        case(cur_state)
            STATE_LFSR_INIT: begin
                next_state = STATE_RAND_DATA_SET;
            end
            STATE_RAND_DATA_SET: begin
                next_state = STATE_CHECK_RESET;
            end
            STATE_CHECK_RESET: begin
                next_state = STATE_WAIT;
            end
            STATE_WAIT: begin
                if(i_result_valid == {MATCHER_NUM{1'b1}} && i_result_match == {MATCHER_NUM{1'b0}})
                    next_state = STATE_SAVE_MATCH;
                else
                    next_state = STATE_WAIT;
            end
            STATE_SAVE_MATCH: begin
                next_state = STATE_SAVE_PASS;
            end
            STATE_SAVE_PASS: begin
                next_state = STATE_SAVE_FILTER;
            end
            STATE_SAVE_FILTER: begin
                next_state = STATE_RAND_DATA_SET;
            end
            default: begin
                next_state = STATE_LFSR_INIT;
            end
        endcase
    end

    always @(*) begin
        case(cur_state)
            STATE_LFSR_INIT: begin
                r_lfsr_init = 1'b1;
                r_lfsr_enable = 1'b1;
                r_data_valid = 1'b0;
                r_matcher_mem_ce = 1'b0;
                r_matcher_mem_we = 'h0;
                r_matcher_mem_addr = 'h0;
            end
            STATE_RAND_DATA_SET: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b1;
                r_data_valid = 1'b0;
                r_matcher_mem_ce = 1'b1;
                r_matcher_mem_we = 'h0;
                r_matcher_mem_addr = ADDR_RESET;
            end
            STATE_CHECK_RESET: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b0;
                r_data_valid = 1'b1;
                r_matcher_mem_ce = 1'b1;
                r_matcher_mem_we = 'h0;
                r_matcher_mem_addr = 'h0;
            end
            STATE_WAIT: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b0;
                r_data_valid = 1'b1;
                r_matcher_mem_ce = 1'b0;
                r_matcher_mem_we = 'h0;
                r_matcher_mem_addr = 'h0;
            end
            STATE_SAVE_MATCH: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b0;
                r_data_valid = 1'b0;
                r_matcher_mem_ce = 1'b1;
                r_matcher_mem_we = 'hF;
                r_matcher_mem_addr = ADDR_MATCH;
            end
            STATE_SAVE_PASS: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b0;
                r_data_valid = 1'b0;
                r_matcher_mem_ce = 1'b1;
                r_matcher_mem_we = 'hF;
                r_matcher_mem_addr = ADDR_PASS;
            end
            STATE_SAVE_FILTER: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b0;
                r_data_valid = 1'b0;
                r_matcher_mem_ce = 1'b1;
                r_matcher_mem_we = 'hF;
                r_matcher_mem_addr = ADDR_FILTER;
            end
            default: begin
                r_lfsr_init = 1'b0;
                r_lfsr_enable = 1'b0;
                r_data_valid = 1'b0;
                r_matcher_mem_ce = 1'b0;
                r_matcher_mem_we = 'h0;
                r_matcher_mem_addr = 'h0;
            end
        endcase
    end

    integer num;

    always @(*) begin
        case(cur_state)
            STATE_SAVE_MATCH: begin
                r_matcher_mem_in = 'h0;
                for(num = 0; num < MATCHER_NUM; num = num + 1)
                    r_matcher_mem_in = r_matcher_mem_in + r_match_count[num];
            end
            STATE_SAVE_PASS: begin
                r_matcher_mem_in = 'h0;
                for(num = 0; num < MATCHER_NUM; num = num + 1)
                    r_matcher_mem_in = r_matcher_mem_in + r_pass_count[num];
            end
            STATE_SAVE_FILTER: begin
                r_matcher_mem_in = 'h0;
                for(num = 0; num < MATCHER_NUM; num = num + 1)
                    r_matcher_mem_in = r_matcher_mem_in + r_filter_count[num];
            end
            default: begin
                r_matcher_mem_in = 'h0;
            end
        endcase
    end

    genvar i;
    for(i = 0; i < MATCHER_NUM; i = i + 1) begin
        always @(posedge i_fclk) begin
            if(!i_reset_n) begin
                r_match_count[i] <= 'h0;
                r_pass_count[i] <= 'h0;
                r_filter_count[i] <= 'h0;
            end else begin
                case(cur_state)
                    STATE_CHECK_RESET: begin
                        if(i_matcher_mem_out[0] == 1'b1) begin
                            r_match_count[i] <= 'h0;
                            r_pass_count[i] <= 'h0;
                            r_filter_count[i] <= 'h0;
                        end
                    end
                    STATE_WAIT: begin
                        if(i_result_valid[i] && i_result_match[i]) begin
                            r_match_count[i] <= r_match_count[i] + 1'b1;
                        end
                    end
                    STATE_SAVE_MATCH: begin
                        r_pass_count[i] <= r_pass_count[i] + 1'b1;
                    end
                endcase
                if(i_shift_result_valid[i]) begin
                    r_filter_count[i] <= r_filter_count[i] + 1'b1;
                end
            end
        end

        assign o_result_reset[i] = (i_result_valid[i] && i_result_match[i]) ? 1'b1 : 1'b0;
    end

    assign o_lfsr_init = r_lfsr_init;
    assign o_lfsr_enable = r_lfsr_enable;
    assign o_data_valid = r_data_valid;

    assign o_matcher_mem_ce = r_matcher_mem_ce;
    assign o_matcher_mem_we = r_matcher_mem_we;
    assign o_matcher_mem_addr = r_matcher_mem_addr;
    assign o_matcher_mem_in = r_matcher_mem_in;

endmodule
