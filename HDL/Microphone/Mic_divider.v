


module mic_divider(
	input clk,
	input rst,
	
	output reg tick = 'b0
);

reg[7:0] tim = 'b0;
reg b_tick = 'b0;

reg mode = 'b0;

always@(posedge clk)
	if(rst) begin
		tim <= 0;
		b_tick <= 0;
		mode <= 0;
	end else
	begin
		if((tim == 16 && (~mode)) || (tim == 15 && (mode))) begin
			b_tick <= 1;
			tim <= 0;
			mode <= ~mode;
		end else
		begin
			b_tick <= 0;
			tim <= tim + 1;
		end
	end
	
always@(posedge clk)
	if(rst)
		tick <= 'b0;
	else
		tick <= b_tick;
		
endmodule	
