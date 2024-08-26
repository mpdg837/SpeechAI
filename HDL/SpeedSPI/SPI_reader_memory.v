module SPI_reader_memory#(
	parameter ADDR = 3'd7
)(
	input clk,
	input rst,
	
	// MM
	
	input[31:0] startaddr,
	input[15:0] len_sector,
	input[15:0] sector,
	input start,
	
	output reg irq = 'b0,
	output reg error = 'b0,
	
	// tocore
	
	input iirq,
	
	output reg avs_s1_write = 'b0,
	output reg avs_s1_read = 'b0,
	output reg[11:0] avs_s1_address = 'b0,
	output reg[31:0] avs_s1_writedata = 'b0,
	
	input[31:0] avs_s1_readdata,
	
	// DMA
	
	output reg[31:0] dma_addr = 'b0,
	output reg dma_read = 'b0,
	output reg dma_write = 'b0,
	output reg[31:0] dma_writedata = 'b0,
	input[31:0] dma_readdata,
	input dma_rdy,
	
	output[31:0] crc_out
);

reg[31:0] b_startaddr = 'b0;
reg[15:0] b_len_sector = 'b0;
reg[15:0] b_sector = 'b0;
reg 		 b_start = 'b0;

	
always@(posedge clk) 
	if(rst) begin
		b_startaddr <= 'b0;
		b_len_sector <= 'b0;
		b_sector <= 'b0;
		b_start <= 'b0;	
	end else
	begin
		b_startaddr <= startaddr;
		b_len_sector <= len_sector;
		b_sector <= sector;
		b_start <= start;		
	end
	
reg[7:0] crc_data_in = 'b0;
reg crc_start = 'b0;
reg crc_clr = 'b0;


SPI_QCRC64_ISO sqci(
  .rst(rst),
  .clk(clk),
  
  .data_in(crc_data_in),
  .start(crc_start),
  .clr(crc_clr),
  
  .crc_out(crc_out)
);

localparam READ_READ_BYTE = 3'h2;

localparam COMMAND = 3'h1;
localparam CLOSE = 3'h3;
localparam INIT = 3'h4;
localparam OPEN = 3'h5;
localparam SPEED = 3'h6;


reg[3:0] f_state = 'b0;
reg[3:0] n_state = 'b0;

reg[31:0] f_addr = 'b0;
reg[31:0] n_addr = 'b0;

reg[15:0] f_sectorcounter = 'b0;
reg[15:0] n_sectorcounter = 'b0;

reg[9:0] f_counter = 'b0;
reg[9:0] n_counter = 'b0;

reg[1:0] f_byte = 'b0;
reg[1:0] n_byte = 'b0;

reg[7:0] f_mem1 = 'b0;
reg[7:0] n_mem1 = 'b0;

reg[7:0] f_mem2 = 'b0;
reg[7:0] n_mem2 = 'b0;

reg[7:0] f_mem3 = 'b0;
reg[7:0] n_mem3 = 'b0;

reg[7:0] f_mem4 = 'b0;
reg[7:0] n_mem4 = 'b0;

reg[7:0] n_mem = 'b0;
reg[7:0] f_mem = 'b0;

reg[3:0] f_sleep = 'b0;
reg[3:0] n_sleep = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_addr <= 'b0;
		f_sectorcounter <= 'b0;
		f_counter <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		f_mem3 <= 'b0;
		f_mem4 <= 'b0;
		
		f_byte <= 0;
		f_mem <= 0;
		
		f_sleep <= 0;
	end else
	begin
		f_state <= n_state;
		f_addr <= n_addr;
		f_sectorcounter <= n_sectorcounter;
		f_counter <= n_counter;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		f_mem3 <= n_mem3;
		f_mem4 <= n_mem4;
		
		f_byte <= n_byte;
		f_mem <= n_mem;
		
		f_sleep <= n_sleep;
	end

always@(*) begin
	n_state = f_state;
	
	n_addr = f_addr;
	n_sectorcounter = f_sectorcounter;
	n_counter = f_counter;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	n_mem3 = f_mem3;
	n_mem4 = f_mem4;
	
	n_byte = f_byte;
	n_mem = f_mem;
	
	n_sleep = f_sleep;
	
	irq = 'b0;
	
	avs_s1_write = 'b0;
	avs_s1_read = 'b0;
	avs_s1_address = 'b0;
   avs_s1_writedata = 'b0;
	
	dma_addr = 'b0;
	dma_read = 'b0;
	dma_write = 'b0;
	dma_writedata = 'b0;
	
	crc_data_in = 'b0;
	crc_start = 'b0;
	crc_clr = 'b0;
	
	error = 'b0;
	
	case(f_state)
		0: if(b_start) begin
			n_addr = b_startaddr;
			n_sectorcounter = 0;
			n_counter = 0;
			n_byte = 0;
			
			crc_clr = 'b1;
			
			n_mem = 0;
			n_mem1 = 0;
			n_mem2 = 0;
			n_mem3 = 0;
			n_mem4 = 0;
			
			n_state = 1;
			n_sleep = 0;
		end
		1: begin
			avs_s1_write = 'b1;
			avs_s1_address = {2'd0,1'b0,COMMAND};
			avs_s1_writedata = {8'd18,4'd0,b_sector,4'd0};
			
			n_state = 2;
		end
		
		2: if(iirq) begin
			n_state = 3;
			
		end
		3: begin
			avs_s1_write = 'b1;
			avs_s1_address = {2'd0,1'b0,OPEN};
			avs_s1_writedata = 514;
			
			n_state = 4;
		end
		4: if(iirq) begin
			n_state = 5;
			
		end
		5: begin
			avs_s1_read = 'b1;
			avs_s1_address = {2'd0,1'b0,READ_READ_BYTE};
			avs_s1_writedata = 16;
			
			n_sleep = 0;
			n_state = 6;
		end
		6: begin
			
			n_sleep = f_sleep + 1;
			
			case(f_sleep)
				0: begin
						n_mem = avs_s1_readdata[7:0];
						
						crc_data_in = avs_s1_readdata[7:0];
						crc_start = 'b1;
					end
				7: begin
					n_counter = f_counter + 1;
				
					case(f_counter) 
						0: n_state = 5;
						1: if(f_mem == 0)
								n_state = 5;
							else begin
								n_state = 15;
								error = 1;
							end
						default: n_state = 7;
					endcase
					
				end
			endcase
		
		
		end
		7: begin
			n_byte = f_byte + 1;
			
			case(f_byte)
				0: n_mem1 = f_mem;
				1: n_mem2 = f_mem;
				2: n_mem3 = f_mem;
				3: n_mem4 = f_mem;
			endcase
			
			if(f_byte == 3) begin
				n_state = 8;
			end else
			begin
				n_state = 5;
			end
				
		end
		8: begin
			n_byte = 0;
			
			dma_addr = f_addr;
			dma_write = 1;
			dma_writedata = {f_mem4,f_mem3,f_mem2,f_mem1};
			
			n_state = 9;
		end
		9: if(dma_rdy) begin
			n_addr = f_addr + 4;
			
			if(f_counter == 514) begin
				n_state = 10;
				n_counter = 0;
			end else
			begin
				n_state = 5;
			end
			
		end
		10: begin
			n_counter = 0;
			n_byte = 0;
			
			n_sectorcounter = f_sectorcounter + 1;
			
			if(f_sectorcounter == b_len_sector) begin
				n_counter = 0;
				n_state = 11;
				
				
			end else
			begin
				
				n_state = 3;
			end
			
		end
		11: begin
			avs_s1_write = 'b1;
			avs_s1_address = {2'd0,1'b0,COMMAND};
			avs_s1_writedata = {8'd12,24'd0};			
			
			n_state = 12;
		end
		12: if(iirq) begin
			n_state = 13;
		end
		13: begin
			avs_s1_write = 'b1;
			avs_s1_address = {2'd0,1'b0,OPEN};
			avs_s1_writedata = 16;
			n_state = 14;
		end
		14: if(iirq) begin
			n_state = 15;
		end
		15: begin
			irq = 1;
			n_state = 0;		
		
		end
		default:;
		
		
	endcase

end

endmodule