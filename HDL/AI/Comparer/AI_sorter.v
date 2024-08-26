
module AI_sorter(
	input clk,
	input rst,
	
	input init,
	
	input[31:0] data_in,
	input data_rdy,
	
	output reg[31:0] data_out = 'b0,
	output reg data_out_rdy = 'b0,
	output reg sort_ready = 'b0
);

localparam SIZE = 8;


localparam IDLE = 0;
localparam MIN_VAL = 1 << 0;
localparam SEND = 1 << 1;

reg[31:0] f_mem_ns[(SIZE - 1):0];
reg[31:0] n_mem_ns[(SIZE - 1):0];

reg[(SIZE - 1):0] f_addr = 'b0;
reg[(SIZE - 1):0] n_addr = 'b0;

reg[1:0] f_status = 'b0;
reg[1:0] n_status = 'b0;

reg[31:0] f_mem = 'b0;
reg[31:0] n_mem = 'b0;

reg[(SIZE - 1):0] f_min_addr = 'b0;
reg[(SIZE - 1):0] n_min_addr = 'b0;

reg[(SIZE - 1):0] f_iter = 'b0;
reg[(SIZE - 1):0] n_iter = 'b0;

wire[31:0] analyse = f_mem_ns[f_addr];

integer n = 0;

always@(posedge clk)
	if(rst) begin
		f_status <= 'b0;
		f_addr <= 'b0;
		f_min_addr <= 'b0;
		f_iter <= 'b0;
		f_mem <= 'b0;
		
		for(n = 0 ; n < SIZE ; n = n + 1)
		begin
			f_mem_ns[n] <= 'b0;
		end
		
	end else
	begin
		f_status <= n_status;
		f_addr <= n_addr;
		f_min_addr <= n_min_addr;
		f_iter <= n_iter;
		f_mem <= n_mem;
		
		for(n = 0 ; n < SIZE ; n = n + 1)
		begin
			f_mem_ns[n] <= n_mem_ns[n];
		end
		
	end
	
always@(*) begin

	n_status = f_status;
	n_addr = f_addr;
	
	n_min_addr = f_min_addr;
	n_iter = f_iter;
	n_mem = f_mem;
	
	for(n = 0 ; n < SIZE ; n = n + 1)
	begin
		n_mem_ns[n] = f_mem_ns[n];
	end
		
	data_out = 0;
	data_out_rdy = 0;	
	
	sort_ready = 0;
	
	
	if(init) begin
		n_status = 'b0;
		n_addr = 'b0;
		n_min_addr = 'b0;
		n_iter = 'b0;
		n_mem = 'b0;
		
		for(n = 0 ; n < SIZE ; n = n + 1)
		begin
			n_mem_ns[n] = 'b0;
		end	
	end
	
	case(f_status)
		IDLE: begin
			if(data_rdy) begin
				n_addr = f_addr + 1;
				
				n_mem_ns[f_addr] = data_in;
				
				if(f_addr == SIZE - 1) begin
					n_status = MIN_VAL;
					
					n_addr = 'b0;
					n_iter = 'b0;
					n_min_addr = 'b0;
					n_mem = 32'hFFFFFFFF;
				end
			
			end
		end
		MIN_VAL: begin
			n_addr = f_addr + 1;
			
			if(analyse[23:0] < f_mem[23:0]) begin
				n_mem = analyse;
				n_min_addr = f_addr;
			end
			
			if(f_addr == SIZE - 1) 
				n_status = SEND;
			
		end
		SEND: begin
				n_iter = f_iter + 1;
				
				n_mem_ns[f_min_addr] = 32'hFFFFFFFF;
				
				data_out = f_mem;
				data_out_rdy = 1;
			
				n_addr = 'b0;
				n_min_addr = 'b0;
				n_mem = 'hFFFFFFFF;
					
				if(f_iter == SIZE - 1) begin
					n_status = IDLE;
					sort_ready = 1;
				end else
				begin
					n_status = MIN_VAL;
				end
			end
		
	endcase
	

end

endmodule

module AI_collector(
	input clk,
	input rst,
	
	// init
	
	input[7:0] packet_size,
	input init,
	
	// fifo
	
	input[31:0] fifo_out, 
	input fifo_empty,
	
	output reg fifo_read = 'b0,
	
	input sort_ready,
	
	// out
	
	output reg[31:0] data_out = 'b0,
	output reg data_rdy = 'b0
	
);

localparam STATE_SIZE = 7;

localparam IDLE 			= 0;
localparam LOAD_BYTE 	= 1 << 0;
localparam MIN_VALUE 	= 1 << 1;
localparam SAVE 			= 1 << 2;
localparam START_SEND 	= 1 << 3;
localparam SEND 			= 1 << 4;
localparam CHECK_SEND 	= 1 << 5;
localparam FINISH		 	= 1 << 6;

integer n = 0;
localparam SIZE = 8;

reg[9:0] f_count = 0;
reg[9:0] n_count = 0;

reg[31:0] f_mem[(SIZE - 1):0];
reg[31:0] n_mem[(SIZE - 1):0];

reg[(STATE_SIZE - 1):0] f_state = 'b0;
reg[(STATE_SIZE - 1):0] n_state = 'b0;

reg[23:0] f_compar_mem = 'b0;
reg[23:0] n_compar_mem = 'b0;

reg[(SIZE - 1):0] f_compar_index = 'b0;
reg[(SIZE - 1):0] n_compar_index = 'b0;

reg[31:0] f_buffer = 'b0;
reg[31:0] n_buffer = 'b0;

reg[(SIZE - 1):0] n_addr = 'b0;
reg[(SIZE - 1):0] f_addr = 'b0;

reg[31:0] analyse;
reg[31:0] analyse_m;

reg f_lock = 'b0;
reg n_lock = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_compar_mem <= 'b0;
		f_compar_index <= 'b0;
		
		f_buffer <= 'b0;
		f_addr <= 'b0;
		
		f_lock <= 'b0;
		
		f_count <= 0;
		
		for( n = 0 ; n < SIZE ; n = n + 1)
			f_mem[n] = 32'hFFFFFFFF;
			
	end else
	begin
	
		for( n = 0 ; n < SIZE ; n = n + 1)
			f_mem[n] = n_mem[n];
		
		f_lock <= n_lock;
		
		f_buffer <= n_buffer;
		
		f_compar_mem <= n_compar_mem;
		f_compar_index <= n_compar_index;
		
		f_state <= n_state;
		f_addr <= n_addr;
		
		f_count <= n_count;
	end
	
always@(*) begin
	n_state = f_state;
	n_count = f_count;
	
	n_compar_mem = f_compar_mem;
	n_compar_index = f_compar_index;
	
	n_buffer = f_buffer;
	n_addr = f_addr;
	
	n_lock = f_lock;
	
	fifo_read = 'b0;
	data_out = 'b0;
	data_rdy = 'b0;
	
	analyse = f_mem[f_addr];
	analyse_m = f_mem[f_compar_index];
	
	for( n = 0 ; n < SIZE ; n = n + 1)
		n_mem[n] = f_mem[n];
	
	if(init) begin
		
		for( n = 0 ; n < SIZE ; n = n + 1)
			n_mem[n] = 32'hFFFFFFFF;			
		
		n_compar_mem = 'b0;
		n_compar_index = 'b0;
		
		n_lock = 'b0;
		n_buffer = 'b0;
		n_count = 0;
		
	end
			
	case(f_state)
		IDLE: begin
			
			if(~fifo_empty) begin
				fifo_read = 'b1;
				n_state = LOAD_BYTE;
			end
			
		end
		LOAD_BYTE: begin
			
			n_addr = 'b0;
			n_lock = 'b0;
			
			n_compar_mem = 'b0;
			n_compar_index = 'b0;
			
			n_buffer = fifo_out;
			n_state = MIN_VALUE;
			
		end
		MIN_VALUE: begin
			
			if(analyse[23:0] >= f_compar_mem) begin
				n_compar_index = f_addr;
				n_compar_mem = analyse[23:0];
				n_lock = 1;
			end
			
			
			if(f_addr == (SIZE - 1)) begin
				n_addr = 0;
				n_state = SAVE;
			end else
			begin
				n_addr = f_addr + 1;
				n_state = MIN_VALUE;
			end
			
		end
		SAVE: begin
			if((analyse_m[23:0] >= f_buffer[23:0]) && f_lock) begin
				n_mem[f_compar_index] = f_buffer;
			end
			
			n_state = START_SEND;
			
		end
		
		START_SEND: begin
		
			n_count = f_count + 1;
			
			if(f_count == packet_size) begin
				n_addr = 'b0;
				n_state = SEND;
				
				n_count = 0;
			end else
			begin
				n_state = IDLE;
			end
			
		end
		SEND: begin
			data_out = analyse;
			data_rdy = 1;
			
			n_state = CHECK_SEND;
		end
		CHECK_SEND: begin
			
			if(f_addr == (SIZE - 1))
				n_state = FINISH;
			else
				n_state = SEND;
			
			n_addr = f_addr + 1;
		end
		FINISH: begin
		
			if(sort_ready) begin
				n_state = IDLE;
			end
			
		end
	endcase
	
end

endmodule
