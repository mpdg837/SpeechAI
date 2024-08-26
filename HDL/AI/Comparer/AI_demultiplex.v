
module AI_demultiplex(
	input clk,
	input rst,
	
	input init,
	
	input[39:0] avs_s2_inout,
	input avs_s2_valid,
	output reg avs_s2_ready = 1'b0,
	
	output reg[7:0] data1 = 'b0,
	output reg data1_rdy = 'b0,
	
	output reg[7:0] data2 = 'b0,
	output reg data2_rdy = 'b0,
	
	output reg[7:0] data3 = 'b0,
	output reg data3_rdy = 'b0,
	
	output reg[7:0] data4 = 'b0,
	output reg data4_rdy = 'b0
);



always@(posedge clk)
	if(rst) begin
		data1 = 'b0;
		data1_rdy = 'b0;

		data2 = 'b0;
		data2_rdy = 'b0;
	
		data3 = 'b0;
		data3_rdy = 'b0;
	
		data4 = 'b0;
		data4_rdy = 'b0;
		
		avs_s2_ready = 1'b0;
	end else
	begin
		data1 = 'b0;
		data1_rdy = 'b0;

		data2 = 'b0;
		data2_rdy = 'b0;
	
		data3 = 'b0;
		data3_rdy = 'b0;
	
		data4 = 'b0;
		data4_rdy = 'b0;
		
		avs_s2_ready = 1'b0;
	
		if(avs_s2_valid) begin
				
			if(avs_s2_inout[32]) begin
				data1_rdy = 'b1;
				data1 = avs_s2_inout[7:0];
			end

			if(avs_s2_inout[33]) begin
				data2_rdy = 'b1;
				data2 = avs_s2_inout[15:8];
			end
		

			if(avs_s2_inout[34]) begin
				data3_rdy = 'b1;
				data3 = avs_s2_inout[23:16];
			end
				
			
			if(avs_s2_inout[35]) begin
				data4_rdy = 'b1;
				data4 = avs_s2_inout[31:24];
			end
					
		end
		
	end
	


endmodule