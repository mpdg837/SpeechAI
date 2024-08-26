
module AI_core_collect(
	input clk,
	input rst,
	

	// cores
	input init,
	
	input[31:0] fsum1_out,
	input fsum1_empty,
	output reg fsum1_read = 1'b0,

	input[31:0] fsum2_out,
	input fsum2_empty,
	output reg fsum2_read = 1'b0,
	
	input[31:0] fsum3_out,
	input fsum3_empty,
	output reg fsum3_read = 1'b0,
	
	input[31:0] fsum4_out,
	input fsum4_empty,
	output reg fsum4_read = 1'b0,
	
	// next
	
	output reg[31:0] sum_out = 'b0,
	output reg sum_rdy = 'b0,
	input sum_full
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg f_b1 = 'b0;
reg n_b1 = 'b0;

reg f_b2 = 'b0;
reg n_b2 = 'b0;

reg f_b3 = 'b0;
reg n_b3 = 'b0;

reg f_b4 = 'b0;
reg n_b4 = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_b1 <= 'b0;
		f_b2 <= 'b0;
		f_b3 <= 'b0;
		f_b4 <= 'b0;
		
	end else
	begin
		f_state <= n_state;
		
		f_b1 <= n_b1;
		f_b2 <= n_b2;
		f_b3 <= n_b3;
		f_b4 <= n_b4;
		
	end

always@(*) begin
	n_state = f_state;
	
	n_b1 = f_b1;
	n_b2 = f_b2;
	n_b3 = f_b3;
	n_b4 = f_b4;
	
	fsum1_read = 1'b0;
	fsum2_read = 1'b0;
	fsum3_read = 1'b0;
	fsum4_read = 1'b0;
	
	sum_out = 'b0;
	sum_rdy = 'b0;
	
	if(init) begin
		n_b1 = 0;
		n_b2 = 0;
		n_b3 = 0;
		n_b4 = 0;
	end
	
	case(f_state)
		0: if(~sum_full) begin
		
			if(f_b4) begin
				sum_out = {fsum4_out[31:30],2'b11,fsum4_out[27:0]};
				sum_rdy = 1'b1;
			end
		
			n_b4 = 'b0;
			
			if(~fsum1_empty) begin
				n_b1 = 1;
				fsum1_read = 1'b1;
			end
			
			n_state = 1;
		end
		1: if(~sum_full) begin
			if(f_b1) begin
				sum_out = {fsum1_out[31:30],2'b00,fsum1_out[27:0]};
				sum_rdy = 1'b1;
			end
		
			n_b1 = 'b0;
			
			if(~fsum2_empty) begin
				n_b2 = 1;
				fsum2_read = 1'b1;
			end
			
			
			n_state = 2;
		end
		2: if(~sum_full) begin
			if(f_b2) begin
				sum_out = {fsum2_out[31:30],2'b01,fsum2_out[27:0]};
				sum_rdy = 1'b1;
			end
		
			n_b2 = 'b0;
			
			if(~fsum3_empty) begin
				n_b3 = 1;
				fsum3_read = 1'b1;
			end
			
			n_state = 3;
		end
		3: if(~sum_full) begin
			if(f_b3) begin
				sum_out = {fsum3_out[31:30],2'b10,fsum3_out[27:0]};
				sum_rdy = 1'b1;
			end
	
			n_b3 = 'b0;
			
			if(~fsum4_empty) begin
				n_b4 = 1;
				fsum4_read = 1'b1;
			end
	
	
			n_state = 0;
		end
	
	endcase
end

endmodule
