module program_counter
(
    input clk,
    input reset_n,
    input jb_enable,
    input [31:0] jb_value,
    output [31:0] pc
);

    reg [31:0] pc_reg;
    reg [31:0] next_pc_comb;

    always @(*) begin
        if(jb_enable)
            next_pc_comb = jb_value;
        else
            next_pc_comb = pc_reg + 1'b1;
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            pc_reg <= 32'h0;
        end else begin
            pc_reg <= next_pc_comb;
        end
    end

    assign pc = pc_reg;

endmodule
