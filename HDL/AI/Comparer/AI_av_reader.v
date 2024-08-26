
module AI_av_reader(
	input clk,
	input rst,
	
	input avs_s0_write,
	input avs_s0_read,
	input[3:0] avs_s0_address,
	
	output reg[31:0] avs_s0_readdata,
	
	input init,
	
	input[31:0] counter,
	input[7:0] mem_out,
	
	input tmr,
	input crc,
	input nde,
	input fifo,
	
	input[31:0] crc_in,
	
	input[31:0] sum_out,
	input sum_out_rdy,
	
	input[31:0] reg1,
	input[31:0] reg2,
	
	input[3:0] max
	
	
);

reg[31:0] mem[7:0];

reg[2:0] addr = 'b0;

always@(posedge clk) 
	if(rst) begin
		addr = 'b0;
	end else
	begin
			
		if(sum_out_rdy) begin
			mem[addr] = sum_out;
			
			addr = addr + 1;
		end
		
		if(init)
			addr = 0;
		
		
	end
	
always@(posedge clk)
	if(rst) begin
		avs_s0_readdata = 'b0;
	end else
	begin
	
		
		avs_s0_readdata = 'b0;
		
		if(avs_s0_read )
			case(avs_s0_address)
				0: begin
						avs_s0_readdata = mem_out;
						
					end
				2: begin
						avs_s0_readdata = counter;
					end
				3: begin
						avs_s0_readdata = {fifo,nde,tmr,crc};
					end
				4: begin
						avs_s0_readdata = mem[0];
					end
				5: begin
						avs_s0_readdata = mem[1];
					end
				6: begin
						avs_s0_readdata = mem[2];
					end
				7: begin
						avs_s0_readdata = mem[3];
					end
				8: begin
						avs_s0_readdata = mem[4];
					end
				9: begin
						avs_s0_readdata = mem[5];
					end
			  10: begin
						avs_s0_readdata = mem[6];
					end
			  11: begin
						avs_s0_readdata = mem[7];
					end
					
			  12: begin
						avs_s0_readdata = reg1;
					end
			  13: begin
						avs_s0_readdata = reg2;
					end 
			  14: begin
						avs_s0_readdata = max;
					end
			  15: begin
						avs_s0_readdata = crc_in;
					end
				default:;
			endcase
		
	end
	
endmodule
