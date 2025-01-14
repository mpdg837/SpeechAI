module spect_mel_table(
	input clk,
	input rst,
	
	input[7:0] addr,
	output reg[7:0] out
);

reg[7:0] memory[255:0];

initial begin
	memory[0] = 0;
	memory[1] = 4;
	memory[2] = 8;
	memory[3] = 12;
	memory[4] = 16;
	memory[5] = 20;
	memory[6] = 23;
	memory[7] = 27;
	memory[8] = 30;
	memory[9] = 33;
	memory[10] = 37;
	memory[11] = 40;
	memory[12] = 43;
	memory[13] = 46;
	memory[14] = 48;
	memory[15] = 51;
	memory[16] = 54;
	memory[17] = 56;
	memory[18] = 59;
	memory[19] = 61;
	memory[20] = 64;
	memory[21] = 66;
	memory[22] = 68;
	memory[23] = 71;
	memory[24] = 73;
	memory[25] = 75;
	memory[26] = 77;
	memory[27] = 79;
	memory[28] = 81;
	memory[29] = 83;
	memory[30] = 85;
	memory[31] = 87;
	memory[32] = 89;
	memory[33] = 91;
	memory[34] = 92;
	memory[35] = 94;
	memory[36] = 96;
	memory[37] = 98;
	memory[38] = 99;
	memory[39] = 101;
	memory[40] = 103;
	memory[41] = 104;
	memory[42] = 106;
	memory[43] = 107;
	memory[44] = 109;
	memory[45] = 110;
	memory[46] = 112;
	memory[47] = 113;
	memory[48] = 115;
	memory[49] = 116;
	memory[50] = 118;
	memory[51] = 119;
	memory[52] = 120;
	memory[53] = 122;
	memory[54] = 123;
	memory[55] = 124;
	memory[56] = 126;
	memory[57] = 127;
	memory[58] = 128;
	memory[59] = 129;
	memory[60] = 131;
	memory[61] = 132;
	memory[62] = 133;
	memory[63] = 134;
	memory[64] = 136;
	memory[65] = 137;
	memory[66] = 138;
	memory[67] = 139;
	memory[68] = 140;
	memory[69] = 141;
	memory[70] = 142;
	memory[71] = 143;
	memory[72] = 144;
	memory[73] = 146;
	memory[74] = 147;
	memory[75] = 148;
	memory[76] = 149;
	memory[77] = 150;
	memory[78] = 151;
	memory[79] = 152;
	memory[80] = 153;
	memory[81] = 154;
	memory[82] = 155;
	memory[83] = 156;
	memory[84] = 157;
	memory[85] = 157;
	memory[86] = 158;
	memory[87] = 159;
	memory[88] = 160;
	memory[89] = 161;
	memory[90] = 162;
	memory[91] = 163;
	memory[92] = 164;
	memory[93] = 165;
	memory[94] = 166;
	memory[95] = 166;
	memory[96] = 167;
	memory[97] = 168;
	memory[98] = 169;
	memory[99] = 170;
	memory[100] = 171;
	memory[101] = 172;
	memory[102] = 172;
	memory[103] = 173;
	memory[104] = 174;
	memory[105] = 175;
	memory[106] = 176;
	memory[107] = 176;
	memory[108] = 177;
	memory[109] = 178;
	memory[110] = 179;
	memory[111] = 179;
	memory[112] = 180;
	memory[113] = 181;
	memory[114] = 182;
	memory[115] = 182;
	memory[116] = 183;
	memory[117] = 184;
	memory[118] = 185;
	memory[119] = 185;
	memory[120] = 186;
	memory[121] = 187;
	memory[122] = 187;
	memory[123] = 188;
	memory[124] = 189;
	memory[125] = 189;
	memory[126] = 190;
	memory[127] = 191;
	memory[128] = 192;
	memory[129] = 192;
	memory[130] = 193;
	memory[131] = 194;
	memory[132] = 194;
	memory[133] = 195;
	memory[134] = 195;
	memory[135] = 196;
	memory[136] = 197;
	memory[137] = 197;
	memory[138] = 198;
	memory[139] = 199;
	memory[140] = 199;
	memory[141] = 200;
	memory[142] = 201;
	memory[143] = 201;
	memory[144] = 202;
	memory[145] = 202;
	memory[146] = 203;
	memory[147] = 204;
	memory[148] = 204;
	memory[149] = 205;
	memory[150] = 205;
	memory[151] = 206;
	memory[152] = 206;
	memory[153] = 207;
	memory[154] = 208;
	memory[155] = 208;
	memory[156] = 209;
	memory[157] = 209;
	memory[158] = 210;
	memory[159] = 210;
	memory[160] = 211;
	memory[161] = 212;
	memory[162] = 212;
	memory[163] = 213;
	memory[164] = 213;
	memory[165] = 214;
	memory[166] = 214;
	memory[167] = 215;
	memory[168] = 215;
	memory[169] = 216;
	memory[170] = 216;
	memory[171] = 217;
	memory[172] = 217;
	memory[173] = 218;
	memory[174] = 218;
	memory[175] = 219;
	memory[176] = 220;
	memory[177] = 220;
	memory[178] = 221;
	memory[179] = 221;
	memory[180] = 222;
	memory[181] = 222;
	memory[182] = 223;
	memory[183] = 223;
	memory[184] = 224;
	memory[185] = 224;
	memory[186] = 224;
	memory[187] = 225;
	memory[188] = 225;
	memory[189] = 226;
	memory[190] = 226;
	memory[191] = 227;
	memory[192] = 227;
	memory[193] = 228;
	memory[194] = 228;
	memory[195] = 229;
	memory[196] = 229;
	memory[197] = 230;
	memory[198] = 230;
	memory[199] = 231;
	memory[200] = 231;
	memory[201] = 232;
	memory[202] = 232;
	memory[203] = 232;
	memory[204] = 233;
	memory[205] = 233;
	memory[206] = 234;
	memory[207] = 234;
	memory[208] = 235;
	memory[209] = 235;
	memory[210] = 236;
	memory[211] = 236;
	memory[212] = 236;
	memory[213] = 237;
	memory[214] = 237;
	memory[215] = 238;
	memory[216] = 238;
	memory[217] = 239;
	memory[218] = 239;
	memory[219] = 239;
	memory[220] = 240;
	memory[221] = 240;
	memory[222] = 241;
	memory[223] = 241;
	memory[224] = 241;
	memory[225] = 242;
	memory[226] = 242;
	memory[227] = 243;
	memory[228] = 243;
	memory[229] = 243;
	memory[230] = 244;
	memory[231] = 244;
	memory[232] = 245;
	memory[233] = 245;
	memory[234] = 245;
	memory[235] = 246;
	memory[236] = 246;
	memory[237] = 247;
	memory[238] = 247;
	memory[239] = 247;
	memory[240] = 248;
	memory[241] = 248;
	memory[242] = 249;
	memory[243] = 249;
	memory[244] = 249;
	memory[245] = 250;
	memory[246] = 250;
	memory[247] = 250;
	memory[248] = 251;
	memory[249] = 251;
	memory[250] = 252;
	memory[251] = 252;
	memory[252] = 252;
	memory[253] = 253;
	memory[254] = 253;
	memory[255] = 253;
end

always@(posedge clk)
	begin
		
		out <= memory[addr]; 
		
	end
	
endmodule
