
module sig_collector(
	input clk,
	input rst,
	
	input init,
	
	input[15:0] audio1,
	input audio1_valid,
	output reg audio1_rdy = 'b0,
	
	input[15:0] audio2,
	input audio2_valid,
	output reg audio2_rdy = 'b0,
	
	output reg[15:0] audio = 'b0,
	output reg audio_valid = 'b0,
	input audio_rdy
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;
 
reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 = 'b0;

reg[15:0] f_mem2 = 'b0;
reg[15:0] n_mem2 = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;	
	end
	
always@(*) begin
	
	n_state = f_state;
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;	
		
	audio1_rdy = 'b0;
	audio2_rdy = 'b0;
	
	audio = 'b0;
	audio_valid = 'b0;

	if(init) begin
		n_state =0 ;
		n_mem1 = 0;
		n_mem2 = 0;
	end
	
	case(f_state)
		0: if(audio1_valid) begin
			
			n_mem1 = audio1;
			
			audio1_rdy = 1'b1;
			n_state = 1'b1;
		end
		1: begin
			audio = f_mem1;
			audio_valid = 1'b1;
			
			if(audio_rdy) begin
				n_state = 2;
			end
		
		end
		2: if(audio2_valid) begin
			
			n_mem2 = audio2;
			
			audio2_rdy = 1'b1;
			n_state = 3;
		end
		3: begin
			audio = f_mem2;
			audio_valid = 1'b1;
			
			if(audio_rdy) begin
				n_state = 0;
			end
		
		end
		
	endcase
end


endmodule
