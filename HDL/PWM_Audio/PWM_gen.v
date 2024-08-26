
module PWM_gen(clk,rst , PWM_in, PWM_out);

	input clk;
	input rst;
	input [15:0] PWM_in;
	output reg PWM_out = 'b0;

	reg [16:0] PWM_accumulator = 'b0;
	
	reg [15:0] b_pwm_in = 'b0;
	
	always@(posedge clk)
		if(rst) begin
			b_pwm_in <= 'b0;
		end else
		begin
			b_pwm_in <= PWM_in;
		end
		
	always @(posedge clk) 
		if(rst)
			PWM_accumulator <= 'b0;
		else
			PWM_accumulator <= PWM_accumulator[15:0] + {b_pwm_in[15:8],8'b0};

	always@(posedge clk)
		if(rst)
			PWM_out <= 'b0;
		else
			PWM_out <= PWM_accumulator[16];

endmodule
