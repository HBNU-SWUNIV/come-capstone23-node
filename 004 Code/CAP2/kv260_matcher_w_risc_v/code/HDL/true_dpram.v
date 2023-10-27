`timescale 1ns/100ps
module true_dpram #
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
    output reg [DATA_WIDTH-1:0] o_a_data_out,
    input wire [DATA_WIDTH-1:0] i_a_data_in,

    input wire i_b_clk,
    input wire i_b_ce,
    input wire [DATA_WIDTH/BYTE_WIDTH-1:0] i_b_we,
    input wire [ADDR_WIDTH-1:0] i_b_addr,
    output reg [DATA_WIDTH-1:0] o_b_data_out,
    input wire [DATA_WIDTH-1:0] i_b_data_in
);

    reg [DATA_WIDTH-1:0] ram [(2**ADDR_WIDTH)-1:0];
    
    integer i;

    always @(posedge i_a_clk) begin
        if(i_a_ce) begin
            for(i = 0; i < DATA_WIDTH/BYTE_WIDTH; i = i + 1) begin
                if(i_a_we[i]) begin
                    ram[i_a_addr][i*BYTE_WIDTH+:BYTE_WIDTH] <= i_a_data_in[i*BYTE_WIDTH+:BYTE_WIDTH];
                end
            end
            o_a_data_out <= ram[i_a_addr];
        end
    end

    always @(posedge i_b_clk) begin
        if(i_b_ce) begin
            for(i = 0; i < DATA_WIDTH/BYTE_WIDTH; i = i + 1) begin
                if(i_b_we[i]) begin
                    ram[i_b_addr][i*BYTE_WIDTH+:BYTE_WIDTH] <= i_b_data_in[i*BYTE_WIDTH+:BYTE_WIDTH];
                end
            end
            o_b_data_out <= ram[i_b_addr];
        end
    end

endmodule
