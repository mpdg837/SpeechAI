
module SPI_av_irq#(
	parameter OFFSET = 2'd0
)(
	input clk,
	input rst,
	
	input avs_s0_write,
	input[15:0] avs_s0_address,
		
	input irq,
	
	output reg avm_s0_irq = 'b0
);

localparam IRQ_RET = 3'h0;

always@(posedge clk)
	if(rst) begin
		avm_s0_irq = 1'b0;
	end else
	begin
		
		if(avs_s0_write)
			case(avs_s0_address)
				{2'd0,1'b0,IRQ_RET}: avm_s0_irq = 1'b0;
			endcase
		
		if(irq)
			avm_s0_irq = 1'b1;
	end
	
endmodule
