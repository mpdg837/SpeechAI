module Normalizer(
	input csi_clk,
	input rsi_reset_n,
	
	output avm_s0_irq,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata = 'b0,

	
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
wire[31:0] start_addr;
wire[31:0] stop_addr;

wire start;

wire[15:0] max_value;
wire sqrt_normal;

wire[15:0] area1;
wire[15:0] area2;

normalizer_parameters npar(
	.clk(clk),
	.rst(rst),
	
	.avm_s0_irq(avm_s0_irq),
	.irq(irq),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata),	
	
	.area1(area1),
	.area2(area2),
	
	// Registers
	.start_addr(start_addr),
	.stop_addr(stop_addr),

	.start(start),

	.max_value(max_value),
	.sqrt_normal(sqrt_normal)
);

normalizer_core ncor(
	.clk(clk),
	.rst(rst),
	
	// Status
	.start_addr(start_addr),
	.stop_addr(stop_addr),
	
	.max_value(max_value),
	.start(start),
	.sqrt_normal(sqrt_normal),
	
	.irq(irq),
	
	// DMA

	.area1(area1),
	.area2(area2),
		
	.avm_m1_write(avm_m1_write),
	.avm_m1_read(avm_m1_read),
	
	.avm_m1_waitrequest(avm_m1_waitrequest),
	.avm_m1_readdatavalid(avm_m1_readdatavalid),
	
	.avm_m1_address(avm_m1_address),
	.avm_m1_writedata(avm_m1_writedata),
	
	.avm_m1_readdata(avm_m1_readdata),


	
	.avm_m2_write(avm_m2_write),
	.avm_m2_read(avm_m2_read),
	
	.avm_m2_waitrequest(avm_m2_waitrequest),
	.avm_m2_readdatavalid(avm_m2_readdatavalid),
	
	.avm_m2_address(avm_m2_address),
	.avm_m2_writedata(avm_m2_writedata),
	
	.avm_m2_readdata(avm_m2_readdata)

	
);

endmodule
