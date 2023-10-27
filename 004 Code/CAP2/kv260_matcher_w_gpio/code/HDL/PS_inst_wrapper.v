//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
//Date        : Sat Oct 21 20:21:30 2023
//Host        : DESKTOP-R1J4DM4 running 64-bit major release  (build 9200)
//Command     : generate_target PS_inst_wrapper.bd
//Design      : PS_inst_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module PS_inst_wrapper
   (GPIO_0_tri_i,
    GPIO_1_tri_i,
    GPIO_2_tri_i,
    GPIO_3_tri_o,
    pl_clk0,
    pl_resetn0);
  input [31:0]GPIO_0_tri_i;
  input [31:0]GPIO_1_tri_i;
  input [31:0]GPIO_2_tri_i;
  output [7:0]GPIO_3_tri_o;
  output pl_clk0;
  output pl_resetn0;

  wire [31:0]GPIO_0_tri_i;
  wire [31:0]GPIO_1_tri_i;
  wire [31:0]GPIO_2_tri_i;
  wire [7:0]GPIO_3_tri_o;
  wire pl_clk0;
  wire pl_resetn0;

  PS_inst PS_inst_i
       (.GPIO_0_tri_i(GPIO_0_tri_i),
        .GPIO_1_tri_i(GPIO_1_tri_i),
        .GPIO_2_tri_i(GPIO_2_tri_i),
        .GPIO_3_tri_o(GPIO_3_tri_o),
        .pl_clk0(pl_clk0),
        .pl_resetn0(pl_resetn0));
endmodule
