

module PWM_fifo_stream(
	input clk,
	input rst,
	
	input[15:0] sound,
	input sound_valid,
	output reg sound_rdy = 'b0,
	
	input tick,
	
	output reg[15:0] sound_out = 'b0,
	output reg sound_out_rdy = 'b0
);

reg w_en = 'b0;
reg r_en = 'b0;

reg[15:0] data_in = 'b0;
wire[15:0] data_out;

wire full;
wire empty;

reg[1:0] f_state_in = 'b0;
reg[1:0] n_state_in = 'b0;

reg[15:0] f_mem_in = 'b0;
reg[15:0] n_mem_in = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state_in <= 'b0;
		f_mem_in <= 'b0;
	end else
	begin
		f_state_in <= n_state_in;
		f_mem_in <= n_mem_in;
	end
	
always@(*) begin
	n_state_in = f_state_in;
	n_mem_in = f_mem_in;
	
	sound_rdy = 'b0;
	
	data_in = 'b0;
	w_en = 'b0;
	
	case(f_state_in)
		0: if(sound_valid) begin
			n_mem_in = sound;
			n_state_in = 1;
		end
		1: begin
			data_in = f_mem_in;
			w_en = 1'b1;
			
			n_state_in = 2;
		end
		2: if(~full) begin
			n_state_in = 0;
			sound_rdy = 1'b1;
		end
	endcase
end

PWM_FIFO_basic #
	(
		.DEPTH(32), 
		.DATA_WIDTH(16)
	) 
	pfifo
	(
		.clk(clk),
		.rst(rst),
		
		
		.w_en(w_en), 
		.r_en(r_en),
		
		
		.data_in(data_in),
		.data_out(data_out),

		.full(full), 
		.empty(empty)
	);

reg[15:0] f_mem_out = 'b0;
reg[15:0] n_mem_out = 'b0;

reg[2:0] f_state_out = 'b0;
reg[2:0] n_state_out = 'b0;

reg b_tick = 'b0;

always@(posedge clk)
	if(rst) 
		b_tick <= 'b0;
	else
		b_tick <= tick;
		
always@(posedge clk)
	if(rst) begin
		f_mem_out <= 'b0;
		f_state_out <= 'b0;
	end else
	begin
		f_mem_out <= n_mem_out;
		f_state_out <= n_state_out;
	end

always@(*) begin
	n_state_out = f_state_out;
	n_mem_out = f_mem_out;
	
	r_en = 'b0;
	
	sound_out = 'b0;
	sound_out_rdy = 'b0;
	
	case(f_state_out)
		0: begin
				if(~empty) begin
					r_en = 1'b1;
					n_state_out = 1;
				end else if(b_tick) begin
					n_state_out = 3;
					n_mem_out = 0;
				end
			end
		1: begin
			n_mem_out = data_out;
			n_state_out = 2;
		end
		2: if(b_tick) begin
			n_state_out = 3;
		end
		3: begin
		
			sound_out = f_mem_out;
			sound_out_rdy = 'b1;
			
			n_state_out = 0;
		end
	endcase
end


endmodule
