
module SPI_multiplex(
	input clk,
	input rst,
	
	input[7:0] avs_s0_dout,
	input avs_s0_ivalid,
	output reg avs_s0_ready,
	
	input[7:0] avs_s1_dout,
	input avs_s1_ivalid,
	output reg avs_s1_ready,
	
	input[7:0] avs_s2_dout,
	input avs_s2_ivalid,
	output reg avs_s2_ready,
	
	input[7:0] avs_s3_dout,
	input avs_s3_ivalid,
	output reg avs_s3_ready,
	
	output reg[39:0] o_avs_s0_dout,
	output reg o_avs_s0_ivalid,
	input o_avs_s0_ready
);

always@(posedge clk) begin
	if(rst) begin
		o_avs_s0_dout = 0;
		o_avs_s0_ivalid = 0;	
	
		avs_s0_ready = 0;	
		avs_s1_ready = 0;	
		avs_s2_ready = 0;	
		avs_s3_ready = 0;	
		
	end else
	begin
		o_avs_s0_dout = 0;
		o_avs_s0_ivalid = 0;		

		avs_s0_ready = 0;	
		avs_s1_ready = 0;	
		avs_s2_ready = 0;	
		avs_s3_ready = 0;	
		
		if(avs_s0_ivalid | avs_s1_ivalid | avs_s2_ivalid | avs_s3_ivalid) begin
			
			if(avs_s0_ivalid) begin
				o_avs_s0_dout[32] = 1;
				o_avs_s0_dout[7:0] = avs_s0_dout;
			end

			if(avs_s1_ivalid) begin
				o_avs_s0_dout[33] = 1;
				o_avs_s0_dout[15:8] = avs_s1_dout;
			end

			if(avs_s2_ivalid) begin
				o_avs_s0_dout[34] = 1;
				o_avs_s0_dout[23:16] = avs_s2_dout;
			end

			if(avs_s3_ivalid) begin
				o_avs_s0_dout[35] = 1;
				o_avs_s0_dout[31:24] = avs_s3_dout;
			end
			
			o_avs_s0_ivalid = 1;	
		end
		
	end
end


endmodule