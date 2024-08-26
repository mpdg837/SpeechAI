
module sig_mel_spect(
	input clk,
	input rst,
	
	input init,
	
	input[15:0] spect_data,
	input spect_valid,
	output reg spect_rdy = 'b0,
	
	output reg[15:0] mel_spect_data = 'b0,
	output reg mel_spect_valid = 'b0,
	input mel_spect_rdy

);

reg[7:0] addr = 'b0;
wire[7:0] out;

spect_mel_table smet(
	.clk(clk),
	.rst(rst),
	
	.addr(addr),
	.out(out)
);

reg[3:0] f_state = 'b0;
reg[3:0] n_state = 'b0;

reg[2:0] f_lcounter = 'b0;
reg[2:0] n_lcounter = 'b0;

reg[7:0] f_counter = 'b0;
reg[7:0] n_counter = 'b0;

reg[15:0] f_mem = 'b0;
reg[15:0] n_mem = 'b0;

reg[15:0] f_spect_data = 'b0;
reg[15:0] n_spect_data = 'b0;

reg[7:0] f_addr1 = 'b0;
reg[7:0] n_addr1 = 'b0;

reg[7:0] f_addr2 = 'b0;
reg[7:0] n_addr2 = 'b0;

reg[2:0] f_diff = 'b0;
reg[2:0] n_diff = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_counter <= 'b0;
		f_mem <= 'b0;
		f_lcounter <= 'b0;
		
		f_addr1 <= 'b0;
		f_addr2 <= 'b0;
		
		f_diff <= 'b0;
		f_spect_data <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_counter <= n_counter;
		f_mem <= n_mem;
		f_lcounter <= n_lcounter;
		
		f_addr1 <= n_addr1;
		f_addr2 <= n_addr2;
		
		f_diff <= n_diff;
		
		f_spect_data <= n_spect_data;
	end
	
always@(*) begin
	n_state = f_state;
	n_counter = f_counter;
	n_mem = f_mem;
	n_lcounter = f_lcounter;
	
	n_diff = f_diff;
	
	n_addr1 = f_addr1;
	n_addr2 = f_addr2;
	
	n_spect_data = f_spect_data;
	addr = 'b0;
	
	mel_spect_data = 0;
	mel_spect_valid = 0;
	spect_rdy = 0;
	
	if(init) begin 
		n_state = 0;
		n_counter = 0;
		n_mem = 0;	
	end
	
	case(f_state)
		0: if(spect_valid) begin
			
			n_spect_data = spect_data;
			spect_rdy = 1'b1;
			
			n_state = 1;
		end
		1: begin
		
			if(f_mem < f_spect_data)
				n_mem = f_spect_data;
			
			addr = f_counter;
			n_state = 2;
		end
		2: begin
			
			n_addr1 = out;
			addr = f_counter + 1;
			
			n_state = 3;
			
		end	
		3: begin
			if(f_counter == 255) begin
				n_addr2 = 255;
			end else
			begin	
				n_addr2 = out;
			end
			
			
			n_state = 4;
		end
		4: begin
		
			if(f_counter == 255) begin
				n_diff = 3;
			end else
			begin
				n_diff = f_addr2 - f_addr1;
			end
				
			
			n_state = 5;
		end
		5: begin
			
			n_lcounter = 0;
			n_counter = f_counter + 1;
			
			if(f_diff == 0) begin
				 n_state = 0;
			end else
			begin
				n_state = 6;
			end
			
		end
		6: begin
			
			mel_spect_data = f_mem;
			mel_spect_valid = 1'b1;
			
			if(mel_spect_rdy) begin
				
				n_state = 7;
			end
			
		end
		7: begin
			
			n_lcounter = f_lcounter + 1;
			
			
			if(f_lcounter == f_diff - 1) begin
				n_state = 0;
				n_mem = 0;
			end else
			begin
				n_state = 6;
			end
			
		end
		
	endcase
	
end


endmodule
