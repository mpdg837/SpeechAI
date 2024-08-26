
module PWM_config(
	input clk,
	input rst,
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] startaddr = 'b0,
	output reg[31:0] stopaddr = 'b0,
	output reg[3:0] volume = 'b0,
	output reg start = 'b0,
	
	output reg avm_s0_irq = 1'b0,
	output reg stop = 1'b0,
	
	input irq
);

always@(posedge clk)
	if(rst) begin
		startaddr = 'b0;
		stopaddr = 'b0;
		start = 'b0;
		volume = 'b0;
		stop = 'b0;
		
	end else
	begin
		
		start = 'b0;
		stop = 'b0;
		if(avs_s0_write)
			case(avs_s0_address)
				1: startaddr = avs_s0_writedata[31:0];
				2: stopaddr = avs_s0_writedata[31:0];
				3: volume = avs_s0_writedata[3:0];
				4: start = 1'b1;
				5: stop = 1'b1;
				default:;
			endcase
			
	end

always@(posedge clk) 
	if(rst) begin
		avm_s0_irq = 1'b0;
	end else
	begin
		
		if(avs_s0_write)
			case(avs_s0_address)
				0: avm_s0_irq = 1'b0;
			endcase		
			
		if(irq)
			avm_s0_irq = 1'b1;
	end
	
endmodule