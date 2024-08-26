
module PWM_soft_launch(
	input clk,
	input rst,
	
	input start,
	
	input[15:0] audio_in,
	input audio_in_valid,
	output reg audio_in_rdy = 'b0,
	
	output reg[15:0] audio_out = 'b0,
	output reg[15:0] audio_out_valid = 'b0,
	input audio_out_rdy
	
);

reg f_started = 'b0;
reg n_started = 'b0;

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;

reg[15:0] f_last = 'b0;
reg[15:0] n_last = 'b0;


reg b_start = 'b0;

always@(posedge clk)
	if(rst) begin
		b_start <= 0;
	end else
	begin
		b_start <= start;
	end
	
always@(posedge clk)
	if(rst) begin
		f_state <= 0;
		
		f_mem <= 'b0;
		f_started <= 'b0;
		f_last <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem <= n_mem;
		f_started <= n_started;
		f_last <= n_last;
	end
	
always@(*) begin
	n_state = f_state;
	
	n_mem = f_mem;

	audio_in_rdy = 'b0;
	
	audio_out = 'b0;
	audio_out_valid = 'b0;
	
	case(f_state)
		0: if(audio_in_valid) begin
			
			n_mem = audio_in;
			audio_in_rdy = 'b1;
			
			n_state = 1;
			end
		1: begin
			audio_out = f_mem;
			audio_out_valid = 'b1;
			
			if(audio_out_rdy)
				n_state = 0;
		end
	endcase
	
end

endmodule
