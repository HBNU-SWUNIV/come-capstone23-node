`timescale 1ns/100ps
module MATCHING_CTRL #
(
    parameter integer FILTER_LENGTH = 1024,
    parameter integer DATA_WIDTH = 64
)
(
    input wire i_fclk,
    input wire i_reset_n,

    output wire o_lfsr_init,
    output wire o_lfsr_enable,
    input wire [3:0] i_loop_done,

    output wire o_data_valid,
    input wire i_result_match,
    input wire i_result_valid,
    input wire [DATA_WIDTH-1:0] i_result_data,
    input wire i_shift_result_valid,
    output wire o_result_reset,

    input wire i_counter_reset,

    output wire [31:0] match_count_result,
    output wire [31:0] pass_count_result,
    output wire [31:0] filter_count_result
);

    localparam integer  STATE_LFSR_INIT = 'h0,
                        STATE_RAND_DATA_SET = 'h1,
                        STATE_WAIT = 'h2,
                        STATE_SET_FLAG = 'h3;

    reg [7:0] cur_state, next_state;

    reg [31:0] match_count;
    reg [31:0] pass_count;
    reg [31:0] filter_count;

    reg o_lfsr_init_reg;
    reg o_lfsr_enable_reg;
    reg o_data_valid_reg;
    reg o_result_reset_reg;

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
                next_state = STATE_WAIT;
            end
            STATE_WAIT: begin
                if(i_result_valid)
                    next_state = STATE_SET_FLAG;
                else
                    next_state = STATE_WAIT;
            end
            STATE_SET_FLAG: begin
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
                o_lfsr_init_reg = 1'b1;
                o_lfsr_enable_reg = 1'b1;
                o_data_valid_reg = 1'b0;
                o_result_reset_reg = 1'b0;
            end
            STATE_RAND_DATA_SET: begin
                o_lfsr_init_reg = 1'b0;
                o_lfsr_enable_reg = 1'b0;
                o_data_valid_reg = 1'b1;
                o_result_reset_reg = 1'b0;
            end
            STATE_WAIT: begin
                o_lfsr_init_reg = 1'b0;
                o_lfsr_enable_reg = 1'b0;
                o_data_valid_reg = 1'b1;
                o_result_reset_reg = 1'b0;
            end
            STATE_SET_FLAG: begin
                if(i_result_match) begin
                    o_lfsr_init_reg = 1'b0;
                    o_lfsr_enable_reg = 1'b0;
                    o_data_valid_reg = 1'b1;
                    o_result_reset_reg = 1'b1;
                end else begin
                    o_lfsr_init_reg = 1'b0;
                    o_lfsr_enable_reg = 1'b1;
                    o_data_valid_reg = 1'b0;
                    o_result_reset_reg = 1'b0;
                end
            end
            default: begin
                o_lfsr_init_reg = 1'b0;
                o_lfsr_enable_reg = 1'b0;
                o_data_valid_reg = 1'b0;
                o_result_reset_reg = 1'b0;
            end
        endcase
    end

    assign o_lfsr_init = o_lfsr_init_reg;
    assign o_lfsr_enable = o_lfsr_enable_reg;
    assign o_data_valid = o_data_valid_reg;
    assign o_result_reset = o_result_reset_reg;

    always @(posedge i_fclk) begin
        if(!i_reset_n) begin
            match_count <= 'h0;
            pass_count <= 'h0;
            filter_count <= 'h0;
        end else begin
            if(i_counter_reset) begin
                match_count <= 'h0;
                pass_count <= 'h0;
                filter_count <= 'h0;
            end else begin
                if(cur_state == STATE_SET_FLAG) begin
                    if(i_result_match)
                        match_count <= match_count + 1'b1;
                    else
                        pass_count <= pass_count + 1'b1;
                end
                if(i_shift_result_valid)
                    filter_count <= filter_count + 1'b1;
            end
        end
    end

    assign match_count_result = match_count;
    assign pass_count_result = pass_count;
    assign filter_count_result = filter_count;

endmodule
