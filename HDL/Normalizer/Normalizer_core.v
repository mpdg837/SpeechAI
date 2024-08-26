
module normalizer_core(
	input clk,
	input rst,
	
	// Status
	input[31:0] start_addr,
	input[31:0] stop_addr,
	
	input[15:0] max_value,
	input start,
	
	input sqrt_normal,
	
	input[15:0] area1,
	input[15:0] area2,
	
	output irq,
	
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

wire[31:0] b1_in1;
wire[31:0] b1_in2;
wire b1_start;

wire[31:0] b1_out;
wire b1_rdy;

normalizer_division_block ndb_1(
	.clk(clk),
	.rst(rst),
	
	.in1(b1_in1),
	.in2(b1_in2),
	.start(b1_start),
	
	.out(b1_out),
	.rdy(b1_rdy)
);

wire[31:0] b2_in1;
wire[31:0] b2_in2;
wire b2_start;

wire[31:0] b2_out;
wire b2_rdy;

normalizer_division_block ndb_2(
	.clk(clk),
	.rst(rst),
	
	.in1(b2_in1),
	.in2(b2_in2),
	.start(b2_start),
	
	.out(b2_out),
	.rdy(b2_rdy)
);

wire sqrt1_start;
wire sqrt1_valid;
wire[31:0] sqrt1_root;
wire[31:0] sqrt1_rad;

sqrt_int #(.WIDTH(32)) nsqrt1(  
    .clk(clk),
    .start(sqrt1_start),             
    
    .valid(sqrt1_valid),             
    .rad(sqrt1_rad),   
    .root(sqrt1_root),  
    
    );
	 
wire sqrt2_start;
wire sqrt2_valid;
wire[31:0] sqrt2_root;
wire[31:0] sqrt2_rad;

sqrt_int #(.WIDTH(32)) nsqrt2(  
    .clk(clk),
	 
    .start(sqrt2_start),             
    .valid(sqrt2_valid),             
    .rad(sqrt2_rad),   
    .root(sqrt2_root),  
    
    );
	 
wire[31:0] dma_addr;
wire dma_read;
wire dma_write;
wire[31:0] dma_writedata;
wire[31:0] dma_readdata;
wire dma_rdy;


wire[15:0] max;
wire[15:0] min;
	
wire[15:0] spect_data_1;
wire[15:0] spect_data_2;
wire spect_valid;
	
wire spect_rdy;

normalizer_controller ncon(
	
	.clk(clk),
	.rst(rst),
	

	.max(max),
	.min(min),
	
	.spect_data_1(spect_data_1),
	.spect_data_2(spect_data_2),
	.spect_valid(spect_valid),
	
	.sqrt_normal(sqrt_normal),
	.spect_rdy(spect_rdy),
	
	// Status
	.start_addr(start_addr),
	.stop_addr(stop_addr),
	
	.max_value(max_value),
	.start(start),
	
	.area1(area1),
	.area2(area2),
	
	// DMA
	
	.dma_addr(dma_addr),
	.dma_read(dma_read),
	.dma_write(dma_write),
	.dma_writedata(dma_writedata),
	.dma_readdata(dma_readdata),
	.dma_rdy(dma_rdy)
	
);

wire[31:0] sspect_data_1;
wire sspect_minus_1;
wire[31:0] sspect_data_2;
wire sspect_minus_2;

wire sspect_valid;
wire sspect_rdy;

normalizer_divider nordiv(
	.clk(clk),
	.rst(rst),
	
	// parameters
	
	.max(max),
	.min(min),
	
	.sqrt_normal(sqrt_normal),
	.start(start),
	
	// Dividers

	.b1_in1(b1_in1),
	.b1_in2(b1_in2),
	.b1_start(b1_start),

	.b1_out(b1_out),
	.b1_rdy(b1_rdy),
	
	.b2_in1(b2_in1),
	.b2_in2(b2_in2),
	.b2_start(b2_start),

	.b2_out(b2_out),
	.b2_rdy(b2_rdy),
	
	
	// spect in
	
	.spect_data_1(spect_data_1),
	.spect_data_2(spect_data_2),
	.spect_valid(spect_valid),
	
	.spect_rdy(spect_rdy),
	
	// scaled spect out
	
	.sspect_data_1(sspect_data_1),
	.sspect_minus_1(sspect_minus_1),
	.sspect_data_2(sspect_data_2),
	.sspect_minus_2(sspect_minus_2),
	.sspect_valid(sspect_valid),
	
	.sspect_rdy(sspect_rdy)
);

wire[15:0] sroot_data_1;
wire[15:0] sroot_data_2;
wire sroot_valid;
wire sroot_rdy;

normalizer_sqrt norsqrt(
	.clk(clk),
	.rst(rst),
	
	// parameters
	
	.max(max),
	.min(min),
	
	.max_value(max_value),
	
	.start(start),
	.sqrt_normal(sqrt_normal),
	
	// Sqrt
	
	.sqrt1_start(sqrt1_start),             
   .sqrt1_valid(sqrt1_valid),             
   .sqrt1_rad(sqrt1_rad),   
   .sqrt1_root(sqrt1_root),

	.sqrt2_start(sqrt2_start),             
   .sqrt2_valid(sqrt2_valid),             
   .sqrt2_rad(sqrt2_rad),   
   .sqrt2_root(sqrt2_root),
	
	// spect in
	
	.sspect_data_1(sspect_data_1),
	.sspect_minus_1(sspect_minus_1),
	.sspect_data_2(sspect_data_2),
	.sspect_minus_2(sspect_minus_2),
	.sspect_valid(sspect_valid),
	
	.sspect_rdy(sspect_rdy),
	
	// scaled spect out
	
	.sroot_data_1(sroot_data_1),
	.sroot_data_2(sroot_data_2),
	.sroot_valid(sroot_valid),
	
	.sroot_rdy(sroot_rdy)
);

normalizer_dma ndm1(
	.clk(clk),
	.rst(rst),
	
	.dma_addr(dma_addr),
	.dma_read(dma_read),
	.dma_write(dma_write),
	.dma_writedata(dma_writedata),
	.dma_readdata(dma_readdata),
	.dma_rdy(dma_rdy),
	
	// DMA
	
	.avm_m1_write(avm_m1_write),
	.avm_m1_read(avm_m1_read),
	
	.avm_m1_waitrequest(avm_m1_waitrequest),
	.avm_m1_readdatavalid(avm_m1_readdatavalid),
	
	.avm_m1_address(avm_m1_address),
	.avm_m1_writedata(avm_m1_writedata),
	
	.avm_m1_readdata(avm_m1_readdata)
	
);

wire[31:0] dma1_addr;
wire dma1_read;
wire dma1_write;
wire[31:0] dma1_writedata;
wire[31:0] dma1_readdata;
wire dma1_rdy;

normalizer_saver nosav(
	
	.clk(clk),
	.rst(rst),

	
	// Status
	.start_addr(start_addr),
	.stop_addr(stop_addr),
	
	.max_value(max_value),
	.start(start),
	.sqrt_normal(sqrt_normal),
	
	// out
	
	.max(max),
	.min(min),
	
	.spect_data_1(sroot_data_2),
	.spect_data_2(sroot_data_1),
	.spect_valid(sroot_valid),
	
	.spect_rdy(sroot_rdy),
	
	
	.irq(irq),
	
	// DMA
	
	.dma_addr(dma1_addr),
	.dma_read(dma1_read),
	.dma_write(dma1_write),
	.dma_writedata(dma1_writedata),
	.dma_readdata(dma1_readdata),
	.dma_rdy(dma1_rdy)
	
	
);

normalizer_dma ndm2(
	.clk(clk),
	.rst(rst),
	
	.dma_addr(dma1_addr),
	.dma_read(dma1_read),
	.dma_write(dma1_write),
	.dma_writedata(dma1_writedata),
	.dma_readdata(dma1_readdata),
	.dma_rdy(dma1_rdy),
	
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
