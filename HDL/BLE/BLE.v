module BLEUART(
	input csi_clk,
	input rsi_reset_n,
	
	output avm_s0_irq,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output avs_s0_waitrequest = 'b0,
	output[31:0] avs_s0_readdata = 'b0,

	// UART
	
	input uart_status,
	output uart_enable,
	
	output uart_tx,
	input uart_rx
);

wire clk = csi_clk;
wire rst = ~rsi_reset_n;

wire tick;
wire r_tick;

wire[7:0] uart_out;
wire uart_out_rdy;

wire[7:0] uart_in;
wire uart_in_rdy;
wire uart_in_valid;

wire error_irq;
wire start;
wire error;

reg irq = 'b0;

always@(posedge clk)
	if(rst)
		irq <= 'b0;
	else
		irq <= error_irq | uart_in_rdy | uart_out_rdy;

BLEUART_error_catcher bec(
	.clk(clk),
	.rst(rst),
	
	.uart_in_error(uart_in_error),
	.start(write | read),
	
	.irq(error_irq),
	.error(error)
);


BLEUART_recv_byte brb(
	.clk(clk),
	.rst(rst),
	
	.rx(uart_rx),
	
	.tick(r_tick),
	
	.out(uart_in),
	.rdy(uart_in_rdy),
	.error(uart_in_error)
);

wire read;
wire[7:0] read_data;
wire read_empty;

BLEUART_fifo_in(
	.clk(clk),
	.rst(rst),
	
	.read(read),
	.read_data(read_data),
	
	.data_in(uart_in),
	.data_rdy(uart_in_rdy),
	
	.empty(read_empty)
);

BLEUART_trans_byte btb(
	.clk(clk),
	.rst(rst),
	
	.tx(uart_tx),
	
	.tick(tick),
	
	.in(uart_out),
	.valid(uart_out_valid),
	.rdy(uart_out_rdy)
);

wire write;
wire[7:0] write_data;
wire write_full;

BLEUART_fifo_out bfo(
	.clk(clk),
	.rst(rst),
	
	.write(write),
	.write_data(write_data),
	
	.data_out(uart_out),
	.data_valid(uart_out_valid),
	.data_rdy(uart_out_rdy),
	
	.full(write_full)
);

BLEUART_baudtick#(
	.TIMEOUT(868)
) bbaud(
	.clk(clk),
	.rst(rst),
	
	.rx(uart_rx),
	
	.r_tick(r_tick),
	.tick(tick)
);


BLEUART_av bav(

	.clk(clk),
	.rst(rst),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_waitrequest(avs_s0_waitrequest),
	.avs_s0_readdata(avs_s0_readdata),
	
	.avm_s0_irq(avm_s0_irq),
	
	.irq(irq),
	.error(error),
	
	.read(read),
	.read_data(read_data),
	.read_empty(read_empty),
	
	.write(write),
	.write_data(write_data),
	.write_full(write_full),
	
	.uart_status(uart_status),
	.uart_enable(uart_enable)
	

);


endmodule