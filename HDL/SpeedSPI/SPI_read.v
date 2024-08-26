

module SPI_read(
	input clk,
	input rst,
	
	input[1:0] speed,
	input tick,
	// spi
	output reg spi_sclk = 1'b1,
	input spi_mosi,
	
	// inside interface
	
	output reg[7:0] data = 'b0,
	input start,
	
	output reg rdy,
	output reg mutex
);

localparam IDLE 		= 3'b00;
localparam SET_BIT 	= 3'b01;
localparam CHECK_BIT	= 3'b10;

reg f_spi_sclk = 1'b1;
reg f_mutex = 1'b0;

reg[2:0] f_state = 'b0;
reg[2:0] n_state = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[3:0] f_num = 'b0;
reg[3:0] n_num = 'b0;

always@(posedge clk)
	if(rst) begin
		f_spi_sclk = 'b1;
		
		f_state = 'b0;
		f_mem = 'b0;
		f_num = 'b0;
		
		f_mutex = 'b0;
	end else
	begin
		f_spi_sclk = spi_sclk;
		
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
					n_state = SET_BIT;
			
			SET_BIT: if(tick)
							n_state = CHECK_BIT;		
			CHECK_BIT:
					if(tick)
						if(f_num == 8) 
							n_state = IDLE;
						else 
							n_state = SET_BIT;	
		endcase
		
end

always@(*)
	begin
		n_mem = f_mem;
		n_num = f_num;		
		
		mutex = f_mutex;
		rdy = 0;
		data = 0;
		
		case(f_state)
			IDLE: begin
					mutex = 0;
				
					if(start)begin
						n_num = 'b0;
						n_mem = 'h0;
						mutex = 1'b1;
					end
					
				end
			SET_BIT:  if(tick) begin
					
						mutex = 1;
						n_num = f_num + 1;
						
					end
			CHECK_BIT: if(tick) begin
					mutex = 1;
					n_mem = {f_mem[6:0],spi_mosi};
					
					if(f_num == 8) begin
						data = {f_mem[6:0],spi_mosi};
						rdy = 1;
					end
						
				end
		endcase
		
	end

always@(*)
	begin
		spi_sclk = f_spi_sclk;
		
		case(f_state)
			IDLE: begin
				if(start)
					spi_sclk = 1'b1;
				else
					spi_sclk = 1'b0;
			end
			SET_BIT: if(tick) begin
				
				spi_sclk = 1'b1;
					
				
			end
			CHECK_BIT: if(tick) begin
				
				spi_sclk = 1'b0;
					
				
			end
		endcase
		
	end
	
endmodule

module SPI_read_fast(
	input clk,
	input rst,
	input[1:0] speed,
	
	input tick,
	// spi
	output reg spi_sclk = 1'b1,
	input spi_mosi,
	
	// inside interface
	
	output reg[7:0] data = 'b0,
	output reg rdy,
	
	input start,
	
	output reg mutex
);

localparam IDLE 		 = 6'b000000;
localparam IDLE1 		 = 6'b000001;
localparam SET_BIT 	 = 6'b000010;
localparam WAIT 		 = 6'b000100;
localparam CHECK_BIT  = 6'b001000;
localparam FINISH     = 6'b010000;
localparam FINISH1    = 6'b100000;

reg b_start = 'b0;
reg[1:0] b_speed = 'b0;

always@(posedge clk)
	b_speed <= speed;
	
reg f_spi_sclk = 1'b1;
reg f_mutex = 1'b0;

reg[5:0] f_state = 'b0;
reg[5:0] n_state = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[3:0] f_num = 'b0;
reg[3:0] n_num = 'b0;

reg n_buff = 'b0;
reg f_buff = 'b0;

always@(posedge clk)
	if(rst) begin
		f_spi_sclk = 'b1;
		
		f_state = 'b0;
		f_mem = 'b0;
		f_num = 'b0;
		
		f_mutex = 'b0;
		f_buff = 'b0;
	end else
	begin
		f_spi_sclk = spi_sclk;
		
		f_state = n_state;
		f_mem = n_mem;
		f_num = n_num;
		
		f_mutex = mutex;
		f_buff = n_buff;
	end

always@(*) begin
	n_state = f_state;

	case(f_state)
	
			IDLE:
				if(start)
					n_state = SET_BIT;
					
			IDLE1: if(tick)
						n_state = SET_BIT;
						
			SET_BIT: if(tick)
							if(b_speed[0])
								n_state = CHECK_BIT;
							else 
								n_state = WAIT;
			
			WAIT:		if(tick)
							n_state = CHECK_BIT;
			CHECK_BIT:
					if(tick)
						if(f_num == 8) 
							n_state = FINISH;
						else 
							n_state = IDLE1;
		   FINISH: if(tick)
						n_state = FINISH1;
		   FINISH1: if(tick)
						n_state = IDLE;						
		endcase
		
end


always@(*)
	begin
		n_mem = f_mem;
		n_num = f_num;		
		n_buff = f_buff;
		
		mutex = f_mutex;
		rdy = 0;
		data = 0;
		
		data = {f_mem[6:0],f_buff};
		
		case(f_state)
			IDLE: begin
				
				
				if(start)begin
					mutex = 1'b1;
					
					n_num = 'b1;
					n_mem = 'h0;
					
					n_buff = 'b0;
					
				end
				
			end
			IDLE1:if(tick) begin
						mutex = 1;
						n_num = f_num + 1;
						
						n_mem = {f_mem[6:0],f_buff};
					end
			SET_BIT: if(tick) begin
					
					mutex = 1;
				end
			WAIT: if(tick) mutex = 1;
			CHECK_BIT: if(tick) begin
					mutex = 1;
					n_buff = spi_mosi;
					
					data = {f_mem[6:0],spi_mosi};
					
					if(f_num == 8) begin	
						rdy = 1;
					end
						
				end
			FINISH: if(tick) begin
				mutex = 1;
				
				rdy = 1;			
			end
			FINISH1: if(tick) begin
				mutex = 1;
				rdy = 1;			
			end
		endcase
		
	end

always@(*)
	begin
		spi_sclk = f_spi_sclk;
		
		case(f_state)
			IDLE: begin
				if(start) 
					spi_sclk = 1'b1;
				else
					spi_sclk = 1'b0;
			end
			IDLE1: if(tick) begin
				
				spi_sclk = 1'b1;
					
				
			end
			IDLE: if(tick) begin
				
				spi_sclk = 1'b1;
					
				
			end
			default: if(tick) begin
				
				spi_sclk = 1'b0;
					
				
			end
		endcase
		
	end
	
endmodule
