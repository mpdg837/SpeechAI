
module BLEUART_fifo_out(
	input clk,
	input rst,
	
	input write,
	input[7:0] write_data,
	
	
	output reg[7:0] data_out = 'b0,
	output reg data_valid = 'b0,
	input data_rdy,
	
	output full,
	output empty
);

wire[7:0] read_data;
reg read = 'b0;

BLEUART_FIFO_basic fifo
(
  .clk(clk), 
  .rst(rst),
  
  .w_en(write), 
  .data_in(write_data),
  
  .r_en(read),
  .data_out(read_data),
  
  .full(full), 
  .empty(empty)
);

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

always@(posedge clk)
	if(rst) begin
		f_mem <= 'b0;
		f_state <= 'b0;
	end else
	begin
		f_mem <= n_mem;
		f_state <= n_state;
	end
	
always@(*) begin
	n_state = f_state;
	n_mem = f_mem;
	
	read = 'b0;

	data_out = 'b0;
	data_valid = 'b0;
	
	case(f_state)
		0: if(~empty) begin
			n_state = 1;
			read = 1'b1;
		end
		1: begin
			n_mem = read_data;
			n_state = 2;
		end
		2: begin
			data_out = f_mem;
			data_valid = 'b1;
	
			if(data_rdy) begin
				n_state = 0;
			end
		end
	endcase

end


endmodule
