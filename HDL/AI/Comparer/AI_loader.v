
module AI_loader(
	input clk,
	input rst,
	
	input init,
	input compress,
	
	input[7:0] stream_in,
	input stream_rdy,
	input[14:0] sample_size,
	
	output reg[15:0] c_ram_addr = 'b0,
	output reg c_ram_read = 'b0,
	input c_ram_rdy,
	input[31:0] c_ram_data,
	
	output reg[63:0] data_out = 'b0,
	output reg rdy_out = 'b0
	
);

reg[63:0] b_data_out = 'b0;
reg b_rdy_out = 'b0;
	
reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_counter = 'b0;
reg[15:0] n_counter = 'b0;



reg[7:0] f_last_mem = 'b0;
reg[7:0] n_last_mem = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[7:0] f_next_mem = 'b0;
reg[7:0] n_next_mem = 'b0;



reg[7:0] f_last1 = 'b0;
reg[7:0] n_last1 = 'b0;

reg[7:0] f_last2 = 'b0;
reg[7:0] n_last2 = 'b0;

reg[7:0] f_last3 = 'b0;
reg[7:0] n_last3 = 'b0;

reg[7:0] f_last4 = 'b0;
reg[7:0] n_last4 = 'b0;



reg[7:0] f_next1 = 'b0;
reg[7:0] n_next1 = 'b0;

reg[7:0] f_next2 = 'b0;
reg[7:0] n_next2 = 'b0;

reg[7:0] f_next3 = 'b0;
reg[7:0] n_next3 = 'b0;

reg[7:0] f_next4 = 'b0;
reg[7:0] n_next4 = 'b0;




reg[7:0] n_delta = 'b0;
reg[7:0] f_delta = 'b0;

reg f_start = 'b0;
reg n_start = 'b0;


reg f_minus = 'b0;
reg n_minus = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_counter <= 'b0;
		f_state <= 'b0;
		f_mem <= 'b0;
		
		f_last1 <= 'b0;
		f_last2 <= 'b0;
		f_last3 <= 'b0;
		f_last4 <= 'b0;
		
		f_next1 <= 'b0;
		f_next2 <= 'b0;
		f_next3 <= 'b0;
		f_next4 <= 'b0;		
		
		f_last_mem <= 'b0;
		f_next_mem <= 'b0;
		
		f_start <= 'b0;
		
		f_delta <= 'b0;
		f_minus <= 'b0;
	end else
	begin
		f_counter <= n_counter;
		f_state <= n_state;
		f_mem <= n_mem;
		
		f_last1 <= n_last1;
		f_last2 <= n_last2;
		f_last3 <= n_last3;
		f_last4 <= n_last4;
		
		f_next1 <= n_next1;
		f_next2 <= n_next2;
		f_next3 <= n_next3;
		f_next4 <= n_next4;		
		
		f_next_mem <= n_next_mem;
		f_last_mem <= n_last_mem;
		
		f_start <= n_start;
		
		f_delta <= n_delta;
		f_minus <= n_minus;
	end
end

always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	n_mem = f_mem;
	
	n_last1 = f_last1;
	n_last2 = f_last2;
	n_last3 = f_last3;
	n_last4 = f_last4;

	n_next1 = f_next1;
	n_next2 = f_next2;
	n_next3 = f_next3;
	n_next4 = f_next4;
	
	n_last_mem = f_last_mem;
	n_next_mem = f_next_mem;
	
	n_delta = f_delta;
	n_minus = f_minus;
	
	n_start = f_start;
	
	c_ram_addr = 'b0;
	c_ram_read = 'b0;
	
	b_data_out = 'b0;
	b_rdy_out = 'b0;
	
	if(init) begin
		n_mem = 'b0;
		
		n_last1 = 'b0;
		n_last2 = 'b0;
		n_last3 = 'b0;
		n_last4 = 'b0;

		n_next1 = 'b0;
		n_next2 = 'b0;
		n_next3 = 'b0;
		n_next4 = 'b0;
		
		n_last_mem = 'b0;
		n_next_mem = 'b0;
		n_mem = 'b0;
		
		n_delta = 0;
		n_counter = 'b0;
		n_state = 'b0;
		
		n_start = 'b0;
	end
	
	case(f_state) 
		0: begin
			
			if(stream_rdy) begin
			
				if(compress)
					c_ram_addr = {1'b0,f_counter[14:0]};
				else
					c_ram_addr = {2'b0,f_counter[14:1]};
				
				c_ram_read = 1;
				
				n_next_mem = stream_in;
				n_mem = f_next_mem;
				n_last_mem = f_mem;
				
				n_last1 = f_next1;
				n_last2 = f_next2;
				n_last3 = f_next3;
				n_last4 = f_next4;
				
				n_state = 1;
			end
		end 
		1: begin
		
				if(compress)
					c_ram_addr = {1'b0,f_counter[14:0]};
				else
					c_ram_addr = {2'b0,f_counter[14:1]};
					
				c_ram_read = 1;
		
				if(c_ram_rdy) begin
					
					n_start = 1;
					
					if(f_start)
						n_state = 2;
					else begin
						n_counter = f_counter + 1;
						n_state = 0;
					end
					
					n_next1 = c_ram_data[7:0];
					n_next2 = c_ram_data[15:8];
					n_next3 = c_ram_data[23:16];
					n_next4 = c_ram_data[31:24];
				end
			
		end
		2: begin
	
				if(f_counter == sample_size) begin
					n_counter = 0;
					
					n_mem = 0;
					n_next_mem = 0;
					n_last_mem = 0;
					
				end else
				begin
					n_counter = f_counter + 1;
				end
			
				b_data_out = {f_last1,f_last1,f_last2,f_last3,f_last4,f_next_mem,f_mem,f_last_mem};
				b_rdy_out = 1'b1;
				
				n_state = 0;
			
			
		end		
	endcase
end

always@(posedge clk)
	if(rst) begin
		data_out <= 'b0;
		rdy_out <= 'b0;
	end else
	begin
		data_out <= b_data_out;
		rdy_out <= b_rdy_out;	
	end
	
endmodule