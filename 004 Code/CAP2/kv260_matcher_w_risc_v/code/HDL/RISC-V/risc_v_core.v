module risc_v_core
(
    input clk,
    input reset_n,

    output wire instruction_mem_ce,
    output wire [3:0] instruction_mem_we,
    output wire [9:0] instruction_mem_addr,
    output wire [31:0] instruction_mem_d,
    input wire [31:0] instruction_mem_q,

    output wire data_mem_ce,
    output wire [3:0] data_mem_we,
    output wire [9:0] data_mem_addr,
    output wire [31:0] data_mem_d,
    input wire [31:0] data_mem_q,

    output wire o_jb_enable
);

    wire jb_enable;
    wire [31:0] jb_value;
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [4:0] rd;
    wire [31:0] imm;

    wire [4:0] register_read_addr1;
    wire [31:0] register_read_data1;
    wire [4:0] register_read_addr2;
    wire [31:0] register_read_data2;
    
    wire register_write_req;
    wire [31:0] register_write_data;
    wire [4:0] register_write_addr;
    
    wire alu_write_req;
    wire [31:0] alu_write_data;
    wire [4:0] alu_write_addr;

    wire jump_branch_write_req;
    wire [31:0] jump_branch_write_data;
    wire [4:0] jump_branch_write_addr;

    wire data_memory_write_req;
    wire [31:0] data_memory_write_data;
    wire [4:0] data_memory_write_addr;

    wire [5:0] operation_con;

    wire data_memory_ce;
    wire [3:0] data_memory_we;
    wire [29:0] data_memory_addr;
    wire [31:0] data_memory_d;
    wire [31:0] data_memory_q;

    program_counter pc1
    (
        .clk(clk),
        .reset_n(reset_n),
        .jb_enable(jb_enable),
        .jb_value(jb_value),
        .pc(pc)
    );

    decode_logic dl1
    (
        .clk(clk),
        .reset_n(reset_n),
        .instruction(instruction),
        .jump_branch_enable(jb_enable),
        .rs1(register_read_addr1),
        .rs2(register_read_addr2),
        .rd(rd),
        .imm(imm),
        .operation_con(operation_con)
    );

    register_file rf1
    (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(register_write_req),
        .wr_index(register_write_addr),
        .wr_data(register_write_data),
        .rd_en1(1'b1),
        .rd_index1(register_read_addr1),
        .rd_en2(1'b1),
        .rd_index2(register_read_addr2),
        .rd_data1(register_read_data1),
        .rd_data2(register_read_data2)
    );

    alu alu1
    (
        .clk(clk),
        .reset_n(reset_n),
        .jump_branch_enable(jb_enable),
        .pc(pc),
        .src1_value(register_read_data1),
        .src2_value(register_read_data2),
        .imm(imm),
        .rd(rd),
        .operation_con(operation_con),
        .write_req(alu_write_req),
        .write_addr(alu_write_addr),
        .write_data(alu_write_data)
    );

    jump_branch jb1
    (
        .clk(clk),
        .reset_n(reset_n),
        .pc(pc),
        .src1_value(register_read_data1),
        .src2_value(register_read_data2),
        .imm(imm),
        .rd(rd),
        .operation_con(operation_con),
        .jb_target_pc(jb_value),
        .jb_enable(jb_enable),
        .write_req(jump_branch_write_req),
        .write_addr(jump_branch_write_addr),
        .write_data(jump_branch_write_data)
    );

    data_memory_ctrl dm_ctrl1
    (
        .clk(clk),
        .reset_n(reset_n),
        .jump_branch_enable(jb_enable),
        .src1_value(register_read_data1),
        .src2_value(register_read_data2),
        .imm(imm),
        .rd(rd),
        .operation_con(operation_con),

        .write_req(data_memory_write_req),
        .write_addr(data_memory_write_addr),
        .write_data(data_memory_write_data),

        .mem_addr(data_memory_addr),
        .mem_we(data_memory_we),
        .mem_ce(data_memory_ce),
        .mem_d(data_memory_d),
        .mem_q(data_memory_q)
    );

    //for debug
    `include "instruction_param.vh"
    reg [5:0] priv_operation;
    always @(posedge clk) begin
        priv_operation <= 'h0;
        if(reset_n) begin
        end else begin
            //if(priv_operation != operation_con) begin
                case(operation_con)
                    NONE: begin
                        $display("NONE");
                    end
                    ADDI: begin
                        $display("ADDI");
                    end
                    SLTI: begin
                        $display("SLTI");
                    end
                    SLTIU: begin
                        $display("SLTIU");
                    end
                    ANDI: begin
                        $display("ANDI");
                    end
                    ORI: begin
                        $display("ORI");
                    end
                    XORI: begin
                        $display("XORI");
                    end
                    SLLI: begin
                        $display("SLLI");
                    end
                    SRLI: begin
                        $display("SRLI");
                    end
                    SRAI: begin
                        $display("SRAI");
                    end
                    LUI: begin
                        $display("LUI");
                    end
                    AUIPC: begin
                        $display("AUIPC");
                    end
                    ADD: begin
                        $display("ADD");
                    end
                    SLT: begin
                        $display("SLT");
                    end
                    SLTU: begin
                        $display("SLTU");
                    end
                    AND: begin
                        $display("AND");
                    end
                    OR: begin
                        $display("OR");
                    end
                    XOR: begin
                        $display("XOR");
                    end
                    SLL: begin
                        $display("SLL");
                    end
                    SRL: begin
                        $display("SRL");
                    end
                    SUB: begin
                        $display("SUB");
                    end
                    SRA: begin
                        $display("SRA");
                    end
                    JAL: begin
                        $display("JAL");
                    end
                    JALR: begin
                        $display("JALR");
                    end
                    BEQ: begin
                        $display("BEQ");
                    end
                    BNE: begin
                        $display("BNE");
                    end
                    BLT: begin
                        $display("BLT");
                    end
                    BLTU: begin
                        $display("BLTU");
                    end
                    BGE: begin
                        $display("BGE");
                    end
                    BGEU: begin
                        $display("BGEU");
                    end
                    LB: begin
                        $display("LB");
                    end
                    LH: begin
                        $display("LH");
                    end
                    LW: begin
                        $display("LW");
                    end
                    LBU: begin
                        $display("LBU");
                    end
                    LHU: begin
                        $display("LHU");
                    end
                    SB: begin
                        $display("SB");
                    end
                    SH: begin
                        $display("SH");
                    end
                    SW: begin
                        $display("SW");
                    end
                    MISC_MEM: begin
                        $display("MISC_MEM");
                    end
                    ECALL: begin
                        $display("ECALL");
                    end
                    EBREAK: begin
                        $display("EBREAK");
                    end
                endcase
                priv_operation = operation_con;
            //end
        end
        
    end

    assign instruction_mem_ce = 1'b1;
    assign instruction_mem_we = {4{1'b0}};
    assign instruction_mem_addr = pc[0+:10];
    assign instruction_mem_d = {32{1'b0}};
    assign instruction = instruction_mem_q;

    assign data_mem_ce = data_memory_ce;
    assign data_mem_we = data_memory_we;
    assign data_mem_addr = data_memory_addr[0+:10];
    assign data_mem_d = data_memory_d;
    assign data_memory_q = data_mem_q;

    assign register_write_req = alu_write_req | jump_branch_write_req | data_memory_write_req;
    assign register_write_addr = alu_write_req ? alu_write_addr : (jump_branch_write_req ? jump_branch_write_addr : (data_memory_write_req ? data_memory_write_addr : 5'h0));
    assign register_write_data = alu_write_req ? alu_write_data : (jump_branch_write_req ? jump_branch_write_data : (data_memory_write_req ? data_memory_write_data : 32'h0));

    assign o_jb_enable = jb_enable;

endmodule
