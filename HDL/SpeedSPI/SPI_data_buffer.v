
module SPI_data_buffer(
	input clk,
	input rst,
	
	input[7:0] in_data,
	input in_valid,
	output reg in_ready = 'b0,
	
	output reg[7:0] out_data = 'b0, 
	output reg out_valid = 'b0,
	input out_ready 
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[7:0] b_out_data = 'b0; 
reg b_out_valid = 'b0;
	
always@(posedge clk)
	if(rst) begin
		f_mem <= 0;
		f_state <= 0;
	end else
	begin
		f_mem <= n_mem;
		f_state <= n_state;
	end
	
always@(posedge clk)
	if(rst) begin
		out_data <= 0;
		out_valid <= 0;
	end else
	begin
		out_data <= b_out_data;
		out_valid <= b_out_valid;
	end
	
always@(*) begin
	n_mem = f_mem;
	n_state = f_state;

	b_out_data = 'b0; 
	b_out_valid = 'b0;
	
	in_ready = 'b0;
	
	case(f_state)
		0: if(in_valid) begin
			n_mem = in_data;
			n_state = 1;
			
			in_ready = 'b1;
		end
		1: begin
			b_out_data = f_mem; 
			b_out_valid = 'b1;
	
			n_state = 0;
		end
	endcase
end

endmodule
