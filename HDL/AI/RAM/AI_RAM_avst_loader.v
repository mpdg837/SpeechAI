
module AI_RAM_avst_loader(
	input clk,
	input rst,
	
	input[31:0] 	avs_s4_data,
	input 			avs_s4_valid,
	input 			avs_s4_startofpacket,
	input 			avs_s4_endofpacket,
	output reg		avs_s4_ready = 'b0,
	
	output reg[13:0]	q_addr = 'b0,
	output reg	   	q_write = 'b0,
	
	output reg[7:0]	q_data1 = 'b0,
	output reg[7:0]	q_data2 = 'b0,
	output reg[7:0]	q_data3 = 'b0,
	output reg[7:0]	q_data4 = 'b0
	
);

reg[31:0] f_mem = 'b0;
reg[31:0] n_mem = 'b0;

reg[13:0] f_addr = 'b0;
reg[13:0] n_addr = 'b0;

reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_mem <= 'b0;
		f_addr <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem <= n_mem;
		f_addr <= n_addr;
	end

always@(*) begin
	n_state = 'b0;
	
	n_mem = f_mem;
	n_addr = f_addr;
	
	avs_s4_ready = 'b0;
	
	q_addr = 'b0;
	q_write = 'b0;
	
	q_data1 = 'b0;
	q_data2 = 'b0;
	q_data3 = 'b0;
	q_data4 = 'b0;

	
	
	case(f_state)
		0: if(avs_s4_valid) begin
			
			n_mem = avs_s4_data;
			
			if(avs_s4_startofpacket) begin
				n_state = 3;
			end else if(avs_s4_endofpacket) begin
				n_state = 2;
			end else begin
				n_state = 1;
			end
			
			avs_s4_ready = 'b1;
		end
		1: begin
			q_addr = f_addr;
			q_write = 'b1;
			
			q_data1 = f_mem[7:0];
			q_data2 = f_mem[15:8];
			q_data3 = f_mem[23:16];
			q_data4 = f_mem[31:24];
					
			
			n_addr = f_addr + 1;
			
			n_state = 0;
		end
		2: begin
			q_addr = f_addr;
			q_write = 'b1;
			
			q_data1 = f_mem[7:0];
			q_data2 = f_mem[15:8];
			q_data3 = f_mem[23:16];
			q_data4 = f_mem[31:24];
			
			n_addr = 0;
			n_state = 0;
		end
		3: begin
			q_addr = 0;
			q_write = 'b1;
			
			q_data1 = f_mem[7:0];
			q_data2 = f_mem[15:8];
			q_data3 = f_mem[23:16];
			q_data4 = f_mem[31:24];
			
			n_addr = 1;
			n_state = 0;
		end		
		
	endcase

	
end


endmodule