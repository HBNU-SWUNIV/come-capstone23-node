module decode_logic
(
    input clk,
    input reset_n,
    input [31:0] instruction,
    input jump_branch_enable,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    output [5:0] operation_con
);

    `include "instruction_param.vh"

    wire instruction_invalid;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [6:0] opcode;
    wire imm_valid;

    wire [10:0] dec_bits_11;

    wire [31:0] imm_comb;
    reg [31:0] imm_priv_reg;
    reg [31:0] imm_final_reg;

    wire [4:0] rd_comb;
    reg [4:0] rd_priv_reg;
    reg [4:0] rd_final_reg;

    wire [4:0] rs1_comb;
    wire [4:0] rs2_comb;
    reg [4:0] rs1_reg;
    reg [4:0] rs2_reg;

    reg [5:0] operation_con_priv;
    reg [5:0] operation_con_final;

    reg jump_branch_enable_reg;

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            operation_con_priv <= NONE;
        end else begin
            if(jump_branch_enable)
                operation_con_priv <= NONE;
            else begin
                casex(dec_bits_11)
                    11'bx_000_0010011://addi
                        operation_con_priv <= ADDI;
                    11'bx_010_0010011://slti
                        operation_con_priv <= SLTI;
                    11'bx_011_0010011://sltiu
                        operation_con_priv <= SLTIU;
                    11'bx_111_0010011://andi
                        operation_con_priv <= ANDI;
                    11'bx_110_0010011://ori
                        operation_con_priv <= ORI;
                    11'bx_100_0010011://xori
                        operation_con_priv <= XORI;
                    11'b0_001_0010011://slli
                        operation_con_priv <= SLLI;
                    11'b0_101_0010011://srli
                        operation_con_priv <= SRLI;
                    11'b1_101_0010011://srai
                        operation_con_priv <= SRAI;
                    11'bx_xxx_0110111://lui
                        operation_con_priv <= LUI;
                    11'bx_xxx_0010111://auipc
                        operation_con_priv <= AUIPC;
                    11'b0_000_0110011://add
                        operation_con_priv <= ADD;
                    11'b0_010_0110011://slt
                        operation_con_priv <= SLT;
                    11'b0_011_0110011://sltu
                        operation_con_priv <= SLTU;
                    11'b0_111_0110011://and
                        operation_con_priv <= AND;
                    11'b0_110_0110011://or
                        operation_con_priv <= OR;
                    11'b0_100_0110011://xor
                        operation_con_priv <= XOR;
                    11'b0_001_0110011://sll
                        operation_con_priv <= SLL;
                    11'b0_101_0110011://srl
                        operation_con_priv <= SRL;
                    11'b1_000_0110011://sub
                        operation_con_priv <= SUB;
                    11'b1_101_0110011://sra
                        operation_con_priv <= SRA;
                    11'bx_xxx_1101111://jal
                        operation_con_priv <= JAL;
                    11'bx_000_1100111://jalr
                        operation_con_priv <= JALR;
                    11'bx_000_1100011://beq
                        operation_con_priv <= BEQ;
                    11'bx_001_1100011://bne
                        operation_con_priv <= BNE;
                    11'bx_100_1100011://blt
                        operation_con_priv <= BLT;
                    11'bx_110_1100011://bltu
                        operation_con_priv <= BLTU;
                    11'bx_101_1100011://bge
                        operation_con_priv <= BGE;
                    11'bx_111_1100011://bgeu
                        operation_con_priv <= BGEU;
                    11'bx_000_0000011://lb
                        operation_con_priv <= LB;
                    11'bx_001_0000011://lh
                        operation_con_priv <= LH;
                    11'bx_010_0000011://lw
                        operation_con_priv <= LW;
                    11'bx_100_0000011://lbu
                        operation_con_priv <= LBU;
                    11'bx_101_0000011://lhu
                        operation_con_priv <= LHU;
                    11'bx_000_0100011://sb
                        operation_con_priv <= SB;
                    11'bx_001_0100011://sh
                        operation_con_priv <= SH;
                    11'bx_010_0100011://sw
                        operation_con_priv <= SW;
                    default:
                        operation_con_priv <= NONE;
                endcase
            end
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            operation_con_final <= NONE;
        end else begin
            if(jump_branch_enable) begin
                operation_con_final <= NONE;
            end else begin
                operation_con_final <= operation_con_priv;
            end
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            imm_priv_reg <= 32'h0;
            imm_final_reg <= 32'h0;

            rd_priv_reg <= 5'h0;
            rd_final_reg <= 5'h0;

            rs1_reg <= 5'h0;
            rs2_reg <= 5'h0;
        end else begin
            imm_priv_reg <= imm_comb;
            imm_final_reg <= imm_priv_reg;

            rd_priv_reg <= rd_comb;
            rd_final_reg <= rd_priv_reg;

            rs1_reg <= rs1_comb;
            rs2_reg <= rs2_comb;
        end
    end

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            jump_branch_enable_reg <= 1'b0;
        end else begin
            jump_branch_enable_reg <= jump_branch_enable;
        end
    end

    decode_instruction dec_inst1
    (
        .instruction(instruction),
        .instruction_invalid(instruction_invalid),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1_comb),
        .rs2(rs2_comb),
        .rd(rd_comb),
        .opcode(opcode),
        .imm_valid(imm_valid),
        .imm(imm_comb)
    );

    assign dec_bits_11 = jump_branch_enable_reg ? 7'h0 : {funct7[5], funct3, opcode};

    assign operation_con = operation_con_final;

    assign imm = imm_final_reg;
    assign rd = rd_final_reg;

    assign rs1 = rs1_reg;
    assign rs2 = rs2_reg;

endmodule
