module SPI_initizer(
	
	input clk,
	input rst,
	
	output reg spi_cs = 1'b0,
	
	input close,
	input init_start,
	output reg i_rdy = 'b0,
	
	output reg start = 'b0,
	output reg[7:0] data ='b0,
	
	input rdy
);

localparam IDLE 	= 4'b0000;
localparam SEND 	= 4'b0001;
localparam WAIT 	= 4'b0010;
localparam CHECK 	= 4'b0100;
localparam FINISH = 4'b1000;

reg[7:0] f_num = 'b0;
reg[7:0] n_num = 'b0;

reg[3:0] f_state = 'b0;
reg[3:0] n_state = 'b0;

reg f_spi_cs = 1'b1;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		f_num <= 'b0;
		f_spi_cs <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_num <= n_num;
		f_spi_cs <= spi_cs;
	end
	
always@(*) begin
	n_state = f_state;
	n_num = f_num;
	spi_cs = f_spi_cs;
	
	i_rdy = 'b0;
	start = 'b0;
	data ='b0;
	
	if(close)
		spi_cs = 1;
		
	case(f_state)
		IDLE: begin
			if(init_start) begin
				spi_cs = 1;
				n_num = 0;
				n_state = SEND;
			end
		end
		SEND: begin
			start = 1'b1;
			data = 8'hFF;
			n_state = WAIT;
		end
		WAIT: begin
			
			if(rdy) begin
				n_state = CHECK;
			end
			
		end
		CHECK: begin
			if(f_num == 255) begin
				n_state = FINISH;
			end else
			begin
				n_state = SEND;
				n_num = f_num + 1;
			end
		end
		FINISH: begin
			spi_cs = 0;
			i_rdy = 1;
			n_state = IDLE;
		end
		
	endcase
end
	
endmodule
