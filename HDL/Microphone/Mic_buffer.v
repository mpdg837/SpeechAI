
module mic_buffer(
	input clk,
	input rst,
	
	output[23:0] out_audio,
	input out_read,
	
	output reg out_irq = 'b0,
	
	input in_enable,
	output reg enable = 'b0,
	
	input[23:0] audio,
	input irq,
	
	output full,
	output empty
);

reg l_in_enable = 'b0;
reg e_rst = 'b0;

always@(posedge clk)
	if(rst) begin
		l_in_enable <= 'b0;
		e_rst <= 'b0;
	end else
	begin
		if((~l_in_enable) & in_enable) begin
			e_rst <= 'b1;
			l_in_enable <= in_enable;
		end else
		begin
			e_rst <= 'b0;
			l_in_enable <= in_enable;
		end
		
	end
	
Mic_FIFO_basic fifo
(
  .clk(clk), 
  .rst(rst | e_rst),
  
  .w_en(irq), 
  .data_in(audio),
  
  .r_en(out_read),
  .data_out(out_audio),
  
  .full(full), 
  .empty(empty)
);


always@(posedge clk)
	if(rst) begin
		out_irq <= 0;
		enable <= 0;
	end else
	begin
		enable <= in_enable;
		out_irq <= irq;
	end



endmodule
