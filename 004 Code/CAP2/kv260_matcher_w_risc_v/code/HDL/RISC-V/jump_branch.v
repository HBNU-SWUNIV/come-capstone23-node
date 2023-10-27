module jump_branch
(
    input clk,
    input reset_n,
    input [31:0] pc,
    input [31:0] src1_value,
    input [31:0] src2_value,
    input [31:0] imm,
    input [4:0] rd,
    input [5:0] operation_con,
    
    output [31:0] jb_target_pc,
    output jb_enable,

    output write_req,
    output [4:0] write_addr,
    output [31:0] write_data
);

    `include "instruction_param.vh"

    reg taken_branch_reg;
    reg [31:0] target_pc_reg;

    reg [31:0] pc_wait_reg [2:0];

    reg [31:0] write_data_reg;
    reg [4:0] write_addr_reg;
    reg write_req_reg;

    wire [31:0] pc_next_value;
    wire [31:0] jalr_value;

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
            taken_branch_reg <= 1'b0;
            target_pc_reg <= 32'h0;
            write_data_reg <= 32'h0;
            write_addr_reg <= 5'h0;
            write_req_reg <= 1'b0;
        end else begin
            case(operation_con)
                JAL: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= ~jb_enable;
                        target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    write_req_reg <= ~jb_enable;
                    write_addr_reg <= rd;
                    write_data_reg <= {pc_next_value[29:0], {2{1'b0}}};
                end
                JALR: begin
                    if(jalr_value == pc_wait_reg[2] + 1'b1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= ~jb_enable;
                        target_pc_reg <= jalr_value;
                    end
                    
                    write_req_reg <= ~jb_enable;
                    write_addr_reg <= rd;
                    write_data_reg <= {pc_next_value[29:0], {2{1'b0}}};
                end
                BEQ: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= (src1_value == src2_value) ? ~jb_enable : 1'b0;
                        target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    
                    write_req_reg <= 1'b0;
                end
                BNE: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= (src1_value != src2_value) ? ~jb_enable : 1'b0;
                        target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    write_req_reg <= 1'b0;
                end
                BLT: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= (src1_value < src2_value) ^ (src1_value[31] != src2_value[31]) ? ~jb_enable : 1'b0;
                        target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    write_req_reg <= 1'b0;
                end
                BGE: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= (src1_value >= src2_value) ^ (src1_value[31] != src2_value[31]) ? ~jb_enable : 1'b0;
                    target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    write_req_reg <= 1'b0;
                end
                BLTU: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= (src1_value < src2_value) ? ~jb_enable : 1'b0;
                        target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    write_req_reg <= 1'b0;
                end
                BGEU: begin
                    if(imm[31:2] == 30'h1) begin
                        taken_branch_reg <= 1'b0;
                    end else begin
                        taken_branch_reg <= (src1_value >= src2_value) ? ~jb_enable : 1'b0;
                        target_pc_reg <= pc_wait_reg[2] + {imm[31], imm[31], imm[31:2]};
                    end
                    write_req_reg <= 1'b0;
                end
                default: begin
                    taken_branch_reg <= 1'b0;
                    target_pc_reg <= 32'h0;
                    write_req_reg <= 1'b0;
                end
            endcase
        end
    end

    assign pc_next_value = pc_wait_reg[2] + 1'b1;
    assign jalr_value = {src1_value[31], src1_value[31], src1_value[31:2]} + {imm[31], imm[31], imm[31:2]};
    assign jb_target_pc = target_pc_reg;
    assign jb_enable = taken_branch_reg;

    assign write_req = write_req_reg;
    assign write_data = write_data_reg;
    assign write_addr = write_addr_reg;
    

endmodule
