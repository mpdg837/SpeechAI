

module AI_crosser(
	input clk,
	input rst,
	
	input init,
	
	input[63:0] data2_in,
	input rdy2_in,

	input[63:0] data4_in,
	input rdy4_in,
	
	output reg[9:0] data_out = 'b0,
	output reg rdy_out = 'b0
);

reg[63:0] b_data_in = 'b0;
reg b_data_in_rdy = 'b0;

always@(posedge clk)
	if(rst) begin
		b_data_in <= 'b0;
		b_data_in_rdy <= 'b0;
	end else
	if(rdy4_in) begin 
		b_data_in <= data4_in;
		b_data_in_rdy <= 1;	
	end else
	if(rdy2_in) begin 
		b_data_in <= data2_in;
		b_data_in_rdy <= 1;	
	end else
	begin
		b_data_in <= 0;
		b_data_in_rdy <= 0;		
	end
	
wire[7:0] last1 = b_data_in[63:56];
wire[7:0] last2 = b_data_in[55:48];
wire[7:0] last3 = b_data_in[47:40];
wire[7:0] last4 = b_data_in[39:32];

wire[7:0] next1 = b_data_in[31:24];
wire[7:0] next2 = b_data_in[23:16];
wire[7:0] next3 = b_data_in[15:8];
wire[7:0] next4 = b_data_in[7:0];


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


reg[7:0] f_count1 = 0;
reg[7:0] n_count1 = 0;

reg[7:0] f_count2 = 0;
reg[7:0] n_count2 = 0;

reg[7:0] f_count3 = 0;
reg[7:0] n_count3 = 0;

reg[7:0] f_count4 = 0;
reg[7:0] n_count4 = 0;

reg[9:0] b_data_out = 'b0;
reg b_rdy_out = 'b0;



always@(posedge clk)
	if(rst) begin
		data_out <= 'b0;
		rdy_out <= 'b0;	
	end else
	begin
		data_out <= b_data_out;
		rdy_out <= b_rdy_out;	
	end
	
always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_mem1 <= 'b0;
		f_mem2 <= 'b0; 
		f_mem3 <= 'b0;
		f_mem4 <= 'b0;
	
		f_count1 <= 'b0;
		f_count2 <= 'b0;
		f_count3 <= 'b0;
		f_count4 <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_mem1 <= n_mem1;
		f_mem2 <= n_mem2;
		f_mem3 <= n_mem3;
		f_mem4 <= n_mem4;
		
		f_count1 <= n_count1;
		f_count2 <= n_count2;
		f_count3 <= n_count3;
		f_count4 <= n_count4;
	end

always@(*) begin
	n_mem1 = f_mem1;
	n_mem2 = f_mem2;
	n_mem3 = f_mem3;
	n_mem4 = f_mem4;	
	
	n_state = f_state;
	
	n_count1 = f_count1;
	n_count2 = f_count2;
	n_count3 = f_count3;
	n_count4 = f_count4;
	
	b_data_out = 'b0;
	b_rdy_out = 'b0;
	
	if(init) begin
		n_mem1 = 0;
		n_mem2 = 0;
		n_mem3 = 0;
		n_mem4 = 0;
		
		n_state = 0;
	end
	
	case(f_state)
		0: begin
			if(b_data_in_rdy) begin
			
			
				if(last1 > next1) begin
					n_mem1 = {last1,next1};
				end else
				begin
					n_mem1 = {next1,last1};
				end
				
				if(last2 > next2) begin
					n_mem2 = {last2,next2};
				end else
				begin
					n_mem2 = {next2,last2};
				end
		
				if(last3 > next3) begin
					n_mem3 = {last3,next3};
				end else
				begin
					n_mem3 = {next3,last3};
				end
		
				if(last4 > next4) begin
					n_mem4 = {last4,next4};
				end else
				begin
					n_mem4 = {next4,last4};
				end		
				
				n_state = 1;
			end
		end
		1: begin
		
			n_count1 = f_mem1[15:8] - f_mem1[7:0];
			n_count2 = f_mem2[15:8] - f_mem2[7:0];
			n_count3 = f_mem3[15:8] - f_mem3[7:0];
			n_count4 = f_mem4[15:8] - f_mem4[7:0];
			
			n_state = 2;
		end
		2: begin
			
		 	b_data_out = f_count4 + f_count3 + f_count2 + f_count1;
			b_rdy_out = 'b1;
			
			n_state = 0;
	
		end
	endcase
end

endmodule