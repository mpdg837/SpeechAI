
module SPI_starter#(
	parameter OFFSET = 2'd0
)(
	
	input clk,
	input rst,
	
	input in_irq,
	output reg irq = 'b0,
	output reg[1:0] error = 'b0,
	output reg success = 'b0,
	
	input avs_s1_write,
	input[15:0] avs_s1_address, 
	
	output reg avs_s0_read = 'b0,
	output reg avs_s0_write = 'b0,
	output reg[15:0] avs_s0_address = 'b0,
	output reg[31:0] avs_s0_writedata = 'b0,
	
	input[31:0] avs_s0_readdata
	
);


localparam READ_READ_BYTE = 3'h2;

localparam COMMAND = 3'h1;
localparam CLOSE = 3'h3;
localparam INIT = 3'h4;
localparam OPEN = 3'h5;
localparam SPEED = 3'h6;

wire out_irq;

SPI_irq_sleeper sis(
	.clk(clk),
	.rst(rst),
	
	.in_irq(in_irq),
	.irq_out(out_irq)
);


reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[7:0] f_arg1 = 'b0;
reg[7:0] n_arg1 = 'b0;

reg[7:0] f_arg2 = 'b0;
reg[7:0] n_arg2 = 'b0;

reg[7:0] f_arg3 = 'b0;
reg[7:0] n_arg3 = 'b0;

reg[7:0] f_arg4 = 'b0;
reg[7:0] n_arg4 = 'b0;

reg[3:0] f_state = 'b0;
reg[3:0] n_state = 'b0;

reg[11:0] f_retries = 'b0;
reg[11:0] n_retries = 'b0;

reg[2:0] f_command = 'b0;
reg[2:0] n_command = 'b0;

reg[7:0] f_sleep = 'b0;
reg[7:0] n_sleep = 'b0;

reg[2:0] f_read_an = 'b0;
reg[2:0] n_read_an = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_retries <= 'b0;
		f_command <= 'b0;
		f_mem <= 'b0;
		f_sleep <= 'b0;
		
		f_read_an <= 'b0;
		
		f_arg1 <= 'b0;
		f_arg2 <= 'b0;
		f_arg3 <= 'b0;
		f_arg4 <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_retries <= n_retries;
		f_command <= n_command;
		f_mem <= n_mem;
		f_sleep <= n_sleep;
		
		f_read_an <= n_read_an;
		
		f_arg1 <= n_arg1;
		f_arg2 <= n_arg2;
		f_arg3 <= n_arg3;
		f_arg4 <= n_arg4;
		
	end

always@(*) begin
	n_state = f_state;
	n_retries = f_retries;
	n_command = f_command;
	n_mem = f_mem;
	n_sleep = f_sleep;
	
	n_read_an = f_read_an;
	
	n_arg1 = f_arg1;
	n_arg2 = f_arg2;
	n_arg3 = f_arg3;
	n_arg4 = f_arg4;
	avs_s0_read = 'b0;
	avs_s0_write = 'b0;
	avs_s0_address = 'b0;
	avs_s0_writedata = 'b0;
	
	irq = 0;
	error = 0;
	success = 0;
	
	case(f_state)
		0: begin
			if(avs_s1_write)
				case(avs_s1_address) 
					{OFFSET + 1}: begin
						n_state = 1;
						
						avs_s0_write = 'b1;
						avs_s0_address = {2'd0,1'b0,SPEED};
						avs_s0_writedata = 0;
						
					end
				endcase
		end
		1: begin
		
			n_mem = 'b0;
			n_retries = 'b0;
			n_command = 'b0;
			n_sleep = 'b0;
			n_read_an = 'b0;
			
			avs_s0_write = 'b1;
			avs_s0_address = {2'd0,1'b0,INIT};
			avs_s0_writedata = 0;
			n_state = 2;
		end
		2: if(out_irq)
				n_state = 3;
		3: begin
			avs_s0_write = 'b1;
			avs_s0_address = {2'd0,1'b0,COMMAND};
			
			case(f_command) 
				0: begin
					avs_s0_writedata = {8'd0,24'h0};
				end
				1: begin
					avs_s0_writedata = {8'd8,24'h1AA};
				end
				2: begin
					avs_s0_writedata = {8'd58,24'h0};
				end
				3: begin
					avs_s0_writedata = {8'd55,24'h0};
				end
				4: begin
					avs_s0_writedata = {{8'd41 | 8'h40} , 24'h0};
				end
				5: begin
					avs_s0_writedata = {8'd58,24'd0};
				end	
			endcase
			
			n_state = 4;		
		end
		4: begin
			if(out_irq) begin
				n_state = 5;
				
				avs_s0_write = 'b1;
				avs_s0_address = {2'd0,1'b0,OPEN};
				avs_s0_writedata = 16;
				
			end
		end
		5: if(out_irq) begin
				n_read_an = 0;
				n_state = 6;
				
			end
		6: begin
			avs_s0_read = 'b1;
			avs_s0_address = {2'd0,1'b0,READ_READ_BYTE};
			avs_s0_writedata = 16;
		
			n_state = 7;
			n_sleep = 0;
		end
		7: begin
			case(f_read_an)
				1: n_mem = avs_s0_readdata[7:0];
				2: n_arg1 = avs_s0_readdata[7:0];
				3: n_arg2 = avs_s0_readdata[7:0];
				4: n_arg3 = avs_s0_readdata[7:0];
				5: n_arg4 = avs_s0_readdata[7:0];
			endcase
			
			
			n_state = 8;
		end
		8: begin
			n_sleep = f_sleep + 1;
			
			if(f_sleep == 255) begin
				n_state = 9;
			end
		end
		9: begin
			n_read_an = f_read_an + 1;
			
			if(f_read_an == 5) begin
				n_state = 10; 
			end else
			begin
				n_state = 6;
			end
		end
		10: begin
			
			n_retries = f_retries + 1;
			
			case(f_command)
				0: n_command = 1;
				1: n_command = 2;
				2: n_command = 3;
				3: n_command = 4;
				4: begin
					if(f_mem == 0) begin
						n_command = 5;
					end else
					begin
						n_command = 3;
					end
				end
				5: n_command = 0;
			endcase

				
			if(f_mem == 0 || f_mem == 1) begin
			
				
				if(f_command == 1) begin
					
					if(f_arg4 == 8'hAA) begin
						n_state = 3;
					end else
					begin
						n_state = 11;
						error = 2'b11;
					end
					
				end else
				begin
				
					if(f_command == 5) begin
						success = 1;
					end
					
					if(f_retries == 4095)
						error = 2'b11;
					
					if(f_command == 5 || f_retries == 4095) begin
						n_state = 11;
					end else
					begin
						n_state = 3;
					end
				
				end
			end
			else begin
				error = 2'b10;
				n_state = 11;
			end
			

		end
		11: begin
			irq = 1;
			n_state = 0;
			
			
			avs_s0_write = 'b1;
			avs_s0_address = {2'd0,1'b0,SPEED};
			avs_s0_writedata = 1;
						
		end
	endcase
end

endmodule
