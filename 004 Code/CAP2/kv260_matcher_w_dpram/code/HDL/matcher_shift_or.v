`timescale 1ns/100ps
module matcher_shift_or #
(
    parameter integer INPUT_STREAM_WIDTH = 512,
    parameter integer DATA_WIDTH = 64
)
(
    input fclk,
    input areset_n,

    //matcher input data interface
    input [INPUT_STREAM_WIDTH-1:0] input_stream,

    //matcher filter result output interface
    input [DATA_WIDTH-1:0] compare_data,
    input filter_result_valid,

    output result_valid,
    output result_match,
    input result_reset
);

    reg [DATA_WIDTH/8-1:0] binary_vector;
    reg [DATA_WIDTH/8:0] shift_vector;
    reg [$clog2(INPUT_STREAM_WIDTH/8)-1:0] filter_result_index;
    reg result_match_reg;

    reg [7:0] cur_state;
    reg [7:0] next_state;

    wire operation_done;

    localparam [7:0]  SHIFT_IDLE = 8'h0,
                SHIFT_OPERATION = 8'h1,
                SHIFT_DONE = 8'h2;

    always @(posedge fclk) begin
        if(!areset_n) begin
            cur_state <= SHIFT_IDLE;
        end else begin
            cur_state <= next_state;
        end
    end

    always @(*) begin
        case(cur_state)
            SHIFT_IDLE: begin
                if(filter_result_valid)
                    next_state <= SHIFT_OPERATION;
                else
                    next_state <= SHIFT_IDLE;
            end
            SHIFT_OPERATION: begin
                if(operation_done)
                    next_state <= SHIFT_DONE;
                else
                    next_state <= SHIFT_OPERATION;
            end
            SHIFT_DONE: begin
                if(result_reset)
                    next_state <= SHIFT_IDLE;
                else
                    next_state <= SHIFT_DONE;
            end
            default: begin
                next_state <= SHIFT_IDLE;
            end
        endcase
    end
    
    always @(posedge fclk) begin
        if(!areset_n) begin
            filter_result_index <= 'h0;
        end else begin
            if(cur_state == SHIFT_OPERATION) 
                filter_result_index <= filter_result_index + 1;
            else if(cur_state == SHIFT_IDLE)
                filter_result_index <= 'h0;
        end
    end

    assign operation_done = filter_result_index == INPUT_STREAM_WIDTH/8-1 || shift_vector[DATA_WIDTH/8] ? 1'b1 : 1'b0;

    integer binary_vector_count;
    always @(*) begin
        for(binary_vector_count = 0; binary_vector_count < DATA_WIDTH/8; binary_vector_count = binary_vector_count + 1) begin
            if(input_stream[8*filter_result_index+:8] == compare_data[8*binary_vector_count+:8])
                binary_vector[binary_vector_count] = 1'b1;
            else
                binary_vector[binary_vector_count] = 1'b0;
        end
    end

    integer shift_vector_count;
    always @(posedge fclk) begin
        if(!areset_n) begin
            shift_vector <= 'h0;
        end else begin
            if(cur_state == SHIFT_OPERATION) begin
                shift_vector[0] <= 1'b1;
                for(shift_vector_count = 0; shift_vector_count < DATA_WIDTH/8; shift_vector_count = shift_vector_count + 1) begin
                    shift_vector[shift_vector_count+1] <= shift_vector[shift_vector_count] & binary_vector[shift_vector_count];
                end
            end
        end
    end

    always @(posedge fclk) begin
        if(!areset_n) begin
            result_match_reg <= 1'b0;
        end else begin
            if(cur_state == SHIFT_OPERATION)
                result_match_reg <= shift_vector[DATA_WIDTH/8];
            else if(cur_state == SHIFT_IDLE)
                result_match_reg <= 1'b0;
        end
    end

    assign result_match = cur_state == SHIFT_DONE ? result_match_reg : 1'b0;
    assign result_valid = cur_state == SHIFT_DONE ? 1'b1 : 1'b0;

endmodule