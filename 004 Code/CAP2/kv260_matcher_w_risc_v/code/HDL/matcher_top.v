`timescale 1ns/100ps
module matcher_top # 
(
    parameter integer INPUT_STREAM_WIDTH = 512,
    parameter integer DATA_WIDTH = 64,
    parameter integer COMPARE_WIDTH = 16,
    parameter integer FILTER_LENGTH = 1024
)
(
    input wire fclk,
    input wire areset_n,

    input wire [INPUT_STREAM_WIDTH-1:0] input_stream,
    input wire data_valid,
    
    output wire result_match,
    output wire result_valid,
    output wire [DATA_WIDTH-1:0] result_data,
    output wire shift_result_valid,
    input wire result_reset
);

    localparam integer INTERNAL_INPUT_STREAM_WIDTH = INPUT_STREAM_WIDTH + DATA_WIDTH;

    wire mem_enable;
    wire [$clog2(FILTER_LENGTH)-1:0] mem_addr;
    wire [DATA_WIDTH-1:0] mem_data_out;
    wire [INTERNAL_INPUT_STREAM_WIDTH/8-1:0] filter_result;
    wire [DATA_WIDTH-1:0] filter_result_data;
    wire filter_result_valid;
    wire filter_result_done;
    wire filter_result_reset;
    wire _result_valid;
    wire _result_match;
    wire _result_reset;

    reg [DATA_WIDTH-1:0] _save_input_stream_last;
    reg [DATA_WIDTH-1:0] _set_input_stream_last;

    assign result_match = _result_match;
    assign result_valid = _result_match || filter_result_done;
    assign _result_reset = _result_match ? result_reset : _result_valid;
    assign filter_result_reset = _result_match ? result_reset : _result_valid;
    assign result_data = filter_result_data;
    assign shift_result_valid = _result_valid;

    always @(posedge fclk) begin
        if(!areset_n) begin
            _save_input_stream_last <= 'h0;
            _set_input_stream_last <= 'h0;
        end else begin
            if(data_valid)
                _save_input_stream_last <= input_stream[0+:DATA_WIDTH];
            if(!data_valid)
                _set_input_stream_last <= _save_input_stream_last;
        end
    end

    matcher_filter # (
        .INPUT_STREAM_WIDTH(INTERNAL_INPUT_STREAM_WIDTH),
        .COMPARE_WIDTH(COMPARE_WIDTH),
        .FILTER_LENGTH(FILTER_LENGTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) matcher_filter_inst (
        .fclk(fclk),
        .areset_n(areset_n),

        //matcher list memory interface
        .mem_enable(mem_enable),
        .mem_addr(mem_addr),
        .mem_data_out(mem_data_out),

        //matcher input data interface
        .input_stream({_set_input_stream_last, input_stream}),
        .data_valid(data_valid),

        //matcher filter result output interface
        .filter_result(filter_result),
        .filter_result_data(filter_result_data),
        .filter_result_valid(filter_result_valid),
        .filter_result_done(filter_result_done),
        .filter_result_reset(filter_result_reset)
    );

    matcher_list_rom # (
        .LIST_WIDTH($clog2(FILTER_LENGTH)),
        .DATA_WIDTH(DATA_WIDTH)
    ) matcher_list_rom_inst (
        .fclk(fclk),

        .enable(mem_enable),
        .addr(mem_addr),

        .data_out(mem_data_out)
    );

    matcher_shift_or # (
        .INPUT_STREAM_WIDTH(INTERNAL_INPUT_STREAM_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) matcher_shift_or_inst (
        .fclk(fclk),
        .areset_n(areset_n),

        //matcher input data interface
        .input_stream({_set_input_stream_last, input_stream}),

        //matcher filter result output interface
        .compare_data(filter_result_data),
        .filter_result_valid(filter_result_valid),
        .result_valid(_result_valid),
        .result_match(_result_match),
        .result_reset(_result_reset)
    );


endmodule
