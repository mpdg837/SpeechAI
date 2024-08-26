module SPI_irq_sleeper(
	input clk,
	input rst,
	
	input in_irq,
	output reg irq_out = 'b0
);

reg[11:0] f_timer = 'b0;
reg[11:0] n_timer = 'b0;

reg n_state = 'b0;
reg f_state = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_state <= 'b0;
		f_timer <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_timer <= n_timer;
	end	
end

always@(*) begin
	n_state = f_state;
	
	n_timer= f_timer;
	
	irq_out = 'b0;
	case(f_state)
		0: begin
		
			n_timer = 0;
			if(in_irq) n_state = 1;
		end
		1: begin
			n_timer = f_timer + 1;
			
			if(f_timer == 4095) begin
				irq_out = 1;
				n_timer = 0;
				
				n_state = 0;
			end
		end
	endcase
end


endmodule
