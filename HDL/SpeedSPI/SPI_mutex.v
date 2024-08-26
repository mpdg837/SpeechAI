module SPI_mutex(
	input clk,
	input rst,
	
	
	input mutex,
	input omutex,
	
	input read_spi_sclk,
	input read_spi_cs,
	
	input send_spi_sclk,
	input send_spi_cs,
	
	output reg spi_sclk = 1'b1,
	output reg spi_cs = 1'b1,
	
	// a
	
	input spi_mosi,
	output reg b_spi_mosi = 1'b1
);


always@(*) begin
	if(mutex) spi_sclk <= send_spi_sclk;
	else if(omutex) spi_sclk <= read_spi_sclk;
	else spi_sclk <= 0;
end

always@(negedge clk)
	b_spi_mosi <= spi_mosi;

endmodule


module SPI_mutex_fast(
	input clk,
	input rst,
	
	
	input mutex,
	input omutex,
	
	input read_spi_sclk,
	input read_spi_cs,
	
	input send_spi_sclk,
	input send_spi_cs,
	
	output reg spi_sclk = 1'b1,
	output reg spi_cs = 1'b1,
	
	// a
	
	input spi_mosi,
	output reg b_spi_mosi = 1'b1
);


always@(*) begin
	if(mutex) spi_sclk <= send_spi_sclk;
	else if(omutex) spi_sclk <= read_spi_sclk;
	else spi_sclk <= 0;
end

always@(posedge clk)
	b_spi_mosi <= spi_mosi;

endmodule
