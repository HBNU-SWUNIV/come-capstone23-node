`timescale 1ns/1ps

module MATCHER_W #
(
    parameter integer MATCHER_WIDTH = 8,        //utf-8 8비트
    parameter integer MATCHER_LENGTH = 8,       //리스트 속 스트링의 최대 길이
    parameter integer MATCHER_LIST_LENGTH = 10, //리스트의 길이
    parameter integer MATCHER_WORKER_COUNT = 5,  //동시에 비교하는 matcher의 갯수
    parameter integer ADDR_WIDTH = 8
)
(
    input wire clk,
    input wire reset_n,

    input wire [MATCHER_WIDTH-1:0] data_stream,
    input wire stream_enable,

    output wire [MATCHER_LENGTH-1:0] result,
    output wire result_enable
);

    //블랙리스트 ROM
    reg [MATCHER_WIDTH-1:0] mem_list [(MATCHER_LENGTH*MATCHER_LIST_LENGTH)-1:0];

    //블랙리스트 이진 벡터
    reg [MATCHER_LENGTH-1:0] match_array [MATCHER_WORKER_COUNT-1:0];
    
    //블랙리스트 쉬프트 레지스터
    reg [MATCHER_LENGTH-1:0] match_shift [MATCHER_WORKER_COUNT-1:0];

    reg [MATCHER_WORKER_COUNT-1:0] match_result [MATCHER_LENGTH-1:0];

    reg stream_enable_edge [1:0];

    wire stream_enable_rise;

    reg [ADDR_WIDTH-1:0] list_state;

    reg [ADDR_WIDTH-1:0] matcher_delay;

    wire matcher_set_done;

    initial begin
        $readmemh("black_list.txt", mem_list);              //41 42 43 00 00 00 00 00   //IP 사용 확인
    end                                                     //A  B  C  NL NL NL NL NL

    integer worker_count;
    integer length_count;

    //이진 벡터 계산
    always @(*) begin
        if(!stream_enable) begin
            for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count = worker_count + 1)
                match_array[worker_count] <= {MATCHER_LENGTH{1'b1}};
        end else begin
            for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count = worker_count + 1) begin
                for(length_count = 0; length_count < MATCHER_LENGTH; length_count = length_count + 1) begin
                    if(mem_list[(MATCHER_WORKER_COUNT*MATCHER_LENGTH*list_state)+worker_count*MATCHER_LENGTH+length_count] == data_stream || mem_list[(MATCHER_WORKER_COUNT*MATCHER_LENGTH*list_state)+worker_count*MATCHER_LENGTH+length_count] == 'h0)
                        match_array[worker_count][length_count] <= 1'b0;
                    else
                        match_array[worker_count][length_count] <= 1'b1;
                end 
            end
        end
    end

    //쉬프트 레지스터 계산
    always @(posedge clk) begin
        if(!reset_n) begin
            for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count = worker_count + 1)
                match_shift[worker_count] <= {MATCHER_LENGTH{1'b1}};
        end else begin
            if(!stream_enable) begin
                for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count = worker_count + 1)
                    match_shift[worker_count] <= {MATCHER_LENGTH{1'b1}};
            end else begin
                for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count = worker_count + 1) begin
                    match_shift[worker_count] <= match_shift[worker_count] << 1 | match_array[worker_count];
                end
            end
        end
    end

    always @(posedge clk) begin
        if(!reset_n) begin
            matcher_delay <= {ADDR_WIDTH{1'b0}};
        end else begin
            if(stream_enable) begin
                matcher_delay <= matcher_delay + 1;
            end else begin
                matcher_delay <= {ADDR_WIDTH{1'b0}};
            end
        end
    end

    assign matcher_set_done = matcher_delay == MATCHER_LENGTH + 1 ? 1'b1 : 1'b0;
    assign result_enable = (matcher_set_done && list_state == ;

    always @(posedge clk) begin
        if(!reset_n) begin
            list_state <= {ADDR_WIDTH{1'b0}};
        end else begin
            if(matcher_set_done) begin
                list_state <= list_state + 1;
            end else begin
                
            end
        end
    end

    //stream_enable 상승엣지 검출
    always @(posedge clk) begin
        if(!reset_n) begin
            stream_enable_edge[0] <= 1'b0;
            stream_enable_edge[1] <= 1'b0;
        end else begin
            stream_enable_edge[0] <= stream_enable;
            stream_enable_edge[1] <= stream_enable_edge[0];
        end
    end

    assign stream_enable_rise = stream_enable_edge[0] & ~stream_enable_edge[0];

    //결과 저장
    always @(posedge clk) begin
        if(!reset_n) begin
            for(length_count = 0; length_count < MATCHER_LENGTH; length_count = length_count + 1)
                match_result[length_count] <= {MATCHER_WORKER_COUNT{1'b1}};
        end else begin
            if(matcher_set_done) begin
                for(length_count = 0; length_count < MATCHER_LENGTH; length_count = length_count + 1)
                    match_result[length_count] <= {MATCHER_WORKER_COUNT{1'b1}};
            end else begin
                for(length_count = 0; length_count < MATCHER_LENGTH; length_count = length_count + 1) begin
                    for(worker_count = 0; worker_count < MATCHER_WORKER_COUNT; worker_count = worker_count + 1) begin
                        if(match_shift[worker_count][length_count] == 1'b0)
                        match_result[length_count][worker_count] <= 1'b0;
                    end
                end
            end
        end
    end

    genvar result_index;
    for(result_index = 0; result_index < MATCHER_LENGTH; result_index = result_index + 1) begin
        assign result[result_index] = match_result[result_index] == {MATCHER_WORKER_COUNT{1'b1}} ? 1'b0 : 1'b1;
    end

endmodule
