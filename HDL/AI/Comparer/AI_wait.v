module AI_wait(
	input clk,
	input rst,
	
	input[7:0] card_in,
	input card_in_rdy,
	
	output reg[7:0] card_out = 'b0,
	output reg card_out_rdy = 'b0
);

reg f_m = 'b0;
reg n_m = 'b0;

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

always@(posedge clk)
	if(rst) begin
		f_mem <= 'b0;
		f_state <= 'b0;
		f_m <= 'b0;
	end else
	begin
		f_mem <= n_mem;
		f_state <= n_state;
		f_m <= n_m;
	end
	
always@(*) begin
	n_m = f_m; 
	n_state = f_state;
	n_mem = f_mem;
	

	card_out = 'b0;
	card_out_rdy = 'b0;
	
	case(f_state)
		0: if(card_in_rdy) begin
			n_mem = card_in;
			n_state = 1;
		end
		1: begin
			n_state = 0;
				
			card_out = f_mem;
			card_out_rdy = 'b1;
			
		end
		
	endcase

	
end

endmodule