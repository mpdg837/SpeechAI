
module sig_loader(
	input clk,
	input rst,
	
	input start,
	input[31:0] start_addr_read,
	
	// DMA
	
	output reg[31:0] dma1_addr,
	output reg dma1_read,
	output reg dma1_write,
	output reg[31:0] dma1_writedata,	
	
	input[31:0] dma_readdata,
	input dma_rdy,
	
	// Stream
	
	output reg[15:0] audio_data = 'b0,
	output reg audio_valid = 'b0,
	input audio_rdy

);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[9:0] f_counter = 'b0;
reg[9:0] n_counter = 'b0;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[31:0] f_mem_next = 'b0;
reg[31:0] n_mem_next = 'b0;

reg[31:0] f_mem_act = 'b0;
reg[31:0] n_mem_act = 'b0;

reg f_read = 'b0;
reg n_read = 'b0;

reg f_start = 'b0;
reg n_start = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		f_addr <= 'b0;
		
		f_mem_next <= 'b0;
		f_mem_act <= 'b0;
		
		f_read <= 'b0;
		f_start <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		f_addr <= n_addr;
		
		f_mem_next <= n_mem_next;
		f_mem_act <= n_mem_act;
		
		f_read <= n_read;
		f_start <= n_start;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	n_addr = f_addr;
	
	n_mem_act = f_mem_act;
	n_mem_next = f_mem_next;
	
	n_read = f_read;
	n_start = f_start;
	
	dma1_addr = 'b0;
	dma1_read = 'b0;
	dma1_write = 'b0;
	dma1_writedata = 'b0;
	
	audio_data = 'b0;
	audio_valid = 'b0;
	
	if(dma_rdy) begin
		n_mem_next = dma_readdata;
		n_read = 1'b1;
	end
			
	case(f_state)
		0: if(start) begin
			n_state = 1;
			n_counter = 'b0;
			n_addr = start_addr_read;
			
			n_mem_act = 'b0;
			n_mem_next = 'b0;
			
			n_start = 'b0;
			n_read = 'b0;
		end
		1: begin
			dma1_addr = f_addr;
			dma1_read = 'b1;
			dma1_write = 'b0;
			dma1_writedata = 'b0;
			
			n_read = 'b0;
			
			if(f_start) begin
				n_state = 2;
			end else
			begin
				n_state = 4;
			end
		end
		
		2: begin
			audio_data = f_mem_act[15:0];
			audio_valid = 1'b1;
			
			if(audio_rdy) begin
				n_state = 3;
				n_counter = f_counter + 1;
			end
			
		
		end
		3: begin
			audio_data = f_mem_act[31:16];
			audio_valid = 1'b1;
			
			if(audio_rdy) begin
				n_state = 4;
				n_counter = f_counter + 1;
			end
			
		end
		4: begin
			
			n_start = 1'b1;
			
			if(f_read) begin
				n_addr = f_addr + 4;
				n_mem_act = f_mem_next;
			
				if(f_counter == 512) begin
					n_state = 0;
				end else
				begin
					n_state = 1;
				end
			end
		end
	endcase
end

endmodule
