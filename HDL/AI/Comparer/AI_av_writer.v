module AI_av_writer(
	input clk,
	input rst,
	
	input avs_s0_write,
	input avs_s0_read,
	input[3:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] r_mem_addr = 'b0,
	output reg init = 'b0,
	output reg compress = 'b0,
	output reg[15:0] load_sector = 'b0,
	output reg[15:0] load_len = 'b0,
	
	output reg[23:0] max = 'b0,
	
	output reg[14:0]	sample_size = 'b0,
	output reg[7:0]	packet_size = 'b0,
	
	output reg[7:0] score_minimum = 'b0
);

reg b_init = 'b0;
reg[15:0] b_load_sector = 'b0;
reg[15:0] b_load_len = 'b0;
	
always@(posedge clk)
	if(rst) begin
		init <= 'b0;
		
		load_sector <= 0;
		load_len <= 0;
	end else
	begin
		init <= b_init;
		
		
		load_sector <= b_load_sector;
		load_len <= b_load_len;
	end

always@(posedge clk)
	if(rst) begin
	
		b_init = 'b0;
		b_load_sector = 'b0;
		b_load_len = 'b0;
		
		sample_size = 'b0;
		packet_size = 'b0;
		
		max = 'b0;
		compress = 'b0;
		
		score_minimum = 'b0;
	end else
	begin
		b_init = 'b0;
		
		b_load_sector = 'b0;
		b_load_len = 'b0;
		
		if(avs_s0_write)
			case(avs_s0_address)
				0: begin
					b_init = 'b1;
					b_load_sector = avs_s0_writedata[31:16];
					b_load_len = avs_s0_writedata[15:0];
				end
				1: begin
					score_minimum = avs_s0_writedata[7:0];
				end
				2: begin
					sample_size = {avs_s0_writedata[14:0]};
					packet_size = avs_s0_writedata[23:16];
				end
				3: begin
					max = avs_s0_writedata[23:0];
				end
				4: begin
					compress = avs_s0_writedata[0];
				end
				default:;
			endcase		
	end
	
endmodule

