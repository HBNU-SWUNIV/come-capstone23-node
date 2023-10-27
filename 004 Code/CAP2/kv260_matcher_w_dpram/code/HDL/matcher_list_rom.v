`timescale 1ms/100ps
module matcher_list_rom #
(
    parameter integer LIST_WIDTH = 10,
    parameter integer DATA_WIDTH = 64,
    parameter integer FILTER_INDEX = 0
)
(
    input fclk,

    input enable,
    input [LIST_WIDTH-1:0] addr,

    output wire [DATA_WIDTH-1:0] data_out

);

    reg [DATA_WIDTH-1:0] list_mem [(2**LIST_WIDTH) + FILTER_INDEX-1:0];
    reg [DATA_WIDTH-1:0] data_out_reg;

    initial begin
        $readmemh("list.mem", list_mem);
    end

    always @(posedge fclk) begin
        if(enable) begin
            data_out_reg <= list_mem[addr + FILTER_INDEX];
        end else begin
            data_out_reg <= 'h0;
        end
    end

    assign data_out = data_out_reg;

endmodule
