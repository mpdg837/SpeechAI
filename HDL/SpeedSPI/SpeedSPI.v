module SpeedSPI(
	
	input csi_clk,
	input rsi_reset_n,

	input sclk,
	
	output avm_s0_irq,
	
	// SPI
	output spi1_sclk,
	inout spi1_miso,
	inout  spi1_mosi,
	output spi1_cs,

	output spi2_sclk,
	inout spi2_miso,
	inout  spi2_mosi,
	output spi2_cs,

	output spi3_sclk,
	inout spi3_miso,
	inout  spi3_mosi,
	output spi3_cs,

	output spi4_sclk,
	inout spi4_miso,
	inout  spi4_mosi,
	output spi4_cs,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata,
	
	// Avalon Stream
	
	output[39:0] avm_m1_dout,
	output avm_m1_ivalid,
	input avm_m1_oready,

	input[39:0] avs_s2_inout,
	input avs_s2_valid,
	output avs_s2_ready,

	// DMA
	
	output avm_m1_write,
	output avm_m1_read,
	
	input avm_m1_waitrequest,
	input avm_m1_readdatavalid,
	
	output[31:0] avm_m1_address,
	output[31:0] avm_m1_writedata,
	
	input [31:0] avm_m1_readdata
	
);
	
wire clk = csi_clk;
wire rst = (~rsi_reset_n);

wire[7:0] i_avs_s0_dout;
wire i_avs_s0_ivalid;
wire i_avs_s0_ready;

wire[7:0] i_avs_s1_dout;
wire i_avs_s1_ivalid;
wire i_avs_s1_ready;

wire[7:0] i_avs_s2_dout;
wire i_avs_s2_ivalid;
wire i_avs_s2_ready;

wire[7:0] i_avs_s3_dout;
wire i_avs_s3_ivalid;
wire i_avs_s3_ready;

wire irq0;
wire irq1;
wire irq2;
wire irq3;
wire irq4;

wire ii_avs_s0_ready;
wire ii_avs_s1_ready;
wire ii_avs_s2_ready;
wire ii_avs_s3_ready;

wire[31:0] avs_s0_readdata_1;
wire[31:0] avs_s0_readdata_2;
wire[31:0] avs_s0_readdata_3;
wire[31:0] avs_s0_readdata_4;


	
SPI_av_irq #(
	.OFFSET(0)
) savi(
	.clk(clk),
	.rst(rst),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_address(avs_s0_address),
		
	.irq(irq0 | irq1 | irq2 | irq3 | irq4),
	
	.avm_s0_irq(avm_s0_irq)
);

wire[31:0] startaddr;
wire[15:0] len_sector;
wire[15:0] sector;
wire start_read;

SPI_config spicon(
	.clk(clk),
	.rst(rst),
	
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	
	.startaddr(startaddr),
	.len_sector(len_sector),
	.sector(sector),
	.start(start_read)
	
);


wire iirq;
	
wire avs_s1_write;
wire avs_s1_read;
wire[11:0] avs_s1_address;
wire[31:0] avs_s1_writedata;
	
wire[31:0] avs_s1_readdata;

wire[31:0] crc_out;
wire error;

SPI_reader_memory#(
	.ADDR(3'd7)
) spirmem(
	.clk(clk),
	.rst(rst),
	
	.startaddr(startaddr),
	.len_sector(len_sector),
	.sector(sector),
	.start(start_read),
	
	// MM

	.irq(irq4),
	
	// tocore
	
	.iirq(iirq),
	.error(error),

	.avs_s1_write(avs_s1_write),
	.avs_s1_read(avs_s1_read),
	.avs_s1_address(avs_s1_address),
	.avs_s1_writedata(avs_s1_writedata),
	
	.avs_s1_readdata(avs_s1_readdata),
	
	// DMA
	
	.dma_addr(dma_addr),
	.dma_read(dma_read),
	.dma_write(dma_write),
	.dma_writedata(dma_writedata),
	.dma_readdata(dma_readdata),
	.dma_rdy(dma_rdy),
	
	.crc_out(crc_out)
	
);


wire[31:0] dma_addr;
wire dma_read;
wire dma_write;
wire[31:0] dma_writedata;
wire[31:0] dma_readdata;
wire dma_rdy;


SpeedSPI_card_core #(
	.OFFSET(2'd0)
)scc1(
	.csi_clk(csi_clk),
	.rsi_reset(rst),
	
	.sclk(sclk),
	.irq(irq0),
	
	// SPI
	.spi_sclk(spi1_sclk),
	.spi_miso(spi1_miso),
	.spi_mosi(spi1_mosi),
	.spi_cs(spi1_cs),
	
	// Avalon MM
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata_1),
	
	.iirq(iirq),
	
	.avs_s1_write(avs_s1_write),
	.avs_s1_read(avs_s1_read),
	.avs_s1_address(avs_s1_address),
	.avs_s1_writedata(avs_s1_writedata),
	
	.avs_s1_readdata(avs_s1_readdata),
	
	// Avalon Stream
	
	.avm_m1_dout(i_avs_s0_dout),
	.avm_m1_ivalid(i_avs_s0_ivalid),
	.avm_m1_oready(i_avs_s0_ready),

	.avs_s2_inout(avs_s2_inout),
	.avs_s2_valid(avs_s2_valid),
	.avs_s2_ready(ii_avs_s0_ready)
		
);

SpeedSPI_card_core #(
	.OFFSET(2'd1)
)scc2(
	.csi_clk(csi_clk),
	.rsi_reset(rst),
	
	.sclk(sclk),
	.irq(irq1),
	
	// SPI
	.spi_sclk(spi2_sclk),
	.spi_miso(spi2_miso),
	.spi_mosi(spi2_mosi),
	.spi_cs(spi2_cs),
	
	// Avalon MM
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata_2),

	.avm_m1_dout(i_avs_s1_dout),
	.avm_m1_ivalid(i_avs_s1_ivalid),
	.avm_m1_oready(i_avs_s1_ready),

	.avs_s2_inout(avs_s2_inout),
	.avs_s2_valid(avs_s2_valid),
	.avs_s2_ready(ii_avs_s1_ready)		
);

SpeedSPI_card_core #(
	.OFFSET(2'd2)
)scc3(
	.csi_clk(csi_clk),
	.rsi_reset(rst),

	.sclk(sclk),
	.irq(irq2),
	
	// SPI
	.spi_sclk(spi3_sclk),
	.spi_miso(spi3_miso),
	.spi_mosi(spi3_mosi),
	.spi_cs(spi3_cs),
	
	// Avalon MM
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata_3),
	
	.avm_m1_dout(i_avs_s2_dout),
	.avm_m1_ivalid(i_avs_s2_ivalid),
	.avm_m1_oready(i_avs_s2_ready),

	.avs_s2_inout(avs_s2_inout),
	.avs_s2_valid(avs_s2_valid),
	.avs_s2_ready(ii_avs_s2_ready)
		
);

SpeedSPI_card_core #(
	.OFFSET(2'd3)
)scc4(
	.csi_clk(csi_clk),
	.rsi_reset(rst),
	
	.sclk(sclk),
	.irq(irq3),
	
	// SPI
	.spi_sclk(spi4_sclk),
	.spi_miso(spi4_miso),
	.spi_mosi(spi4_mosi),
	.spi_cs(spi4_cs),
	
	// Avalon MM
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata_4),

	.avm_m1_dout(i_avs_s3_dout),
	.avm_m1_ivalid(i_avs_s3_ivalid),
	.avm_m1_oready(i_avs_s3_ready),

	.avs_s2_inout(avs_s2_inout),
	.avs_s2_valid(avs_s2_valid),
	.avs_s2_ready(ii_avs_s3_ready)
		
);

wire[31:0] avs_s0_readdata_5;

assign avs_s2_ready = ii_avs_s0_ready | ii_avs_s1_ready | ii_avs_s2_ready | ii_avs_s3_ready;
assign avs_s0_readdata = avs_s0_readdata_1 | avs_s0_readdata_2 | avs_s0_readdata_3 | avs_s0_readdata_4 | avs_s0_readdata_5;

SPI_output spio(
	.clk(clk),
	.rst(rst),
	
	.error(error),
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_readdata(avs_s0_readdata_5),
	
	.crc_out(crc_out)
);

SPI_multiplex spim(
	.clk(clk),
	.rst(rst),
	
	.avs_s0_dout(i_avs_s0_dout),
	.avs_s0_ivalid(i_avs_s0_ivalid),
	.avs_s0_ready(i_avs_s0_ready),
	
	.avs_s1_dout(i_avs_s1_dout),
	.avs_s1_ivalid(i_avs_s1_ivalid),
	.avs_s1_ready(i_avs_s1_ready),
	
	.avs_s2_dout(i_avs_s2_dout),
	.avs_s2_ivalid(i_avs_s2_ivalid),
	.avs_s2_ready(i_avs_s2_ready),
	
	.avs_s3_dout(i_avs_s3_dout),
	.avs_s3_ivalid(i_avs_s3_ivalid),
	.avs_s3_ready(i_avs_s3_ready),
		
	.o_avs_s0_dout(avm_m1_dout),
	.o_avs_s0_ivalid(avm_m1_ivalid),
	.o_avs_s0_ready(avm_m1_oready)
);


SPI_dma ndm(
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



endmodule
