
module signal_modulus(
	input clk,
	input rst,
	
	input[31:0] power_data,
	input power_valid,
	output reg power_rdy = 'b0,
	
	output reg[15:0] spect_data = 'b0,
	output reg spect_valid = 'b0,
	input spect_rdy
);

reg start = 'b0;
reg[31:0] rad = 'b0;

wire[31:0] root;
wire valid;

sqrt_int #(.WIDTH(32)) sqtop(      // width of radicand
    .clk(clk),
    .start(start),             // start signal
	 
    .valid(valid),             // root and rem are valid
    .rad(rad),   // radicand
    .root(root)  // root
    );
	 
reg[1:0] f_state = 'b0;
reg[1:0] n_state = 'b0;
	 
reg[31:0] f_rad = 'b0;
reg[31:0] n_rad = 'b0;

reg[15:0] f_root = 'b0;
reg[15:0] n_root = 'b0;

always@(posedge clk)
	if(rst) begin
		f_state <= 'b0;
		
		f_root <= 'b0;
		f_rad <= 'b0;
	end else
	begin
		f_state <= n_state;
		
		f_root <= n_root;
		f_rad <= n_rad;
	end

always@(*) begin
	n_state = f_state; 
	n_rad = f_rad;
	n_root = f_root;
	
	start = 'b0;
	rad = 'b0;
	
	power_rdy = 'b0;
	
	spect_data = 'b0;
	spect_valid = 'b0;
	
	case(f_state)
		0: if(power_valid) begin
			power_rdy = 1'b1;
			
			n_rad = power_data;
			n_state = 1;
		end
		1: begin
			start = 1;
			rad = f_rad;
			
			n_state = 2;
		end
		2: if(valid) begin
			n_root = root;
			n_state = 3;
		end
		3: begin
				
			spect_data = f_root;
			spect_valid = 1;
	
			if(spect_rdy) begin
				n_state = 0;
			end
		end
	endcase
end

endmodule
