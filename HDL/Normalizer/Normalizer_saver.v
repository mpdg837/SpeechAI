
module normalizer_saver(
	
	input clk,
	input rst,

	
	// Status
	input[31:0] start_addr,
	input[31:0] stop_addr,
	
	input[15:0] max_value,
	input start,
	input sqrt_normal,
	
	// out
	
	input[15:0] max,
	input[15:0] min,
	
	input[15:0] spect_data_1,
	input[15:0] spect_data_2,
	input spect_valid,
	
	output reg spect_rdy = 1'b0,
	
	// DMA
	
	output reg[31:0] dma_addr = 'b0,
	output reg dma_read = 'b0,
	output reg dma_write = 'b0,
	output reg[31:0] dma_writedata = 'b0,
	input[31:0] dma_readdata,
	input dma_rdy,
	
	output reg irq = 1'b0
);

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[7:0] f_counter = 'b0;
reg[7:0] n_counter = 'b0;

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 = 'b0;

reg[15:0] n_mem2 = 'b0;
reg[15:0] f_mem2 = 'b0;

reg f_save = 'b0;
reg n_save = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 0;
		
		f_mem1 <= 0;
		f_mem2 <= 0;
		
		f_addr <= 0;
		f_counter <= 0;
		
		f_save <= 0;
	end else
	begin
		f_state <= n_state;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		
		f_addr <= n_addr;
		f_counter <= n_counter;
		
		f_save <= n_save;
	end

always@(*) begin
	n_state = f_state;
	n_save = f_save;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	
	n_counter = f_counter;
	n_addr = f_addr;
	
	irq = 0;
	
	spect_rdy = 1'b0;

	dma_addr = 'b0;
	dma_read = 'b0;
	dma_write = 'b0;
	dma_writedata = 'b0;
	
	if(start) begin
		n_state = 0;
	
		n_mem1 = 0;
		n_mem2 = 0;
		
		n_counter = 0;
		n_addr = start_addr;
		
		n_save = 'b1;
	end
	
	if(dma_rdy) begin
		n_save = 1'b1;
	end
	
	case(f_state)
		0: if(spect_valid) begin
			n_mem1 = spect_data_1;
			n_mem2 = spect_data_2;
			
			spect_rdy = 1'b1;
			
			n_state = 1;
		end
		1: if(f_save) begin
			dma_addr = f_addr;
			dma_read = 'b0;
			dma_write = 'b1;
			dma_writedata = {f_mem1,f_mem2};

			n_state = 2;
			n_save = 'b0;
		end
		2: begin
		
				if(f_counter == 128 & sqrt_normal) begin
					n_counter = 0;
					n_addr = f_addr + 128;
				end else
				begin
					n_counter = f_counter + 1;
					n_addr = f_addr + 4;
				end
				
				if(f_addr == stop_addr) begin
					n_state =3;
				end else
				begin
					n_state = 0;
				end
				
		end
		3: begin
			irq = 1;
			n_state = 0;
		end
		
	
	endcase
end

endmodule