module AI_DMA(
	input csi_clk,
	input rsi_reset_n,

	output avm_s0_irq,
		
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[3:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata,
	

	
	// DMA
	
	output avm_m1_write,
	output avm_m1_read,
	
	input avm_m1_waitrequest,
	input avm_m1_readdatavalid,
	
	output[31:0] avm_m1_address,
	output[31:0] avm_m1_writedata,
	
	input [31:0] avm_m1_readdata,

	// DMA stream
	
	output 		  avs_m1_valid,
	output[31:0]  avs_m1_data,
	output 		  avs_m1_startofpacket,
	output		  avs_m1_endofpacket,
	input	 		  avs_m1_ready
		
);

wire clk = csi_clk;
wire rst = ~rsi_reset_n;

wire[31:0] dma1_addr;
wire dma1_read;
wire dma1_write;
wire[31:0] dma1_writedata;
wire[31:0] dma1_readdata;
wire dma1_rdy;

wire start;
wire irq;

wire[31:0] start_addr_block;
wire[31:0] stop_addr_block;

wire[31:0] start_addr_read;

wire[15:0] data_len;

wire[7:0] minimum1;
wire[7:0] minimum2;

wire[7:0] wage1;
wire[7:0] wage2;

wire shift;

	
wire[15:0]	line_width;
wire[15:0] 	region_width;
dma_parameters npar(
	.clk(clk),
	.rst(rst),
	
	.avm_s0_irq(avm_s0_irq),
	.irq(irq),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata),	
	
	// Registers
	
	.start_addr_read(start_addr_read),
	
	.start_addr_block(start_addr_block),
	.stop_addr_block(stop_addr_block),
	
	.data_len(data_len),

	
	.shift(shift),
	.start(start),
	
	.minimum1(minimum1),
	.minimum2(minimum2),	

	.wage1(wage1),
	.wage2(wage2),	
	
	.line_width(line_width),
	.region_width(region_width)
	

);


wire 		  avs_m2_valid;
wire[31:0] avs_m2_data;
wire 		  avs_m2_startofpacket;
wire		  avs_m2_endofpacket;
wire	 	  avs_m2_ready;

wire 		  avs_m3_valid;
wire[31:0] avs_m3_data;
wire 		  avs_m3_startofpacket;
wire		  avs_m3_endofpacket;
wire	 	  avs_m3_ready;


dma_noise_reducer dsc1(
	.clk(clk),
	.rst(rst),
	
	// params
	
	.minimum1(minimum1),
	.minimum2(minimum2),	
		
	.line_width(line_width),
	.region_width(region_width),
	
	.start(start),
	
	
	// Out
	
	.avs_m1_valid(avs_m3_valid),
	.avs_m1_data(avs_m3_data),
	.avs_m1_startofpacket(avs_m3_startofpacket),
	.avs_m1_endofpacket(avs_m3_endofpacket),
	.avs_m1_ready(avs_m3_ready),
	
	
	// in
	.avs_m2_valid(avs_m2_valid),
	.avs_m2_data(avs_m2_data),
	.avs_m2_startofpacket(avs_m2_startofpacket),
	.avs_m2_endofpacket(avs_m2_endofpacket),
	.avs_m2_ready(avs_m2_ready)
	
);

dma_wager dwag1(
	.clk(clk),
	.rst(rst),
	
	// params
	
	.wage1(wage1),
	.wage2(wage2),	
		
	.line_width(line_width),
	.region_width(region_width),
	
	.start(start),
	
	
	// Out
	
	.avs_m1_valid(avs_m1_valid),
	.avs_m1_data(avs_m1_data),
	.avs_m1_startofpacket(avs_m1_startofpacket),
	.avs_m1_endofpacket(avs_m1_endofpacket),
	.avs_m1_ready(avs_m1_ready),
	
	
	// in
	.avs_m2_valid(avs_m3_valid),
	.avs_m2_data(avs_m3_data),
	.avs_m2_startofpacket(avs_m3_startofpacket),
	.avs_m2_endofpacket(avs_m3_endofpacket),
	.avs_m2_ready(avs_m3_ready)
	
);

dma_loader dl1(
	.clk(clk),
	.rst(rst),
	
	.start(start),
	.irq(irq),
	
	.shift(shift),
	
	.start_addr_read(start_addr_read),
	.start_addr_block(start_addr_block),
	.stop_addr_block(stop_addr_block),
	.data_len(data_len),
	
	
	.avs_m1_valid(avs_m2_valid),
	.avs_m1_data(avs_m2_data),
	.avs_m1_startofpacket(avs_m2_startofpacket),
	.avs_m1_endofpacket(avs_m2_endofpacket),
	.avs_m1_ready(avs_m2_ready),

	.dma1_addr(dma1_addr),
	.dma1_read(dma1_read),
	.dma1_write(dma1_write),
	.dma1_writedata(dma1_writedata),
	
	.dma1_readdata(dma1_readdata),
	.dma1_rdy(dma1_rdy),
		
);

dma_dma sigdma1(
	.clk(clk),
	.rst(rst),
	
	.dma1_addr(dma1_addr),
	.dma1_read(dma1_read),
	.dma1_write(dma1_write),
	.dma1_writedata(dma1_writedata),
	
	.dma_readdata(dma1_readdata),
	.dma_rdy(dma1_rdy),
	
	// DMA
	
	.avm_m1_write(avm_m1_write),
	.avm_m1_read(avm_m1_read),
	
	.avm_m1_waitrequest(avm_m1_waitrequest),
	.avm_m1_readdatavalid(avm_m1_readdatavalid),
	
	.avm_m1_address(avm_m1_address),
	.avm_m1_writedata(avm_m1_writedata),
	
	.avm_m1_readdata(avm_m1_readdata)
);


endmodule
