
module BLEUART_error_catcher(
	input clk,
	input rst,
	
	input uart_in_error,
	input start,
	
	output reg irq = 'b0,
	output reg error = 'b0
);

reg f_error = 'b0;
reg n_error = 'b0;

always@(posedge clk)
	if(rst) begin
		f_error <= 'b0;
	end else
	begin
		f_error <= n_error;
	end
	
always@(*) begin
	
	n_error = f_error;
	
	irq = 'b0;
	error = f_error;
	
	if(start) begin
		n_error = 'b0;
	end
	
	if(uart_in_error) begin
		n_error = 1'b1;
		irq = 'b1;
	end
	
end

endmodule
