
module PWM_freq#(
	parameter CYCLE = 2083,
	parameter SPEED_CYCLE = CYCLE / 8
)(
	input clk,
	input rst,
	
	output reg tick = 'b0,
	output reg s_tick = 'b0

);
reg[15:0] tim = 0;
reg[2:0] s_tim = 0;

reg b_tick = 'b0;
reg b_s_tick = 'b0;

always@(posedge clk)
	if(rst) begin
		tick <= 'b0;
		s_tick <= 'b0;
	end else
	begin
		tick <= b_tick;
		s_tick <= b_s_tick;	
	end

always@(posedge clk) begin
	if(rst) begin
		tim = 0;
		s_tim = 0;
		b_tick = 0;
		b_s_tick = 0;
	end else
	begin
		if(tim == SPEED_CYCLE - 1) begin
			if(s_tim == 0) begin
				b_tick = 1'b1;
				b_s_tick = 1'b0;
			end
			else begin
				b_tick = 1'b0;
				b_s_tick = 1'b1;			
			end
				
			tim = 0;
			s_tim = s_tim + 1;
		end else
		begin
			b_tick = 1'b0;
			b_s_tick = 1'b0;
			tim = tim + 1;
		end
	end
end



endmodule
