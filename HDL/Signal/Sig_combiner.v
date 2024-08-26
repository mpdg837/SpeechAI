


module signal_combiner(
	input clk,
	input rst,
	
	input init,
	
	input[15:0] spect_data,
	input spect_valid,
	output reg spect_rdy = 'b0,
	
	input[7:0] zcr_data,
	input zcr_valid,
	output reg zcr_rdy = 'b0,
	
	output reg[15:0] profile_data = 'b0,
	output reg profile_valid = 'b0,
	input profile_rdy
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[8:0] f_counter = 'b0;
reg[8:0] n_counter = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;

reg[7:0] f_zcr = 'b0;
reg[7:0] n_zcr = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		
		f_mem <= 'b0;
		f_zcr <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		
		f_zcr <= n_zcr;
		f_mem <= n_mem;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	
	n_mem = f_mem;
	n_zcr = f_zcr;
	
	spect_rdy = 'b0;
	zcr_rdy = 'b0;

	profile_data = 'b0;
	profile_valid = 'b0;
	
	if(init) begin
		n_counter = 'b0;
		n_zcr = 'b0;
		n_state = 0;
	end
	
	case(f_state)
		0: if(spect_valid) begin
			n_mem = spect_data;
			spect_rdy = 1'b1;
			
			n_state = 2;
		end
		1: if(zcr_valid) begin
			n_zcr = zcr_data;
			zcr_rdy = 1'b1;
			
			n_state = 2;
		end
		2: begin
			
			if(f_counter > 255) begin
				profile_data = f_zcr;
				profile_valid = 'b1;			
			end else
			begin
				profile_data = f_mem;
				profile_valid = 'b1;
			end
			
			if(profile_rdy) begin
				n_counter = f_counter + 1;
				
				if(f_counter == 319) begin
					n_state = 3;
				end else
				if(f_counter == 255) begin
					n_state = 1;
				end else if(f_counter < 255)
				begin
					n_state = 0;
				end
				
			end
			
		end
		3: begin
			
			n_counter = 0;
			n_zcr = 0;
			n_mem = 0;
			
			
			n_state = 0;
		end
	endcase
	
end
endmodule