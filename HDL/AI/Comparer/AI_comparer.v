
module AI_comparer(

	input csi_clk,
	input rsi_reset_n,

	output avm_s0_irq,
		
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[3:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata,
	
	// QRAM

	input[63:0] avm_s2_dout, // data
	input avm_s2_valid,
	output avm_s2_ready,
	
	output[31:0] avm_m2_dout, // addr
	output avm_m2_valid,
	input avm_m2_ready,

	
	// Avalon Stream
	
	output[39:0] avm_m1_dout, // commands
	output avm_m1_ivalid,
	input avm_m1_oready,

	input[39:0] avs_s2_inout, // data
	input avs_s2_valid,
	output avs_s2_ready
	
);


wire[7:0] score_minimum;

wire[7:0] data1;
wire data1_rdy;

wire[7:0] data2;
wire data2_rdy;

wire[7:0] data3;
wire data3_rdy;

wire[7:0] data4;
wire data4_rdy;

AI_demultiplex aidupx(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.avs_s2_inout(avs_s2_inout),
	.avs_s2_valid(avs_s2_valid),
	.avs_s2_ready(avs_s2_ready),
	
	.data1(data1),
	.data1_rdy(data1_rdy),
	
	.data2(data2),
	.data2_rdy(data2_rdy),
	
	.data3(data3),
	.data3_rdy(data3_rdy),
	
	.data4(data4),
	.data4_rdy(data4_rdy)
);

	
wire clk = csi_clk;
wire rst = ~rsi_reset_n;


wire[15:0] c1_ram_addr;
wire c1_ram_read;
wire c1_ram_rdy;
wire[31:0] c1_ram_data;

wire[15:0] c2_ram_addr;
wire c2_ram_read;
wire c2_ram_rdy;
wire[31:0] c2_ram_data;

wire[15:0] c3_ram_addr;
wire c3_ram_read;
wire c3_ram_rdy;
wire[31:0] c3_ram_data;

wire[15:0] c4_ram_addr;
wire c4_ram_read;
wire c4_ram_rdy;
wire[31:0] c4_ram_data;

AI_IDMA aiidma(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	// QRAM
	
	.avs_s2_dout(avm_s2_dout), // data
	.avm_s2_valid(avm_s2_valid),
	.avm_s2_ready(avm_s2_ready),
	
	.avm_m2_dout(avm_m2_dout), // addr
	.avm_m2_valid(avm_m2_valid),
	.avm_m2_ready(avm_m2_ready),

	// Inside
	
	.c1_ram_addr(c1_ram_addr),
	.c1_ram_read(c1_ram_read),
	.c1_ram_rdy(c1_ram_rdy),
	.c1_ram_data(c1_ram_data),
	
	.c2_ram_addr(c2_ram_addr),
	.c2_ram_read(c2_ram_read),
	.c2_ram_rdy(c2_ram_rdy),
	.c2_ram_data(c2_ram_data),
	
	.c3_ram_addr(c3_ram_addr),
	.c3_ram_read(c3_ram_read),
	.c3_ram_rdy(c3_ram_rdy),
	.c3_ram_data(c3_ram_data),
	
	.c4_ram_addr(c4_ram_addr),
	.c4_ram_read(c4_ram_read),
	.c4_ram_rdy(c4_ram_rdy),
	.c4_ram_data(c4_ram_data)
	
);



wire compress;
wire init;

wire crc_err;
wire tmr_err;
wire nde_err;
wire fifo_err;

wire crc2_err;
wire tmr2_err;
wire nde2_err;
wire fifo2_err;

wire crc3_err;
wire tmr3_err;
wire nde3_err;
wire fifo3_err;

wire crc4_err;
wire tmr4_err;
wire nde4_err;
wire fifo4_err;

wire[31:0] fsum1_out;
wire fsum1_empty;
wire fsum1_read;

wire[31:0] fsum2_out;
wire fsum2_empty;
wire fsum2_read;

wire[31:0] fsum3_out;
wire fsum3_empty;
wire fsum3_read;

wire[31:0] fsum4_out;
wire fsum4_empty;
wire fsum4_read;

wire[31:0] i_sum_sum;
wire i_sum_rdy;
wire i_sum_full;

wire[31:0] crc1;
wire[31:0] crc2;
wire[31:0] crc3;
wire[31:0] crc4;

wire[23:0] max_core;



AI_core_collect aicc(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	// cores
	
	.fsum1_out(fsum1_out),
	.fsum1_empty(fsum1_empty),
	.fsum1_read(fsum1_read),

	.fsum2_out(fsum2_out),
	.fsum2_empty(fsum2_empty),
	.fsum2_read(fsum2_read),
	
	.fsum3_out(fsum3_out),
	.fsum3_empty(fsum3_empty),
	.fsum3_read(fsum3_read),
	
	.fsum4_out(fsum4_out),
	.fsum4_empty(fsum4_empty),
	.fsum4_read(fsum4_read),
	
	// next
	
	.sum_out(i_sum_sum),
	.sum_rdy(i_sum_rdy),
	.sum_full(i_sum_full)
);


wire[31:0] sum_out;
wire sum_rdy;

AI_sort aisor(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	.packet_size(packet_size),
	
	.sum_in(i_sum_sum),
	.sum_rdy(i_sum_rdy),
	.sum_full(i_sum_full),
	
	.sum_out(sum_out),
	.sum_out_rdy(sum_rdy)
);

wire[33:0] crc_out;

AI_QCRC_sum aqsum(
	.clk(clk),
	.rst(rst),
	
	.crc1(crc1),
	.crc2(crc2),
	.crc3(crc3),
	.crc4(crc4),
	
	.crc(crc_out)
);

wire[31:0] reg1;
wire[31:0] reg2;

wire[23:0] mini;

wire[3:0] max;
wire score_rdy;

AI_scorer aisco(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	.min(mini),
	
	.sum_in(sum_out),
	.sum_rdy(sum_rdy),
	
	.reg1(reg1),
	.reg2(reg2),
	
	.rdy(score_rdy)
);


AI_decision aidec(
 	.clk(clk),
 	.rst(rst),
 	
	.init(init),
	.min(mini),
	
 	.reg1(reg1),
 	.reg2(reg2),
 	
 	.score_rdy(score_rdy),
 	
	.score_minimum(score_minimum),
 	.max(max)
);

wire irq_in;
wire irq2_in;
wire irq3_in;
wire irq4_in;

wire[14:0] sample_size;
wire[7:0] packet_size;

AI_core aic1(
	.clk(clk),
	.rst(rst),

	.compress(compress),	
	.init(init),
	.load_len(load_len),

	// RAM
	.c1_ram_addr(c1_ram_addr),
	.c1_ram_read(c1_ram_read),
	
	.c1_ram_rdy(c1_ram_rdy),
	.c1_ram_data(c1_ram_data),
	
	// Data in
	
	.card_data(data1),
	.card_rdy(data1_rdy),
	
	// Data out
	
	.fsum_out(fsum1_out),
	.fsum_empty(fsum1_empty),
	.fsum_read(fsum1_read),
	
	// Control
	
	.tmr_err(tmr_err),
	.crc_err(crc_err),
	.nde_err(nde_err),
	.fifo_err(fifo_err),
	
	.irq_in(irq_in),
	
	// Config
	
	.max(max_core),
	.packet_size(packet_size),
	.sample_size(sample_size),
	
	.crc_out(crc1)
);

AI_core aic2(
	.clk(clk),
	.rst(rst),

	.compress(compress),	
	.init(init),
	.load_len(load_len),

	// RAM
	.c1_ram_addr(c2_ram_addr),
	.c1_ram_read(c2_ram_read),
	
	.c1_ram_rdy(c2_ram_rdy),
	.c1_ram_data(c2_ram_data),
	
	// Data in
	
	.card_data(data2),
	.card_rdy(data2_rdy),
	
	// Data out
	
	.fsum_out(fsum2_out),
	.fsum_empty(fsum2_empty),
	.fsum_read(fsum2_read),
	
	// Control
	
	.tmr_err(tmr2_err),
	.crc_err(crc2_err),
	.nde_err(nde2_err),
	.fifo_err(fifo2_err),
	
	.irq_in(irq2_in),
	
	// Config
	
	.max(max_core),	
	.packet_size(packet_size),
	.sample_size(sample_size),
	
	.crc_out(crc2)
	
);


AI_core aic3(
	.clk(clk),
	.rst(rst),

	.compress(compress),	
	.init(init),
	.load_len(load_len),

	// RAM
	.c1_ram_addr(c3_ram_addr),
	.c1_ram_read(c3_ram_read),
	
	.c1_ram_rdy(c3_ram_rdy),
	.c1_ram_data(c3_ram_data),
	
	// Data in
	
	.card_data(data3),
	.card_rdy(data3_rdy),
	
	// Data out
	
	.fsum_out(fsum3_out),
	.fsum_empty(fsum3_empty),
	.fsum_read(fsum3_read),
	
	// Control
	
	.tmr_err(tmr3_err),
	.crc_err(crc3_err),
	.nde_err(nde3_err),
	.fifo_err(fifo3_err),
		
	.irq_in(irq3_in),
	
	// Config
	
	.max(max_core),	
	.packet_size(packet_size),
	.sample_size(sample_size),
	
	.crc_out(crc3)
	
);


AI_core aic4(
	.clk(clk),
	.rst(rst),

	.compress(compress),	
	.init(init),
	.load_len(load_len),

	// RAM
	.c1_ram_addr(c4_ram_addr),
	.c1_ram_read(c4_ram_read),
	
	.c1_ram_rdy(c4_ram_rdy),
	.c1_ram_data(c4_ram_data),
	
	// Data in
	
	.card_data(data4),
	.card_rdy(data4_rdy),
	
	// Data out
	
	.fsum_out(fsum4_out),
	.fsum_empty(fsum4_empty),
	.fsum_read(fsum4_read),
	
	// Control
	
	.tmr_err(tmr4_err),
	.crc_err(crc4_err),
	.nde_err(nde4_err),
	.fifo_err(fifo4_err),
		
	.irq_in(irq4_in),
	
	// Config
	
	.max(max_core),	
	.packet_size(packet_size),
	.sample_size(sample_size),
	
	.crc_out(crc4)

);

wire[15:0] load_sector;
wire[15:0] load_len;
 
AI_initizer aiini(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	.sector(load_sector),
	.len(load_len),
	
	.nde_err(nde_err | nde2_err | nde3_err | nde4_err),
	.crc_err(crc_err | crc2_err | crc3_err | crc4_err),
	.tmr_err(tmr_err | tmr2_err | tmr3_err | tmr4_err),
	.fifo_err(fifo_err | fifo2_err | fifo3_err | fifo4_err),
	
	.avm_m1_dout(avm_m1_dout),
	.avm_m1_ivalid(avm_m1_ivalid),
	.avm_m1_oready(avm_m1_oready)
);





AI_interrupt airq(
	.clk(clk),
	.rst(rst),
	
	.irq_in1(irq_in),
	.irq_in2(irq2_in),
	.irq_in3(irq3_in),
	.irq_in4(irq4_in),
	
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	
	.avm_s0_irq(avm_s0_irq)
);

wire[31:0] r_mem_addr;

wire[31:0] counter;
wire[7:0] mem_out;


wire tmr;
wire crc;
wire nde;
wire fifo;

AI_status aist(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.nde_err(nde_err | nde2_err | nde3_err | nde4_err),
	.crc_err(crc_err | crc2_err | crc3_err | crc4_err),
	.tmr_err(tmr_err | tmr2_err | tmr3_err | tmr4_err),
	.fifo_err(fifo_err | fifo2_err | fifo3_err | fifo4_err),
	
	.tmr(tmr),
	.crc(crc),
	.nde(nde),
	.fifo(fifo)
);

	
AI_av_writer ai_v_w(
	.clk(clk),
	.rst(rst),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.r_mem_addr(r_mem_addr),
	.init(init),
	.compress(compress),
	.load_sector(load_sector),
	.load_len(load_len),
	
	.max(max_core),
	
	.sample_size(sample_size),
	.packet_size(packet_size),
	
	
	.score_minimum(score_minimum)
);

AI_av_reader ai_v_r(
	.clk(clk),
	.rst(rst),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	
	.avs_s0_readdata(avs_s0_readdata),
	
	.init(init),
	
	.counter(counter),
	.mem_out(mem_out),
	
	.crc_in(crc_out),
	
	.tmr(tmr),
	.crc(crc),
	.nde(nde),
	.fifo(fifo),
	
	.sum_out(sum_out),
	.sum_out_rdy(sum_rdy),
	
	.reg1(reg1),
	.reg2(reg2),
	
	.max(max)
	
);

endmodule
