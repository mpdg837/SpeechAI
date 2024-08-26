
module dma_initizer(
	input clk,
	input rst,
	
	input[15:0] height_in,
	input[15:0] height_out,
	
	input start,
	
	output reg[31:0] divider = 'b0,
	output reg start_p = 'b0
);

reg[31:0] b1_in1 = 'b0;
reg[31:0] b1_in2 = 'b0;
reg b1_start = 'b0;

wire[31:0] b1_out;
wire b1_rdy;

dma_division_block ndb_1(
	.clk(clk),
	.rst(rst),
	
	.in1(b1_in1),
	.in2(b1_in2),
	.start(b1_start),
	
	.out(b1_out),
	.rdy(b1_rdy)
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[31:0] f_divider = 'b0;
reg[31:0] n_divider = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_divider <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_divider <= n_divider;
	end
	
always@(*) begin
	n_state = f_state;
	n_divider = f_divider;

	divider = f_divider;
	start_p = 0;

	b1_in1 = 'b0;
	b1_in2 = 'b0;
	b1_start = 'b0;
	
	case(f_state)
		0: if(start) begin
			
			n_state = 1;
		end
		1: begin
			
			b1_in1 = {height_out,15'b0};
			b1_in2 = {height_in,15'b0};
			b1_start = 'b1;
	
			n_state = 2;
		end
		2: begin
			if(b1_rdy) begin
				n_divider = b1_out;
				n_state = 3;
			end
				
		end
		3: begin
			start_p = 1;
			n_state = 0;
		end
	endcase
	
end
	
	
endmodule
