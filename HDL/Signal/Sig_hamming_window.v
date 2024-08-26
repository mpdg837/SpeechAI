
module sig_hamming_window(
	input clk,
	input rst,
	
	input init,
	
	input[15:0] audio_out,
	input audio_valid,
	output reg audio_rdy = 1'b0,
	
	output reg[15:0] window_out = 'b0,
	output reg window_valid = 'b0,
	input window_rdy,
	
	output reg[15:0] zcr_window_out = 'b0,
	output reg zcr_window_valid = 'b0,
	input zcr_window_rdy
		
);

reg[8:0] mul_addr;

wire[15:0] mul_out;

hamming_window_array hwa(
	.clk(clk),
	.rst(rst),
	
	.mul_addr(mul_addr),
	.mul_out(mul_out)
);
	
reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;


reg[8:0] f_addr = 'b0;
reg[8:0] n_addr = 'b0;

reg[31:0] f_mul = 'b0;
reg[31:0] n_mul = 'b0;

reg[31:0] f_multi = 'b0;
reg[31:0] n_multi = 'b0;

reg f_minus = 'b0;
reg n_minus = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_state <= 'b0;
		f_addr <= 'b0;
		
		f_mem <= 'b0;
		f_multi <= 'b0;
		
		f_mul <= 'b0;
		f_minus <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_addr <= n_addr;
		
		f_mem <= n_mem;
		f_multi <= n_multi;
		
		f_mul <= n_mul;
		f_minus <= n_minus;
	end
end

always@(*) begin
	n_state = f_state;
	n_addr = f_addr;
	n_minus = f_minus;
	
	n_mem = f_mem;
	n_multi = f_multi;
	
	n_mul = f_mul;
	
	window_out = 'b0;
	window_valid = 'b0;

	zcr_window_out = 'b0;
	zcr_window_valid = 'b0;
	
	audio_rdy = 'b0;
	
	mul_addr = 'b0;
	
	if(init) begin
		n_addr = 'b0;
		n_state = 'b0;
		n_mem = 'b0;
		n_mul = 'b0;
		n_multi = 'b0;
		n_minus = 'b0;
	end
	
	case(f_state)
		0: begin
			if(audio_valid) begin
				n_state = 1;
				
				if(audio_out[15]) begin
					n_minus = 1;
					n_mem = (~audio_out) + 1;
				end else
				begin
					n_minus = 0;
					n_mem = audio_out;
				end
				
				
				audio_rdy = 1'b1;
			end
		end
		1: begin
			mul_addr = f_addr;
			n_state = 2;
		end
		2: begin
			mul_addr = f_addr;
			n_multi = mul_out;
			n_state = 3;
		end
		3: begin
			n_mul = f_multi * f_mem;
			n_state = 4;
		end
		4: begin
		
			if(f_minus)
				window_out = (~f_mul[31:16]) + 1;
			else
				window_out = f_mul[31:16];
				
			window_valid = 'b1;
			
			if(window_rdy) begin
				n_state = 5;
			end
			
		end
		5: begin
			if(f_minus)
				zcr_window_out = (~f_mul[31:16]) + 1;
			else
				zcr_window_out = f_mul[31:16];
				
			zcr_window_valid = 'b1;
			
			if(zcr_window_rdy) begin
				n_state = 0;
				n_addr = f_addr + 1;
			end		
		
		end
	endcase
end

endmodule
