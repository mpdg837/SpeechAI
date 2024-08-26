

module normalizer_controller(
	
	input clk,
	input rst,

	
	// Status
	input[31:0] start_addr,
	input[31:0] stop_addr,
	
	input[15:0] max_value,
	input start,
	input sqrt_normal,
	
	input[15:0] area1,
	input[15:0] area2,
	
	// out
	
	output reg[15:0] max,
	output reg[15:0] min,
	
	output reg[15:0] spect_data_1 = 'b0,
	output reg[15:0] spect_data_2 = 'b0,
	output reg spect_valid = 'b0,
	
	input spect_rdy,
	
	// DMA
	
	output reg[31:0] dma_addr = 'b0,
	output reg dma_read = 'b0,
	output reg dma_write = 'b0,
	output reg[31:0] dma_writedata = 'b0,
	input[31:0] dma_readdata,
	input dma_rdy
	
	
);

reg b_sqrt_normal = 'b0;

always@(posedge clk)
	if(rst) begin
		b_sqrt_normal <= 'b0;
	end else
	begin
		b_sqrt_normal <= sqrt_normal;
	end
	
	
reg f_minus1;
reg n_minus1;

reg f_minus2;
reg n_minus2;

reg[3:0] f_state;
reg[3:0] n_state;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[7:0] f_counter = 'b0;
reg[7:0] n_counter = 'b0;

reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 ='b0;

reg[15:0] f_mem2 = 'b0;
reg[15:0] n_mem2 = 'b0;



reg[15:0] f_max1 = 'b0;
reg[15:0] n_max1 = 'b0;


reg[15:0] f_max2 = 'b0;
reg[15:0] n_max2 = 'b0;

reg[15:0] f_max = 'b0;
reg[15:0] n_max = 'b0;


always@(posedge clk)
	if(rst) begin
		f_state <= 0;
		f_addr <= 0;
		
		f_mem1 <= 0;
		f_mem2 <= 0;

		f_counter <= 0;
		
		f_max1 <= 0;
		f_max2 <= 0;
		
		f_max <= 0;
	end else
	begin
		f_state <= n_state;
		f_addr <= n_addr;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		
		f_counter <= n_counter;
		
		f_max1 <= n_max1;
		f_max2 <= n_max2;

		f_max <= n_max;
		
	end

always@(*) begin
	
	n_max = f_max;
	
	max = f_max;
	
	if(f_state == 0) begin
		n_max = 0;
	
	end

	if(f_max1 > f_max2) begin
		n_max = f_max1;
	end else
	begin
		n_max = f_max2;
	end
	
end	
always@(*) begin

	n_state = f_state;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;

	n_counter = f_counter;
	n_addr = f_addr;
	
	n_max1 = f_max1;
	n_max2 = f_max2;

	dma_addr = 'b0;
	dma_read = 'b0;
	dma_write = 'b0;
	dma_writedata = 'b0;
	
	spect_data_1 = 'b0;
	spect_data_2 = 'b0;
	spect_valid = 'b0;
	

				
	case(f_state) 
		0: if(start) begin
				n_state = 1;
				n_addr = start_addr;
				
				n_max1 = 'b0;
				n_max2 = 'b0;
				
				n_counter = 'b0;
			end
		1: begin
				dma_addr = f_addr;
				dma_read = 1'b1;
				n_state = 2;
			end
		2: begin
				if(dma_rdy) begin
					
					
					if(dma_readdata[31]) begin
						n_mem1 = (~dma_readdata[31:16]) + 1;
					end else
					begin
						n_mem1 = dma_readdata[31:16];
					end
					
					if(dma_readdata[15]) begin
						n_mem2 = (~dma_readdata[15:0]) + 1;
					end else
					begin
						n_mem2 = dma_readdata[15:0];
					end
					
					n_state = 3;
				
				end
				
			
			end
		3: begin
				if(f_max1 < f_mem1) begin
					n_max1 = f_mem1;
				end
				
				
				if(f_max2 < f_mem2) begin
					n_max2 = f_mem2;
				end

				
					
				if((f_counter == area1[8:1]) & b_sqrt_normal) begin
					n_counter = 0;
					n_addr = f_addr + {area2,1'b0};
				end else
				begin
					n_counter = f_counter + 1;
					n_addr = f_addr + 4;
				end
				
				
				if(f_addr == stop_addr) begin
					n_state = 4;
					n_addr = start_addr;
					n_counter = 0;
				end else
				begin
					n_state = 1;
				end
				
			end
		4: begin
				
				dma_addr = f_addr;
				dma_read = 1'b1;
				n_state = 5;
			end
		5: begin
				if(dma_rdy) begin
					
					
					n_mem1 = dma_readdata[31:16];
					n_mem2 = dma_readdata[15:0];
				
					n_state = 6;
				end
				
				
			end
			
		6: begin
				spect_data_1 = f_mem1;
				spect_data_2 = f_mem2;
				spect_valid = 'b1;
				
				if(spect_rdy) begin
					n_state = 7;
				end
			end
			
		7: begin
				
				if((f_counter == area1[8:1]) & b_sqrt_normal) begin
					n_counter = 0;
					n_addr = f_addr + {area2,1'b0};
				end else
				begin
					n_counter = f_counter + 1;
					n_addr = f_addr + 4;
				end
				
				if(f_addr == stop_addr) begin
					n_state =8;
				end else
				begin
					n_state = 4;
				end
				
			end
		8: begin
				n_state = 0;
			end
	endcase
end
	
endmodule
