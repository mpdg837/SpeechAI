
module sig_saver(
	input clk,
	input rst,
	
	input start,
	input[31:0] start_addr_write,
	
	// DMA
	
	output reg[31:0] dma2_addr = 'b0,
	output reg dma2_read = 'b0,
	output reg dma2_write = 'b0,
	output reg[31:0] dma2_writedata = 'b0,	
	
	input[31:0] dma_readdata,
	input dma_rdy,
	
	// Stream
	
	input[15:0] profile_data,
	input profile_valid,
	output reg profile_rdy = 'b0,

	output reg irq = 'b0
);

reg f_save = 'b0;
reg n_save = 'b0;

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[9:0] f_counter = 'b0;
reg[9:0] n_counter = 'b0;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 = 'b0;

reg[15:0] f_mem2 = 'b0;
reg[15:0] n_mem2 = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		f_addr <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		
		f_save <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		f_addr <= n_addr;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		
		f_save <= n_save;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	n_addr = f_addr;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	
	n_save = f_save;
	dma2_addr = 'b0;
	dma2_read = 'b0;
	dma2_write = 'b0;
	dma2_writedata = 'b0;
	
	profile_rdy = 'b0;
	
	irq = 'b0;
	
	if(dma_rdy) begin
		n_save = 1'b1;
	end
			
	case(f_state)
		0: if(start) begin
			n_state = 1;
			n_counter = 'b0;
			n_addr = start_addr_write;
			
			n_mem1= 'b0;
			n_mem2 = 'b0;
			
			n_save = 'b1;
		end
		1: if(profile_valid) begin
			n_mem1 = profile_data;
			
			profile_rdy = 1'b1;
			n_counter = f_counter + 1;
			
			n_state = 2;
			
			
		end
		2: if(profile_valid) begin
			n_mem2 = profile_data;
			
			profile_rdy = 1'b1;
			n_counter = f_counter + 1;
			
			n_state = 3;
			
		end
		3: begin
			
			if(f_save)  begin

				
				if(f_counter == 320) begin
					n_state = 4;
				end else
				begin
					n_state = 5;
				end
				
				n_save = 'b0;
			end
		end
		4: begin
			irq = 1;
			n_state = 0;
		end
		5: begin
			dma2_write = 1'b1;
			dma2_addr = f_addr;
			dma2_writedata = {f_mem2,f_mem1};
				
			n_addr = f_addr + 4;
			
			n_state = 1;
		end
	endcase
end

endmodule
