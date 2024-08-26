
module PWM_serializer(
	input clk,
	input rst,
	
	input[15:0] sound,
	input 		sound_rdy,
	
	output reg[15:0] in_sound = 'b0
);

localparam MINIMUM = 2048;

reg[15:0] f_mem;
reg[15:0] n_mem;

reg[15:0] b_sound = 'b0;

reg[15:0] b_in_sound = 'b0;
reg b_in_sound_rdy = 'b0;

always@(posedge clk)
	if(rst)
		in_sound <= 'b0;
	else if(b_sound < MINIMUM) begin
		in_sound <= MINIMUM;
	end else
		in_sound <= b_sound;
		
always@(posedge clk) 
	if(rst) begin
		f_mem <= 0;
	end else
	begin
		f_mem <= n_mem;
	end

always@(posedge clk)
	if(rst) begin
		b_in_sound <= 'b0;
		b_in_sound_rdy <= 'b0;	
	end else
	begin
		b_in_sound <= sound;
		b_in_sound_rdy <= sound_rdy;		
	end
	
always@(*) begin
	n_mem = f_mem;
	
	b_sound = f_mem;
	
	if(b_in_sound_rdy) begin
		if(b_in_sound[15])
			n_mem = {1'b0,b_in_sound[14:0]};
		else
			n_mem = {1'b1,b_in_sound[14:0]};
	end
	
end




endmodule
