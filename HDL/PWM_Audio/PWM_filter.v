module PWM_filter(
	input clk,
	input rst,
	
	input enable,
	
	input[15:0] data_in,
	input data_in_rdy,
	
	output reg[15:0] data_out = 0,
	output reg data_out_rdy = 0
);

reg[23:0] b_data_in;
reg b_data_in_rdy;

always@(posedge clk)
	if(rst) begin
		b_data_in <= 'b0;
		b_data_in_rdy <= 'b0;
	end else
	begin
		b_data_in <= data_in;
		b_data_in_rdy <= data_in_rdy;	
	end
	
localparam SIZE = 24;
localparam MAX_SIZE = 24;

integer n = 0;

reg[15:0] code[(MAX_SIZE - 1):0];

reg[15:0] f_signal1[(SIZE - 1):0];
reg[15:0] n_signal1[(SIZE - 1):0];

initial begin
	code[0] = 16'hfec8;
	code[1] = 16'hff26;
	code[2] = 16'hffbf;
	code[3] = 16'h94;
	code[4] = 16'h1a0;
	code[5] = 16'h2db;
	code[6] = 16'h437;
	code[7] = 16'h5a2;
	code[8] = 16'h708;
	code[9] = 16'h853;
	code[10] = 16'h96f;
	code[11] = 16'ha48;
	code[12] = 16'had1;
	code[13] = 16'haff;
	code[14] = 16'had1;
	code[15] = 16'ha48;
	code[16] = 16'h96f;
	code[17] = 16'h853;
	code[18] = 16'h708;
	code[19] = 16'h5a2;
	code[20] = 16'h437;
	code[21] = 16'h2db;
	code[22] = 16'h1a0;
	code[23] = 16'h94;
end

// first
reg start1 = 'b0;

always@(posedge clk)
	if(rst) begin
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			f_signal1[n] <= 'b0;
		end
		
	end
	else begin
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			f_signal1[n] <= n_signal1[n];
		end		
	end
	
always@(*) begin
	for(n = 0 ; n < SIZE ; n = n + 1) begin
		n_signal1[n] = f_signal1[n];
	end		
	
	start1 = 'b0;
	
	if(b_data_in_rdy) begin
		start1 = 1'b1;
		
		for(n = 1 ; n < SIZE ; n = n + 1) begin
			n_signal1[n] = f_signal1[n - 1];
		end
		
		n_signal1[0] = b_data_in;
	end
	
end

// buffer
reg[15:0] b_signal1[(SIZE - 1):0];
reg 		 b_start;

always@(posedge clk)
	if(rst) begin
		for(n=0;n< SIZE ; n=n+1) begin
			b_signal1[n] <= 'b0;
		end
		b_start <= 'b0;
	end else
	begin
		for(n=0;n< SIZE ; n=n+1) begin
			b_signal1[n] <= n_signal1[n];
		end
		b_start <= start1;
	end
	
// second

reg[15:0] mul1[(SIZE - 1):0];
reg[15:0] mul2[(SIZE - 1):0];

reg minus2[(SIZE - 1):0];
reg start2 = 'b0;

reg[15:0] check1;
reg[15:0] check2;

always@(posedge clk)
	if(rst) begin
		
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			mul2[n] <= 'b0;
			mul1[n] <= 'b0;
			minus2[n] <= 'b0;
		end
		start2 <= 'b0;
		
	end
	else begin
		if(b_start) begin
			for(n = 0 ; n < SIZE ; n = n + 1) begin
				
				check1 = b_signal1[n];
				check2 = code[n];
				
				case({check1[15],check2[15]})
					2'b00: begin
						minus2[n] = 0;
						
						mul1[n] = b_signal1[n];
						mul2[n] = code[n];
					end
					2'b10: begin
						minus2[n] = 1;
						
						mul1[n] = ~b_signal1[n];
						mul2[n] = code[n];
					end
					2'b01: begin
						minus2[n] = 1;

						mul1[n] = b_signal1[n];
						mul2[n] = ~code[n];
					end
					2'b11: begin
						minus2[n] = 0;
						
						mul1[n] = ~b_signal1[n];
						mul2[n] = ~code[n];
					end
					
				endcase
				
			end
			start2 <= 'b1;	
		end else
		begin
		
			for(n = 0 ; n < SIZE ; n = n + 1) begin
			
				
				mul2[n] <= 'b0;
				mul1[n] <= 'b0;
				minus2[n] <= 'b0;
				
				
			end
			start2 <= 'b0;		
		
		end
		
	end

// buffer

reg[15:0] b_mul1[(SIZE - 1):0];
reg[15:0] b_mul2[(SIZE - 1):0];

reg b_minus2[(SIZE - 1):0];
reg b_start2 = 'b0;

always@(posedge clk)
	if(rst) begin
	
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			b_mul1[n] <= 'b0;
			b_mul2[n] <= 'b0;

			b_minus2[n] <= 'b0;
		end
		
		b_start2 <= 'b0;
	
	end else
	begin
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			b_mul1[n] <= mul1[n];
			b_mul2[n] <= mul2[n];

			b_minus2[n] <= minus2[n];
		end
		
		b_start2 <= start2;
	end
	
// third

reg[31:0] mulresult[(SIZE - 1):0];
reg minus3[(SIZE - 1):0];
reg start3;

always@(posedge clk)
	if(rst) begin
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			mulresult[n] <= 'b0;
			minus3[n] <= 'b0;
		end	
		start3<='b0;
	end else
	begin
		if(b_start2) begin
			
			for(n = 0 ; n < SIZE ; n = n + 1) begin
				mulresult[n] <= b_mul1[n] * b_mul2[n];
				minus3[n] <= b_minus2[n];
			end	
			start3 <= 'b1;	
		end else
		begin
			for(n = 0 ; n < SIZE ; n = n + 1) begin
				mulresult[n] <= 'b0;
				minus3[n] <= 'b0;
			end	
			start3 <= 'b0;		
		end
		
	end
	
// fourth

reg[31:0] result[(SIZE - 1):0];
reg start4;

always@(posedge clk)
	if(rst) begin
		for(n = 0 ; n < SIZE ; n = n + 1) begin
			result[n] <= 'b0;
		end	
		start4<='b0;
	end else
	begin
		if(start3) begin
			
			for(n = 0 ; n < SIZE ; n = n + 1) begin
			
				if(minus3[n]) 
					result[n] <= ~mulresult[n];
				else
					result[n] <= mulresult[n];
			end	
			start4 <= 'b1;	
		end else
		begin
			for(n = 0 ; n < SIZE ; n = n + 1) begin
				result[n] <= 'b0;
			end	
			start4 <= 'b0;		
		end
		
	end

// fifth

reg[31:0] sum1;
reg[31:0] sum2;
reg[31:0] sum3;
reg[31:0] sum4;
reg[31:0] sum5;
reg[31:0] sum6;

reg start5;

always@(posedge clk)
	if(rst) begin
		sum1 <= 'b0;
		sum2 <= 'b0;
		sum3 <= 'b0;
		sum4 <= 'b0;
		sum5 <= 'b0;
		sum6 <= 'b0;
		
		start5 <='b0;
	end else
	begin
	
		if(start4) begin
			
			sum1 <= result[0] + result[1] + result[2] + result[3];
			sum2 <= result[4] + result[5] + result[6] + result[7];
			sum3 <= result[8] + result[9] + result[10] + result[11];
			sum4 <= result[12] + result[13] + result[14] + result[15];
			sum5 <= result[16] + result[17] + result[18] + result[19];
			sum6 <= result[20] + result[21] + result[22] + result[23];
			
			start5 <='b1;
			
		end else
		begin
			sum1 <= 'b0;
			sum2 <= 'b0;
			sum3 <= 'b0;
			sum4 <= 'b0;
			sum5 <= 'b0;
			sum6 <= 'b0;
			
			start5 <='b0;
		end
		
	end

// sixth

reg[31:0] b_sum1;
reg[31:0] b_sum2;
reg b_rdy;

always@(posedge clk)
	if(rst) begin
		b_rdy <= 'b0;
		b_sum1 <= 'b0;
		b_sum2 <= 'b0;
		
	end else
	begin
	
		if(start5) begin
			b_sum1 <= sum1 + sum2 + sum3;
			b_sum2 <= sum4 + sum5 + sum6;
			b_rdy <= 1'b1;
			
		end else
		begin
			b_sum1 <= 'b0;
			b_sum2 <= 'b0;
			b_rdy <= 1'b0;
			
		end
		
	end

// seventh

reg[31:0] bb_sum;
reg bb_rdy;

always@(posedge clk)
	if(rst) begin
		bb_rdy <= 'b0;
		bb_sum <= 'b0;
		
	end else
	begin
	
		if(b_rdy) begin
			bb_sum <= b_sum1 + b_sum2;
			bb_rdy <= 1'b1;
			
		end else
		begin
			bb_sum <= 'b0;
			bb_rdy <= 1'b0;
		end
		
	end
	
// eighth

always@(posedge clk)
	if(rst) begin
		data_out <= 'b0;
		data_out_rdy <= 'b0;
		
	end else
	begin
	
		data_out <= bb_sum[31:16];
		data_out_rdy <=  bb_rdy;
		
	end
	
endmodule
