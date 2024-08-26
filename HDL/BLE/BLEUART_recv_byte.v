module BLEUART_recv_byte(
	input clk,
	input rst,
	
	input rx,
	
	input tick,
	
	output reg[7:0] out = 'b0,
	output reg rdy = 'b0,
	output reg error = 'b0
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[2:0] f_counter = 'b0;
reg[2:0] n_counter = 'b0;

reg f_error = 'b0;
reg n_error = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

always@(posedge clk)
	if(rst) begin
		f_mem <= 'b0;
		f_error <= 'b0;
		f_counter <= 'b0;
		
		f_state <= 'b0;
	end else
	begin
		f_mem <= n_mem;
		f_error <= n_error;
		f_counter <= n_counter;
		
		f_state <= n_state;
	end
	
always@(*) begin
	n_mem = f_mem;
	n_counter = f_counter;
	n_error = f_error;
	
	n_state = f_state;

	out = 'b0;
	rdy = 'b0;
	error = 'b0;
	
	case(f_state)
		0: if(tick) begin
			
			if(~rx) begin
				n_state = 1;
				
				n_counter = 0;
				n_error = 0;
				n_mem = 0;
				
			end
			
		end
		1: if(tick) begin
			n_counter = f_counter + 1;
			n_mem = {rx,f_mem[7:1]};
			
			if(f_counter == 7) begin
				n_state = 2;
			end else
			begin
				n_state = 1;
			end
			
		end
		2: if(tick) begin
			
			if(rx) begin
				n_error = 0;
			end else
			begin
				n_error = 1;	
			end
			
			n_state = 3;
		end
		3: begin
			out = f_mem;
			rdy = 'b1;
			error = f_error;
				
			n_state = 0;
			
		end
	endcase
	
end

endmodule
