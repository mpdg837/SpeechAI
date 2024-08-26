

module mic_parameters(
	input clk,
	input rst,
	
	output reg avm_s0_irq = 'b0,
	input irq,
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output reg[31:0] avs_s0_readdata = 'b0,	
	output reg avs_s0_waitrequest = 'b0,
	
	// Registers
	output reg read_audio = 'b0,
	output reg enable = 'b0,
	input[23:0] audio,
	
	input full,
	input empty
);

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[23:0] f_mem = 'b0;
reg[23:0] n_mem = 'b0;

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
	
	avs_s0_readdata = 'b0;
	avs_s0_waitrequest = 'b0;
	
	read_audio = 'b0;
	
	case(f_state)
		0: begin
		
			if(avs_s0_read) begin
				
				avs_s0_waitrequest = 'b1;
				
				case(avs_s0_address)
					2: n_state = 1;
					3: n_state = 3;
					default:;
				endcase
			end
			
		end
		1: begin
			avs_s0_waitrequest = 'b1;
			read_audio = 'b1;
			n_state = 2;
		end
		2: begin
			avs_s0_readdata = audio;
			n_state = 0;
		end
		3: begin
			avs_s0_readdata = {full,empty};
			n_state = 0;		
		end
		default:;
		
	endcase
	
end
always@(posedge clk)
	if(rst) begin
		enable = 0;
	end else
	begin
		
		
		if(avs_s0_write)
			case(avs_s0_address)
				1: enable = avs_s0_writedata[0];
				default:;
			endcase
	end
	
always@(posedge clk)
	if(rst) begin
		avm_s0_irq = 'b0;
	end else
	begin
		
		if(irq) begin
			avm_s0_irq = 1'b1;
		end
		
		if(avs_s0_write)
			case(avs_s0_address)
				0: avm_s0_irq = 1'b0;
			endcase
	end
	
endmodule

