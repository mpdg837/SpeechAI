module timerModule#(
	parameter TIME_MAX = 100000
)(
	input csi_clk,
	input rsi_reset_n,
	
	output reg irq = 1'b0,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[1:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] avs_s0_readdata = 'b0
	
);

localparam FLAG_IRQ_RET = 3'h0;
localparam GET_TIME = 3'h1;
localparam SET_MAX_TIME = 3'h2;
localparam ENABLE_TIMER = 3'h3;
localparam RESET = 3'h4;

localparam TIME_SIZE = $clog2(TIME_MAX);

wire reset = ~rsi_reset_n;

reg ena_timer = 'b0;

reg[TIME_SIZE - 1:0] max_timer = 'b0;
reg[TIME_SIZE - 1:0] timer = 'b0;


always@(posedge csi_clk)
	if(reset) begin
		timer = 'b0;
	end else
	begin
		
		if(ena_timer)
			if(timer == max_timer) begin
				timer = 0;
			end else
			begin
				timer = timer + 1;
			end
		
		
	end
	
always@(posedge csi_clk)
	if(reset) begin
		irq = 1'b0;

		max_timer = 'b0;
		ena_timer = 'b0;
		
		
	end else
	begin
		
		if(avs_s0_write) begin
			case(avs_s0_address)
				SET_MAX_TIME: begin
					max_timer = avs_s0_writedata;
				end
				ENABLE_TIMER: begin
					ena_timer = avs_s0_writedata[0];
				end
				FLAG_IRQ_RET: begin
					irq = 0;
				end
				
			endcase
		end
		
		if(ena_timer)
			if(timer == 0) begin
				irq = 1;
			end
			
	end

always@(posedge csi_clk)
	if(reset) begin
		avs_s0_readdata = 'b0;
		
	end else
	begin
	
		if(avs_s0_read) begin
			case(avs_s0_address)
				
				GET_TIME: avs_s0_readdata = timer;
				default: avs_s0_readdata = 'b0;
				
			endcase
		end else
		begin
			avs_s0_readdata = 'b0;
		end
		
	end
	
endmodule
