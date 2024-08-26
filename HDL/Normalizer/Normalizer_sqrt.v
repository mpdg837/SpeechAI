

module normalizer_sqrt(
	input clk,
	input rst,
	
	// parameters
	
	input[15:0] max,
	input[15:0] min,
	
	input[15:0] max_value,
	
	input start,
	input sqrt_normal,
	// Sqrt
	
	
	output reg[31:0] sqrt1_rad = 'b0,
	output reg sqrt1_start = 'b0,
	
	input sqrt1_valid,
	input[31:0] sqrt1_root,
	
	
	output reg[31:0] sqrt2_rad = 'b0,
	output reg sqrt2_start = 'b0,
	
	input sqrt2_valid,
	input[31:0] sqrt2_root,	
	
	// spect in
	
	input sspect_minus_1,
	input[15:0] sspect_data_1,
	input sspect_minus_2,
	input[15:0] sspect_data_2,
	input sspect_valid,
	
	output reg sspect_rdy = 'b0,
	
	// scaled spect out
	
	output reg[15:0] sroot_data_1 = 'b0,
	output reg[15:0] sroot_data_2 = 'b0,
	output reg sroot_valid = 'b0,
	
	input sroot_rdy
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 = 'b0;

reg[15:0] f_mem2 = 'b0;
reg[15:0] n_mem2 = 'b0;

reg[15:0] f_result1 = 'b0;
reg[15:0] n_result1 = 'b0;

reg[15:0] f_result2 = 'b0;
reg[15:0] n_result2 = 'b0;

reg[31:0] f_mul1 = 'b0;
reg[31:0] n_mul1 = 'b0;

reg[31:0] f_mul2 = 'b0;
reg[31:0] n_mul2 = 'b0;

reg f_minus1 = 'b0;
reg n_minus1 = 'b0;

reg f_minus2 = 'b0;
reg n_minus2 = 'b0;

reg[15:0] f_memmul1 = 'b0;
reg[15:0] n_memmul1 = 'b0;

reg[15:0] f_memmul2 = 'b0;
reg[15:0] n_memmul2 = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_state <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		
		f_result1 <= 'b0;
		f_result2 <= 'b0;
		
		f_mul1 <= 'b0;
		f_mul2 <= 'b0;
		
		f_minus1 <= 'b0;
		f_minus2 <= 'b0;
		
		f_memmul1 <= 'b0;
		f_memmul2 <= 'b0;
		
	end else
	begin
		f_state <= n_state;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		
		f_result1 <= n_result1;
		f_result2 <= n_result2;
		
		f_mul1 <= n_mul1;
		f_mul2 <= n_mul2;
		
		f_minus1 <= n_minus1;
		f_minus2 <= n_minus2;
		
		f_memmul1 <= n_memmul1;
		f_memmul2 <= n_memmul2;
	end
end

always@(*) begin
	n_state = f_state;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	
	n_result1 = f_result1;
	n_result2 = f_result2;
	
	n_mul1 = f_mul1;
	n_mul2 = f_mul2;
	
	n_minus1 = f_minus1;
	n_minus2 = f_minus2;
	
	n_memmul1 = f_memmul1;
	n_memmul2 = f_memmul2;
	
	sqrt1_rad = 'b0;
	sqrt1_start = 'b0;
	
	sqrt2_rad = 'b0;
	sqrt2_start = 'b0;
	
	sspect_rdy = 'b0;

	sroot_data_1 = 'b0;
	sroot_data_2 = 'b0;
	sroot_valid = 'b0;
	
	if(start) begin
		n_state = 0;
		
		n_mem1 = 0;
		n_mem2 = 0;
		
		n_result1 = 0;
		n_result2 = 0;	
	
		n_memmul1 = 0;
		n_memmul2 = 0;	
		
		n_minus1 = 0;
		n_minus2 = 0;
	end
	
	case(f_state)
		0: if(sspect_valid) begin
			
			n_mem1 = sspect_data_1;
			n_mem2 = sspect_data_2;
			
			
			n_memmul1 = sspect_data_1;
			n_memmul2 = sspect_data_2;
			
			n_minus1 = sspect_minus_1;
			n_minus2 = sspect_minus_2;
			
			n_mul1 = 0;
			n_mul2 = 0;
			
			sspect_rdy = 1'b1;
			n_state = 1;
		end
		1: begin
			
			n_mul1 = max_value * f_memmul1[15:0];
			n_mul2 = max_value * f_memmul2[15:0];
			
			if(sqrt_normal) begin
				sqrt1_rad = f_mem1;
				sqrt1_start = 'b1;
				
				sqrt2_rad = f_mem2;
				sqrt2_start = 'b1;	
			
				n_state = 2;					
				
			end else
			begin
				n_state = 3;
			end

			
			
		end
		2: if(sqrt1_valid & sqrt2_valid)begin
			n_result1 = sqrt1_root[15:0];
			n_result2 = sqrt2_root[15:0];
				
			n_state = 3;
		end
		3: begin
			
			if(sqrt_normal) begin
				
				sroot_data_1 = f_result2;
				sroot_data_2 = f_result1;
					
			end else
			begin
				if(f_minus2)
					sroot_data_1 = ~f_mul2[31:16] + 1;
				else
					sroot_data_1 = f_mul2[31:16];
					
				if(f_minus1)
					sroot_data_2 = ~f_mul1[31:16] + 1;
				else
					sroot_data_2 = f_mul1[31:16];
					
			end
			

			sroot_valid = 'b1;
		
			if(sroot_rdy) begin
				n_state = 0;
			end
		end
	endcase
	
end

endmodule
