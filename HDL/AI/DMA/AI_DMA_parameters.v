
module dma_parameters(
	input clk,
	input rst,
	
	output reg avm_s0_irq = 'b0,
	input irq,
	
	input avs_s0_write,
	input avs_s0_read,
	input[3:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata = 'b0,	
	
	// Registers
	output reg[31:0] start_addr_block = 'b0,
	output reg[31:0] stop_addr_block = 'b0,
	
	output reg[31:0] start_addr_read = 'b0,
	
	output reg[15:0] data_len = 'b0,
	
	output reg[7:0] minimum1 = 'b0,
	output reg[7:0] minimum2 = 'b0,
	
	output reg[7:0] wage1 = 'b0,
	output reg[7:0] wage2 = 'b0,
	
	
	output reg[15:0] line_width = 'b0,
	output reg[15:0] region_width = 'b0,
	
	output reg shift = 'b0,
	output reg start = 'b0
);

always@(posedge clk)
	if(rst) begin
		start_addr_block = 'b0;
		stop_addr_block = 'b0;
		
		start_addr_read = 'b0;
		
		data_len = 'b0;
		minimum1 = 'b0;
		minimum2 = 'b0;

		wage1 = 'b0;
		wage2 = 'b0;
		
		start = 'b0;
		shift = 'b0;

		line_width = 'b0;
		region_width = 'b0;	
	end else
	begin
		
		start = 'b0;
		
		if(avs_s0_write)
			case(avs_s0_address)
				1: start_addr_block = avs_s0_writedata[31:0];
				2: stop_addr_block = avs_s0_writedata[31:0];
				3: data_len = avs_s0_writedata[15:0];
				4: begin
						minimum1 = avs_s0_writedata[7:0];
						minimum2 = avs_s0_writedata[15:8];
						shift = avs_s0_writedata[16];
					end
				5: begin
						wage1 = avs_s0_writedata[7:0];
						wage2 = avs_s0_writedata[15:8];
					end					
				6: start_addr_read = avs_s0_writedata[31:0];
				7:	start = 'b1;
				8: line_width = avs_s0_writedata[15:0];
				9: region_width = avs_s0_writedata[15:0];
				default:;
			endcase
	end

always@(posedge clk)
	if(rst) begin
		avm_s0_irq = 'b0;
	end else
	begin
		
		if(irq) begin
			avm_s0_irq = 1'b1;
		end
		
		if(avs_s0_write)
			case(avs_s0_address)
				0: avm_s0_irq = 1'b0;
			endcase
	end
	
endmodule



