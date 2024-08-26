module dma_loader(
	input clk,
	input rst,
	
	input start,
	input shift,
	
	output reg irq = 'b0,
	
	input[31:0] start_addr_read,
	
	input[31:0] start_addr_block,
	input[31:0] stop_addr_block,
	
	input[15:0] data_len,
	
	
	output reg 		  avs_m1_valid = 'b0,
	output reg[31:0] avs_m1_data = 'b0,
	output reg		  avs_m1_startofpacket = 'b0,
	output reg		  avs_m1_endofpacket = 'b0,
	input	 		  	  avs_m1_ready,

	output reg[31:0] dma1_addr = 'b0,
	output reg dma1_read = 'b0,
	output reg dma1_write = 'b0,
	output reg[31:0] dma1_writedata = 'b0,	
	
	input[31:0] dma1_readdata,
	input dma1_rdy
		
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[15:0] f_counter = 'b0;
reg[15:0] n_counter = 'b0;

reg[7:0] f_mem1 = 'b0;
reg[7:0] f_mem2 = 'b0;
reg[7:0] f_mem3 = 'b0;
reg[7:0] f_mem4 = 'b0;

reg[7:0] n_mem1 = 'b0;
reg[7:0] n_mem2 = 'b0;
reg[7:0] n_mem3 = 'b0;
reg[7:0] n_mem4 = 'b0;

	
reg[31:0] b_start_addr_read = 'b0;
reg[31:0] b_start_addr_block = 'b0;
reg[31:0] b_stop_addr_block = 'b0;
reg[15:0] b_data_len = 'b0;

reg b_start = 'b0;
reg b_shift = 'b0;

always@(posedge clk)
	if(rst) begin
		b_start <= 'b0;
		
		b_start_addr_read <= 'b0;
		b_start_addr_block <= 'b0;
		b_stop_addr_block <= 'b0;
		b_data_len <= 'b0;
		
		b_shift <= 0;
	end else
	begin
		b_start <= start;
		
		b_start_addr_read <= start_addr_read;
		
		b_start_addr_block <= start_addr_block;
		b_stop_addr_block <= stop_addr_block;
		
		b_data_len <= data_len;
		
		b_shift <= shift;
	end
always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_addr <= 'b0;
		f_counter <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		f_mem3 <= 'b0;
		f_mem4 <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_addr <= n_addr;
		f_counter <= n_counter;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		f_mem3 <= n_mem3;
		f_mem4 <= n_mem4;
	end
	
always@(*) begin
	n_state = f_state;
	
	n_addr = f_addr;
	n_counter = f_counter;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	n_mem3 = f_mem3;
	n_mem4 = f_mem4;
	
	irq = 0;
	
	dma1_addr = 'b0;
	dma1_read = 'b0;
	dma1_write = 'b0;
	dma1_writedata = 'b0;
	
	avs_m1_valid = 'b0;
	avs_m1_data = 'b0;
	avs_m1_startofpacket = 'b0;
	avs_m1_endofpacket = 'b0;
	
	case(f_state)
		0: if(b_start) begin
			
			n_counter = 0;
			n_addr = b_start_addr_read;
			
			n_mem1 = 'b0;
			n_mem2 = 'b0;
			n_mem3 = 'b0;
			n_mem4 = 'b0;
			
			n_state = 1;
		end
		1: begin
				dma1_addr = f_addr;
				dma1_read = 'b1;
				dma1_write = 'b0;
				dma1_writedata = 'b0;
				n_state = 2;
				
			end
		2: begin
				if(dma1_rdy) begin
					
						if(b_shift)
							n_mem2 = dma1_readdata[25:18];
						else
							n_mem2 = dma1_readdata[23:16];
				

						if(b_shift)
							n_mem1 = dma1_readdata[10:2];
						else
							n_mem1 = dma1_readdata[8:0];
				
					
					if(b_stop_addr_block == f_addr) begin
						n_addr = b_start_addr_block;
					end else
					begin
						n_addr = f_addr + 4;
					end
					
					n_counter = f_counter + 4;
					
					n_state = 3;
				end
		end
		3: begin
				dma1_addr = f_addr;
				dma1_read = 'b1;
				dma1_write = 'b0;
				dma1_writedata = 'b0;
				
				n_state = 4;
			end
		4: begin
				if(dma1_rdy) begin
					
						if(b_shift)
							n_mem4 = dma1_readdata[25:18];
						else
							n_mem4 = dma1_readdata[23:16];
					
				

						if(b_shift)
							n_mem3 = dma1_readdata[10:2];
						else
							n_mem3 = dma1_readdata[7:0];
					
					if(b_stop_addr_block == f_addr) begin
						n_addr = b_start_addr_block;
					end else
					begin
						n_addr = f_addr + 4;
					end
					
					n_counter = f_counter + 4;
					
					n_state = 5;
				end
			end
		5: begin
				avs_m1_valid = 'b1;
				avs_m1_data = {f_mem4,f_mem3,f_mem2,f_mem1};
				
				if(f_counter == 8) begin
					avs_m1_startofpacket = 'b1;
				end else
				begin
					avs_m1_startofpacket = 'b0;
				end
				
				if(f_counter == b_data_len) begin
					avs_m1_endofpacket = 'b1;
					
					if(avs_m1_ready) begin
						n_state = 6;
					end
					
				end else
				begin
					avs_m1_endofpacket = 'b0;
					
					if(avs_m1_ready) begin
						n_state = 1;
					end
				end
		
			end
		6: begin
			
			irq = 1'b1;
			
			n_state = 0;
		end
	endcase
	
end


endmodule