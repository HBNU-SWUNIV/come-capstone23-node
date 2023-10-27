`timescale 1ns/100ps
module PWM #
(
    parameter integer CLOCK_FREQUENCY = 100_000_000,
    parameter integer OUTPUT_FREQUENCY = 20_000
)
(
    input wire i_fclk,
    input wire i_reset_n,
    input wire [7:0] i_width,
    output wire o_pwm_out
);

    reg [$clog2(CLOCK_FREQUENCY/OUTPUT_FREQUENCY)-1:0] clock_div;
    reg [7:0] out_width_reg;

    wire clock_tick;

    always @(posedge i_fclk) begin
        if(!i_reset_n) begin
            clock_div <= 'h0;
        end else begin
            if(clock_div == CLOCK_FREQUENCY/OUTPUT_FREQUENCY-1)
                clock_div <= 'h0;
            else    
                clock_div <= clock_div + 1'b1;
        end
    end

    assign clock_tick = clock_div == CLOCK_FREQUENCY/OUTPUT_FREQUENCY-1 ? 1'b1 : 1'b0;

    always @(posedge i_fclk) begin
        if(!i_reset_n) begin
            out_width_reg <= 'h0;
        end else begin
            if(clock_tick)
                out_width_reg <= out_width_reg + 1'b1;
        end
    end

    assign o_pwm_out = out_width_reg <= i_width ? 1'b1: 1'b0;

endmodule
