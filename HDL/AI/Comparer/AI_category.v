
module AI_category(
	input clk,
	input rst,
	
	input init,
	
	input[7:0] packet_size,
	
	input[31:0] in_sum_sum,
	input in_sum_rdy,
	
	output reg[31:0] sum_b_sum = 'b0,
	output reg sum_b_rdy = 'b0
);

reg f_state = 'b0;
reg n_state = 'b0;

reg[31:0] f_mem = 'b0;
reg[31:0] n_mem = 'b0;

reg[7:0] f_counter = 'b0;
reg[7:0] n_counter = 'b0;

reg[3:0] f_model = 'b0;
reg[3:0] n_model = 'b0;

reg[7:0] b_packet_size = 0;

always@(posedge clk)
	b_packet_size <= packet_size;
	
always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_mem <= 'b0;
		f_counter <= 'b0;
		f_model <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_mem <= n_mem;
		f_counter <= n_counter;
		f_model <= n_model;	
	end
	
always@(*) begin
	n_state = f_state;
	n_mem = f_mem;
	n_counter = f_counter;
	n_model = f_model;

	sum_b_sum = 'b0;
	sum_b_rdy = 'b0;
	
	if(init) begin
		n_state = 0;
		n_mem = 0;
		n_counter = 0;
		n_model = 0;	
	end
	
	case(f_state)
		0: begin
			if(in_sum_rdy) begin
				n_mem = in_sum_sum;
				
				n_state = 1;
			end
			
		end
		1: begin
			if(f_counter == b_packet_size) begin
				n_counter = 0;
				n_model = f_model + 1;
			end else
			begin
				n_counter = f_counter + 1;
			end
			
			sum_b_sum = {4'b0100,f_model,f_mem[23:0]};
			sum_b_rdy = 'b1;		
			
			
			n_state = 0;
		end
	endcase
end

	
endmodule