
module normalizer_parameters(
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
	output reg[31:0] start_addr = 'b0,
	output reg[31:0] stop_addr = 'b0,

	output reg start = 'b0,
	output reg sqrt_normal = 'b0,
	output reg[15:0] max_value = 'b0,
	
	output reg [15:0] area1 = 'b0,
	output reg [15:0] area2 = 'b0
	
);

always@(posedge clk)
	if(rst) begin
		start_addr = 'b0;
		stop_addr = 'b0;
		sqrt_normal = 'b0;
		start = 'b0;

		max_value = 'b0;
		
		area1 = 'b0;
		area2 = 'b0;
	end else
	begin
		
		start = 'b0;
		
		if(avs_s0_write)
			case(avs_s0_address)
				1: max_value = avs_s0_writedata[15:0];
				2: start_addr = avs_s0_writedata;
				3: stop_addr = avs_s0_writedata;
				4:	start = 'b1;
				5: sqrt_normal = avs_s0_writedata;
				6: begin
					area1 =  avs_s0_writedata[15:0];
					area2 =  avs_s0_writedata[31:16];
				end
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
