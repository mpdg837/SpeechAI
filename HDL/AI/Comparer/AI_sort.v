
module AI_sort(
	input clk,
	input rst,
	
	input init,
	input[7:0] packet_size,
	
	input[31:0] sum_in,
	input sum_rdy,
	output sum_full,
	
	output[31:0] sum_out,
	output sum_out_rdy
);

wire fifo_read;
wire[31:0] fifo_out;
wire fifo_empty;

AI_FIFO_basic aifb(
	  .clk(clk), 
	  .rst(rst | init),
	  
	  .w_en(sum_rdy), 
	  .data_in(sum_in),
	  
	  .r_en(fifo_read),
	  .data_out(fifo_out),
	  .empty(fifo_empty),
	  .full(sum_full)
);

wire[31:0] col_sum_out;
wire col_sum_rdy;

wire sort_ready;

AI_collector aicol(
	.clk(clk),
	.rst(rst),
	
	// init
	.init(init),
	.packet_size(packet_size),
	.sort_ready(sort_ready),
	
	// fifo
	
	.fifo_out(fifo_out), 
	.fifo_empty(fifo_empty),
	.fifo_read(fifo_read),
	
	// out
	.data_out(col_sum_out),
	.data_rdy(col_sum_rdy)
	
);

AI_sorter aisor(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.data_in(col_sum_out),
	.data_rdy(col_sum_rdy),
	
	.sort_ready(sort_ready),
	.data_out(sum_out),
	.data_out_rdy(sum_out_rdy)
);
endmodule
