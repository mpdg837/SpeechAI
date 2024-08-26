
module SPI_output(
	input clk,
	input rst,
	
	input error,
	
	input avs_s0_write,
	input avs_s0_read,
	input[11:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] avs_s0_readdata = 'b0,
	
	input[31:0] crc_out
);

always@(posedge clk)
	if(rst) begin
		avs_s0_readdata = 'b0;
	end else
	begin
		avs_s0_readdata = 'b0;
		
		if(avs_s0_read)
			case(avs_s0_address)
				6: 		avs_s0_readdata = error;
				7: 		avs_s0_readdata = crc_out;
				default: avs_s0_readdata = 'b0;
			endcase
		
	end
	
endmodule
