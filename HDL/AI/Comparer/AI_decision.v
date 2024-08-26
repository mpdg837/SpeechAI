

module AI_decision(
	input clk,
	input rst,
	
	input init,
	
	input[23:0] min,
	
	input[31:0] reg1,
	input[31:0] reg2,
	
	input score_rdy,
	input[7:0] score_minimum,
	
	output reg[3:0] max
);


localparam SIZE = 8;

reg[5:0] f_min = 'b0;
reg[5:0] n_min = 'b0;

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[2:0] f_counter = 'b0;
reg[2:0] n_counter = 'b0;


reg[5:0] f_max_val = 'b0;
reg[3:0] f_max_index = 'b0;

reg[5:0] n_max_val = 'b0;
reg[3:0] n_max_index = 'b0;

reg[3:0] f_max = 'b0;
reg[3:0] b_max = 'b0;

always@(posedge clk) 
	if(rst) begin
		max <= 'b0;
	end else
	begin
		max <= b_max;
	end
	
reg[SIZE - 1:0] mem[SIZE - 1:0];

always@(*) begin
	mem[0] = reg1[31:24];
	mem[1] = reg1[23:16];
	mem[2] = reg1[15:8];
	mem[3] = reg1[7:0];
	mem[4] = reg2[31:24];
	mem[5] = reg2[23:16];
	mem[6] = reg2[15:8];
	mem[7] = reg2[7:0];
	
end

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		f_max <= 'b0;
		
		f_max_val <= 'b0;
		f_max_index <= 'b0;
		
		f_min <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		f_max <= b_max;
		
		f_max_val <= n_max_val;
		f_max_index <= n_max_index;
		f_min <= n_min;
	end

always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	
	n_min = f_min;
	
	b_max = f_max;
	
	n_max_index = f_max_index;
	n_max_val = f_max_val;
	
	if(init) begin
		n_state = 'b0;
		n_counter = 'b0;
		b_max = 'b0;
		
		n_max_val = 'b0;
		n_max_index = 'b0;
		
		n_min = score_minimum;
	end
	
	case(f_state)
		0: begin
			if(score_rdy) begin
				n_state = 1;
				
				n_max_val = 'b0;
				n_max_index = 'b0;
				
				n_counter = 'b0;
			end	
		end
		1: begin
			
			if(f_max_val < mem[f_counter]) begin
				n_max_val = mem[f_counter];
				n_max_index = f_counter;
			end
			
			if(f_counter == SIZE - 1) begin
				n_state = 2;
			end else
			begin
				n_counter = f_counter + 1;
			end
			
		end
		2: begin
			
			if(f_max_val >= f_min)
			
				if(min == 24'hFFFFFF) begin
					b_max = 4'hF;
				end else
				begin
					b_max = f_max_index;
				end
			else
				b_max = 4'hF;
				
			n_state = 0;
		end
	endcase
end

endmodule