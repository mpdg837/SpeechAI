

module dma_wager(
	input clk,
	input rst,
	
	// Params
	
	input[7:0] 	wage1,
	input[7:0] 	wage2,
	
	input start,
	
	input[15:0]			line_width,
	input[15:0] 		region_width,	

	// Out
	
	output reg 		  avs_m1_valid = 'b0,
	output reg[31:0] avs_m1_data = 'b0,
	output reg		  avs_m1_startofpacket = 'b0,
	output reg		  avs_m1_endofpacket = 'b0,
	input	 		  	  avs_m1_ready,
	
	
	// in
	input 		  	  avs_m2_valid,
	input[31:0]	  	  avs_m2_data,
	input 		  	  avs_m2_startofpacket,
	input			  	  avs_m2_endofpacket,
	output reg	  	  avs_m2_ready = 'b0
	
);

reg[8:0] b_wage1;
reg[8:0] b_wage2;

reg[15:0] b_line_width;
reg[15:0] b_region_width;

reg b_start;

always@(posedge clk)
	if(rst) begin
		b_wage1 <= 'b0;
		b_wage2 <= 'b0;
		
		b_start <= 'b0;
		
		b_line_width <= 'b0;
		b_region_width <= 'b0;		
	end else
	begin
		b_start <= start;
		
		b_wage1 <= wage1 + 1;
		b_wage2 <= wage2 + 1;
	
		b_line_width <= line_width;
		b_region_width <= region_width;
	end


reg[15:0] f_lcounter = 'b0;
reg[15:0] n_lcounter = 'b0;
	
reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[15:0] f_mem1 = 'b0;
reg[15:0] n_mem1 = 'b0;

reg[15:0] f_mem2 = 'b0;
reg[15:0] n_mem2 = 'b0;

reg[15:0] f_mem3 = 'b0;
reg[15:0] n_mem3 = 'b0;

reg[15:0] f_mem4 = 'b0;
reg[15:0] n_mem4 = 'b0;

reg f_eop = 'b0;
reg n_eop = 'b0;

reg f_sop = 'b0;
reg n_sop = 'b0;


always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		f_mem3 <= 'b0;
		f_mem4 <= 'b0;
		
		f_eop <= 'b0;
		f_sop <= 'b0;
		
		n_lcounter <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem1 = n_mem1;
		f_mem2 = n_mem2;
		f_mem3 = n_mem3;
		f_mem4 = n_mem4;
		
		f_eop <= n_eop;
		f_sop <= n_sop;
		
		n_lcounter <= f_lcounter;
	end

always@(*) begin
	n_state = f_state;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	n_mem3 = f_mem3;
	n_mem4 = f_mem4;
	
	n_lcounter = f_lcounter;
	n_eop = f_eop;
	n_sop = f_sop;
	
	
	avs_m2_ready = 'b0;
		
	avs_m1_valid = 'b0;
	avs_m1_data = 'b0;
	avs_m1_startofpacket = 'b0;
	avs_m1_endofpacket = 'b0;
	
	if(b_start)
		n_lcounter = 0;
		
	case(f_state)
		0: if(avs_m2_valid) begin
			
			n_mem1 = {8'b0,avs_m2_data[7:0]};
			n_mem2 = {8'b0,avs_m2_data[15:8]};
			n_mem3 = {8'b0,avs_m2_data[23:16]};
			n_mem4 = {8'b0,avs_m2_data[31:24]};
		
			n_eop = avs_m2_endofpacket;
			n_sop = avs_m2_startofpacket;
			
			avs_m2_ready = 'b1;
		
			n_state = 1;
			
			if(f_lcounter >= b_line_width) begin
				n_lcounter = 0;
			end
			
		end
		1: begin
		
			if(f_lcounter >= b_region_width) begin
				n_mem1 = f_mem1 * b_wage2;
				n_mem2 = f_mem2 * b_wage2;
				n_mem3 = f_mem3 * b_wage2;
				n_mem4 = f_mem4 * b_wage2;

			end else
			begin
				n_mem1 = f_mem1 * b_wage1;
				n_mem2 = f_mem2 * b_wage1;
				n_mem3 = f_mem3 * b_wage1;
				n_mem4 = f_mem4 * b_wage1;
			end
			
			n_state = 2;
		end
		2: begin
				
				
			avs_m1_valid = 'b1;
			avs_m1_data = {f_mem4[15:8],f_mem3[15:8],f_mem2[15:8],f_mem1[15:8]};
			avs_m1_startofpacket = f_sop;
			avs_m1_endofpacket = f_eop;
		
			if(avs_m1_ready) begin
			
				n_lcounter = f_lcounter + 4;
				
				n_state = 0;
			end
		end
		
	endcase
end





endmodule

module dma_noise_reducer(
	input clk,
	input rst,
	
	// Params
	
	input[7:0] 	minimum1,
	input[7:0] 	minimum2,
	
	input start,
	
	input[15:0]			line_width,
	input[15:0] 		region_width,
	
	// Out
	
	output reg 		  avs_m1_valid = 'b0,
	output reg[31:0] avs_m1_data = 'b0,
	output reg		  avs_m1_startofpacket = 'b0,
	output reg		  avs_m1_endofpacket = 'b0,
	input	 		  	  avs_m1_ready,
	
	
	// in
	input 		  	  avs_m2_valid,
	input[31:0]	  	  avs_m2_data,
	input 		  	  avs_m2_startofpacket,
	input			  	  avs_m2_endofpacket,
	output reg	  	  avs_m2_ready = 'b0
	
);

reg[7:0] b_minimum1;
reg[7:0] b_minimum2;

reg[15:0] b_line_width;
reg[15:0] b_region_width;

reg b_start;

always@(posedge clk)
	if(rst) begin
		b_minimum1 <= 'b0;
		b_minimum2 <= 'b0;
		
		b_start <= 'b0;
		
		b_line_width <= 'b0;
		b_region_width <= 'b0;		
	end else
	begin
		b_start <= start;
		
		b_minimum1 <= minimum1;
		b_minimum2 <= minimum2;
	
		b_line_width <= line_width;
		b_region_width <= region_width;
	end

reg[15:0] f_lcounter = 'b0;
reg[15:0] n_lcounter = 'b0;
	
reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;

reg[7:0] f_mem1 = 'b0;
reg[7:0] n_mem1 = 'b0;

reg[7:0] f_mem2 = 'b0;
reg[7:0] n_mem2 = 'b0;

reg[7:0] f_mem3 = 'b0;
reg[7:0] n_mem3 = 'b0;

reg[7:0] f_mem4 = 'b0;
reg[7:0] n_mem4 = 'b0;

reg f_eop = 'b0;
reg n_eop = 'b0;

reg f_sop = 'b0;
reg n_sop = 'b0;


always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0;
		f_mem3 <= 'b0;
		f_mem4 <= 'b0;
		
		f_eop <= 'b0;
		f_sop <= 'b0;
		
		n_lcounter <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem1 = n_mem1;
		f_mem2 = n_mem2;
		f_mem3 = n_mem3;
		f_mem4 = n_mem4;
		
		f_eop <= n_eop;
		f_sop <= n_sop;
		
		n_lcounter <= f_lcounter;
	end

always@(*) begin
	n_state = f_state;
	
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	n_mem3 = f_mem3;
	n_mem4 = f_mem4;
	
	n_lcounter = f_lcounter;
	n_eop = f_eop;
	n_sop = f_sop;
	
	
	avs_m2_ready = 'b0;
		
	avs_m1_valid = 'b0;
	avs_m1_data = 'b0;
	avs_m1_startofpacket = 'b0;
	avs_m1_endofpacket = 'b0;
	
	if(b_start)
		n_lcounter = 0;
		
	case(f_state)
		0: if(avs_m2_valid) begin
			
			n_mem1 = avs_m2_data[7:0];
			n_mem2 = avs_m2_data[15:8];
			n_mem3 = avs_m2_data[23:16];
			n_mem4 = avs_m2_data[31:24];
		
			n_eop = avs_m2_endofpacket;
			n_sop = avs_m2_startofpacket;
			
			avs_m2_ready = 'b1;
		
			n_state = 1;
			
			if(f_lcounter >= b_line_width) begin
				n_lcounter = 0;
			end
			
		end
		1: begin
		
			if(f_lcounter >= b_region_width) begin
				if(f_mem1 <= b_minimum2) 
					n_mem1 = 'b0;
					
				if(f_mem2 <= b_minimum2) 
					n_mem2 = 'b0;
				
				if(f_mem3 <= b_minimum2) 
					n_mem3 = 'b0;
					
				if(f_mem4 <= b_minimum2) 
					n_mem4 = 'b0;

			end else
			begin
				if(f_mem1 <= b_minimum1) 
					n_mem1 = 'b0;
					
				if(f_mem2 <= b_minimum1) 
					n_mem2 = 'b0;
				
				if(f_mem3 <= b_minimum1) 
					n_mem3 = 'b0;
					
				if(f_mem4 <= b_minimum1) 
					n_mem4 = 'b0;
			end
			
			n_state = 2;
		end
		2: begin
				
				
			avs_m1_valid = 'b1;
			avs_m1_data = {f_mem4,f_mem3,f_mem2,f_mem1};
			avs_m1_startofpacket = f_sop;
			avs_m1_endofpacket = f_eop;
		
			if(avs_m1_ready) begin
			
				n_lcounter = f_lcounter + 4;
				
				n_state = 0;
			end
		end
		
	endcase
end



endmodule
