module SPI_av_reader#(
	parameter OFFSET = 2'd0
)(
	input clk,
	input rst,
	
	input avs_s0_read,
	input[15:0] avs_s0_address,
	
	output reg[31:0] avs_s0_readdata = 'b0,
	output reg read_start = 'b0,
	
	input[7:0] read_data,
	input read_save
);

localparam READ_READ_BYTE = 3'h2;

reg[7:0] read_mem = 'b0;

always@(posedge clk)
	if(rst) begin
		avs_s0_readdata = 'b0;
		read_start = 1'b0;
	end else
	begin
		read_start = 1'b0;
		avs_s0_readdata = 'b0;
		if(avs_s0_read)
			case(avs_s0_address)
				{2'd0,1'b0,READ_READ_BYTE}: begin
					read_start = 1;
					avs_s0_readdata = read_mem;
				end
				default: avs_s0_readdata = 'b0;
			endcase
	end
	



always@(posedge clk)
	if(rst) read_mem = 'b0;
	else begin
		if(read_save) read_mem = read_data;
	end

	

endmodule
