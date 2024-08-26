

module AI_final(
	input clk,
	input rst,
	
	input[15:0] len,
	
	input char_rdy,
	input init,
	
	output reg nde_err = 'b0,
	output reg irq = 'b0
);

localparam TIMEOUT = 500000;

reg[$clog2(TIMEOUT) - 1 : 0] f_tim = 'b0;
reg[$clog2(TIMEOUT) - 1 : 0] n_tim = 'b0;

reg[24:0] f_counter = 'b0;
reg[24:0] n_counter = 'b0;

reg[15:0] f_len = 'b0;
reg[15:0] n_len = 'b0;

reg[24:0] b_len = 'b0;
reg[24:0] bb_len = 'b0;

always@(posedge clk)
	b_len <= {(f_len - 1),9'b0};

always@(posedge clk)
	bb_len <= b_len;
	
always@(posedge clk)
	if(rst) begin
		f_tim <= 0;
		f_counter <= 0;
		f_len <= 0;
	end else
	begin
		f_tim <= n_tim;
		f_counter <= n_counter;
		f_len <= n_len;
	end
	
always@(*) begin
	irq = 0;
	nde_err = 'b0;
	
	n_counter = f_counter;
	n_len = f_len;
	
	
	if(f_tim == TIMEOUT - 1) 
		n_tim = f_tim;
	else
		n_tim = f_tim + 1;
	
	if(char_rdy | init) begin
		n_tim = 0;
		n_counter = f_counter + 1;
	end
	
	if(init) begin
		n_counter = 0;
		n_len = len;
		n_tim = 0;
	end
	
	if(f_tim == TIMEOUT - 2) begin
		irq = 1;
		
		if(f_counter < bb_len) begin
			nde_err = 1;
		end else
		begin
			nde_err = 0;
		end
		
	end 
	
	

end

endmodule

