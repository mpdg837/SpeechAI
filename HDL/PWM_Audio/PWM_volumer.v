
module PWM_volumer(
	input clk,
	input rst,
	
	input[3:0] volume,
	input pwm_in,
	
	output reg[7:0] audio1 = 'b0,
	output reg[7:0] audio2 = 'b0
);

reg[7:0] b_audio1 = 'b0;
reg[7:0] b_audio2 = 'b0;

always@(posedge clk) 
	if(rst) begin
		b_audio1 <= 0;
	end else
	begin
			if(volume[3])
				b_audio1 <= {pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
			else
				case(volume[2:0])
					0: b_audio1 <= 8'b0;
					1: b_audio1 <= {6'b0                                     ,pwm_in,pwm_in};
					2: b_audio1 <= {5'b0                              ,pwm_in,pwm_in,pwm_in};
					3: b_audio1 <= {4'b0                       ,pwm_in,pwm_in,pwm_in,pwm_in};
					4: b_audio1 <= {3'b0			  			,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
					5: b_audio1 <= {2'b0  		  ,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
					6: b_audio1 <= {1'b0  ,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
					7: b_audio1 <= {pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
					default: b_audio1 <= 'b0;
				endcase
	end
	
	
always@(posedge clk) 
	if(rst) begin
		b_audio2 <= 0;
	end else
	begin
		if(volume[3])
			case(volume[2:0])
				0: b_audio2 <= 8'b0;
				1: b_audio2 <= {6'b0                                     ,pwm_in,pwm_in};
				2: b_audio2 <= {5'b0                              ,pwm_in,pwm_in,pwm_in};
				3: b_audio2 <= {4'b0                       ,pwm_in,pwm_in,pwm_in,pwm_in};
				4: b_audio2 <= {3'b0			  			,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
				5: b_audio2 <= {2'b0  		  ,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
				6: b_audio2 <= {1'b0  ,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
				7: b_audio2 <= {pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in,pwm_in};
				default: b_audio2 <= 'b0;
			endcase
		else
			b_audio2 <= 'b0;
	end

always@(posedge clk)
	if(rst) begin
		audio1 <= 'b0;
	end else
	begin
		audio1 <= b_audio1;
	end

always@(posedge clk)
	if(rst) begin
		audio2 <= 'b0;
	end else
	begin
		audio2 <= b_audio2;
	end
	
endmodule
