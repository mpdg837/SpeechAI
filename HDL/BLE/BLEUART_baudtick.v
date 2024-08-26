
module BLEUART_baudtick#(
	parameter TIMEOUT = 868
)(
	input clk,
	input rst,
	
	input rx,
	
	output reg tick = 1'b0,
	output reg r_tick = 1'b0
);
localparam HALF = TIMEOUT/2;

reg[15:0] timer = 0;

reg l_rx = 'b1;
reg b_tick = 'b0;
reg b_r_tick = 'b0;

always@(posedge clk)
	if(rst) begin
		timer = 0;
		b_tick = 0;
		b_r_tick = 0;
		l_rx = 1;
	end else
	begin
		
		if(timer == HALF) begin
			b_r_tick = 1'b1;
		end else
		begin
			b_r_tick = 1'b0;
		end
		
		if( ((~l_rx) & rx) | ((~rx) & l_rx) )begin
			timer = 0;
			b_tick = 0;
		end else if(timer == TIMEOUT - 1) begin
			timer = 0;
			b_tick = 1;
		end else
		begin
			timer = timer + 1;
			b_tick = 0;
		end
		

		l_rx = rx;
	end
	
always@(posedge clk)
	if(rst) begin
		tick <= 'b0;
		r_tick <= 'b0;
	end else
	begin
		tick <= b_tick;
		r_tick <= b_r_tick;
	end
	

endmodule
