

module normalizer_division_block#(
	parameter LENGTH = 32
)(
	input clk,
	input rst,
	
	input[31:0] in1,
	input[31:0] in2,
	input start,
	
	output reg[31:0] out = 'b0,
	output reg rdy = 'b0
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[47:0] f_a = 'b0;
reg[47:0] n_a = 'b0;

reg[47:0] f_b = 'b0;
reg[47:0] n_b = 'b0;

reg[47:0] f_acc = 'b0;
reg[47:0] n_acc = 'b0;

reg[47:0] f_q = 'b0;
reg[47:0] n_q = 'b0;

reg[7:0] f_counter = 'b0;
reg[7:0] n_counter = 'b0;

reg[1:0] f_minus = 'b0;
reg[1:0] n_minus = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_state <= 'b0;
		
		f_a <= 'b0;
		f_b <= 'b0;
		f_acc <= 'b0;
		
		f_q <= 'b0;
		
		f_counter <= 'b0;
		f_minus <= 0;
	end else
	begin
		f_state <= n_state;
		
		f_q <= n_q;
		f_acc <= n_acc;
		f_a <= n_a;
		
		f_b <= n_b;
		
		f_counter <= n_counter;
		f_minus <= n_minus;
	end
end

reg[LENGTH - 1:0] b_in1 = 'b0; 
reg[LENGTH - 1:0] b_in2 = 'b0;
reg b_start = 'b0;

reg b_minus1 = 'b0;
reg b_minus2 = 'b0;

reg[LENGTH - 1:0] b_out = 'b0;
reg b_rdy = 'b0;

always@(posedge clk) begin
	if(rst) begin
		b_in1 <= 'b0;
		b_in2 <= 'b0;
		b_start <= 'b0;
		b_minus1 <= 'b0;
		b_minus2 <= 'b0;
	end else
	begin
		
		if(start) begin
			if(in1[LENGTH - 1]) begin
				b_minus1 <= 1'b1;
				b_in1 <= (~in1) + 1;
			end else
			begin
				b_minus1 <= 'b0;
				b_in1 <= in1;
			end
			
			if(in2[LENGTH - 1]) begin
				b_minus2 <= 1'b1;
				b_in2 <= (~in2) + 1;
			end else begin
				b_minus2 <= 1'b0;
				b_in2 <= in2;
			end 
			
			b_start <= 1;
		end else
		begin
			b_in1 <= 'b0;
			b_in2 <= 'b0;
			b_start <= 'b0;
			b_minus1 <= 'b0;
			b_minus2 <= 'b0;		
		end
	end
end

always@(*) begin
	n_state = f_state;
	
	n_a = f_a;
	n_q = f_q;
	n_acc = f_acc;
	
	n_b = f_b;
	
	n_counter = f_counter;
	n_minus = f_minus;
	
	b_out = 'b0;
	b_rdy = 'b0;

	case(f_state)
		0: begin
			if(b_start) begin
				
				n_minus = {b_minus1,b_minus2};
				
				n_a = {b_in1,16'b0};
				n_b = {16'b0,b_in2};
				
				n_acc = 'b0;
				n_q = 'b0;
				
				n_state = 1;
				n_counter = 'b0;
			end
		end
		1: begin
			n_counter = f_counter + 1;
				
			n_acc = {f_acc[46:0],f_a[47]};
			n_a = {f_a[46:0],f_q[47]};
			n_q = {f_q[46:0],1'b0};
			
			if(n_acc >= f_b) begin
				n_acc = n_acc - f_b;
				n_q = {n_q[47:1],1'b1};
			end
			
			
			if(f_counter == 47) begin
				n_state = 2;
			end else
			begin
				n_state = 1;
			end
		end
		2: begin
		
			if(f_minus == 2'b0 || f_minus == 2'b11) begin
				b_out = f_q[31:0];

			end else
			begin
				b_out = (~f_q[31:0]) + 1;

			end
			b_rdy = 1'b1;
			
			n_state = 0;
		end
	endcase
	
end

always@(posedge clk) begin
	if(rst) begin
		out <= 'b0;
		rdy <= 'b0;
	end else
	begin
		out <= b_out;
		rdy <= b_rdy;
	end
end	

endmodule
