
module AI_status(
	input clk,
	input rst,
	
	input init,
	
	input crc_err,
	input tmr_err,
	input nde_err,
	input fifo_err,
	
	output reg tmr = 'b0,
	output reg crc = 'b0,
	output reg nde = 'b0,
	output reg fifo = 'b0

);

always@(posedge clk)
	if(rst) begin
		tmr = 'b0;
		crc = 'b0;
		nde = 'b0;
		fifo = 'b0;
	end else
	begin
		
		if(crc_err) begin
			crc = 'b1;
		end
		
		if(tmr_err) begin
			tmr = 'b1;
		end
		
		if(nde_err) begin
			nde = 'b1;
		end

		if(fifo_err) begin
			fifo = 'b1;
		end
		
		if(init) begin
			tmr = 'b0;
			crc = 'b0;
			nde = 'b0;
			fifo = 'b0;
		end
	end
	

endmodule

