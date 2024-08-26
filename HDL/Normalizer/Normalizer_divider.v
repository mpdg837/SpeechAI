
module normalizer_divider(
	input clk,
	input rst,
	
	// parameters
	
	input[15:0] max,
	input[15:0] min,
	
	input sqrt_normal,
	input start,
	
	// Dividers

	output reg[31:0] b1_in1 = 'b0,
	output reg[31:0] b1_in2 = 'b0,
	output reg b1_start = 'b0,

	input[31:0] b1_out,
	input b1_rdy,
	
	output reg[31:0] b2_in1 = 'b0,
	output reg[31:0] b2_in2 = 'b0,
	output reg b2_start = 'b0,

	input[31:0] b2_out,
	input b2_rdy,
	
	// spect in
	
	input[15:0] spect_data_1,
	input[15:0] spect_data_2,
	input spect_valid,
	
	output reg spect_rdy = 'b0,
	
	// scaled spect out
	
	output reg sspect_minus_1 = 'b0,
	output reg[31:0] sspect_data_1 = 'b0,
	output reg sspect_minus_2 = 'b0,
	output reg[31:0] sspect_data_2 = 'b0,
	output reg sspect_valid = 'b0,
	
	input sspect_rdy
);

reg[15:0] b_min = 0;

always@(posedge clk)
	if(sqrt_normal) 
		b_min <= min;
	else
		b_min <= 0;
		

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 = 'b0;

reg[15:0] f_mem2 = 'b0;
reg[15:0] n_mem2 = 'b0;

reg[31:0] f_result1 = 'b0;
reg[31:0] n_result1 = 'b0;

reg[31:0] f_result2 = 'b0;
reg[31:0] n_result2 = 'b0;

reg f_minus1 = 'b0;
reg n_minus1 = 'b0;

reg f_minus2 = 'b0;
reg n_minus2 = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_state <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		
		f_result1 <= 'b0;
		f_result2 <= 'b0;
		
		f_minus1 <= 'b0;
		f_minus2 <= 'b0;
	end else
	begin
		
		f_state <= n_state;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		
		f_result1 <= n_result1;
		f_result2 <= n_result2;
		
		f_minus1 <= n_minus1;
		f_minus2 <= n_minus2;
	end
end

always@(*) begin
	n_state = f_state;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	
	n_result1 = f_result1;
	n_result2 = f_result2;
	
	n_minus1 = f_minus1;
	n_minus2 = f_minus2;
	
	spect_rdy = 'b0;
	
	sspect_data_1 = 'b0;
	sspect_minus_1 = 'b0;
	sspect_data_2 = 'b0;
	sspect_minus_2 = 'b0;
	sspect_valid = 'b0;
	
	b1_in1 = 0;
	b1_in2 = 0;
	b1_start = 0;
	
				
	b2_in1 = 0;
	b2_in2 = 0;
	b2_start = 0;
				
	if(start) begin
		n_state = 0;
	
		n_mem1 = 0;
		n_mem2 = 0;
		
		n_result1 = 0;
		n_result2 = 0;
		
		n_minus1 = 'b0;
		n_minus2 = 'b0;
	end
	
	case(f_state)
		0: begin
				if(spect_valid) begin
					spect_rdy = 1'b1;
					
				
						if(spect_data_1[15]) begin
							n_mem1 = ~spect_data_1 + 1;
							n_minus1 = 1;
						end else
						begin
							n_mem1 = spect_data_1;
							n_minus1 = 0;
						end
						
						if(spect_data_2[15]) begin
							n_mem2 = ~spect_data_2 + 1;
							n_minus2 = 1;
						end else
						begin
							n_mem2 = spect_data_2;
							n_minus2 = 0;
						end
						
					
					
					
					n_state = 1;
				end
			end
		1: begin
				b1_in1 = {f_mem1,16'b0};
				b1_in2 = {max,16'b0};
				b1_start = 'b1;
	
				
				b2_in1 = {f_mem2,16'b0};
				b2_in2 = {max,16'b0};
				b2_start = 'b1;
				
				n_state = 2;		
			end
		2: if(b1_rdy) begin
				
				if(f_mem1 == 0)
					n_result1 = 0;
				else
					n_result1 = b1_out;
					
				if(f_mem2 == 0)
					n_result2 = 0;
				else
					n_result2 = b2_out;
					
				n_state = 3;
			end
		3: begin
				
				sspect_data_1 = f_result1;
				sspect_minus_1 = f_minus1;
				sspect_data_2 = f_result2;
				sspect_minus_2 = f_minus2;
				
				sspect_valid = 'b1;
	
				
				if(sspect_rdy) begin
					n_state = 0;
				end
			end
	endcase
	

end
endmodule