
module BLEUART_trans_byte(
	input clk,
	input rst,
	
	output reg tx = 'b1,
	
	input tick,
	
	input[7:0] in,
	input valid,
	output reg rdy = 'b0
);

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[2:0] f_counter = 'b0;
reg[2:0] n_counter = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg f_tx = 'b1;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		f_mem <= 'b0;
		
		f_tx <= 'b1;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		f_mem <= n_mem;	
		
		f_tx <= tx;
	end
	
always@(*) begin
	n_mem = f_mem;
	n_state = f_state;
	n_counter = f_counter;
	
	tx = f_tx;
	rdy = 0;
	
	case(f_state)
		0: if(valid) begin
			n_mem = in;
			n_state = 1;
			n_counter = 0;
		end
		1: if(tick) begin
			tx = 0;
			n_state = 2;
		end
		2: if(tick) begin
			n_counter = f_counter + 1;
			tx = f_mem[f_counter];
			
			if(f_counter == 7) 
				n_state = 3;
			else
				n_state = 2;
		end	
		3: if(tick) begin
			tx = 1;
			n_state = 0;
			
			rdy = 1;
		end
	endcase
end


endmodule