`timescale 1ns/1ps

module MATCHER #
(
    parameter integer MATCHER_WIDTH = 8,        //utf-8 8비트
    parameter integer MATCHER_LENGTH = 8,       //리스트 속 스트링의 최대 길이
    parameter integer MATCHER_LIST_LENGTH = 10, //리스트의 길이
    parameter integer MATCHER_WORKER_COUNT = 5  //동시에 비교하는 matcher의 갯수
)
(
    input wire clk,
    input wire reset_n,

    input wire [MATCHER_WIDTH-1:0] data_stream,
    input wire stream_enable,

    output wire [MATCHER_LENGTH/2-1:0] result,
    output wire result_enable
);

    //블랙리스트 ROM
    reg [MATCHER_WIDTH-1:0] mem_list [(MATCHER_LENGTH*MATCHER_LIST_LENGTH)-1:0];

    //블랙리스트 이진 벡터
    reg match_array [(MATCHER_LENGTH*MATCHER_WORKER_COUNT)-1:0];
    
    //블랙리스트 쉬프트 레지스터
    reg match_shift [(MATCHER_LENGTH*MATCHER_WORKER_COUNT)-1:0];

    reg match_result [MATCHER_LENGTH-1:0];

    initial begin
        $readmemh("black_list.txt", mem_list);              //41 42 43 00 00 00 00 00
    end                                                     //A  B  C  NL NL NL NL NL

    integer array_count;
    integer worker_count;
    integer length_count;

    //이진 벡터 계산
    always @(posedge clk) begin
        if(!reset_n) begin
            for(array_count = 0; array_count < MATCHER_LENGTH*MATCHER_WORKER_COUNT; array_count = array_count + 1)
                match_array[array_count] <= 1'b1;
        end else begin
            if(!stream_enable) begin
                for(array_count = 0; array_count < MATCHER_LENGTH*MATCHER_WORKER_COUNT; array_count = array_count + 1)
                    match_array[array_count] <= 1'b1;
            end else begin
                for(array_count = 0; array_count < MATCHER_LENGTH*MATCHER_WORKER_COUNT; array_count = array_count + 1) begin
                    if(mem_list[array_count] == data_stream || mem_list[array_count] == 'h0)
                        match_array[array_count] <= 1'b0;
                end
            end
        end
    end

    //쉬프트 레지스터 계산
    always @(posedge clk) begin
        if(!reset_n) begin
            for(array_count = 0; array_count < MATCHER_LENGTH*MATCHER_WORKER_COUNT; array_count=array_count+1)
                match_shift[array_count] <= 1'b1;
        end else begin
            if(!stream_enable) begin
                for(array_count = 0; array_count < MATCHER_LENGTH*MATCHER_WORKER_COUNT; array_count=array_count+1)
                    match_shift[array_count] <= 1'b1;
            end else begin
                for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count=worker_count+1) begin
                    match_shift[worker_count*MATCHER_LENGTH] <= 1'b0;
                    for(length_count = 0; length_count < MATCHER_LENGTH-1; length_count=length_count+1)
                        match_shift[worker_count*MATCHER_LENGTH+length_count+1] <= match_shift[worker_count*MATCHER_LENGTH+length_count] | match_array[worker_count*MATCHER_LENGTH+length_count];
                end
            end
        end
    end
/*
    genvar result_index;
    genvar worker_index;

    for(worker_index = 0; worker_index < MATCHER_WORKER_COUNT; worker_index++)
        assign match_result[worker_index] 
    
    for(result_index = 0; result_index < MATCHER_WORKER_COUNT/2; result_index++)
        assign match_result[result_index] = 
        for(worker_index = 0; worker_index < MATCHER_WORKER_COUNT; worker_index++)
            | match_shift[];
*/
endmodule
