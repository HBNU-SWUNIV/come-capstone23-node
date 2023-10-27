module alu
(
    input clk,
    input reset_n,
    input jump_branch_enable,
    input [31:0] pc,
    input [31:0] src1_value,
    input [31:0] src2_value,
    input [31:0] imm,
    input [4:0] rd,
    input [5:0] operation_con,
    
    output write_req,
    output [4:0] write_addr,
    output [31:0] write_data
);

    `include "instruction_param.vh"

    reg [31:0] write_data_reg;
    reg [4:0] write_addr_reg;
    reg write_req_reg;

    reg [31:0] pc_wait_reg [2:0];

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            pc_wait_reg[0] <= 32'h0;
            pc_wait_reg[1] <= 32'h0;
            pc_wait_reg[2] <= 32'h0;
        end else begin
            pc_wait_reg[0] <= pc;
            pc_wait_reg[1] <= pc_wait_reg[0];
            pc_wait_reg[2] <= pc_wait_reg[1];
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            write_data_reg <= 32'h0;
            write_req_reg <= 1'b0;
            write_addr_reg <= 5'h0;
        end else begin
            case(operation_con)
                ADDI: begin
                    write_data_reg <= src1_value + imm;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SLTI: begin
                    write_data_reg <= ((src1_value < imm) ^ (src1_value[31] != imm[31])) ? 32'h1 : 32'h0;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SLTIU: begin
                    write_data_reg <= (src1_value < imm) ? 32'h1 : 32'h0;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                ANDI: begin
                    write_data_reg <= src1_value & imm;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                ORI: begin
                    write_data_reg <= src1_value | imm;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                XORI: begin
                    write_data_reg <= src1_value ^ imm;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SLLI: begin
                    write_data_reg <= src1_value << imm[4:0];
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SRLI: begin
                    write_data_reg <= src1_value >> imm[4:0];
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SRAI: begin
                    if(imm[31] == 1'b1)
                        write_data_reg <= src1_value << (~imm[4:0]) + 1'b1;
                    else
                        write_data_reg <= $signed(src1_value) >>> imm[4:0];
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                LUI: begin
                    write_data_reg <= imm;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                AUIPC: begin
                    write_data_reg <= imm + {pc_wait_reg[2][29:0], {2{1'b0}}};
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                ADD: begin
                    write_data_reg <= src1_value + src2_value;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SLT: begin
                    write_data_reg <= ((src1_value < src2_value) ^ (src1_value[31] != src2_value[31])) ? 32'h1 : 32'h0;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SLTU: begin
                    write_data_reg <= (src1_value < src2_value) ? 32'h1 : 32'h0;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                AND: begin
                    write_data_reg <= (src1_value & src2_value);
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                OR: begin
                    write_data_reg <= (src1_value | src2_value);
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                XOR: begin
                    write_data_reg <= (src1_value ^ src2_value);
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SLL: begin
                    write_data_reg <= src1_value << src2_value[4:0];
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SRL: begin
                    write_data_reg <= src1_value >> src2_value[4:0];
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SUB: begin
                    write_data_reg <= src1_value - src2_value;
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                SRA: begin
                    if(imm[31] == 1'b1)
                        write_data_reg <= src1_value << (~src2_value[4:0]) + 1'b1;
                    else
                        write_data_reg <= $signed(src1_value) >>> src2_value[4:0];
                    write_req_reg <= ~jump_branch_enable;
                    write_addr_reg <= rd;
                end
                default: begin
                    write_data_reg <= 32'h0;
                    write_req_reg <= 1'b0;
                    write_addr_reg <= 5'h0;
                end
            endcase
        end
    end

    assign write_req = write_req_reg;
    assign write_data = write_data_reg;
    assign write_addr = write_addr_reg;

endmodule
