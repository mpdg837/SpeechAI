
module PWM_reducer(
	input clk,
	input rst,
	
	input[15:0] sound_in,
	input sound_rdy,
	
	output reg[15:0] reduced_out = 'b0,
	output reg reduced_rdy = 'b0
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;

reg f_minus = 'b0;
reg n_minus = 'b0;

reg[15:0] f_value = 'b0;
reg[15:0] n_value = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_minus <= 'b0;
		f_mem <= 'b0;
		
		f_value <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_minus <= n_minus;
		f_mem <= n_mem;
		
		f_value <= n_value;
	end
	
always@(*) begin
	n_state = f_state;
	
	n_mem = f_mem;
	n_minus = f_minus;
	
	n_value = f_value;
	
	reduced_out = 'b0;
	reduced_rdy = 'b0;
	
	case(f_state)
		0: if(sound_rdy) begin
			
			if(sound_in[15]) begin
				n_minus = 1'b1;
				n_mem = ~sound_in + 1;
			end else
			begin
				n_minus = 1'b0;
				n_mem = sound_in;
			end
			n_state = 1;
		end
		1: begin
			
			n_value = {1'b0,f_mem[14:0]};
			n_state = 2;
		
		end
		2: begin
			if(f_minus) begin
				reduced_out = ~f_value + 1;
			end else
			begin
				reduced_out = f_value;
			end
			
			reduced_rdy = 'b1;
			n_state = 0;
		end
	endcase
	
end


endmodule
