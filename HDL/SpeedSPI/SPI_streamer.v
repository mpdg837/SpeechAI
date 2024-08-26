
module SPI_streamer(
	input clk,
	input rst,

	output reg 		 orst = 1'b0,
	// Stream
	output reg[7:0] avm_m1_dout,
	output reg 		 avm_m1_ivalid,
	input 			 avm_m1_oready,

	input[39:0] 	 avs_s2_inout,
	input 			 avs_s2_valid,
	output reg 		 avs_s2_ready,
	
	// Queue
	
	output reg 		 fifo_reset = 'b0,
	// Commander
	
	output reg 		  com_start = 1'b0,
	output reg[7:0]  com_cmd = 'b0,
	output reg[23:0] com_arg = 'b0,

	input com_rdy,
	
	// Loader
	
	output reg 		  init_p = 1'b0,
	output reg 		  init_r = 1'b0,
	output reg[31:0] init_len ='b0,
	
	// Reader
	
	output reg    	  read_start = 'b0,
	input[7:0]		  read_data,
	input				  read_rdy,
	input				  read_save	
);

reg[10:0] f_state = 'b0;
reg[10:0] n_state = 'b0;

// stream
reg f_m1_dout = 'b0;
reg f_m1_ivalid = 'b0;

// data saved

reg[15:0] f_len;
reg[15:0] n_len;

reg[15:0] f_sector;
reg[15:0] n_sector;

reg[7:0] f_mem;
reg[7:0] n_mem;

// status

reg[15:0] f_counter;
reg[15:0] n_counter;

reg[9:0] f_scounter;
reg[9:0] n_scounter;

// status

reg f_started = 1'b0;
reg n_started = 1'b0;

localparam IDLE 			=  0 ;
localparam INIT 			=  ('b1 << 0);
localparam INIT_WAIT 	=  ('b1 << 1);

localparam LOAD 			=  ('b1 << 2);
localparam LOAD_WAIT 	=  ('b1 << 3);
localparam CHECK 			=  ('b1 << 4);
localparam LOAD_BYTE 	=  ('b1 << 5);
localparam FINISH_BYTE 	=  ('b1 << 6);

localparam FINISH 		=  ('b1 << 7);
localparam FINISH_RDY 	=  ('b1 << 8);
localparam FINISH_LOAD  =  ('b1 << 9);
localparam FINISH_LOAD_R=  ('b1 << 10);

reg 		b_read_save = 'b0;
reg[7:0] b_read_data = 'b0;

reg 		n_stop = 'b0;
reg		f_stop = 'b0;

reg b_orst = 'b0;

always@(posedge clk)
	orst <= b_orst;
	
always@(posedge clk)
	begin
		b_read_save <= read_save;
		b_read_data <= read_data;
	end
	
	
always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_m1_dout <= 'b0;
		f_m1_ivalid <= 'b0;
		
		f_len <= 'b0;
		f_sector <= 'b0;
		f_mem <= 'b0;
		
		f_counter <= 'b0;
		f_scounter <= 'b0;
		
		f_started <= 'b0;
		f_stop <= 'b0;
	end else
	begin
		f_state <= n_state;
		f_m1_dout <= avm_m1_dout;
		f_m1_ivalid <= avm_m1_ivalid;
		
		f_len <= n_len;
		f_sector <= n_sector;
		f_mem <= n_mem;
		
		f_counter <= n_counter;
		f_scounter <= n_scounter;
		
		f_started <= n_started;
		f_stop <= n_stop;
	end
	
reg b_ready = 'b0;

always@(posedge clk)
	b_ready <= avm_m1_oready;
	
always@(*) begin
	n_state = f_state;
	
	avm_m1_dout = f_m1_dout;
	avm_m1_ivalid = f_m1_ivalid;
	
	n_len = f_len;
	n_sector = f_sector;
	
	n_counter = f_counter;
	n_scounter = f_scounter;
	n_started = f_started;
	
	n_mem = f_mem;
	n_stop = f_stop;
	avs_s2_ready = 1'b0;

	com_start = 1'b0;
	com_cmd = 'b0;
	com_arg = 'b0;

	init_p = 1'b0;
	init_len = 'b0;
	
	init_r = 'b0;
	
	fifo_reset = 1'b0;
	read_start = 'b0;
	
	b_orst = 0;
	
	if(b_ready) begin
		avm_m1_dout = 'b0;
		avm_m1_ivalid = 'b0;
	end
	
	if(avs_s2_valid) 
		if(avs_s2_inout[39:32] == 8'hFF) begin
			n_stop = 1;
		end
		
	case(f_state)
		IDLE: begin
			if(avs_s2_valid) begin
				avs_s2_ready = 1'b1;
				
				n_len = avs_s2_inout[15:0];
				n_sector = avs_s2_inout[31:16];

				n_state = INIT;
			end
		end
		INIT: begin
			com_start = 1'b1;
			com_cmd = 'd18;
			com_arg = {f_sector,8'b0};		

			n_counter = 'b0;
			n_scounter = 'b0;
			n_stop = 0;
			n_mem = 0;
				
			fifo_reset = 1'b1;
			
			n_state = INIT_WAIT;
		end
		INIT_WAIT: begin
			if(com_rdy) begin
				n_state = LOAD;
			end
		end
		LOAD: begin
			init_p = 1'b1;
			init_r = 1;
			
			n_scounter = 'b0;
			init_len = 'd514;
			
			if(f_started) n_state = LOAD_BYTE;
			else n_state = LOAD_WAIT;
			
		end
		
		LOAD_BYTE: begin
			read_start = 1'b1;
			n_state = FINISH_BYTE;
		end
		FINISH_BYTE: begin
			if(b_read_save) begin
				avm_m1_dout = b_read_data;
				avm_m1_ivalid = 'b1;
				
				n_scounter = f_scounter + 1;
				
				if(f_scounter == 513) begin
					n_state = LOAD_WAIT;
				end else
				begin
					n_state = LOAD_BYTE;
				end
				
			end
		end
		
		LOAD_WAIT: begin
			if(read_rdy) begin
				
				n_state = CHECK;
				n_started = 1;
			end
		end
		
		CHECK: begin
			n_counter = f_counter + 1;
			
			
			if(f_counter == f_len || f_stop) begin
				n_state = FINISH;
				
				
			end else
			begin
				n_state = LOAD;
			end
			
		end
		FINISH:begin
		
			com_start = 1'b1;
			com_cmd = 'd12;
			com_arg = 'b0;
				
			n_state = FINISH_RDY;
		
		end
		FINISH_RDY: begin
		
			if(com_rdy) begin
				
				n_state = FINISH_LOAD;
			
			end
		end
		
		FINISH_LOAD: begin
			
			init_p = 1'b1;
			init_r = 1;
			
			init_len = 'd16;
				
			n_state = FINISH_LOAD_R;
		end
		FINISH_LOAD_R: begin
			if(read_rdy) begin
		
				b_orst = 1;	
			end
		end
		
	endcase
end

	
endmodule
