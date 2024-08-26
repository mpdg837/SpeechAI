module SignalProcessor(
	input csi_clk,
	input rsi_reset_n,

	output avm_s0_irq,
		
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
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
	

	output avm_m2_write,
	output avm_m2_read,
	
	input avm_m2_waitrequest,
	input avm_m2_readdatavalid,
	
	output[31:0] avm_m2_address,
	output[31:0] avm_m2_writedata,
	
	input [31:0] avm_m2_readdata
	
);

wire clk = csi_clk;
wire rst = ~rsi_reset_n;

wire irq;

wire start;

wire[31:0] start_addr_read;
wire[31:0] start_addr_write;


sig_parameters npar(
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
	.start_addr_write(start_addr_write),

	.start(start)
);


wire[15:0] audio_data;
wire audio_valid;
wire audio_rdy;


wire[15:0] profile_data;
wire profile_valid;
wire profile_rdy;



sig_core scor(
	.clk(clk),
	.rst(rst),
	
	.init(start),
	
	.audio_data(audio_data),
	.audio_valid(audio_valid),

	.audio_rdy(audio_rdy),


	.profile_data(profile_data),
	.profile_valid(profile_valid),
	.profile_rdy(profile_rdy)	
);

wire[31:0] dma1_addr;
wire dma1_read;
wire dma1_write;
wire[31:0] dma1_writedata;
wire[31:0] dma1_readdata;
wire dma1_rdy;


wire[31:0] dma2_addr;
wire dma2_read;
wire dma2_write;
wire[31:0] dma2_writedata;
wire[31:0] dma2_readdata;
wire dma2_rdy;

sig_loader siglod(
	.clk(clk),
	.rst(rst),
	
	.start(start),
	.start_addr_read(start_addr_read),
	
	// DMA
	
	.dma1_addr(dma1_addr),
	.dma1_read(dma1_read),
	.dma1_write(dma1_write),
	.dma1_writedata(dma1_writedata),
	
	.dma_readdata(dma1_readdata),
	.dma_rdy(dma1_rdy),
	
	// Stream
	
	.audio_data(audio_data),
	.audio_valid(audio_valid),
	.audio_rdy(audio_rdy)

);

sig_saver sigsav(
	.clk(clk),
	.rst(rst),
	
	.start(start),
	.start_addr_write(start_addr_write),
	
	// DMA
	
	.dma2_addr(dma2_addr),
	.dma2_read(dma2_read),
	.dma2_write(dma2_write),
	.dma2_writedata(dma2_writedata),
	
	.dma_readdata(dma2_readdata),
	.dma_rdy(dma2_rdy),
	
	// Stream
	
	.profile_data(profile_data),
	.profile_valid(profile_valid),
	.profile_rdy(profile_rdy),

	.irq(irq)
);


sig_dma sigdma1(
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

sig_dma sigdma2(
	.clk(clk),
	.rst(rst),
	
	.dma1_addr(dma2_addr),
	.dma1_read(dma2_read),
	.dma1_write(dma2_write),
	.dma1_writedata(dma2_writedata),
	
	.dma_readdata(dma2_readdata),
	.dma_rdy(dma2_rdy),
	
	// DMA
	
	.avm_m1_write(avm_m2_write),
	.avm_m1_read(avm_m2_read),
	
	.avm_m1_waitrequest(avm_m2_waitrequest),
	.avm_m1_readdatavalid(avm_m2_readdatavalid),
	
	.avm_m1_address(avm_m2_address),
	.avm_m1_writedata(avm_m2_writedata),
	
	.avm_m1_readdata(avm_m2_readdata)
);
endmodule
