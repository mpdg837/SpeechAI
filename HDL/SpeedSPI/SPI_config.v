
module SPI_config(
	input clk,
	input rst,
	
	input avs_s0_write,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] startaddr = 'b0,
	output reg[15:0] len_sector = 'b0,
	output reg[15:0] sector = 'b0,
	output reg start = 'b0
	
);

always@(posedge clk)
	if(rst) begin
		startaddr = 'b0;
		len_sector = 'b0;
		sector = 'b0;
		start = 'b0;
	end else
	begin
		start = 1'b0;
		
		if(avs_s0_write)
			case(avs_s0_address)
				3'd5: startaddr = avs_s0_writedata;
				3'd6: begin
					len_sector = avs_s0_writedata[15:0];
					sector = avs_s0_writedata[31:16];
				end
				3'd7: start = 1'b1;
				default:;
			endcase
	end
	
endmodule
