
module mic_recv(
	input clk,
	input rst,
	
	input enable,
	input tick,
	
	output reg[23:0] out = 'b0,
	output reg rdy = 'b0,
	
	// I2S
	
	input da,
	output reg sck = 'b0,
	output reg sel = 'b0,
	output reg ws = 'b0
	
);

reg b_rdy = 'b0;
reg b_ws = 'b0;
reg b_sel = 'b0;
reg b_sck = 'b0;

reg b_da = 'b0;

always@(posedge clk)
	if(rst) begin
		b_da <= 'b0;
		ws <= 'b0;
		sel <= 'b0;
		sck <= 'b0;
	end else
	begin
		b_da <= da;
		ws <= b_ws;
		sel <= b_sel;
		sck <= b_sck;
	end

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[23:0] f_mem = 'b0;
reg[23:0] n_mem = 'b0;

reg[5:0] f_counter = 'b0;
reg[5:0] n_counter = 'b0;

reg[4:0] f_index = 'b0;
reg[4:0] n_index = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_mem <= 'b0;
		f_counter <= 'b0;
		f_index <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem <= n_mem;
		f_counter <= n_counter;
		f_index <= n_index;
	end
	
always@(*) begin
	n_state = f_state;
	
	n_mem = f_mem;
	n_counter = f_counter;
	n_index = f_index;
	
	out = 0;
	rdy = 0;
	
	b_sck = 0;
	b_sel = 1'b0;
	b_ws = 0;
	
	if(enable)
		case(f_state)
			0: if(enable) begin
				b_sck = 0;


				if(tick) begin
					n_state = 1;
					n_index = 0;
					
					n_mem = 0;
					
					out = f_mem;
					rdy = 1'b1;
				
				end
					
			end
			1: begin
				b_sck = 1;
				
				if(tick) begin
					n_state = 2;
					n_index = 0;
					n_counter = f_counter + 1;
				end
				
			end
			2: begin
				b_sck = 0;
				
				if(tick)
					n_state = 3;
			end
			3: begin
				b_sck = 1;
				
				if(tick) begin
					n_mem = {f_mem[22:0],b_da};
					
					n_counter = f_counter + 1;
					n_index = f_index + 1;
					
					if(f_index == 23) 
						n_state = 4;
					else 
						n_state = 2;
				end
				
			end
			4: begin
				b_sck = 0;
				
				if(tick)
					n_state = 5;
			end
			5: begin
				b_sck = 1;
				
				if(tick) begin
					n_counter = f_counter + 1;
					
					if(f_counter == 31)
						n_state = 6;
					else
						n_state = 4;
				end
				
			end
			
			6: begin
				b_sck = 0;
				b_ws = 1;
				
				if(tick)
					n_state = 7;
			end
			7: begin
				b_sck = 1;
				b_ws = 1;
				
				if(tick) begin
					n_counter = f_counter + 1;
					
					if(f_counter == 63) 
						n_state = 0;
					else
						n_state = 6;
				end
			end
		endcase
	
end

endmodule
