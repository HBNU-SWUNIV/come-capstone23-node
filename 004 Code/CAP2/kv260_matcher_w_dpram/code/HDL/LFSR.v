`timescale 1ns/100ps
module LFSR #
(
    parameter integer BIT_WIDTH = 16
)
(
    input wire i_fclk,
    input wire i_enable,

    input wire i_seed_data_valied,
    input wire [BIT_WIDTH-1:0] i_seed_data,

    output wire [BIT_WIDTH-1:0] o_lfsr_data,
    output wire o_lfsr_loop
);

    reg [BIT_WIDTH:1] lfsr_reg;
    reg xnor_reg;

    always @(posedge i_fclk) begin
        if(i_enable) begin
            if(i_seed_data_valied)
                lfsr_reg <= i_seed_data;
            else
                lfsr_reg <= {lfsr_reg[1+:BIT_WIDTH-1], xnor_reg};
        end
    end

    // https://docs.xilinx.com/v/u/en-US/xapp052
    always @(*) begin
        case(BIT_WIDTH)
            3:
                xnor_reg = lfsr_reg[3] ^~ lfsr_reg[2];
            4:
                xnor_reg = lfsr_reg[4] ^~ lfsr_reg[3];
            5:
                xnor_reg = lfsr_reg[5] ^~ lfsr_reg[3];
            6:
                xnor_reg = lfsr_reg[6] ^~ lfsr_reg[5];
            7:
                xnor_reg = lfsr_reg[7] ^~ lfsr_reg[6];
            8:
                xnor_reg = lfsr_reg[8] ^~ lfsr_reg[6] ^~ lfsr_reg[5] ^~ lfsr_reg[4];
            9:
                xnor_reg = lfsr_reg[9] ^~ lfsr_reg[5];
            10:
                xnor_reg = lfsr_reg[10] ^~ lfsr_reg[7];
            11:
                xnor_reg = lfsr_reg[11] ^~ lfsr_reg[9];
            12:
                xnor_reg = lfsr_reg[12] ^~ lfsr_reg[6] ^~ lfsr_reg[4] ^~ lfsr_reg[1];
            13:
                xnor_reg = lfsr_reg[13] ^~ lfsr_reg[4] ^~ lfsr_reg[3] ^~ lfsr_reg[1];
            14:
                xnor_reg = lfsr_reg[14] ^~ lfsr_reg[5] ^~ lfsr_reg[3] ^~ lfsr_reg[1];
            15:
                xnor_reg = lfsr_reg[15] ^~ lfsr_reg[14];
            16:
                xnor_reg = lfsr_reg[16] ^~ lfsr_reg[15] ^~ lfsr_reg[13] ^~ lfsr_reg[4];
            17:
                xnor_reg = lfsr_reg[17] ^~ lfsr_reg[14];
            18:
                xnor_reg = lfsr_reg[18] ^~ lfsr_reg[11];
            19:
                xnor_reg = lfsr_reg[19] ^~ lfsr_reg[6] ^~ lfsr_reg[2] ^~ lfsr_reg[1];
            20:
                xnor_reg = lfsr_reg[20] ^~ lfsr_reg[17];
            21:
                xnor_reg = lfsr_reg[21] ^~ lfsr_reg[19];
            22:
                xnor_reg = lfsr_reg[22] ^~ lfsr_reg[21];
            23:
                xnor_reg = lfsr_reg[23] ^~ lfsr_reg[18];
            24:
                xnor_reg = lfsr_reg[24] ^~ lfsr_reg[23] ^~ lfsr_reg[22] ^~ lfsr_reg[17];
            25:
                xnor_reg = lfsr_reg[25] ^~ lfsr_reg[22];
            26:
                xnor_reg = lfsr_reg[26] ^~ lfsr_reg[6] ^~ lfsr_reg[2] ^~ lfsr_reg[1];
            27:
                xnor_reg = lfsr_reg[27] ^~ lfsr_reg[5] ^~ lfsr_reg[2] ^~ lfsr_reg[1];
            28:
                xnor_reg = lfsr_reg[28] ^~ lfsr_reg[25];
            29:
                xnor_reg = lfsr_reg[29] ^~ lfsr_reg[27];
            30:
                xnor_reg = lfsr_reg[30] ^~ lfsr_reg[6] ^~ lfsr_reg[4] ^~ lfsr_reg[1];
            31:
                xnor_reg = lfsr_reg[31] ^~ lfsr_reg[28];
            32:
                xnor_reg = lfsr_reg[32] ^~ lfsr_reg[22] ^~ lfsr_reg[2] ^~ lfsr_reg[1];
            33:
                xnor_reg = lfsr_reg[33] ^~ lfsr_reg[20];
            34:
                xnor_reg = lfsr_reg[34] ^~ lfsr_reg[27] ^~ lfsr_reg[2] ^~ lfsr_reg[1];
            35:
                xnor_reg = lfsr_reg[35] ^~ lfsr_reg[33];
            36:
                xnor_reg = lfsr_reg[36] ^~ lfsr_reg[25];
            37:
                xnor_reg = lfsr_reg[37] ^~ lfsr_reg[5] ^~ lfsr_reg[4] ^~ lfsr_reg[3] ^~ lfsr_reg[2] ^~ lfsr_reg[1];
            38:
                xnor_reg = lfsr_reg[38] ^~ lfsr_reg[6] ^~ lfsr_reg[5] ^~ lfsr_reg[1];
            39:
                xnor_reg = lfsr_reg[39] ^~ lfsr_reg[35];
            40:
                xnor_reg = lfsr_reg[40] ^~ lfsr_reg[38] ^~ lfsr_reg[21] ^~ lfsr_reg[19];
            41:
                xnor_reg = lfsr_reg[41] ^~ lfsr_reg[38];
            42:
                xnor_reg = lfsr_reg[42] ^~ lfsr_reg[41] ^~ lfsr_reg[20] ^~ lfsr_reg[19];
            43:
                xnor_reg = lfsr_reg[43] ^~ lfsr_reg[42] ^~ lfsr_reg[38] ^~ lfsr_reg[37];
            44:
                xnor_reg = lfsr_reg[44] ^~ lfsr_reg[43] ^~ lfsr_reg[18] ^~ lfsr_reg[17];
            45:
                xnor_reg = lfsr_reg[45] ^~ lfsr_reg[44] ^~ lfsr_reg[42] ^~ lfsr_reg[41];
            46:
                xnor_reg = lfsr_reg[46] ^~ lfsr_reg[45] ^~ lfsr_reg[26] ^~ lfsr_reg[25];
            47:
                xnor_reg = lfsr_reg[47] ^~ lfsr_reg[42];
            48:
                xnor_reg = lfsr_reg[48] ^~ lfsr_reg[47] ^~ lfsr_reg[21] ^~ lfsr_reg[20];
            49:
                xnor_reg = lfsr_reg[49] ^~ lfsr_reg[40];
            50:
                xnor_reg = lfsr_reg[50] ^~ lfsr_reg[49] ^~ lfsr_reg[24] ^~ lfsr_reg[23];
            51:
                xnor_reg = lfsr_reg[51] ^~ lfsr_reg[50] ^~ lfsr_reg[36] ^~ lfsr_reg[35];
            52:
                xnor_reg = lfsr_reg[52] ^~ lfsr_reg[49];
            53:
                xnor_reg = lfsr_reg[53] ^~ lfsr_reg[52] ^~ lfsr_reg[38] ^~ lfsr_reg[37];
            54:
                xnor_reg = lfsr_reg[54] ^~ lfsr_reg[53] ^~ lfsr_reg[18] ^~ lfsr_reg[17];
            55:
                xnor_reg = lfsr_reg[55] ^~ lfsr_reg[31];
            56:
                xnor_reg = lfsr_reg[56] ^~ lfsr_reg[55] ^~ lfsr_reg[35] ^~ lfsr_reg[34];
            57:
                xnor_reg = lfsr_reg[57] ^~ lfsr_reg[50];
            58:
                xnor_reg = lfsr_reg[58] ^~ lfsr_reg[39];
            59:
                xnor_reg = lfsr_reg[59] ^~ lfsr_reg[58] ^~ lfsr_reg[38] ^~ lfsr_reg[37];
            60:
                xnor_reg = lfsr_reg[60] ^~ lfsr_reg[59];
            61:
                xnor_reg = lfsr_reg[61] ^~ lfsr_reg[60] ^~ lfsr_reg[46] ^~ lfsr_reg[45];
            62:
                xnor_reg = lfsr_reg[62] ^~ lfsr_reg[61] ^~ lfsr_reg[6] ^~ lfsr_reg[5];
            63:
                xnor_reg = lfsr_reg[63] ^~ lfsr_reg[62];
            64:
                xnor_reg = lfsr_reg[64] ^~ lfsr_reg[63] ^~ lfsr_reg[61] ^~ lfsr_reg[60];
            65:
                xnor_reg = lfsr_reg[65] ^~ lfsr_reg[47];
            66:
                xnor_reg = lfsr_reg[66] ^~ lfsr_reg[65] ^~ lfsr_reg[57] ^~ lfsr_reg[56];
            67:
                xnor_reg = lfsr_reg[67] ^~ lfsr_reg[66] ^~ lfsr_reg[58] ^~ lfsr_reg[57];
            68:
                xnor_reg = lfsr_reg[68] ^~ lfsr_reg[59];
            69:
                xnor_reg = lfsr_reg[69] ^~ lfsr_reg[67] ^~ lfsr_reg[42] ^~ lfsr_reg[40];
            70:
                xnor_reg = lfsr_reg[70] ^~ lfsr_reg[69] ^~ lfsr_reg[55] ^~ lfsr_reg[54];
            71:
                xnor_reg = lfsr_reg[71] ^~ lfsr_reg[65];
            72:
                xnor_reg = lfsr_reg[72] ^~ lfsr_reg[66] ^~ lfsr_reg[25] ^~ lfsr_reg[19];
            73:
                xnor_reg = lfsr_reg[73] ^~ lfsr_reg[48];
            74:
                xnor_reg = lfsr_reg[74] ^~ lfsr_reg[73] ^~ lfsr_reg[59] ^~ lfsr_reg[58];
            75:
                xnor_reg = lfsr_reg[75] ^~ lfsr_reg[74] ^~ lfsr_reg[65] ^~ lfsr_reg[64];
            76:
                xnor_reg = lfsr_reg[76] ^~ lfsr_reg[75] ^~ lfsr_reg[41] ^~ lfsr_reg[40];
            77:
                xnor_reg = lfsr_reg[77] ^~ lfsr_reg[76] ^~ lfsr_reg[47] ^~ lfsr_reg[46];
            78:
                xnor_reg = lfsr_reg[78] ^~ lfsr_reg[77] ^~ lfsr_reg[59] ^~ lfsr_reg[58];
            79:
                xnor_reg = lfsr_reg[79] ^~ lfsr_reg[70];
            80:
                xnor_reg = lfsr_reg[80] ^~ lfsr_reg[79] ^~ lfsr_reg[43] ^~ lfsr_reg[42];
            81:
                xnor_reg = lfsr_reg[81] ^~ lfsr_reg[77];
            82:
                xnor_reg = lfsr_reg[82] ^~ lfsr_reg[79] ^~ lfsr_reg[47] ^~ lfsr_reg[44];
            83:
                xnor_reg = lfsr_reg[83] ^~ lfsr_reg[82] ^~ lfsr_reg[38] ^~ lfsr_reg[37];
            84:
                xnor_reg = lfsr_reg[84] ^~ lfsr_reg[71];
            85:
                xnor_reg = lfsr_reg[85] ^~ lfsr_reg[84] ^~ lfsr_reg[58] ^~ lfsr_reg[57];
            86:
                xnor_reg = lfsr_reg[86] ^~ lfsr_reg[85] ^~ lfsr_reg[74] ^~ lfsr_reg[73];
            87:
                xnor_reg = lfsr_reg[87] ^~ lfsr_reg[74];
            88:
                xnor_reg = lfsr_reg[88] ^~ lfsr_reg[87] ^~ lfsr_reg[17] ^~ lfsr_reg[16];
            89:
                xnor_reg = lfsr_reg[89] ^~ lfsr_reg[51];
            90:
                xnor_reg = lfsr_reg[90] ^~ lfsr_reg[89] ^~ lfsr_reg[72] ^~ lfsr_reg[71];
            91:
                xnor_reg = lfsr_reg[91] ^~ lfsr_reg[90] ^~ lfsr_reg[8] ^~ lfsr_reg[7];
            92:
                xnor_reg = lfsr_reg[92] ^~ lfsr_reg[91] ^~ lfsr_reg[80] ^~ lfsr_reg[79];
            93:
                xnor_reg = lfsr_reg[93] ^~ lfsr_reg[91];
            94:
                xnor_reg = lfsr_reg[94] ^~ lfsr_reg[73];
            95:
                xnor_reg = lfsr_reg[95] ^~ lfsr_reg[84];
            96:
                xnor_reg = lfsr_reg[96] ^~ lfsr_reg[94] ^~ lfsr_reg[49] ^~ lfsr_reg[47];
            97:
                xnor_reg = lfsr_reg[97] ^~ lfsr_reg[91];
            98:
                xnor_reg = lfsr_reg[98] ^~ lfsr_reg[87];
            99:
                xnor_reg = lfsr_reg[99] ^~ lfsr_reg[97] ^~ lfsr_reg[54] ^~ lfsr_reg[52];
            100:
                xnor_reg = lfsr_reg[100] ^~ lfsr_reg[63];
            101:
                xnor_reg = lfsr_reg[101] ^~ lfsr_reg[100] ^~ lfsr_reg[95] ^~ lfsr_reg[94];
            102:
                xnor_reg = lfsr_reg[102] ^~ lfsr_reg[101] ^~ lfsr_reg[36] ^~ lfsr_reg[35];
            103:
                xnor_reg = lfsr_reg[103] ^~ lfsr_reg[94];
            104:
                xnor_reg = lfsr_reg[104] ^~ lfsr_reg[103] ^~ lfsr_reg[94] ^~ lfsr_reg[93];
            105:
                xnor_reg = lfsr_reg[105] ^~ lfsr_reg[89];
            106:
                xnor_reg = lfsr_reg[106] ^~ lfsr_reg[91];
            107:
                xnor_reg = lfsr_reg[107] ^~ lfsr_reg[105] ^~ lfsr_reg[44] ^~ lfsr_reg[42];
            108:
                xnor_reg = lfsr_reg[108] ^~ lfsr_reg[77];
            109:
                xnor_reg = lfsr_reg[109] ^~ lfsr_reg[108] ^~ lfsr_reg[103] ^~ lfsr_reg[102];
            110:
                xnor_reg = lfsr_reg[110] ^~ lfsr_reg[109] ^~ lfsr_reg[98] ^~ lfsr_reg[97];
            111:
                xnor_reg = lfsr_reg[111] ^~ lfsr_reg[101];
            112:
                xnor_reg = lfsr_reg[112] ^~ lfsr_reg[110] ^~ lfsr_reg[69] ^~ lfsr_reg[67];
            113:
                xnor_reg = lfsr_reg[113] ^~ lfsr_reg[104];
            114:
                xnor_reg = lfsr_reg[114] ^~ lfsr_reg[113] ^~ lfsr_reg[33] ^~ lfsr_reg[32];
            115:
                xnor_reg = lfsr_reg[115] ^~ lfsr_reg[114] ^~ lfsr_reg[101] ^~ lfsr_reg[100];
            116:
                xnor_reg = lfsr_reg[116] ^~ lfsr_reg[115] ^~ lfsr_reg[46] ^~ lfsr_reg[45];
            117:
                xnor_reg = lfsr_reg[117] ^~ lfsr_reg[115] ^~ lfsr_reg[99] ^~ lfsr_reg[97];
            118:
                xnor_reg = lfsr_reg[118] ^~ lfsr_reg[85];
            119:
                xnor_reg = lfsr_reg[119] ^~ lfsr_reg[111];
            120:
                xnor_reg = lfsr_reg[120] ^~ lfsr_reg[113] ^~ lfsr_reg[9] ^~ lfsr_reg[2];
            121:
                xnor_reg = lfsr_reg[121] ^~ lfsr_reg[103];
            122:
                xnor_reg = lfsr_reg[122] ^~ lfsr_reg[121] ^~ lfsr_reg[63] ^~ lfsr_reg[62];
            123:
                xnor_reg = lfsr_reg[123] ^~ lfsr_reg[121];
            124:
                xnor_reg = lfsr_reg[124] ^~ lfsr_reg[87];
            125:
                xnor_reg = lfsr_reg[125] ^~ lfsr_reg[124] ^~ lfsr_reg[18] ^~ lfsr_reg[17];
            126:
                xnor_reg = lfsr_reg[126] ^~ lfsr_reg[125] ^~ lfsr_reg[90] ^~ lfsr_reg[89];
            127:
                xnor_reg = lfsr_reg[127] ^~ lfsr_reg[126];
            128:
                xnor_reg = lfsr_reg[128] ^~ lfsr_reg[126] ^~ lfsr_reg[101] ^~ lfsr_reg[99];
            129:
                xnor_reg = lfsr_reg[129] ^~ lfsr_reg[124];
            130:
                xnor_reg = lfsr_reg[130] ^~ lfsr_reg[127];
            131:
                xnor_reg = lfsr_reg[131] ^~ lfsr_reg[130] ^~ lfsr_reg[84] ^~ lfsr_reg[83];
            132:
                xnor_reg = lfsr_reg[132] ^~ lfsr_reg[103];
            133:
                xnor_reg = lfsr_reg[133] ^~ lfsr_reg[132] ^~ lfsr_reg[82] ^~ lfsr_reg[81];
            134:
                xnor_reg = lfsr_reg[134] ^~ lfsr_reg[77];
            135:
                xnor_reg = lfsr_reg[135] ^~ lfsr_reg[124];
            136:
                xnor_reg = lfsr_reg[136] ^~ lfsr_reg[135] ^~ lfsr_reg[11] ^~ lfsr_reg[10];
            137:
                xnor_reg = lfsr_reg[137] ^~ lfsr_reg[116];
            138:
                xnor_reg = lfsr_reg[138] ^~ lfsr_reg[137] ^~ lfsr_reg[131] ^~ lfsr_reg[130];
            139:
                xnor_reg = lfsr_reg[139] ^~ lfsr_reg[136] ^~ lfsr_reg[134] ^~ lfsr_reg[131];
            140:
                xnor_reg = lfsr_reg[140] ^~ lfsr_reg[111];
            141:
                xnor_reg = lfsr_reg[141] ^~ lfsr_reg[140] ^~ lfsr_reg[110] ^~ lfsr_reg[109];
            142:
                xnor_reg = lfsr_reg[142] ^~ lfsr_reg[121];
            143:
                xnor_reg = lfsr_reg[143] ^~ lfsr_reg[142] ^~ lfsr_reg[123] ^~ lfsr_reg[122];
            144:
                xnor_reg = lfsr_reg[144] ^~ lfsr_reg[143] ^~ lfsr_reg[75] ^~ lfsr_reg[74];
            145:
                xnor_reg = lfsr_reg[145] ^~ lfsr_reg[93];
            146:
                xnor_reg = lfsr_reg[146] ^~ lfsr_reg[145] ^~ lfsr_reg[87] ^~ lfsr_reg[86];
            147:
                xnor_reg = lfsr_reg[147] ^~ lfsr_reg[146] ^~ lfsr_reg[110] ^~ lfsr_reg[109];
            148:
                xnor_reg = lfsr_reg[148] ^~ lfsr_reg[121];
            149:
                xnor_reg = lfsr_reg[149] ^~ lfsr_reg[148] ^~ lfsr_reg[40] ^~ lfsr_reg[39];
            150:
                xnor_reg = lfsr_reg[150] ^~ lfsr_reg[97];
            151:
                xnor_reg = lfsr_reg[151] ^~ lfsr_reg[148];
            152:
                xnor_reg = lfsr_reg[152] ^~ lfsr_reg[151] ^~ lfsr_reg[87] ^~ lfsr_reg[86];
            153:
                xnor_reg = lfsr_reg[153] ^~ lfsr_reg[152];
            154:
                xnor_reg = lfsr_reg[154] ^~ lfsr_reg[152] ^~ lfsr_reg[27] ^~ lfsr_reg[25];
            155:
                xnor_reg = lfsr_reg[155] ^~ lfsr_reg[154] ^~ lfsr_reg[124] ^~ lfsr_reg[123];
            156:
                xnor_reg = lfsr_reg[156] ^~ lfsr_reg[155] ^~ lfsr_reg[41] ^~ lfsr_reg[40];
            157:
                xnor_reg = lfsr_reg[157] ^~ lfsr_reg[156] ^~ lfsr_reg[131] ^~ lfsr_reg[130];
            158:
                xnor_reg = lfsr_reg[158] ^~ lfsr_reg[157] ^~ lfsr_reg[132] ^~ lfsr_reg[131];
            159:
                xnor_reg = lfsr_reg[159] ^~ lfsr_reg[128];
            160:
                xnor_reg = lfsr_reg[160] ^~ lfsr_reg[159] ^~ lfsr_reg[142] ^~ lfsr_reg[141];
            161:
                xnor_reg = lfsr_reg[161] ^~ lfsr_reg[143];
            162:
                xnor_reg = lfsr_reg[162] ^~ lfsr_reg[161] ^~ lfsr_reg[75] ^~ lfsr_reg[74];
            163:
                xnor_reg = lfsr_reg[163] ^~ lfsr_reg[162] ^~ lfsr_reg[104] ^~ lfsr_reg[103];
            164:
                xnor_reg = lfsr_reg[164] ^~ lfsr_reg[163] ^~ lfsr_reg[151] ^~ lfsr_reg[150];
            165:
                xnor_reg = lfsr_reg[165] ^~ lfsr_reg[164] ^~ lfsr_reg[135] ^~ lfsr_reg[134];
            166:
                xnor_reg = lfsr_reg[166] ^~ lfsr_reg[165] ^~ lfsr_reg[128] ^~ lfsr_reg[127];
            167:
                xnor_reg = lfsr_reg[167] ^~ lfsr_reg[161];
            168:
                xnor_reg = lfsr_reg[168] ^~ lfsr_reg[166] ^~ lfsr_reg[153] ^~ lfsr_reg[151];
        endcase
    end

    assign o_lfsr_data = lfsr_reg[1+:BIT_WIDTH];

    assign o_lfsr_loop = (lfsr_reg[1+:BIT_WIDTH] == i_seed_data) ? 1'b1 : 1'b0;

endmodule
