

module AI_scorer(
	input clk,
	input rst,
	
	input init,
	
	output reg[23:0] min,
	
	input[31:0] sum_in,
	input sum_rdy,
	
	output reg[31:0] reg1 = 'b0,
	output reg[31:0] reg2 = 'b0,
	
	output reg rdy = 'b0
);

localparam SIZE = 8;

reg[23:0] f_min = 'b0;
reg[23:0] b_min = 'b0;

always@(posedge clk)
	if(rst) begin
		min <= 'b0;
	end else
	begin
		min <= b_min;
	end
	
reg[7:0] f_score[(SIZE - 1):0];
reg[7:0] n_score[(SIZE - 1):0];

reg[2:0] f_counter = 'b0;
reg[2:0] n_counter = 'b0;

reg[7:0] f_buffer = 'b0;
reg[7:0] n_buffer = 'b0;

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[31:0] f_reg1 = 'b0;
reg[31:0] f_reg2 = 'b0;

reg f_lock = 'b0;
reg n_lock = 'b0;
integer n = 0;

always@(posedge clk)
	if(rst) begin
		f_counter <= 'b0;
		f_buffer <= 'b0;
		f_state <= 'b0;
		
		f_reg1 <= 'b0;
		f_reg2 <= 'b0;
		
		f_min <= 'b0;
		f_lock <= 'b0;
		
		for( n = 0 ; n < SIZE ; n = n + 1 )
			f_score[n] <= 'b0;
	end else
	begin
		f_counter <= n_counter;
		f_buffer <= n_buffer;
		f_state <= n_state;
		
		f_reg1 <= reg1;
		f_reg2 <= reg2;
		
		f_lock <= n_lock;
		f_min <= b_min;
		for( n = 0 ; n < SIZE ; n = n + 1 )
			f_score[n] <= n_score[n];
	end
	
always@(*) begin

	rdy = 0;
	
	b_min = f_min;
	
	n_counter = f_counter;
	n_buffer = f_buffer;
	n_state = f_state;
	
	reg1 = f_reg1;
	reg2 = f_reg2;
	
	n_lock = f_lock;
	
	for( n = 0 ; n < SIZE ; n = n + 1 )
		n_score[n] = f_score[n];
	
	if(init) begin
		for( n = 0 ; n < SIZE ; n = n + 1 )
			n_score[n] = 0;	
	
		b_min = 0;
	
		n_counter = 0;
		n_buffer = 0;
		n_state = 0;
		
		reg1 = 0;
		reg2 = 0;
		
		n_lock = 0;
	end
	
	case(f_state)
		0: begin
			if(sum_rdy) begin
				
				n_buffer = sum_in[31:24];
				n_lock = ~sum_in[27];
				
				
				if(f_counter == 0) begin
					b_min = sum_in[23:0];
				end
				
				n_state = 1;
			end
		end
		1: begin
			if(f_counter == 0) begin
				
				for( n = 0 ; n < SIZE ; n = n + 1 )
					n_score[n] = 0;			
				
			end
			n_state = 2;
		end
		2: begin
			
			if(f_lock)
				n_score[f_buffer[2:0]] = f_score[f_buffer[2:0]] + (SIZE - f_counter);
			
			if(f_counter == SIZE - 1) begin
				n_state = 3;
			end else
			begin
				n_state = 0;
				n_counter = f_counter + 1;
			end
			
		end
		3: begin
			reg1 = {f_score[0],f_score[1],f_score[2],f_score[3]};
			reg2 = {f_score[4],f_score[5],f_score[6],f_score[7]};
			
			n_counter = 'b0;
			
			n_state = 0;
			rdy = 1'b1;
			
		end
	endcase
end
	
endmodule