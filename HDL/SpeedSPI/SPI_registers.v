
module SPI_registers#(
	parameter OFFSET = 1
)(
	input clk,
	input rst,
	
	input[1:0] error,
	input success,
	
	input avs_s0_read,
	input[15:0] avs_s0_address,
	output reg[31:0] avs_s0_readdata = 'b0
);


localparam INIT = 3'h4;

reg[7:0] read_mem = 'b0;

always@(posedge clk)
	if(rst) begin
		avs_s0_readdata = 'b0;
		read_mem = 'b0;
	end else
	begin
		avs_s0_readdata = 'b0;
		
		if(success)
			read_mem = 8'h1;
		
		if(error == 2'b10) 
			read_mem = 8'h2;
		
		if(error == 2'b11)
			read_mem = 8'h3;
		
		if(avs_s0_read)
			case(avs_s0_address)
				{OFFSET + 1}: begin
					avs_s0_readdata = read_mem;
				end
				default: avs_s0_readdata = 'b0;
			endcase
	end
	
	
endmodule
