
module AI_buffer(
	input clk,
	input rst,

	input init,
	
	input[7:0] card_data,
	input card_rdy,
	
	output reg[7:0] b_data_out = 'b0,
	output reg b_data_rdy = 1'b0,
	
	output reg crc_err = 'b0,
	output reg tmr_err = 'b0
);

reg[1:0] f_status = 'b0;
reg[1:0] n_status = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[9:0] f_counter = 'b0;
reg[9:0] n_counter = 'b0;

reg f_lock = 'b0;
reg n_lock = 'b0;

always@(posedge clk) begin
	if(rst) begin
		f_status <= 'b0;
		f_mem <= 'b0;
		f_counter <= 'b0;
		
		f_lock <= 'b0;
	end else
	begin
		f_status <= n_status;
		f_mem <= n_mem;
		f_counter <= n_counter;
		
		f_lock <= n_lock;
	end
end

always@(*) begin
	n_status = f_status;
	n_mem = f_mem;
	n_counter = f_counter;
	
	n_lock = f_lock;
	
	b_data_out = 'b0;
	b_data_rdy = 1'b0;

	crc_err = 'b0;
	tmr_err = 'b0;	
	
	if(init) begin
		n_mem = 0;
		n_status = 0;
		n_counter = 1;
		n_lock = 0;
	end
	
	case(f_status)
		0: begin
			if(card_rdy) begin
				
				n_mem = card_data;
				n_status = 1;
				
			end
		end
		1: begin
		
			n_counter = f_counter + 1;
			
			
			case(f_counter)
				0: begin
					if(f_mem == 8'hFE) begin
						tmr_err = 'b1;
						n_lock = 1;
					end else if(f_mem == 8'hFD) begin
						crc_err = 'b1;
						n_lock = 1;
					end else if(f_mem != 0) begin
						tmr_err = 'b1;
						n_lock = 1;
					end
				
					
				end
				1: begin
					if(f_mem == 8'hFE) begin
						tmr_err = 'b1;
						n_lock = 1;
					end else if(f_mem == 8'hFD) begin
						crc_err = 'b1;
						n_lock = 1;
					end else if(f_mem != 0) begin
						tmr_err = 'b1;
						n_lock = 1;
					end
					
				end
				
			513: begin
				
				n_counter = 0;
				
				if(~f_lock) begin
					b_data_out = f_mem;
					b_data_rdy = 1'b1;				
				end
	
			end
			default: if(~f_lock) begin
				b_data_out = f_mem;
				b_data_rdy = 1'b1;				
			end
			endcase
			
			n_status = 'd0;
		end
	endcase
end

endmodule
