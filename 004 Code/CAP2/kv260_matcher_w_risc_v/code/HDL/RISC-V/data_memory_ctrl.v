module data_memory_ctrl
(
    input clk,
    input reset_n,
    input jump_branch_enable,
    input [31:0] src1_value,
    input [31:0] src2_value,
    input [31:0] imm,
    input [4:0] rd,
    input [5:0] operation_con,

    output write_req,
    output [4:0] write_addr,
    output [31:0] write_data,

    output [29:0] mem_addr,
    output [3:0] mem_we,
    output mem_ce,
    output [31:0] mem_d,
    input [31:0] mem_q
);

    `include "instruction_param.vh"

    reg [3:0] mem_we_comb;
    reg mem_ce_comb;
    reg [31:0] mem_d_comb;
    reg [31:0] write_data_comb;

    wire [31:0] addr_calc;

    assign addr_calc = src1_value + imm;

    always @(*) begin
        case(operation_con)
            LB: begin
                mem_ce_comb = 1'b1;
                mem_we_comb = 4'b0000;
            end
            LH: begin
                mem_ce_comb = 1'b1;
                mem_we_comb = 4'b0000;
            end
            LW: begin
                mem_ce_comb = 1'b1;
                mem_we_comb = 4'b0000;
            end
            LBU: begin
                mem_ce_comb = 1'b1;
                mem_we_comb = 4'b0000;
            end
            LHU: begin
                mem_ce_comb = 1'b1;
                mem_we_comb = 4'b0000;
            end
            SB: begin
                case(addr_calc[1:0])
                    2'b00: mem_we_comb = 4'b0001;
                    2'b01: mem_we_comb = 4'b0010;
                    2'b10: mem_we_comb = 4'b0100;
                    2'b11: mem_we_comb = 4'b1000;
                endcase
                mem_ce_comb = 1'b1;
            end
            SH: begin
                case(addr_calc[1])
                    1'b0: mem_we_comb = 4'b0011;
                    1'b1: mem_we_comb = 4'b1100;
                endcase
                mem_ce_comb = 1'b1;
            end
            SW: begin
                mem_ce_comb = 1'b1;
                mem_we_comb = 4'b1111;
            end
            default: begin
                mem_ce_comb = 1'b0;
                mem_we_comb = 4'b0000;
            end
        endcase
    end

    always @(*) begin
        case(operation_con)
            LB: begin
                case(addr_calc[1:0])
                    2'b00: write_data_comb = {{24{mem_q[7]}}, mem_q[7:0]};
                    2'b01: write_data_comb = {{24{mem_q[15]}}, mem_q[15:8]};
                    2'b10: write_data_comb = {{24{mem_q[23]}}, mem_q[23:16]};
                    2'b11: write_data_comb = {{24{mem_q[31]}}, mem_q[31:24]};
                endcase
            end
            LH: begin
                case(addr_calc[1])
                    1'b0: write_data_comb = {{16{mem_q[15]}}, mem_q[15:0]};
                    1'b1: write_data_comb = {{16{mem_q[31]}}, mem_q[31:16]};
                endcase
            end
            LW: begin
                write_data_comb = mem_q;
            end
            LBU: begin
                case(addr_calc[1:0])
                    2'b00: write_data_comb = {{24{1'b0}}, mem_q[7:0]};
                    2'b01: write_data_comb = {{24{1'b0}}, mem_q[15:8]};
                    2'b10: write_data_comb = {{24{1'b0}}, mem_q[23:16]};
                    2'b11: write_data_comb = {{24{1'b0}}, mem_q[31:24]};
                endcase
            end
            LHU: begin
                case(addr_calc[1])
                    1'b0: write_data_comb = {{16{1'b0}}, mem_q[15:0]};
                    1'b1: write_data_comb = {{16{1'b0}}, mem_q[31:16]};
                endcase
            end
            default: begin
                write_data_comb = 32'h0;
            end
        endcase
    end

    always @(*) begin
        case(operation_con)
            SB: begin
                case(addr_calc[1:0])
                    2'b00: mem_d_comb = {{24{1'b0}}, src2_value[7:0]};
                    2'b01: mem_d_comb = {{16{1'b0}}, src2_value[7:0], {8{1'b0}}};
                    2'b10: mem_d_comb = {{8{1'b0}}, src2_value[7:0], {16{1'b0}}};
                    2'b11: mem_d_comb = {src2_value[7:0], {24{1'b0}}};
                endcase
            end
            SH: begin
                case(addr_calc[1])
                    1'b0: mem_d_comb = {{16{1'b0}}, src2_value[15:0]};
                    1'b1: mem_d_comb = {src2_value[15:0], {16{1'b0}}};
                endcase
            end
            SW: begin
                mem_d_comb = src2_value;
            end
            default:
                mem_d_comb = 32'h0;
        endcase
    end

    reg [4:0] write_addr_reg;
    reg write_req_reg;

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            write_addr_reg <= 5'h0;
            write_req_reg <= 1'b0;
        end else begin
            write_addr_reg <= rd;
            case(operation_con)
                LB: write_req_reg <= 1'b1;
                LH: write_req_reg <= 1'b1;
                LW: write_req_reg <= 1'b1;
                LBU: write_req_reg <= 1'b1;
                LHU: write_req_reg <= 1'b1;
                default: write_req_reg <= 1'b0;
            endcase
        end
    end

    assign mem_addr = addr_calc[31:2];
    assign mem_d = mem_d_comb;
    assign mem_ce = mem_ce_comb;
    assign mem_we = jump_branch_enable ? 4'h0 : mem_we_comb;

    assign write_req = jump_branch_enable ? 1'b0 : write_req_reg;
    assign write_data = write_data_comb;
    assign write_addr = write_addr_reg;

endmodule