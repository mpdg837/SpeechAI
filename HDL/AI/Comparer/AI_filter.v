module AI_filter(
	input clk,
	input rst,
	
	input[23:0] max,
	
	input[31:0] data_in,
	input data_in_rdy,
	
	output reg[31:0] data_out = 'b0,
	output reg data_out_rdy = 'b0
);

reg[31:0] f_mem = 'b0;
reg[31:0] n_mem = 'b0;

reg f_state = 'b0;
reg n_state = 'b0;

reg[31:0] b_data_in = 'b0;
reg b_data_in_rdy = 'b0;

reg[31:0] b_data_out = 'b0;
reg b_data_out_rdy = 'b0;

always@(posedge clk)
	if(rst) begin
		b_data_in <= 0;
		b_data_in_rdy <= 0;
	end else
	begin
		b_data_in <= data_in;
		b_data_in_rdy <= data_in_rdy;	
	end

always@(posedge clk)
	if(rst) begin
		data_out <= 0;
		data_out_rdy <= 0;
	end else
	begin
		data_out <= b_data_out;
		data_out_rdy <= b_data_out_rdy;	
	end
	
	
always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_mem <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_mem <= n_mem;
	end
	
always@(*) begin
	n_mem = f_mem;
	n_state = f_state;
	
	b_data_out = 'b0;
	b_data_out_rdy = 'b0;
	
	case(f_state)
		0: if(b_data_in_rdy) begin
			n_mem = b_data_in;
			
			n_state = 1;
		end
		1: begin
			
			if(f_mem[23:0] <= max) begin
				b_data_out = f_mem;
			end else
			begin
				b_data_out = {f_mem[31:24],24'hFFFFFF}; 
			end
			
			b_data_out_rdy = 'b1;
			
			n_state = 0;
		end
		
	endcase
end

endmodule
