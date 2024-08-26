module AI_error_catcher(
	input clk,
	input rst,
	
	input init,
	input full,
	
	output reg error = 'b0
);

reg b_error = 'b0;
reg b_full = 'b0;

reg f_error = 'b0;
reg n_error = 'b0;

always@(posedge clk)
	if(rst) begin
		error <= 'b0;
		b_full <= 'b0;
	end else
	begin
		error <= b_error;
		b_full <= full;
	end
	
always@(posedge clk)
	if(rst) begin
		f_error <= 'b0;
	end else
	begin
		f_error <= n_error;
	end

reg last_full = 'b0;

always@(posedge clk)
	if(rst || init) begin
		last_full <= 'b0;
	end else
	begin
		last_full <= b_full;
	end
	
always@(*) begin
	n_error = f_error;
	
	b_error = f_error;
	
	if(init) begin
		n_error = 'b0;
	end
	
	if((~last_full) & b_full) begin
		n_error = 1'b1;
	end
	
	if((last_full) & b_full) begin
		n_error = 1'b0;
	end	
	
end

endmodule
