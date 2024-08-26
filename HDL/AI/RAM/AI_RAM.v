
module AI_RAM(
	
	input csi_clk,
	input rsi_reset_n,
	
	// Avalon
	input avs_s1_write,
	input avs_s1_read,
	input[3:0] avs_s1_byteenable,
	input[13:0] avs_s1_address,
	input[31:0] avs_s1_writedata,
	
	output[31:0] avs_s1_readdata,
	
	// DMA
	
	input 		avs_s4_valid,
	input[31:0] avs_s4_data,
	input			avs_s4_endofpacket,
	input 		avs_s4_startofpacket,
	output 		avs_s4_ready = 1'b1,
	
	// Inside
	
	input[31:0] avm_s1_dout, // addr
	input avm_s1_valid,
	output avm_s1_ready = 1'b1,
	
	output[63:0] avm_m1_dout, // data
	output avm_m1_valid = 'b1,
	input avm_m1_ready


);

wire[13:0] q_addr;
wire 		  q_write;

wire[7:0]  q1_data;
wire[7:0]  q2_data;
wire[7:0]  q3_data;
wire[7:0]  q4_data;

AI_RAM_avst_loader arsl1(
	.clk(clk),
	.rst(rst),
	
	.avs_s4_data(avs_s4_data),
	.avs_s4_valid(avs_s4_valid),
	.avs_s4_endofpacket(avs_s4_endofpacket),
	.avs_s4_startofpacket(avs_s4_startofpacket),
	.avs_s4_ready(avs_s4_ready),
	
	.q_addr(q_addr),
	.q_write(q_write),
	
	.q_data1(q1_data),
	.q_data2(q2_data),
	.q_data3(q3_data),
	.q_data4(q4_data)
	
);
 
wire[15:0] in_addr = avm_s1_dout[15:0];	
wire[15:0] in_addr2 = avm_s1_dout[31:16];

wire[31:0] out_data;
wire[31:0] out_data2;
	
wire clk = csi_clk;
wire rst = ~rsi_reset_n;

wire[7:0] out1;
wire[7:0] out2;
wire[7:0] out3;
wire[7:0] out4;

wire[7:0] out_s1;
wire[7:0] out_s2;
wire[7:0] out_s3;
wire[7:0] out_s4;

wire[7:0] out2_s1;
wire[7:0] out2_s2;
wire[7:0] out2_s3;
wire[7:0] out2_s4;

AI_RAM_sector#(
	.SECTOR(1'b0)
) airs1 (
	
	.clk(clk),
	.rst(rst),
	
	// Avalon
	.avs_s1_write(avs_s1_write),
	.avs_s1_read(avs_s1_read),
	
	.avs_s1_byteenable(avs_s1_byteenable[0]),
	.avs_s1_address(avs_s1_address),
	.avs_s1_writedata(avs_s1_writedata[7:0]),
	
	.avs_s1_readdata(out1),
	
	// DMA
	
	.q_write(q_write),
	.q_addr(q_addr),
	.q_data(q1_data),
	
	// Inside
	.in_addr(in_addr),
	.out_data(out_s1),
	
	.in_addr2(in_addr2),
	.out_data2(out2_s1)
);

AI_RAM_sector#(
	.SECTOR(1'b0)
) airs2 (
	
	.clk(clk),
	.rst(rst),
	
	// Avalon
	.avs_s1_write(avs_s1_write),
	.avs_s1_read(avs_s1_read),
	
	.avs_s1_byteenable(avs_s1_byteenable[1]),
	.avs_s1_address(avs_s1_address),
	.avs_s1_writedata(avs_s1_writedata[15:8]),
	
	.avs_s1_readdata(out2),
	
	// DMA
	
	.q_write(q_write),
	.q_addr(q_addr),
	.q_data(q2_data),
		
	// Inside
	.in_addr(in_addr),
	.out_data(out_s2),
	
	.in_addr2(in_addr2),
	.out_data2(out2_s2)
	
);

AI_RAM_sector#(
	.SECTOR(1'b0)
) airs3 (
	
	.clk(clk),
	.rst(rst),
	
	// Avalon
	.avs_s1_write(avs_s1_write),
	.avs_s1_read(avs_s1_read),
	
	.avs_s1_byteenable(avs_s1_byteenable[2]),
	.avs_s1_address(avs_s1_address),
	.avs_s1_writedata(avs_s1_writedata[23:16]),
	
	.avs_s1_readdata(out3),
		
	// DMA
	
	.q_write(q_write),
	.q_addr(q_addr),
	.q_data(q3_data),
	
	// Inside
	.in_addr(in_addr),
	.out_data(out_s3),
	
	.in_addr2(in_addr2),
	.out_data2(out2_s3)
);

AI_RAM_sector#(
	.SECTOR(1'b0)
) airs4 (
	
	.clk(clk),
	.rst(rst),
	
	// Avalon
	.avs_s1_write(avs_s1_write),
	.avs_s1_read(avs_s1_read),
	
	.avs_s1_byteenable(avs_s1_byteenable[3]),
	.avs_s1_address(avs_s1_address),
	.avs_s1_writedata(avs_s1_writedata[31:24]),
	
	.avs_s1_readdata(out4),
		
	// DMA
	
	.q_write(q_write),
	.q_addr(q_addr),
	.q_data(q4_data),
	
	// Inside
	.in_addr(in_addr),
	.out_data(out_s4),
	
	.in_addr2(in_addr2),
	.out_data2(out2_s4)
);


wire[31:0] out01 = {out_s4 , out_s3, out_s2 , out_s1};
wire[31:0] out11 = {out2_s4 , out2_s3, out2_s2 , out2_s1};

assign avs_s1_readdata = {out4 , out3 , out2 , out1};
assign out_data = out01;
assign out_data2 = out11;

assign avm_m1_dout = {out_data2,out_data};

endmodule
