
module sig_dma(
	input clk,
	input rst,
	
	input[31:0] dma1_addr,
	input dma1_read,
	input dma1_write,
	input[31:0] dma1_writedata,
	
	output reg[31:0] dma_readdata = 'b0,
	output reg dma_rdy = 'b0,
	
	// DMA
	output reg avm_m1_write = 'b0,
	output reg avm_m1_read = 'b0,
	
	input avm_m1_waitrequest,
	input avm_m1_readdatavalid,
	
	output reg[31:0] avm_m1_address = 'b0,
	output reg[31:0] avm_m1_writedata = 'b0,
	
	input [31:0] avm_m1_readdata
	
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[31:0] f_mem = 'b0;
reg[31:0] n_mem = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_state <= 'b0;
		f_mem <= 'b0;
		f_addr <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_mem <= n_mem;
		f_addr <= n_addr;
		
	end
end 

always@(*) begin
	n_state = f_state;
	
	n_mem = f_mem;
	n_addr = f_addr;

	avm_m1_write = 'b0;
	avm_m1_read = 'b0;
	avm_m1_address = 'b0;
	avm_m1_writedata = 'b0;

	dma_readdata = 'b0;
	dma_rdy = 'b0;	
	
	case(f_state)
		0: begin
			if(dma1_read) begin
				n_addr = dma1_addr;
				n_mem = 'b0;
				n_state = 1;
			end 
			
			if(dma1_write)
			begin
				n_addr = dma1_addr;
				n_mem = dma1_writedata;
				n_state = 4;
			end
			
		end
		1: begin
			avm_m1_read = 'b1;
			avm_m1_address = f_addr;
			
			if(~avm_m1_waitrequest) begin
				n_state = 2;
			end
			
		end
		2: begin
			
			if(avm_m1_readdatavalid) begin
				n_mem = avm_m1_readdata;
				n_state = 3;
			end
		end
		3: begin
			dma_readdata = f_mem;
			dma_rdy = 'b1;		
			n_state = 0;
		end
		4: begin
			avm_m1_write = 'b1;
			avm_m1_address = f_addr;		
			avm_m1_writedata = f_mem;
			
			if(~avm_m1_waitrequest) begin
				n_state = 5;
			end
		end
		5: begin
			dma_rdy = 1'b1;
			n_state = 0;
		end
	endcase
end
	

endmodule
