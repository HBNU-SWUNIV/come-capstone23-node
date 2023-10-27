`timescale 1ns/100ps
module matcher_filter #
(
    parameter integer INPUT_STREAM_WIDTH = 512,
    parameter integer COMPARE_WIDTH = 16,
    parameter integer FILTER_LENGTH = 128,
    parameter integer DATA_WIDTH = 24
)
(
    input fclk,
    input areset_n,

    //matcher list memory interface
    output mem_enable,
    output [$clog2(FILTER_LENGTH)-1:0] mem_addr,
    input [DATA_WIDTH-1:0] mem_data_out,

    //matcher input data interface
    input [INPUT_STREAM_WIDTH-1:0] input_stream,
    input data_valid,

    //matcher filter result output interface
    output [INPUT_STREAM_WIDTH/8-1:0] filter_result,
    output [DATA_WIDTH-1:0] filter_result_data,
    output filter_result_valid,
    output filter_result_done,
    input filter_result_reset
);

    localparam[7:0] FILTER_IDLE = 'h00,
                    FILTER_MEM_READ = 'h01,
                    FILTER_RESULT_COMPARE = 'h02,
                    FILTER_RESULT_WAIT = 'h03,
                    FILTER_DONE = 'h04;

    reg [7:0] cur_state;
    reg [7:0] next_state;
    reg mem_enable_reg;
    reg filter_result_valid_reg;
    reg filter_result_done_reg;
    reg [$clog2(FILTER_LENGTH):0] mem_addr_reg;
    reg [INPUT_STREAM_WIDTH/8-1:0] filter_compare_result;
    reg [DATA_WIDTH-1:0] filter_result_data_reg;
    reg [INPUT_STREAM_WIDTH/8-1:0] filter_result_reg;
    wire [COMPARE_WIDTH-1:0] filter_list_head;
    wire compare_result;
    wire mem_read_done;
    

    always @(posedge fclk) begin
        if(!areset_n) begin
            cur_state <= FILTER_IDLE;
        end else begin
            cur_state <= next_state;
        end
    end

    always @(*) begin
        case(cur_state)
            FILTER_IDLE: begin
                if(data_valid)
                    next_state = FILTER_MEM_READ;
                else
                    next_state = FILTER_IDLE;
            end
            FILTER_MEM_READ: begin
                    next_state = FILTER_RESULT_COMPARE;
            end
            FILTER_RESULT_COMPARE: begin
                if(mem_read_done)
                    next_state = FILTER_DONE;
                else if(compare_result)
                    next_state = FILTER_RESULT_WAIT;
                else
                    next_state = FILTER_RESULT_COMPARE;
            end
            FILTER_RESULT_WAIT: begin
                if(!data_valid)
                    next_state = FILTER_IDLE;
                else if(filter_result_reset)
                    next_state = FILTER_MEM_READ;
                else
                    next_state = FILTER_RESULT_WAIT;
            end
            FILTER_DONE: begin
                if(!data_valid)
                    next_state = FILTER_IDLE;
                else
                    next_state = FILTER_DONE;
            end
            default: begin
                next_state = FILTER_IDLE;
            end
        endcase
    end

    always @(*) begin
        case(cur_state)
            FILTER_IDLE: begin
                mem_enable_reg = 1'b0;
                filter_result_valid_reg = 1'b0;
                filter_result_done_reg = 1'b0;
            end
            FILTER_MEM_READ: begin
                mem_enable_reg = 1'b1;
                filter_result_valid_reg = 1'b0;
                filter_result_done_reg = 1'b0;
            end
            FILTER_RESULT_COMPARE: begin
                mem_enable_reg = 1'b1;
                filter_result_valid_reg = 1'b0;
                filter_result_done_reg = 1'b0;
            end
            FILTER_RESULT_WAIT: begin
                mem_enable_reg = 1'b0;
                filter_result_valid_reg = 1'b1;
                filter_result_done_reg = 1'b0;
            end
            FILTER_DONE: begin
                mem_enable_reg = 1'b0;
                filter_result_valid_reg = 1'b0;
                filter_result_done_reg = 1'b1;
            end
            default: begin
                mem_enable_reg = 1'b0;
                filter_result_valid_reg = 1'b0;
                filter_result_done_reg = 1'b0;
            end
        endcase
    end

    assign mem_enable = mem_enable_reg;
    assign filter_result_valid = filter_result_valid_reg;
    assign filter_result_done = filter_result_done_reg;

    always @(posedge fclk) begin
        if(!areset_n) begin
            mem_addr_reg <= 'h0;
        end else begin
            if(cur_state == FILTER_RESULT_COMPARE)
                mem_addr_reg <= mem_addr_reg + 1;
            else if(cur_state == FILTER_IDLE)
                mem_addr_reg <= 'h0;
        end
    end

    assign mem_read_done = mem_addr_reg == FILTER_LENGTH ? 1'b1 : 1'b0;

    assign mem_addr = mem_addr_reg;

    assign filter_list_head = mem_data_out[COMPARE_WIDTH-1:0];

    integer filter_result_index;

    always @(*) begin
        if(cur_state == FILTER_RESULT_COMPARE) begin
            for(filter_result_index = 0; filter_result_index < INPUT_STREAM_WIDTH/8-(COMPARE_WIDTH/8-1); filter_result_index = filter_result_index + 1) begin
                filter_compare_result[filter_result_index] = input_stream[8*filter_result_index+:COMPARE_WIDTH] == filter_list_head ? 1'b1 : 1'b0;
            end
            for(filter_result_index = INPUT_STREAM_WIDTH/8-(COMPARE_WIDTH/8-1); filter_result_index < INPUT_STREAM_WIDTH/8; filter_result_index = filter_result_index + 1) begin
                filter_compare_result[filter_result_index] = 'b0;
            end
        end else begin
            filter_compare_result = 'h0;
        end
    end

    assign compare_result = filter_compare_result != {INPUT_STREAM_WIDTH/8{1'b0}} ? 1'b1 : 1'b0;

    always @(posedge fclk) begin
        if(!areset_n) begin
            filter_result_data_reg <= 'h0;
            filter_result_reg <= 'h0;
        end else begin
            if(cur_state == FILTER_RESULT_COMPARE) begin
                filter_result_data_reg <= mem_data_out;
                filter_result_reg <= filter_compare_result;
            end else if(cur_state == FILTER_MEM_READ) begin
                filter_result_data_reg <= 'h0;
                filter_result_reg <= 'h0;
            end
        end
    end

    assign filter_result = filter_result_reg;
    assign filter_result_data = filter_result_data_reg;

endmodule