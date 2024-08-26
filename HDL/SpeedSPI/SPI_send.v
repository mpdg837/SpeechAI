
module SPI_send(
	input clk,
	input rst,
	
	input tick,
	
	// spi
	output reg spi_sclk = 1'b1,
	output reg spi_miso = 1'b1,
	output reg spi_cs = 1'b1,
	
	// inside interface
	
	input[7:0] data,
	input start,
	
	output reg rdy,
	output reg mutex
);

localparam IDLE 		= 4'b0000;
localparam INIT 		= 4'b0001;
localparam SET_BIT 	= 4'b0010;
localparam CHECK_BIT = 4'b0100;
localparam FINISH 	= 4'b1000;

reg f_spi_sclk = 1'b1;
reg f_spi_miso = 1'b1;
reg f_spi_cs = 1'b1;

reg f_mutex = 1'b0;

reg[3:0] f_state = 'b0;
reg[3:0] n_state = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[3:0] f_num = 'b0;
reg[3:0] n_num = 'b0;

always@(posedge clk)
	if(rst) begin
		f_spi_sclk = 'b1;
		f_spi_miso = 'b1;
		f_spi_cs = 'b1;
		
		f_state = IDLE;
		f_mem = 'b0;
		f_num = 'b0;
		
		f_mutex = 'b0;
	end else
	begin
		f_spi_sclk = spi_sclk;
		f_spi_miso = spi_miso;
		f_spi_cs = spi_cs;
		
		f_state = n_state;
		f_mem = n_mem;
		f_num = n_num;
		
		f_mutex = mutex;
	end

always@(*) begin
	n_state = f_state;

	case(f_state)
	
			IDLE:
				if(start)
					n_state = INIT;
			
			INIT: if(tick) 
						n_state = SET_BIT;
			SET_BIT: if(tick)
							n_state = CHECK_BIT;
			CHECK_BIT:
					if(tick)
						if(f_num == 8) 
							n_state = FINISH;
						else 
							n_state = SET_BIT;
					
			FINISH: if(tick)
						  n_state = IDLE;
		endcase
		
end

always@(*)
	begin
		n_mem = f_mem;
		n_num = f_num;		
		
		mutex = f_mutex;
		rdy = 0;
		
		case(f_state)
			IDLE: begin
				mutex = 0;
				
				if(start)begin
					n_mem = data;
					n_num = 'b0;
				end
				
			end
			INIT: if(tick)
						 mutex = 1;
			SET_BIT: if(tick) begin
				mutex = 1;
				
				n_num = f_num + 1;
					
			end
			CHECK_BIT: if(tick) begin
				mutex = 1;
			end
			FINISH: if(tick) begin
				mutex = 1;
				rdy = 1;
			end
		
		endcase
		
	end

always@(*)
	begin
		spi_sclk = f_spi_sclk;
		spi_miso = f_spi_miso;
		spi_cs = f_spi_cs;
		
		case(f_state)
			IDLE: begin
				
				spi_sclk = 1'b0;
				spi_miso = 1'b1;
				spi_cs = 1'b1;
				
			end
			INIT: if(tick) begin
					
					spi_sclk = 1'b0;
					spi_cs = 1'b0;	
					
					spi_miso = f_mem[7];
			
			end
			SET_BIT: if(tick) begin
				
				spi_sclk = 1'b1;
					
				spi_miso = f_mem[7 - f_num];
				
				
			end
			CHECK_BIT: if(tick) begin
				
				spi_sclk = 1'b0;
					
				if(f_num == 8)
					spi_miso = 1'b1;
				else
					spi_miso = f_mem[7 - f_num];
				
			end
			FINISH: if(tick) begin
				
				spi_sclk = 1'b0;
					
				spi_miso = 1'b1;
				spi_cs = 1'b1;	
				
			end		
		endcase
		
	end
	
endmodule
