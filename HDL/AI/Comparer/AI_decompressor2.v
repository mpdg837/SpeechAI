
module AI_decompressor_2(
	input clk,
	input rst,
	
	input init,
	input compress,
	
	input[63:0] data_in,
	input data_in_rdy,
	
	output reg[63:0] data_out = 'b0,
	output reg data_out_rdy = 'b0
);

reg[63:0] b_data_in = 'b0;
reg b_data_in_rdy = 'b0;

always@(posedge clk)
	if(rst) begin
		b_data_in <= 'b0;
		b_data_in_rdy <= 'b0;	
	end else
	begin
		b_data_in <= data_in;
		b_data_in_rdy <= data_in_rdy;		
	end
	
reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;



reg[7:0] f_last1 = 'b0;
reg[7:0] n_last1 = 'b0;

reg[7:0] f_last2 = 'b0;
reg[7:0] n_last2 = 'b0;

reg[7:0] f_last3 = 'b0;
reg[7:0] n_last3 = 'b0;

reg[7:0] f_last4 = 'b0;
reg[7:0] n_last4 = 'b0;


reg[7:0] f_act4 = 'b0;
reg[7:0] n_act4 = 'b0;

reg[7:0] f_act3 = 'b0;
reg[7:0] n_act3 = 'b0;

reg[7:0] f_act2 = 'b0;
reg[7:0] n_act2 = 'b0;

reg[7:0] f_act1 = 'b0;
reg[7:0] n_act1 = 'b0;



reg[7:0] f_delta1 = 'b0;
reg[7:0] n_delta1 = 'b0;

reg f_minus1 = 'b0;
reg n_minus1 = 'b0;



reg[7:0] f_delta2 = 'b0;
reg[7:0] n_delta2 = 'b0;

reg f_minus2 = 'b0;
reg n_minus2 = 'b0;



reg[7:0] f_next_mem = 'b0;
reg[7:0] f_act_mem = 'b0;
reg[7:0] f_last_mem = 'b0;

reg[7:0] n_next_mem = 'b0;
reg[7:0] n_act_mem = 'b0;
reg[7:0] n_last_mem = 'b0;


reg f_ssel = 'b0;
reg n_ssel = 'b0;

reg f_sel = 'b0;
reg n_sel = 'b0;

reg[63:0] b_data_out = 'b0;
reg b_data_out_rdy = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 0;
		
		f_mem <= 0;
		
		f_last1 <= 0;
		f_last2 <= 0;
		f_last3 <= 0;
		f_last4 <= 0;

		f_act1 <= 0;
		f_act2 <= 0;
		f_act3 <= 0;
		f_act4 <= 0;
		
		f_minus1 <= 0;
		f_delta1 <= 0;
		
		f_minus2 <= 0;
		f_delta2 <= 0;
		
		f_sel <= 0;
		f_ssel <= 0;
		
		f_next_mem <= 0;
		f_act_mem <= 0;
		f_last_mem <= 0;

	end else
	begin
		f_state <= n_state;
		
		f_mem <= n_mem;
		
		f_last1 <= n_last1;
		f_last2 <= n_last2;
		f_last3 <= n_last3;
		f_last4 <= n_last4;

		f_act1 <= n_act1;
		f_act2 <= n_act2;
		f_act3 <= n_act3;
		f_act4 <= n_act4;
				
				
		f_minus1 <= n_minus1;
		f_delta1 <= n_delta1;
		
		f_minus2 <= n_minus2;
		f_delta2 <= n_delta2;
		
		f_sel <= n_sel;
		f_ssel <= n_ssel;
		
		f_next_mem <= n_next_mem;
		f_act_mem <= n_act_mem;
		f_last_mem <= n_last_mem;
	end

reg[7:0] cache = 'b0;



always@(*) begin
	n_state = f_state;
	
	n_mem = f_mem;
	
	n_last1 = f_last1;
	n_last2 = f_last2;
	n_last3 = f_last3;
	n_last4 = f_last4;

	n_act1 = f_act1;
	n_act2 = f_act2;
	n_act3 = f_act3;
	n_act4 = f_act4;
	
	n_delta1 = f_delta1;
	n_minus1 = f_minus1;
	
	n_delta2 = f_delta2;
	n_minus2 = f_minus2;
	
	n_sel = f_sel;
	n_ssel = f_ssel;

	n_next_mem = f_next_mem;
	n_act_mem = f_act_mem;
	n_last_mem = f_last_mem;
	
	b_data_out = 0;
	b_data_out_rdy = 0;

	cache = 'b0;
	
	if(init)
		n_sel = 0;
		
	case(f_state)
		0: if(b_data_in_rdy & ~compress) begin
			
			
			if(f_sel) begin
				n_last1 = {b_data_in[55:49],1'b0};
				n_last2 = {b_data_in[47:41],1'b0};
				n_last3 = 0;
				n_last4 = 0;
			
			end else
			begin
				n_last1 = 0;
				n_last2 = 0;
				n_last3 = {b_data_in[39:33],1'b0};
				n_last4 = {b_data_in[31:25],1'b0};
			end
			
			n_act_mem = {b_data_in[15:9],1'b0};
			n_last_mem = {b_data_in[7:1],1'b0};
			
			n_mem = n_act_mem;
			
			if(n_act_mem < n_last_mem) begin
				n_minus1 = 1;
				n_delta1 = (n_last_mem- n_act_mem);
			end else
			begin
				n_minus1 = 0;
				n_delta1 = (n_act_mem - n_last_mem);
			end
			
			
			if(n_next_mem < n_act_mem) begin
				n_minus2 = 1;
				n_delta2 = (n_act_mem- n_next_mem);
			end else
			begin
				n_minus2 = 0;
				n_delta2 = (n_next_mem - n_act_mem);
			end
			
			
			n_ssel = b_data_in[8];
			n_state = 1;
		end
		1: begin
			
				if(f_sel) begin
					
					n_act3 = 0;
					n_act4 = 0;
					
					
					if(f_ssel) begin
					
						if(f_minus1)
							n_act1 = f_last_mem - {1'b0,f_delta1[7:1]};
						else
							n_act1 = f_last_mem + {1'b0,f_delta1[7:1]};
							
						n_act2 = f_mem;
						
					end else
					begin

						if(f_minus1)
							n_act2 = f_mem - {1'b0,f_delta2[7:1]};
						else
							n_act2 = f_mem + {1'b0,f_delta2[7:1]};
							
						n_act1 = f_mem;
						
					end
					
					
				end else
				begin
					
					n_act1 = 0;
					n_act2 = 0;
					
					if(f_ssel) begin
											
						if(f_minus1)
							n_act3 = f_last_mem - {1'b0,f_delta1[7:1]};
						else
							n_act3 = f_last_mem + {1'b0,f_delta1[7:1]};
						
						n_act4 = f_mem;

					end else
					begin
						
						if(f_minus1)
							n_act4 = f_mem - {1'b0,f_delta2[7:1]};
						else
							n_act4 = f_mem + {1'b0,f_delta2[7:1]};
						
						n_act4 = f_mem;
					end
					
				end
				
		
			
			n_state = 2;
		end
		2: begin

			n_sel = ~f_sel;

			b_data_out = {f_act1,f_act2,f_act3,f_act4,f_last1,f_last2,f_last3,f_last4}; 
			b_data_out_rdy = 1'b1;
			n_state = 0;		
		end
	endcase
end

always@(posedge clk)
	if(rst) begin
		data_out <= 'b0;
		data_out_rdy <= 'b0;
	end else
	begin
		data_out <= b_data_out;
		data_out_rdy <= b_data_out_rdy;	
	end
	
endmodule
