
module AI_IDMA(
	input clk,
	input rst,
	
	input init,
	
	// QRAM
	
	input[63:0] avs_s2_dout, // data
	input avm_s2_valid,
	output reg avm_s2_ready = 'b0,
	
	output reg[31:0] avm_m2_dout = 'b0, // addr
	output reg avm_m2_valid = 'b0,
	input avm_m2_ready,
	
	// Inside
	
	input[15:0] c1_ram_addr,
	input c1_ram_read,
	output reg c1_ram_rdy = 'b0,
	output reg[31:0] c1_ram_data = 'b0,
	
	input[15:0] c2_ram_addr,
	input c2_ram_read,
	output reg c2_ram_rdy = 'b0,
	output reg[31:0] c2_ram_data = 'b0,

	input[15:0] c3_ram_addr,
	input c3_ram_read,
	output reg c3_ram_rdy = 'b0,
	output reg[31:0] c3_ram_data = 'b0,

	input[15:0] c4_ram_addr,
	input c4_ram_read,
	output reg c4_ram_rdy = 'b0,
	output reg[31:0] c4_ram_data = 'b0
	
);

localparam LOAD1 = 1 << 0;
localparam LOAD2 = 1 << 1;

reg[2:0] f_mem = 'b0;
reg[2:0] n_mem = 'b0;

reg[1:0] f_state;
reg[1:0] n_state;

reg f_b1;
reg f_b2;
reg f_b3;
reg f_b4;

reg n_b1;
reg n_b2;
reg n_b3;
reg n_b4;

always@(posedge clk) begin
	if(rst) begin
		f_state <= LOAD1;
		
		f_b1 <= 'b0;
		f_b2 <= 'b0;
		f_b3 <= 'b0;
		f_b4 <= 'b0;
		
		f_mem <= 'b0;
		
	end else
	begin
		f_state <= n_state;
	
		f_b1 <= n_b1;
		f_b2 <= n_b2;
		f_b3 <= n_b3;
		f_b4 <= n_b4;
		
		f_mem <= n_mem;
		
	end
end

always@(*)begin
		
	n_state = f_state;
	n_mem = f_mem;
	
	n_b1 = f_b1;
	n_b2 = f_b2;
	n_b3 = f_b3;
	n_b4 = f_b4;
	
	// QRAM
	avm_s2_ready = 'b0;
	
	avm_m2_dout = 'b0;
	avm_m2_valid = 'b0;

	// Inside
	c1_ram_rdy = 'b0;
	c1_ram_data = 'b0;

	c2_ram_rdy = 'b0;
	c2_ram_data = 'b0;
	
	c3_ram_rdy = 'b0;
	c3_ram_data = 'b0;
	
	c4_ram_rdy = 'b0;
	c4_ram_data = 'b0;

	if(init) begin
		n_state = 'b0;
		
		n_b1 = 'b0;
		n_b2 = 'b0;
		n_b3 = 'b0;
		n_b4 = 'b0;
		
		n_mem = 'b0;
		
	end
	
	case(f_state)
	
		LOAD1: begin
	
			avm_m2_dout = {c1_ram_addr,c3_ram_addr}; // addr
			avm_m2_valid = 'b1;
			
			avm_s2_ready = 'b1;
			
			
			if(c2_ram_read & (f_b2)) begin
				
				c2_ram_rdy = 'b1;
				c2_ram_data = avs_s2_dout[63:32];	
					
			end
		
			if(c4_ram_read & (f_b4)) begin
				
				c4_ram_rdy = 'b1;
				c4_ram_data = avs_s2_dout[31:0];	
					
			end
			
			if(c1_ram_read & (~f_b1)) begin
				
				n_b1 = 1'b1;
			end
			
			if(c3_ram_read & (~f_b3)) begin
				
				n_b3 = 1'b1;
			end
			
			n_b2 = 'b0;	
			n_b4 = 'b0;	
			
			n_state = LOAD2;
		end
		
		LOAD2: begin

		
			avm_m2_dout = {c2_ram_addr,c4_ram_addr}; // addr
			avm_m2_valid = 'b1;
			
			avm_s2_ready = 'b1;
			
			
			if(c1_ram_read & (f_b1)) begin
				
				c1_ram_rdy = 'b1;
				c1_ram_data = avs_s2_dout[63:32];
					
			end	

			if(c3_ram_read & (f_b3)) begin
				
				c3_ram_rdy = 'b1;
				c3_ram_data = avs_s2_dout[31:0];
					
			end
			
			if(c2_ram_read & (~f_b2)) begin
				n_b2 = 1'b1;
			end


			if(c4_ram_read & (~f_b4)) begin
				n_b4 = 1'b1;
			end
			
			n_b3 = 'b0;
			n_b1 = 'b0;
			
			n_state =LOAD1;
		end
		
	endcase



end


endmodule

