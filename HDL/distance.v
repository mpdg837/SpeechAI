module Distance(
	input csi_clk,
	input rsi_reset_n,
	
	output avm_s0_irq,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] avs_s0_readdata = 'b0,
	
	// Button
	
	input button,
	input vbutton,
	
	// Microphone
	input d0,
	output reg a0 = 'b0,
	
	output[9:0] gpio_out
);

reg[3:0] status_gpio = 'b0;

wire clk = csi_clk;
wire rst = ~rsi_reset_n;

always@(posedge clk)
	if(rst) begin
		a0 <= 'b0;
		status_gpio <= 'b0;
	end else
	begin
		
		if(avs_s0_write) begin
			case(avs_s0_address)
				0: begin
					a0 <= avs_s0_writedata[0];
				end
				1: begin
					status_gpio <= avs_s0_writedata[3:0];
				end
				
			endcase
		end
		
	end

	
always@(posedge clk)
	if(rst) begin
		avs_s0_readdata <= 'b0;
	end else
	begin
		
		if(avs_s0_read) begin
			case(avs_s0_address)
				2: begin
					avs_s0_readdata <= d0;
				end
				3: begin
					avs_s0_readdata <= {vbutton,button};
				end
				default: begin
					avs_s0_readdata <= 'b0;
				end
			endcase
		end else
		begin
			avs_s0_readdata <= 'b0;
		end
		
	end
	
	
assign gpio_out = {6'b0,status_gpio};

endmodule
