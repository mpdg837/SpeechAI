module AI_QCRC_sum(
	input clk,
	input rst,
	
	input[31:0] crc1,
	input[31:0] crc2,
	input[31:0] crc3,
	input[31:0] crc4,
	
	output reg[33:0] crc = 'b0
);

reg[33:0] crc01 = 'b0;
reg[33:0] crc02 = 'b0;

reg[33:0] b_crc = 'b0;

always@(posedge clk)
	if(rst) begin
		crc <= 'b0;
		

	end else
	begin
		crc <= b_crc;
		

		
	end
	
always@(posedge clk)
	if(rst) begin
		b_crc <= 'b0;
	end else
	begin
		b_crc <= crc01 + crc02;
	end
	
always@(posedge clk)
	if(rst) begin
		crc01 <= 'b0;
		crc02 <= 'b0;	
	end else
	begin
		crc01 <= crc1 + crc2;
		crc02 <= crc3 + crc4;	
	end
	


endmodule
