
module BLEUART_fifo_in(
	input clk,
	input rst,
	
	input read,
	output[7:0] read_data,
	
	input[7:0] data_in,
	input data_rdy,
	
	output full,
	output empty
);

BLEUART_FIFO_basic fifo
(
  .clk(clk), 
  .rst(rst),
  
  .w_en(data_rdy), 
  .data_in(data_in),
  
  .r_en(read),
  .data_out(read_data),
  
  .full(full), 
  .empty(empty)
);


endmodule
