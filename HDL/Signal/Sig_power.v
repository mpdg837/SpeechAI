
module signal_power(
	input clk,
	input rst,
	
	input[15:0] transform_real,
	input[15:0] transform_imag,
	
	input transform_valid,
	output reg transform_rdy = 'b0,
	
	output reg[31:0] power_data = 'b0,
	output reg power_valid = 'b0,
	input power_rdy
	
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[15:0] f_imag = 'b0;
reg[15:0] n_imag = 'b0;

reg[15:0] f_real = 'b0;
reg[15:0] n_real = 'b0;

reg[31:0] f_mul1 = 'b0;
reg[31:0] n_mul1 = 'b0;

reg[31:0] f_mul2 = 'b0;
reg[31:0] n_mul2 = 'b0;

reg[31:0] f_result = 'b0;
reg[31:0] n_result = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_real <= 'b0;
		f_imag <= 'b0;
		
		f_mul1 <= 'b0;
		f_mul2 <= 'b0;
		
		f_result <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_real <= n_real;
		f_imag <= n_imag;
		
		f_mul1 <= n_mul1;
		f_mul2 <= n_mul2;
		
		f_result <= n_result;
	end
	
always@(*) begin
	n_state = f_state;

	n_imag = f_imag;
	n_real = f_real;
	
	n_mul1 = f_mul1;
	n_mul2 = f_mul2;
	
	n_result = f_result;
	
	transform_rdy = 'b0;
	
	power_data = 'b0;
	power_valid = 'b0;
	
	case(f_state)
		0: if(transform_valid) begin
			
			n_imag = transform_imag;
			n_real = transform_real;
			
			n_state = 1;
			
			transform_rdy = 1'b1;
		end
		1: begin
			if(f_imag[15]) begin
				n_imag = (~f_imag) + 1;
			end else
			begin
				n_imag = f_imag;
			end
			
			if(f_real[15]) begin
				n_real = (~f_real) + 1;
			end else
			begin
				n_real = f_real;
			end			
			
			n_state = 2;
		end
		2: begin
			n_mul1 = f_real * f_real;
			n_mul2 = f_imag * f_imag;
			
			n_state = 3;
		end
		3: begin
			n_result = f_mul1 + f_mul2;
			n_state = 4;
		end
		4: begin
			
			power_data = f_result;
			power_valid = 'b1;
			
			if(power_rdy) begin
				n_state = 0;
			end
			
		end
	endcase
	
end

endmodule
