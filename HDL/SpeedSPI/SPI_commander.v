
module SPI_commander(
	input clk,
	input rst,
	
	// Command interface
	input com_start,
	input[7:0] com_cmd,
	input[23:0] com_arg,
	
	output reg com_rdy,
	
	// Byte interface
	
	output reg start = 'b0,
	output reg[7:0] data = 'b0,
	
	input rdy
	
);

reg[7:0] crc_data_in = 'b0;
reg crc_start = 'b0;
reg crc_clr = 'b0;

wire[7:0] crc_out;
wire crc_rdy;

SPI_QCRC7 spi_qcrc(
				.rst(rst),
				.clk(clk),
  
				.data_in(crc_data_in),
				.start(crc_start),
				.clr(crc_clr),
  
				.crc_out(crc_out),
				.rdy(crc_rdy)
);

localparam IDLE 			 = 7'b0000000;
localparam SEND 			 = 7'b0000001;
localparam CRC 			 = 7'b0000010;
localparam WAIT_CRC 		 = 7'b0000100;
localparam WAIT_SEND 	 = 7'b0001000;
localparam CHECK 			 = 7'b0010000;
localparam SEND_CRC  	 = 7'b0100000;
localparam WAIT_SEND_CRC = 7'b1000000;

reg[7:0] f_command[4:0];
reg[7:0] n_command[4:0];

integer n=0;

reg[6:0] f_state = IDLE;
reg[6:0] n_state = IDLE;

reg[2:0] f_num = 'b0;
reg[2:0] n_num = 'b0;

reg[7:0] f_crc = 'b0;
reg[7:0] n_crc = 'b0;

initial begin
	for(n = 0 ; n < 5 ; n = n + 1) begin
		f_command[n] = 'b0;
		n_command[n] = 'b0;
	end
end

always@(posedge clk)
	if(rst) begin
		for(n = 0 ; n < 5 ; n = n + 1) begin
			f_command[n] <= 'b0;
		end
		f_state <= IDLE;
		f_num <= 'd0;
		f_crc <= 'b0;
	end else
	begin
		for(n = 0 ; n < 5 ; n = n + 1) begin
			f_command[n] <= n_command[n];
		end
		f_state <= n_state;
		f_num <= n_num;
		f_crc <= n_crc;
	end
	
always@(*) begin
	for(n = 0 ; n < 5 ; n = n + 1) begin
		n_command[n] = f_command[n];
	end
	
	n_num = f_num;
	n_state = f_state;
	n_crc = f_crc;
	
	crc_data_in = 'b0;
	crc_start = 'b0;
	crc_clr = 'b0;
	
	com_rdy = 'b0;
	
	start = 'b0; 
	data = 'b0;
	
	case(f_state)
		IDLE: begin
			if(com_start) begin
				
				n_num = 'b0;
				n_state = SEND;
				n_crc = 'b0;
				
				crc_clr = 1'b1;
				
				n_command[0] = {2'b01,com_cmd[5:0]};
				n_command[1] = {com_cmd[7:6],6'b0};
				n_command[2] = com_arg[23:16];
				n_command[3] = com_arg[15:8];
				n_command[4] = com_arg[7:0];
				
			end
		end
		SEND: begin
			
			start = 1'b1; 
			data = f_command[f_num];
						
			n_state = CRC;
		end
		CRC: begin
			crc_data_in = f_command[f_num];
			crc_start = 1'b1;
			
			n_state = WAIT_CRC;
		end
		WAIT_CRC: begin
			if(crc_rdy) begin
				n_crc = crc_out;
				n_state = WAIT_SEND;
			end
		end
		WAIT_SEND: begin
			if(rdy) begin
				n_state = CHECK;
			end
		end
		CHECK: begin
			if(f_num == 4) begin
				n_state = SEND_CRC;
			end else
			begin
				n_state = SEND;
				n_num = f_num + 1;
			end
		end
		SEND_CRC: begin
			start = 1'b1; 
			data = f_crc;
			n_state = WAIT_SEND_CRC;
		end
		WAIT_SEND_CRC: begin
			if(rdy) begin
				n_state = IDLE;
				com_rdy = 'b1;
			end
		end
	
	endcase
	
	
	
end


endmodule



module SPI_command_buffer(
	input clk,
	input rst,
	
	input[40:0] in_data,
	input			in_valid,
	output reg  in_ready = 'b0,
	
	output reg[40:0] out_data = 'b0,
	output reg		  out_valid = 'b0,
	input 			  out_ready
);

always@(posedge clk)	begin
		out_data <= in_data;
		out_valid <= in_valid;
		in_ready <= out_ready;
	end
endmodule

