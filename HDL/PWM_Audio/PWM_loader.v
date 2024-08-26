
module PWM_loader(
	input clk,
	input rst,
	
	input start,
	input stop,
	
	input[31:0] startaddr,
	input[31:0] stopaddr,
	
	output reg[15:0] sound = 'b0,
	output reg sound_valid = 'b0,
	input sound_rdy,
	
	// DMA
	
	output reg[31:0] dma_addr = 'b0,
	output reg dma_read = 'b0,
	output reg dma_write = 'b0,
	output reg[31:0] dma_writedata = 'b0,
	input[31:0] dma_readdata,
	input dma_rdy,
	
	output reg irq = 1'b0
	
);

reg[31:0] b_startaddr = 'b0;
reg[31:0] b_stopaddr = 'b0;
reg b_start = 'b0;
reg b_stop = 'b0;

always@(posedge clk)
	if(rst) begin
		b_startaddr <= 'b0;
		b_stopaddr <= 'b0;
		b_start <= 'b0;	
		b_stop <= 'b0;
	end else
	begin
		b_startaddr <= startaddr;
		b_stopaddr <= stopaddr;
		b_start <= start;	
		b_stop <= stop;	
	end
	
reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[15:0] f_mem_1 = 'b0;
reg[15:0] n_mem_1 = 'b0;

reg[15:0] f_mem_2 = 'b0;
reg[15:0] n_mem_2 = 'b0;

reg b_irq = 'b0;

reg f_irq = 'b0;
reg n_irq = 'b0;

reg f_stopped = 'b1;
reg n_stopped = 'b1;

always@(posedge clk)
	if(rst) begin
		irq <= 'b0;
	end else
	begin
		irq <= b_irq;
	end
	
always@(posedge clk)
	if(rst) begin
		f_state <= 0;
		
		f_addr <= 0;
		f_mem_1 <= 0;
		f_mem_2 <= 0;
		
		f_irq <= 'b0;
		
		f_stopped <= 'b1;
	end else
	begin
		f_state <= n_state;
		
		f_addr <= n_addr;
		f_mem_1 <= n_mem_1;
		f_mem_2 <= n_mem_2;
		
		f_irq <= n_irq;
		
		f_stopped <= n_stopped;
	end

reg[15:0] b_sound = 'b0;
reg b_w = 'b0;

always@(*) begin
	n_state = f_state;
	n_irq = f_irq;
	
	n_addr = f_addr;
	n_mem_1 = f_mem_1;
	n_mem_2 = f_mem_2;
	
	n_stopped = f_stopped;
	
	b_sound = 'b0;
	b_w = 'b0;
	
	dma_addr = 'b0;
	dma_read = 'b0;
	
	b_irq = 'b0;
	
	if(b_stop) begin
		n_stopped = 1'b1;
	end
	
	case(f_state)
		0: if(b_start) begin
			
			n_stopped = 'b0;
			
			n_addr = b_startaddr;
			n_state = 1;
			n_irq = 0;
			
		end
		1: begin
			dma_addr = f_addr;
			dma_read = 1;
			n_state = 2;
		end
		2: if(dma_rdy) begin
			
			n_mem_1 = dma_readdata[15:0];
			n_mem_2 = dma_readdata[31:16];
			
			if(f_stopped)
				n_state = 6;
			else
				n_state = 3;
		end
		3: begin
			b_sound = f_mem_1;
			b_w = 1;
			
			if(sound_rdy)
				n_state = 4;
		end
		4: begin
			b_sound = f_mem_2;
			b_w = 1;	
		
			if(sound_rdy)
				n_state = 5;
			
		end
		5: begin
			n_addr = f_addr + 4;
			
			if(f_addr == b_stopaddr) begin
				n_state = 6;
			end else
			begin
				n_state = 1;
			end
		end
		6: begin
			
			b_irq = 'b1;
			n_stopped = 'b1;
			
			n_state = 0;
		end
	endcase
	
end

always@(posedge clk)
	if(rst) begin
		sound <= 0;
		sound_valid <= 0;
	end
	else begin
		sound <= b_sound;
		sound_valid <= b_w;
	end
	
endmodule
