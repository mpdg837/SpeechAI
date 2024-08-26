

module AI_interrupt(
	input clk,
	input rst,
	
	input irq_in1,
	input irq_in2,
	input irq_in3,
	input irq_in4,
	
	input avs_s0_write,
	input avs_s0_read,
	input[3:0] avs_s0_address,
	
	output reg avm_s0_irq = 1'b0
);

reg i1 = 'b0;
reg i2 = 'b0;
reg i3 = 'b0;
reg i4 = 'b0;


always@(posedge clk)
	if(rst) begin
		 avm_s0_irq = 1'b0;
		 
		 i1 = 'b0;
		 i2 = 'b0;
		 i3 = 'b0;
		 i4 = 'b0;
		 
	end else
	begin
		
		if(i1 & i2 & i3 & i4) begin
			
			avm_s0_irq = 1'b1;
			
			i1 = 0;
			i2 = 0;
			i3 = 0;
			i4 = 0;
			
		end
		
		if(irq_in1) begin
			i1 = 1;
		end

		if(irq_in2) begin
			i2 = 1;
		end

		if(irq_in3) begin
			i3 = 1;
		end

		if(irq_in4) begin
			i4 = 1;
		end
		
		if(avs_s0_write )
			case(avs_s0_address)
				5: avm_s0_irq = 1'b0;
			
			endcase
	end
	
endmodule
