
module SPI_av_writer#(
	parameter OFFSET = 2'd0
)(
	input clk,
	input rst,
	
	input avs_s0_write,
	input[15:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg close = 1'b0,

	output reg init_c = 1'b0,
	output reg init_p = 1'b0,
	output reg[31:0] init_len = 10'b0,

	output reg com_start = 1'b0,
	output reg[7:0] com_cmd = 'b0,
	output reg[23:0] com_arg = 'b0,
	
	output reg[1:0] speed = 'b0
);

localparam COMMAND = 3'h1;
localparam CLOSE = 3'h3;
localparam INIT = 3'h4;
localparam OPEN = 3'h5;
localparam SPEED = 3'h6;

always@(posedge clk)
	if(rst) begin
		
		
		com_start = 1'b0;
		com_cmd = 'b0;
		com_arg = 'b0;
		
		init_c = 1'b0;
		init_p = 1'b0;
		init_len = 8'b0;
		
		close = 1'b0;
		
		speed = 'b1;
	end else
	begin
		com_start = 1'b0;
		com_cmd = 'b0;
		com_arg = 'b0;
		
		
		init_c = 1'b0;
		init_p = 1'b0;
		init_len = 1'b0;
		
		close = 1'b0;
		if(avs_s0_write)
			case(avs_s0_address)
				{2'd0,1'b0,COMMAND}: begin
					com_start = 1;
					com_cmd = avs_s0_writedata[31:24];
					com_arg = avs_s0_writedata[23:0];
				end
				{2'd0,1'b0,CLOSE}: begin
					close = 1'b1;
				end
				{2'd0,1'b0,INIT}: begin
					init_c = 1'b1;
				end
				{2'd0,1'b0,OPEN}: begin
					init_p = 1'b1;
					init_len = avs_s0_writedata[31:0];
				end
				{2'd0,1'b0,SPEED}: begin
					speed = avs_s0_writedata[1:0];
				end
				default:;
			endcase
		
	end
	
	
endmodule
