
module BLEUART_av(

	input clk,
	input rst,
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg avs_s0_waitrequest = 'b0,
	output reg[31:0] avs_s0_readdata = 'b0,
	
	output reg avm_s0_irq = 'b0,
	
	input irq,
	input error,
	
	output reg read = 'b0,
	input[7:0] read_data,
	input read_empty,
	
	output reg write = 'b0,
	output reg[7:0] write_data = 'b0,
	input write_full,
	
	input uart_status,
	output reg uart_enable = 1'b0

);


always@(posedge clk)
	if(rst) begin
		avm_s0_irq = 'b0;
	end else
	begin
		
		if(irq) begin
			avm_s0_irq = 'b1;
		end
		
		if(avs_s0_write) begin
			case(avs_s0_address)
				0: begin
					avm_s0_irq = 'b0;
				end
			endcase
		end
		
		
	end

always@(posedge clk)
	if(rst) begin
		write = 'b0;
		write_data = 'b0;
		uart_enable = 1'b0;
	end else
	begin
		
		write = 'b0;
		write_data = 'b0;
		
		if(avs_s0_write) begin
			case(avs_s0_address)
				1: begin
					write = 'b1;
					write_data = avs_s0_writedata[7:0];
				end
				4: begin
					uart_enable = avs_s0_writedata[0];
				end
			endcase
		end
		
		
	end
	
reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;


always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
	end else
	begin
		f_state <= n_state;
	end
	
always@(*) begin

	n_state = f_state;
	
	avs_s0_waitrequest = 'b0;
	avs_s0_readdata = 'b0;	
	
	read = 'b0;
	
	case(f_state)
		0: begin
			
			if(avs_s0_read) begin
				avs_s0_waitrequest = 'b1;
			
				case(avs_s0_address)
					2: begin
						n_state = 3;
					end
					3: begin
						n_state = 1;
					end
					4: begin
						n_state = 4;
					end
					default:;
				endcase
			end
			
		end
		1: begin
			avs_s0_waitrequest = 'b1;
			read = 'b1;
			
			n_state = 2;
		end
		2: begin
			avs_s0_readdata = {24'b1,read_data};	
			n_state = 0;
		end
		3: begin
			avs_s0_readdata = {error,read_empty,write_full};
			n_state = 0;
		end
		4: begin
			avs_s0_readdata = {uart_status,uart_enable};
			n_state = 0;		
		end
		
	endcase
	
	
end


endmodule