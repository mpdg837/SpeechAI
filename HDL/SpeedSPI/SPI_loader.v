
module SPI_loader(
	input 	  		 clk,
	input 	  		 rst,
	
	input 			 init_r,
	input 			 init_p,
	input[31:0] 	 init_len,
	
	input    	  	 read_start,
	output reg[7:0] read_data = 'b0,
	output reg		 read_rdy = 'b0,
	output reg		 read_save = 1'b0,
	
	output reg 		 ostart = 1'b0,
	input[7:0] 		 odata, 
	input 	  		 ordy
);

localparam SIZE = 514;
localparam SIZE_LEN = 11;

reg in_read_rdy = 1'b0;
reg in_load_rdy = 1'b0;

always@(*) begin
	read_rdy <= in_read_rdy | in_load_rdy;
end

	
// Buffer mem


reg[(SIZE_LEN - 1):0] w_addr_buffer = 'b0;
reg w_buffer = 1'b0;
reg[7:0] in_buffer = 8'b0;

reg[(SIZE_LEN - 1):0] r_addr_buffer = 'b0;
wire[7:0] out_buffer;

RAMs buffer(
	.clock(clk),
	
	.data(in_buffer),
	.wraddress(w_addr_buffer),
	.wren(w_buffer),
	
	.rdaddress(r_addr_buffer),
	.q(out_buffer)
);
	


// to AXI

localparam READ_IDLE = 4'b0000;
localparam READ_READ = 4'b0001;
localparam READ_LOAD = 4'b0010;
localparam READ_SEND = 4'b0100;
localparam WAIT 		= 4'b1000;

reg[2:0] f_delay = 'b0;
reg[2:0] n_delay = 'b0;

reg[7:0] f_mem = 'b0;
reg[7:0] n_mem = 'b0;

reg[(SIZE_LEN - 1):0] f_num = 'b0;
reg[(SIZE_LEN - 1):0] n_num = 'b0;

reg[3:0] n_read_state = 'b0;
reg[3:0] f_read_state = 'b0;

always@(posedge clk)
	if(rst) begin
		f_mem <= 'b0;
		f_num <= 'b0;
		f_read_state <= READ_IDLE;
		f_delay <= 0;
	end else
	begin
		f_mem <= n_mem;
		f_num <= n_num;
		f_read_state <= n_read_state;
		f_delay <= n_delay;
		
	end
	
always@(*) begin
	
	n_read_state = f_read_state;
	n_num = f_num;
	n_mem = f_mem;
	n_delay = f_delay;
	
	read_data = 1'b0;
	in_read_rdy = 1'b0;

	read_save = 1'b0;
	r_addr_buffer = 8'b0;
	
	if(init_r) begin
		n_num = 1'b0;
	end
	
	case(f_read_state)
		READ_IDLE: begin
			
			if(read_start) begin
				n_delay = 0;
				n_read_state = READ_READ;
				
				r_addr_buffer = f_num;
				n_mem = out_buffer;
			end
			
		end
		READ_READ: begin
			r_addr_buffer = f_num;
			n_mem = out_buffer;
			
			n_read_state = READ_LOAD;
		end
		READ_LOAD: begin
			
			n_mem = out_buffer;
			
			n_num = f_num + 1;
			
			n_read_state = READ_SEND;
		end
		READ_SEND: begin
			n_read_state = READ_IDLE;
			
			in_read_rdy = 1'b1;
			read_save = 1'b1;
			read_data = f_mem;
				
		end
		
	endcase
end

// from

reg[7:0] crc_data_in ='b0;
reg crc_start = 1'b0;
reg crc_clr = 1'b0;

wire[15:0] crc_out;
wire crc_rdy;

SPI_QCRC16 qcrc(.rst(rst),
					 .clk(clk),
					  
					 .data_in(crc_data_in),
				    .start(crc_start),
				    .clr(crc_clr),
				  
					 .crc_out(crc_out),
					 .rdy(crc_rdy)
);

localparam MAX_RETRIES = 32767;
localparam MAX_RETRIES_SIZE = $clog2(MAX_RETRIES);

reg[(SIZE_LEN - 1):0] f_load_num = 'b0;
reg[(SIZE_LEN - 1):0] n_load_num = 'b0;

reg[(SIZE_LEN - 1):0] f_load_save_num = 'b0;
reg[(SIZE_LEN - 1):0] n_load_save_num = 'b0;

reg[7:0] f_load_mem = 'b0;
reg[7:0] n_load_mem = 'b0;

reg[3:0] f_load_state = 'b0;
reg[3:0] n_load_state = 'b0;

reg[(MAX_RETRIES_SIZE - 1):0] f_retries = 'b0;
reg[(MAX_RETRIES_SIZE - 1):0] n_retries = 'b0;

reg[15:0] f_crc_mem = 'b0;
reg[15:0] n_crc_mem = 'b0;

reg[15:0] f_crc_get = 'b0;
reg[15:0] n_crc_get = 'b0;

reg n_started = 1'b0;
reg f_started = 1'b0;

reg n_wait = 1'b0;
reg f_wait = 1'b0;

reg n_long = 1'b0;
reg f_long = 1'b0;

localparam LOAD_IDLE 		= 4'b0000;
localparam LOAD_START_READ = 4'b0001;
localparam LOAD_WAIT_READ 	= 4'b0010;
localparam LOAD_CHECK 		= 4'b0100;
localparam LOAD_FINISH 		= 4'b1000;

always@(posedge clk)
	if(rst) begin
		f_load_num <= 'b0;
		f_load_save_num <= 'b0;
		f_load_mem <= 'b0;
		f_load_state <= LOAD_IDLE;
		
		f_started <= 1'b0;
		f_wait <= 1'b0;
		f_long <= 1'b0;
		
		f_crc_mem <= 'b0;
		f_crc_get <= 'b0;
		f_retries <= 'b0;
		
	end else
	begin
		f_load_num <= n_load_num ;
		f_load_save_num <= n_load_save_num;
		f_load_mem <= n_load_mem;
		f_load_state <= n_load_state;		
		
		f_started <= n_started;
		f_wait <= n_wait;
		f_long <= n_long;
		
		f_crc_mem <= n_crc_mem;
		f_crc_get <= n_crc_get;
		
		f_retries <= n_retries;
	end

always@(*) begin
	n_load_num = f_load_num ;
	n_load_save_num = f_load_save_num;
	n_load_mem = f_load_mem;
	n_load_state = f_load_state;

	n_started = f_started;
	n_wait = f_wait;
	n_long = f_long;
	
	n_retries = f_retries;
	n_crc_mem = f_crc_mem;
	n_crc_get = f_crc_get;
	
	ostart = 1'b0;
	in_load_rdy = 1'b0;
	
	// buffer
	w_addr_buffer = 8'b0;
	w_buffer = 1'b0;
	in_buffer = 8'b0;
	
	// crc
	
	crc_data_in ='b0;
	crc_start = 1'b0;
	crc_clr = 1'b0;

	case(f_load_state) 
		LOAD_IDLE: begin
			if(init_p) begin
				
				n_load_save_num = init_len;
				n_load_num = 'b0;
				
				n_load_state = LOAD_START_READ;
				n_started = 'b0;
				n_wait = 'b0;
				
				n_retries = 'b0;
				
				n_crc_get = 'b0;
				n_crc_mem = 'b0;
				
				crc_clr = 1'b1;
					
				if(init_len[31:5] == 0) begin
					n_long = 1'b0;
				end else
				begin
					n_long = 1'b1;
				end
				
			end
		end
		LOAD_START_READ: begin
		
			if(f_retries == MAX_RETRIES) begin
				
				w_addr_buffer = 0;
				w_buffer = 1'b1;
				in_buffer = 8'hFE;
				
				in_load_rdy = 1'b1;
				
				n_load_state = LOAD_IDLE;
			end else
			begin
				
				if(f_load_num != 0 && f_load_num != 514 && f_load_num != 515)
					n_crc_mem = crc_out;
			
				ostart = 1'b1;
				n_load_state = LOAD_WAIT_READ;				
			end
		end 
		LOAD_WAIT_READ: begin
			if(ordy) begin
				
				n_load_mem = odata;
				n_load_state = LOAD_CHECK;
				
				if(odata == 8'h0 || odata == 8'h1 || odata == 8'hFE)begin	
					n_started = 1'b1;
							
					if(~f_started) begin
						w_addr_buffer = 0;
						w_buffer = 1'b1;
						in_buffer = 8'h0;
					end
				end
				
				if(odata == 8'hFE && f_long && (~f_started)) begin
					n_load_num = 1;
					n_wait = 1;
				end
				
				
			end
		end
		LOAD_CHECK: begin
		
		
			if(f_load_save_num == f_load_num) begin
				n_load_state = LOAD_FINISH;
			end else
			begin
				n_load_state = LOAD_START_READ;
			end
			
			
			if(f_started && (f_wait) && (f_load_mem == 8'hFE))begin
				
				n_wait = 1'b0;
				
			end else if(f_started & (~f_wait)) begin
			
				if(f_long && f_load_num == 0) begin
					n_wait = 1'b1;		
				end else
				begin
					crc_data_in = f_load_mem;
					crc_start = 1'b1;
				end
				
				
				if(f_load_num == 513 || f_load_num == 514)begin
					n_crc_get = {f_crc_get[7:0] , f_load_mem};
				end else begin
					w_addr_buffer = f_load_num;
					w_buffer = 1'b1;
					in_buffer = f_load_mem;							
				end
							
				n_load_num = f_load_num + 1;		
				
			end else begin
				n_retries = f_retries + 1;
			end
		
		end
		LOAD_FINISH: begin
			
			if(f_long && f_crc_get != f_crc_mem) begin
				w_addr_buffer = 0;
				w_buffer = 1'b1;
				in_buffer = 8'hFD;				
			end	
			
			in_load_rdy = 1'b1;
			n_load_state = LOAD_IDLE;
		end
	endcase
end

	
endmodule
