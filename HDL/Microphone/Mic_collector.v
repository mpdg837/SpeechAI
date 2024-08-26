
module mic_collector(
	input clk,
	input rst,
		
	input enable,
	input[23:0] mic_dir_data,
	input mic_dir_rdy,
	
	output reg[23:0] out_audio = 'b0,
	
	output reg irq = 'b0
);

reg[23:0] b_audio = 0;
reg b_irq = 0;

always@(posedge clk)
	if(rst) begin
		irq <= 0;
		out_audio <= 0;	
	end else
	begin
		irq <= b_irq;
		out_audio <= b_audio;	
	end
	

reg[1:0] f_timer = 'b0;
reg[1:0] n_timer = 'b0;

reg[25:0] f_mem = 'b0;
reg[25:0] n_mem = 'b0;

always@(posedge clk)
	if(rst) begin
		f_timer <= 0;
		f_mem <= 0;
	end else
	begin
		f_timer <= n_timer;
		f_mem <= n_mem;
	end
	
	
always@(*) begin
	n_mem = f_mem;
	n_timer = f_timer;
	
	b_audio = f_mem[25:2];
	b_irq = 'b0;
	
	
	
	if(enable)
		if(mic_dir_rdy) begin
			
			n_timer = f_timer + 1;
			
			if(f_timer == 0) begin
				
				
				b_irq = 1;
				if(mic_dir_data[23]) 
					n_mem = {2'b11,mic_dir_data};
				else
					n_mem = {2'b00,mic_dir_data};
			
			end else
			begin
			
				if(mic_dir_data[23]) 
					n_mem = f_mem + {2'b11,mic_dir_data};
				else
					n_mem = f_mem + {2'b00,mic_dir_data};
					
			end
			
			if(f_timer == 2) begin
				
				n_timer = 0;
			
			end
			
		end
		
end

endmodule
