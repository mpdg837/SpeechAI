module myfft(
	input i
);

reg clk = 'b0;
reg rst = 'b0;

reg init = 'b0;


integer n = 0;
integer k = 0;

initial begin
	for(k = 0 ; k < 32 ; k = k + 1) begin
		for(n = 0 ; n < 4999 ; n = n + 1) begin
			clk = 1'b1;
			#1;
			clk = 1'b0;
			#1;
		end
	end
	
end

reg[15:0] audio_data = 'b0;
reg audio_valid = 'b0;

wire audio_rdy;


wire[15:0] profile_data;
wire profile_valid;
reg profile_rdy = 'b0;


initial begin
	rst = 1'b1;
	#10;
	rst = 1'b0;
end

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[9:0] f_counter = 'b0;
reg[9:0] n_counter = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
	end else
	begin
		f_counter <= n_counter;
		f_state <= n_state;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	
	audio_data = 'b0;
	audio_valid = 'b0;

	profile_rdy = 'b0;
	
	case(f_state)
		0: begin
			audio_data = f_counter;
			audio_valid = 'b1;		
			
			if(audio_rdy) begin
				n_counter = f_counter + 1;
				
				if(f_counter == 511) begin
					n_state = 1;
				end
			end
		end
		1: if(profile_valid) begin
				profile_rdy = 1;
			end
	endcase
	
end

sig_core scor(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.audio_data(audio_data),
	.audio_valid(audio_valid),

	.audio_rdy(audio_rdy),


	.profile_data(profile_data),
	.profile_valid(profile_valid),
	.profile_rdy(profile_rdy)	
);



endmodule
