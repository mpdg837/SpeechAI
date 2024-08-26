
module singal_fft(
	input clk,
	input rst,
	
	input init,
	
	input[15:0] window_data,
	input window_valid,
	output reg window_rdy = 'b0,
	
	output reg[15:0] transform1_real = 'b0,
	output reg[15:0] transform1_imag = 'b0,
	output reg transform1_valid = 'b0,
	input transform1_rdy,
	
	output reg[15:0] transform2_real = 'b0,
	output reg[15:0] transform2_imag = 'b0,
	output reg transform2_valid = 'b0,
	input transform2_rdy
		
);

reg[15:0] bb_X0 = 'b0;
reg[15:0] bb_X1 = 'b0;
reg[15:0] bb_X2 = 'b0;
reg[15:0] bb_X3 = 'b0;
reg bb_next = 'b0;

reg[31:0] b_X0 = 'b0;
reg[31:0] b_X1 = 'b0;
reg[31:0] b_X2 = 'b0;
reg[31:0] b_X3 = 'b0;
reg b_next = 'b0;


reg[31:0] X0 = 'b0;
reg[31:0] X1 = 'b0;
reg[31:0] X2 = 'b0;
reg[31:0] X3 = 'b0;
reg next = 'b0;


wire[31:0] Y0;
wire[31:0] Y1;
wire[31:0] Y2;
wire[31:0] Y3;

wire next_out;

reg[31:0] b_Y0 = 'b0;
reg[31:0] b_Y1 = 'b0;
reg[31:0] b_Y2 = 'b0;
reg[31:0] b_Y3 = 'b0;

reg b_next_out = 'b0;

reg[15:0] bb_Y0 = 'b0;
reg[15:0] bb_Y1 = 'b0;
reg[15:0] bb_Y2 = 'b0;
reg[15:0] bb_Y3 = 'b0;

reg bb_next_out = 'b0;

reg f_valid1 = 'b0;
reg n_valid1 = 'b0;

reg f_valid2 = 'b0;
reg n_valid2 = 'b0;

always@(posedge clk) begin
	next <= b_next;
	
	X0 <= b_X0;
	X1 <= b_X1;
	X2 <= b_X2;
	X3 <= b_X3;
end 

always@(posedge clk) begin
	b_next <= bb_next;
	
	if(bb_X0[15])
		b_X0 <= {4'hF,bb_X0[15:0],12'hFFF};
	else
		b_X0 <= {4'h0,bb_X0[15:0],12'h000};
		
	if(bb_X1[15])
		b_X1 <= {4'hF,bb_X1[15:0],12'hFFF};
	else
		b_X1 <= {4'h0,bb_X1[15:0],12'h000};
		
	if(bb_X2[15])
		b_X2 <= {4'hF,bb_X2[15:0],12'hFFF};
	else
		b_X2 <= {4'h0,bb_X2[15:0],12'h000};
		
	if(bb_X3[15])
		b_X3 <= {4'hF,bb_X3[15:0],12'hFFF};
	else
		b_X3 <= {4'h0,bb_X3[15:0],12'h000};
end

always@(posedge clk) begin
	b_next_out <= next_out;
	
	b_Y0 <= Y0;
	b_Y1 <= Y1;
	b_Y2 <= Y2;
	b_Y3 <= Y3;
	
end

always@(posedge clk) begin

	bb_next_out <= b_next_out;
	
	
	if(b_Y0[31]) begin 
		if(b_Y0[30:27] == 4'hF)
			bb_Y0 <= b_Y0[27:12];
		else
			bb_Y0 <= 16'h8000;
	end else
	begin
		if(b_Y0[30:27] == 4'h0)
			bb_Y0 <= b_Y0[27:12];
		else
			bb_Y0 <= 16'h7FFF;		
	end
	
	if(b_Y1[31]) begin 
		if(b_Y1[30:27] == 4'hF)
			bb_Y1 <= b_Y1[27:12];
		else
			bb_Y1 <= 16'h8000;
	end else
	begin
		if(b_Y1[30:27] == 4'h0)
			bb_Y1 <= b_Y1[27:12];
		else
			bb_Y1 <= 16'h7FFF;		
	end

	if(b_Y2[31]) begin 
		if(b_Y2[30:27] == 4'hF)
			bb_Y2 <= b_Y2[27:12];
		else
			bb_Y2 <= 16'h8000;
	end else
	begin
		if(b_Y2[30:27] == 4'h0)
			bb_Y2 <= b_Y2[27:12];
		else
			bb_Y2 <= 16'h7FFF;		
	end
	
	if(b_Y3[31]) begin 
		if(b_Y3[30:27] == 4'hF)
			bb_Y3 <= b_Y3[27:12];
		else
			bb_Y3 <= 16'h8000;
	end else
	begin
		if(b_Y3[30:27] == 4'h0)
			bb_Y3 <= b_Y3[27:12];
		else
			bb_Y3 <= 16'h7FFF;		
	end
	
end



reg dclk = 0;
reg rst_in = 0;

reg[7:0] n_addr = 'b0;
reg[7:0] f_addr = 'b0;

reg[7:0] n_addrx = 'b0;
reg[7:0] f_addrx = 'b0;

reg[3:0] f_state = 'b0;
reg[3:0] n_state = 'b0;

reg[3:0] f_statex = 'b0;
reg[3:0] n_statex = 'b0;

reg[9:0] f_counter = 'b0;
reg[9:0] n_counter = 'b0;

reg[9:0] f_counterx = 'b0;
reg[9:0] n_counterx = 'b0;

// in

reg[15:0] f_in_mem1 = 'b0;
reg[15:0] n_in_mem1 = 'b0;

reg[15:0] f_in_mem2 = 'b0;
reg[15:0] n_in_mem2 = 'b0;

// out

reg[15:0] f_real_1 = 'b0;
reg[15:0] n_real_1 = 'b0;

reg[15:0] f_imag_1 = 'b0;
reg[15:0] n_imag_1 = 'b0;

reg[15:0] f_real_2 = 'b0;
reg[15:0] n_real_2 = 'b0;

reg[15:0] f_imag_2 = 'b0;
reg[15:0] n_imag_2 = 'b0;

reg write = 'b0;
reg[7:0] addr = 'b0;

reg[63:0] writedata = 'b0;
wire[63:0] readdata;

RAMFFT ramfft(
	.address(addr),
	.data(writedata),
	.clock(clk),
	.wren(write),
	.q(readdata)
	);
	



dft_top fft(
	.clk(clk), 
	.reset(rst | rst_in), 
	.next(next), 
	.next_out(next_out),
   
	.X0({X0}),
   .X1({X1}),
   .X2({X2}),
   .X3({X3}),

	.Y0(Y0),
   .Y1(Y1),
   .Y2(Y2),
   .Y3(Y3)
	
);

always@(posedge clk)
	if(rst) begin
		
		f_state <= 0;
		
		f_counter <= 0;
		f_counterx <= 0;
		
		f_addr <= 'b0;
		f_addrx <= 'b0;
		
		f_in_mem1 <= 0;
		f_in_mem2 <= 0;
		
		f_real_1 <= 0;
		f_imag_1 <= 0;
		
		f_real_2 <= 0;
		f_imag_2 <= 0;
		
		f_valid1 <= 0;
		f_valid2 <= 0;
	end else
	begin
		
		f_addr <= n_addr;
		f_addrx <= n_addrx;
				
		f_state <= n_state;
		
		f_counter <= n_counter;
		f_counterx <= n_counterx;
		
		f_in_mem1 <= n_in_mem1;
		f_in_mem2 <= n_in_mem2;
		
		f_real_1 <= n_real_1;
		f_imag_1 <= n_imag_1;
		
		f_real_2 <= n_real_2;
		f_imag_2 <= n_imag_2;

		f_valid1 <= n_valid1;
		f_valid2 <= n_valid2;
	end


always@(*) begin
	bb_X0 = 0;
	bb_X1 = 0;
	bb_X2 = 0;
	bb_X3 = 0;
	bb_next = 'b0;
	
	n_addr = f_addr;
	n_addrx = f_addrx;
	
	n_state = f_state;
	
	n_counter = f_counter;
	n_counterx = f_counterx;
	
	n_in_mem1 = f_in_mem1;
	n_in_mem2 = f_in_mem2;
	
	n_real_1 = f_real_1;
	n_imag_1 = f_imag_1;
		
	n_real_2 = f_real_2;
	n_imag_2 = f_imag_2;
	
	n_valid1 = f_valid1;
	n_valid2 = f_valid2;
	
	window_rdy = 'b0;
	
	transform1_real = 'b0;
	transform1_imag = 'b0;
	transform1_valid = 'b0;
	
	transform2_real = 'b0;
	transform2_imag = 'b0;
	transform2_valid = 'b0;
	
	rst_in = 'b0;
	
	
	write = 'b0;
	addr = 'b0;
	writedata = 'b0;

	if(init) begin
		n_counter = 0;
		n_state = 0;
		n_addr = 'b0;
		
		n_in_mem1 = 'b0;
		n_in_mem2 = 'b0;
		
	end
	
	case(f_state)
		0: begin
			n_counter = 0;
			n_in_mem1 = 0;
			n_in_mem2 = 0;
			
			
			n_state = 1;
		end
		1: if(window_valid) begin
			n_in_mem1 = window_data;
			window_rdy = 1;
			n_state = 2;
			
			n_counter = f_counter + 1;
		end
		2: if(window_valid) begin
			n_in_mem2 = window_data;
			window_rdy = 1;
					
			n_counter = f_counter + 1;
			n_state = 3;
		end
				
		3: begin
			write = 'b1;
			addr = f_addr;
			writedata = {f_in_mem1,16'b0,f_in_mem2,16'b0};
			
			n_addr = f_addr + 1;
			if(f_counter == 512) begin
				n_state = 4;
			end else
			begin
				n_state = 1;
			end
			
		end
		4: begin
			
			n_addr = 0;
			n_counter = 0;
			
			rst_in = 1;
			n_state = 5;		
		end
		5: begin
			bb_next = 1'b1;
			
			addr = f_addr;
			n_addr = 1;
			
			n_state = 6;
		end
		6: begin
			
			addr = f_addr;
			n_addr = f_addr + 1;	
			
			bb_X0 = readdata[63:48];
			bb_X1 = readdata[47:32];
			bb_X2 = readdata[31:16];
			bb_X3 = readdata[15:0];
		
			
			if(f_addr == 255) begin
				n_state = 7;
			end
			
		end
		7: if(bb_next_out) begin
			n_addrx = 'b0;
			n_counterx = 'b0;
			n_state = 8;
		end
		8: begin
			n_addrx = f_addrx + 1;
			
			write = 1;
			addr = f_addrx;
			
			
			writedata = {bb_Y0,bb_Y1,bb_Y2,bb_Y3};
			
			if(f_addrx == 255) begin
				n_state = 9;
				n_addrx = 'b0;
				n_counterx = 'b0;
			end
			
		end
		9: begin
			n_state = 10;
			
			addr = f_addrx;
		end
		10: begin
			n_real_1 = readdata[63:48];
			n_imag_1 = readdata[47:32];
			n_real_2 = readdata[31:16];
			n_imag_2 = readdata[15:0];
			
			n_valid1 = 1;
			n_valid2 = 1;
			
			n_state = 11;
		end
		11: begin
		
			if(f_counterx > 2) begin
				transform1_real = f_real_1;
				transform1_imag = f_imag_1;

				transform2_real = f_real_2;
				transform2_imag = f_imag_2;
				
			end else
			begin
				transform1_real = 0;
				transform1_imag = 0;
				
				transform2_real = 0;
				transform2_imag = 0;
			end
			
			transform1_valid = f_valid1;
			transform2_valid = f_valid2;
			
			if(transform1_rdy) 
				n_valid1 = 0;

			if(transform2_rdy) 
				n_valid2 = 0;
				
			if((~f_valid1) & (~f_valid2)) begin
				n_state = 13;
				n_counterx = f_counterx + 2;
			end
			
		end	
		13: begin
			if(f_counterx == 256) begin
				n_state = 0;
			end else
			begin
				n_addrx = f_addrx + 1;
				n_state = 9;
			end
			
		end
		default:;
	endcase

end

endmodule

