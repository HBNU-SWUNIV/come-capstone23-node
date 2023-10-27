module register_file
(
    input clk,
    input reset_n,
    input wr_en,
    input [4:0] wr_index,
    input [31:0] wr_data,
    input rd_en1,
    input [4:0] rd_index1,
    input rd_en2,
    input [4:0] rd_index2,
    output [31:0] rd_data1,
    output [31:0] rd_data2
);

    reg [31:0] mem [31:0];
    reg [31:0] rd_data1_reg;
    reg [31:0] rd_data2_reg;
    reg [4:0] rd_addr1_reg;
    reg [4:0] rd_addr2_reg;

    always @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            rd_data1_reg <= 32'h0;
            rd_data2_reg <= 32'h0;
            mem[0] <= 32'h0;
            rd_addr1_reg <= 5'h0;
            rd_addr2_reg <= 5'h0;
        end else begin
            if(wr_en) begin
                if(wr_index != 5'h0)
                    mem[wr_index] <= wr_data;
            end
                
            if(rd_en1) begin
                if(rd_index1 == wr_index)
                    rd_data1_reg <= wr_data;
                else
                    rd_data1_reg <= mem[rd_index1];
                rd_addr1_reg <= rd_index1;
            end
            if(rd_en2) begin
                if(rd_index2 == wr_index)
                    rd_data2_reg <= wr_data;
                else
                    rd_data2_reg <= mem[rd_index2];
                rd_addr2_reg <= rd_index2;
            end
        end
        
    end

    assign rd_data1 = wr_index == rd_addr1_reg ? wr_data : rd_data1_reg;
    assign rd_data2 = wr_index == rd_addr2_reg ? wr_data : rd_data2_reg;

endmodule
