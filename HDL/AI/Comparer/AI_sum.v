

module AI_sum(
	input 			  clk,
	input 			  rst,
	
	input[9:0]   	  c_data,
	input 			  c_rdy,
	
	input[14:0]		  sample_size,
	input 			  init,
	
	output reg[31:0] sum_out = 'b0,
	output reg		  sum_rdy = 'b0
);

reg[31:0] f_distance = 'b0;
reg[31:0] n_distance = 'b0;

reg[9:0] f_num = 'b0;
reg[9:0] n_num = 'b0;

reg[15:0] f_counter = 'b0;
reg[15:0] n_counter = 'b0;

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[14:0] b_sample_size = 'b0;

always@(posedge clk)
	b_sample_size <= sample_size;
	
always@(posedge clk)
	if(rst) begin
		f_distance <= 'b0;
		
		f_num <= 'b0;
		
		f_state <= 'b0;
		
		f_counter <= 'b0;
	end else
	begin
		f_distance <= n_distance;
		
		f_num <= n_num;
		
		f_state <= n_state;

		f_counter <= n_counter;
	end
	

always@(*) begin
	n_distance = f_distance;
	
	n_num = f_num;
	
	n_state = f_state;
	
	n_counter = f_counter;
	
	sum_out = 'b0;
	sum_rdy = 'b0;
	
	if(init) begin
		n_distance = 'b0;
		
		n_num = 'b0;
		
		n_state = 'b0;
		n_counter = 'b0;
	end
	
	case(f_state)
		0: begin
				if(c_rdy) begin
				 n_num = c_data;
				 
				 n_state = 1;
				end
			end
		1: begin
				n_distance = f_distance + f_num;
				n_counter = f_counter + 1;
				
				if(f_counter == b_sample_size)begin
					n_state = 2;
				end else
				begin
					n_state = 0;
				end
				
			end
		2: begin
		
				n_counter = 'b0;
				n_distance = 'b0;
				
				n_num = 'b0;
				
				n_state = 'b0;
				
				sum_out = f_distance;
				sum_rdy = 1'b1;
				
				
			end
	endcase
end

endmodule
