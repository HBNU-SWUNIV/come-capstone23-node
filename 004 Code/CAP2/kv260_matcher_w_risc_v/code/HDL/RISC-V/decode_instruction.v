module decode_instruction
(
    input [31:0] instruction,
    output instruction_invalid,
    output [2:0] funct3,
    output [6:0] funct7,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [6:0] opcode,
    output imm_valid,
    output [31:0] imm
);

    parameter INSTRUCTION_VALID_VALUE = 2'b11;

    reg instruction_invalid_comb;

    reg is_r_instruction_comb;
    reg is_i_instruction_comb;
    reg is_s_instruction_comb;
    reg is_b_instruction_comb;
    reg is_u_instruction_comb;
    reg is_j_instruction_comb;

    reg [2:0] funct3_comb;
    reg [6:0] funct7_comb;
    reg [4:0] rs1_comb;
    reg [4:0] rs2_comb;
    reg [4:0] rd_comb;
    reg [6:0] opcode_comb;

    reg imm_valid_comb;
    reg [31:0] imm_comb;

    //instruction valid check
    always @(*) begin
        if(instruction[1:0] == INSTRUCTION_VALID_VALUE)
            instruction_invalid_comb = 1'b0;
        else
            instruction_invalid_comb = 1'b1;
    end

    //r-type instruction check
    always @(*) begin
        case(instruction[6:2])
            5'b01011:
                is_r_instruction_comb = 1'b1;
            5'b01100:
                is_r_instruction_comb = 1'b1;
            5'b01110:
                is_r_instruction_comb = 1'b1;
            5'b10100:
                is_r_instruction_comb = 1'b1;
            default:
                is_r_instruction_comb = 1'b0;
        endcase
    end

    //i-type instruction check
    always @(*) begin
        case(instruction[6:2])
            5'b00000:
                is_i_instruction_comb = 1'b1;
            5'b00001:
                is_i_instruction_comb = 1'b1;
            5'b00100:
                is_i_instruction_comb = 1'b1;
            5'b00110:
                is_i_instruction_comb = 1'b1;
            5'b11001:
                is_i_instruction_comb = 1'b1;
            default:
                is_i_instruction_comb = 1'b0;
        endcase
    end

    //s-type instruction check
    always @(*) begin
        case(instruction[6:2])
            5'b01000:
                is_s_instruction_comb = 1'b1;
            5'b01001:
                is_s_instruction_comb = 1'b1;
            default:
                is_s_instruction_comb = 1'b0;
        endcase
    end

    //b-type intruction check
    always @(*) begin
        case(instruction[6:2])
            5'b11000:
                is_b_instruction_comb = 1'b1;
            default:
                is_b_instruction_comb = 1'b0;
        endcase
    end

    //u-type instruction check
    always @(*) begin
        case(instruction[6:2])
            5'b00101:
                is_u_instruction_comb = 1'b1;
            5'b01101:
                is_u_instruction_comb = 1'b1;
            default:
                is_u_instruction_comb = 1'b0;
        endcase
    end

    //j-tpye instruction check
    always @(*) begin
        case(instruction[6:2])
            5'b11011:
                is_j_instruction_comb = 1'b1;
            default:
                is_j_instruction_comb = 1'b0;
        endcase
    end

    //extract funct3
    always @(*) begin
        if(is_r_instruction_comb)
            funct3_comb = instruction[14:12];
        else if(is_i_instruction_comb)
            funct3_comb = instruction[14:12];
        else if(is_s_instruction_comb)
            funct3_comb = instruction[14:12];
        else if(is_b_instruction_comb)
            funct3_comb = instruction[14:12];
        else if(is_u_instruction_comb)
            funct3_comb = 3'h0;
        else if(is_j_instruction_comb)
            funct3_comb = 3'h0;
        else
            funct3_comb = 3'h0;
    end

    //extract funct7
    always @(*) begin
        if(is_r_instruction_comb)
            funct7_comb = instruction[31:25];
        else if(is_i_instruction_comb)
            funct7_comb = instruction[31:25];
        else if(is_s_instruction_comb)
            funct7_comb = 7'h0;
        else if(is_b_instruction_comb)
            funct7_comb = 7'h0;
        else if(is_u_instruction_comb)
            funct7_comb = 7'h0;
        else if(is_j_instruction_comb)
            funct7_comb = 7'h0;
        else
            funct7_comb = 7'h0;
    end

    //extract rs1
    always @(*) begin
        if(is_r_instruction_comb)
            rs1_comb = instruction[19:15];
        else if(is_i_instruction_comb)
            rs1_comb = instruction[19:15];
        else if(is_s_instruction_comb)
            rs1_comb = instruction[19:15];
        else if(is_b_instruction_comb)
            rs1_comb = instruction[19:15];
        else if(is_u_instruction_comb)
            rs1_comb = 5'h0;
        else if(is_j_instruction_comb)
            rs1_comb = 5'h0;
        else
            rs1_comb = 5'h0;
    end

    //extract rs2
    always @(*) begin
        if(is_r_instruction_comb)
            rs2_comb = instruction[24:20];
        else if(is_i_instruction_comb)
            rs2_comb = 5'h0;
        else if(is_s_instruction_comb)
            rs2_comb = instruction[24:20];
        else if(is_b_instruction_comb)
            rs2_comb = instruction[24:20];
        else if(is_u_instruction_comb)
            rs2_comb = 5'h0;
        else if(is_j_instruction_comb)
            rs2_comb = 5'h0;
        else
            rs2_comb = 5'h0;
    end

    //extract rd
    always @(*) begin
        if(is_r_instruction_comb)
            rd_comb = instruction[11:7];
        else if(is_i_instruction_comb)
            rd_comb = instruction[11:7];
        else if(is_s_instruction_comb)
            rd_comb = 5'h0;
        else if(is_b_instruction_comb)
            rd_comb = 5'h0;
        else if(is_u_instruction_comb)
            rd_comb = instruction[11:7];
        else if(is_j_instruction_comb)
            rd_comb = instruction[11:7];
        else
            rd_comb = 5'h0;
    end

    //extract opcode
    always @(*) begin
        if(is_r_instruction_comb)
            opcode_comb = instruction[6:0];
        else if(is_i_instruction_comb)
            opcode_comb = instruction[6:0];
        else if(is_s_instruction_comb)
            opcode_comb = instruction[6:0];
        else if(is_b_instruction_comb)
            opcode_comb = instruction[6:0];
        else if(is_u_instruction_comb)
            opcode_comb = instruction[6:0];
        else if(is_j_instruction_comb)
            opcode_comb = instruction[6:0];
        else
            opcode_comb = 7'h0;
    end

    //check imm valid
    always @(*) begin
        if(is_r_instruction_comb)
            imm_valid_comb = 1'b0;
        else if(is_i_instruction_comb)
            imm_valid_comb = 1'b1;
        else if(is_s_instruction_comb)
            imm_valid_comb = 1'b1;
        else if(is_b_instruction_comb)
            imm_valid_comb = 1'b1;
        else if(is_u_instruction_comb)
            imm_valid_comb = 1'b1;
        else if(is_j_instruction_comb)
            imm_valid_comb = 1'b1;
        else
            imm_valid_comb = 1'b0;
    end

    //set imm value
    always @(*) begin
        if(is_i_instruction_comb)
            imm_comb = {{21{instruction[31]}}, instruction[30:20]};
        else if(is_s_instruction_comb)
            imm_comb = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
        else if(is_b_instruction_comb)
            imm_comb = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        else if(is_u_instruction_comb)
            imm_comb = {instruction[31], instruction[30:20], instruction[19:12], {12{1'b0}}};
        else if(is_j_instruction_comb)
            imm_comb = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        else
            imm_comb = 32'h0;
    end

    assign instruction_invalid = instruction_invalid_comb;
    assign funct3 = funct3_comb;
    assign funct7 = funct7_comb;
    assign rs1 = rs1_comb;
    assign rs2 = rs2_comb;
    assign rd = rd_comb;
    assign opcode = opcode_comb;
    assign imm_valid = imm_valid_comb;
    assign imm = imm_comb;

endmodule