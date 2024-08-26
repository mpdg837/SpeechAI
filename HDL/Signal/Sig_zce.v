
module signal_zcr(
	input clk,
	input rst,
	
	input init,
	input[15:0] window_data,
	input window_valid,
	output reg window_rdy = 'b0,
	
	output reg[7:0] zcr_data ='b0,
	output reg zcr_valid = 'b0,
	input zcr_rdy
	
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[8:0] f_counter = 'b0;
reg[8:0] n_counter = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;

reg[15:0] f_lmem = 'b0;
reg[15:0] n_lmem = 'b0;

reg[7:0] f_zcr = 'b0;
reg[7:0] n_zcr = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		
		f_mem <= 'b0;
		f_lmem <= 'b0;
		
		f_zcr <= 'b0;
	end else
	begin
		f_counter <= n_counter;
		f_state <= n_state;
		
		f_mem <= n_mem;
		f_lmem <= n_lmem;
		
		f_zcr <= n_zcr;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	
	n_mem = f_mem;
	n_lmem = f_lmem;
	
	n_zcr = f_zcr;
	
	window_rdy = 'b0;
	
	zcr_data = 'b0;
	zcr_valid = 'b0;
	
	if(init) begin
		n_counter = 0;
		n_zcr = 'b0;
		
		n_mem = 'b0;
		n_lmem = 'b0;
	end
	
	case(f_state)
		0: if(window_valid) begin
			n_mem = window_data;
			
			window_rdy = 'b1;
			
			n_state = 1;
		end
		1: begin
			
			
			if(f_zcr != 255 && f_counter != 0)
				case({f_lmem[15],f_mem[15]})
					2'b10: n_zcr = f_zcr + 1;
					2'b01: n_zcr = f_zcr + 1;
					default:;
				endcase
			
			n_lmem = f_mem;
			n_counter = f_counter + 1;
			
			if(f_counter == 511) begin
				n_state = 2;
			end else
			begin
				n_state = 0;
			end
		end
		2: begin
			zcr_data = f_zcr;
			zcr_valid = 1;	
			
			if(zcr_rdy) begin
				n_state = 0;
				n_zcr = 'b0;
				
				n_mem = 'b0;
				n_lmem = 'b0;
			end
			
		end
	endcase

end


endmodule
