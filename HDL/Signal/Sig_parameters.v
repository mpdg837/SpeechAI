


module sig_parameters(
	input clk,
	input rst,
	
	output reg avm_s0_irq = 'b0,
	input irq,
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata = 'b0,	
	
	// Registers
	output reg[31:0] start_addr_read = 'b0,
	output reg[31:0] start_addr_write = 'b0,

	output reg start = 'b0
);

always@(posedge clk)
	if(rst) begin
		start_addr_write = 'b0;
		start_addr_read = 'b0;

		start = 'b0;

	end else
	begin
		
		start = 'b0;
		
		if(avs_s0_write)
			case(avs_s0_address)
				1: start_addr_read = avs_s0_writedata;
				2: start_addr_write = avs_s0_writedata;
				3:	start = 'b1;
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
