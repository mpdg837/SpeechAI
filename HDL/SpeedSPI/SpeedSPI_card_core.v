

module SpeedSPI_card_core#(
	parameter OFFSET = 2'd0
)(
	
	input csi_clk,
	input rsi_reset,
	
	input sclk,
	output irq,
	
	// SPI
	output spi_sclk,
	inout spi_miso,
	inout  spi_mosi,
	output spi_cs,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[11:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata,
		
	// Avalon MM inside
	
	output iirq,
	
	input avs_s1_write,
	input avs_s1_read,
	input[11:0] avs_s1_address,
	input[31:0] avs_s1_writedata,
	
	output[31:0] avs_s1_readdata,
	
	// Avalon Stream
	
	output[7:0] avm_m1_dout,
	output avm_m1_ivalid,
	input avm_m1_oready,

	input[39:0] avs_s2_inout,
	input avs_s2_valid,
	output avs_s2_ready
		
);

wire orst;

wire clk = csi_clk;
wire rst = rsi_reset | orst;

// Config
wire[1:0] speed;

// Write

wire init_c;
wire close;

wire init_p;
wire[31:0] init_len;

wire com_start;
wire[7:0] com_cmd;
wire[23:0] com_arg;

wire com_rdy;
wire i_rdy;

wire start;
wire [7:0] data;
wire rdy;

// Read

wire read_save;
wire read_start;
wire[7:0] read_data;
wire read_rdy;


wire avs_i_read;
wire avs_i_write;
wire[15:0] avs_i_address;
wire[31:0] avs_i_writedata;
	
wire[31:0] avs_i_readdata;
	
wire success;
wire[1:0] error;

assign avs_s1_readdata = avs_i_readdata;
assign iirq = in_irq;

SPI_starter #(
	.OFFSET(OFFSET)
)spis(
	
	.clk(clk),
	.rst(rst),
	
	.in_irq(in_irq),
	.irq(irq),

	.error(error),
	.success(success),
		
	.avs_s1_write(avs_s0_write),
	.avs_s1_address(avs_s0_address), 
	
	.avs_s0_read(avs_i_read),
	.avs_s0_write(avs_i_write),
	.avs_s0_address(avs_i_address),
	.avs_s0_writedata(avs_i_writedata),
	
	.avs_s0_readdata(avs_i_readdata)
	
);

SPI_registers#(
	.OFFSET(OFFSET)
)spir(
	.clk(clk),
	.rst(rst),
	
	.error(error),
	.success(success),
	
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_readdata(avs_s0_readdata)
);

SPI_av_writer #(
	.OFFSET(OFFSET)
) savw (
	.clk(clk),
	.rst(rst),
	
	.avs_s0_write(avs_i_write | avs_s1_write),
	.avs_s0_address(avs_i_address | avs_s1_address),
	.avs_s0_writedata(avs_i_writedata | avs_s1_writedata),
	
	.close(close),

	.init_c(init_c),
	.init_p(init_p),
	.init_len(init_len),

	.com_start(com_start),
	.com_cmd(com_cmd),
	.com_arg(com_arg),
	
	.speed(speed)
);

SPI_av_reader #(
	.OFFSET(OFFSET)
) savr (
	.clk(clk),
	.rst(rst),
	
	.avs_s0_read(avs_i_read | avs_s1_read),
	.avs_s0_address(avs_i_address | avs_s1_address),
	
	.avs_s0_readdata(avs_i_readdata),
	.read_start(read_start),
	
	.read_data(read_data),
	.read_save(read_save)
);

reg in_irq;

always@(posedge clk)
	in_irq <= i_rdy | com_rdy | read_rdy;
	
wire tick = 1;	

wire omutex;
wire mutex;


wire r_spi_sclk;
wire r_spi_cs;

wire o_spi_sclk;
wire o_spi_cs;

wire i_start;
wire[7:0] i_data;

wire[7:0] odata;
wire ostart;
wire ordy;

wire b_spi_mosi;


	
wire 		  s_com_start;
wire[7:0]  s_com_cmd;
wire[23:0] s_com_arg;

	
	// Loader
	
wire 		  s_init_p;
wire 		  s_init_r;
wire[31:0] s_init_len;
	
	// Reader
	
wire    	  s_read_start;


wire[40:0] b_data_com;
wire		  b_valid_com;
wire 		  b_ready_com;
	
SPI_loader spil(.clk(clk),
					 .rst(rst),
					
					 .init_r(init_p | s_init_r),
					 .init_p(init_p | s_init_p),
					 .init_len(init_len | s_init_len),
					 
					 .read_start(read_start | s_read_start),
					 .read_data(read_data),
					 .read_rdy(read_rdy),
					 .read_save(read_save),
					 
					 .ostart(ostart),
					 .odata(odata), 
					 .ordy(ordy)
);

SPI_initizer initer(.clk(clk),
						 .rst(rst),
						 
						 .close(close),
						 .spi_cs(spi_cs),
						 
						 .init_start(init_c),
						 .i_rdy(i_rdy),
			
						 .start(i_start),
						 .data(i_data),
			
						 .rdy(rdy)
);

SPI_commander spic(.clk(clk),
						 .rst(rst),
	
						// Command interface
						.com_start(com_start | s_com_start),
						.com_cmd(com_cmd | s_com_cmd),
						.com_arg(com_arg | s_com_arg),
						
						.com_rdy(com_rdy),
	
						// Byte interface
						
						.start(start),
						.data(data),
						
					
					.rdy(rdy)
	
);

SPI_read_fast read(.clk(sclk),
			.rst(rst),
			
			.speed(speed),
			.tick(tick),
			// spi
			.spi_sclk(o_spi_sclk),
			.spi_mosi(b_spi_mosi),
			
			.data(odata),
			.start(ostart),
			
			.rdy(ordy),
			.mutex(omutex)
);


SPI_send send(
		.clk(clk),
		.rst(rst),
		
		.tick(tick),
		// spi
		.spi_sclk(r_spi_sclk),
		.spi_miso(spi_miso),
		
		// inside interface
		
		.data(data | i_data),
		.start(start | i_start),
		
		.rdy(rdy),
		.mutex(mutex)
);

SPI_mutex_fast smutex(
		.clk(sclk),
		.rst(rst),
		
		.mutex(mutex),
		.omutex(omutex),
		
		.read_spi_sclk(o_spi_sclk),
		.send_spi_sclk(r_spi_sclk),
	
		.spi_sclk(spi_sclk),
		
		.b_spi_mosi(b_spi_mosi),
		.spi_mosi(spi_mosi)
);

wire[7:0] b_data;
wire b_valid;
wire b_ready;

wire fifo_reset;
SPI_streamer sstrm(
		.clk(clk),
		.rst(rst),

		.orst(orst),
		
		.avm_m1_dout(b_data),
		.avm_m1_ivalid(b_valid),
		.avm_m1_oready(b_ready),

		.avs_s2_inout(b_data_com),
		.avs_s2_valid(b_valid_com),
		.avs_s2_ready(b_ready_com),
						 
		.com_start(s_com_start),
		.com_cmd(s_com_cmd),
		.com_arg(s_com_arg),

		.com_rdy(com_rdy),
		
		.fifo_reset(fifo_reset),		
		// Loader
						
		.init_p(s_init_p),
		.init_r(s_init_r),
		.init_len(s_init_len),
						
		// Reader
						
		.read_start(s_read_start),
		.read_data(read_data),
		.read_rdy(read_rdy),
		.read_save(read_save)
		
);


 
SPI_command_buffer spi_com_b(
	.clk(clk),
	.rst(rst),
	
	.in_data(avs_s2_inout),
	.in_valid(avs_s2_valid),
	.in_ready(avs_s2_ready),
	
	.out_data(b_data_com),
	.out_valid(b_valid_com),
	.out_ready(b_ready_com)
);

SPI_data_buffer sdbuf(
	.clk(clk),
	.rst(rst),
	
	.in_data(b_data),
	.in_valid(b_valid),
	.in_ready(b_ready),
	
	.out_data(avm_m1_dout),
	.out_valid(avm_m1_ivalid),
	.out_ready(avm_m1_oready)
);

endmodule
