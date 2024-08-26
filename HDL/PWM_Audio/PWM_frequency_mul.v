
module PWM_frequency_mul(
	input clk,
	input rst,
	
	input s_tick,
	
	input[15:0] sound,
	input sound_rdy,
	
	output reg[15:0] sound_out = 'b0,
	output reg sound_out_rdy = 'b0
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[3:0] f_counter = 'b0;
reg[3:0] n_counter = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;

reg[15:0] b_sound_out = 'b0;
reg b_sound_out_rdy = 'b0;

reg[15:0] b_sound = 'b0;
reg b_sound_rdy = 'b0;

always@(posedge clk)
	if(rst) begin
		sound_out <= 'b0;
		sound_out_rdy <= 'b0;	
	end else
	begin
		sound_out <= b_sound_out;
		sound_out_rdy <= b_sound_out_rdy;		
	end
	
always@(posedge clk)
	if(rst) begin
		b_sound <= 'b0;
		b_sound_rdy <= 'b0;	
	end else
	begin
		b_sound <= sound;
		b_sound_rdy <= sound_rdy;		
	end
	
always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		
		f_mem <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		
		f_mem <= n_mem;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	
	n_mem = f_mem;
	
	b_sound_out = 'b0;
	b_sound_out_rdy = 'b0;
	
	case(f_state)
		0: if(b_sound_rdy) begin
			n_mem = b_sound;
			n_counter = 0;
			n_state = 1;
		end
		1: begin
			b_sound_out = f_mem;
			b_sound_out_rdy = 'b1;		
			
			n_counter = 1;
			n_state = 2;
		end
		2: if(s_tick) begin
			
			n_counter = f_counter + 1;
			
			b_sound_out = f_mem;
			b_sound_out_rdy = 'b1;
			
			if(f_counter == 7) begin
				n_state = 0;
			end
		end
	endcase
end



endmodule
