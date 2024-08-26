
module SPI_QCRC16(
  input rst,
  input clk,
  
  input [7:0] data_in,
  input start,
  input clr,
  
  output reg[15:0] crc_out,
  output reg rdy
);

  reg [15:0] lfsr_c = 'b0;
  reg [15:0] lfsr_q = 'b0;

  reg b_rdy = 'b0;
  reg[15:0] b_crc_out = 'b0;
  
  always @(posedge clk) begin
    if(rst) begin
      lfsr_q <= {16{1'b0}};
    end
    else begin
      lfsr_q <= lfsr_c;
    end
  end // always
  
  always@(posedge clk)
	if(rst) begin
		rdy <= 'b0;
		crc_out <= 'b0;
	end else
	begin
		rdy <= b_rdy;
		crc_out <= b_crc_out;	
	end
	
  always @(*) begin
	 lfsr_c = lfsr_q;
	 
    b_crc_out = 16'b0;
	 b_rdy = 1'b0;
	 
    if(clr) begin
		 lfsr_c = 'b0;
	 end
	 
    if(start) begin
		 lfsr_c[0] = data_in[0] ^ data_in[4] ^ lfsr_q[8] ^ lfsr_q[12];
		 lfsr_c[1] = data_in[1] ^ data_in[5] ^ lfsr_q[9] ^ lfsr_q[13];
		 lfsr_c[2] = data_in[2] ^ data_in[6] ^ lfsr_q[10] ^ lfsr_q[14];
		 lfsr_c[3] = data_in[3] ^ data_in[7] ^ lfsr_q[11] ^ lfsr_q[15];
		 lfsr_c[4] = data_in[4] ^ lfsr_q[12];
		 lfsr_c[5] = data_in[0] ^ data_in[4] ^ data_in[5] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[13];
		 lfsr_c[6] = data_in[1] ^ data_in[5] ^ data_in[6] ^ lfsr_q[9] ^ lfsr_q[13] ^ lfsr_q[14];
		 lfsr_c[7] = data_in[2] ^ data_in[6] ^ data_in[7] ^ lfsr_q[10] ^ lfsr_q[14] ^ lfsr_q[15];
		 lfsr_c[8] = data_in[3] ^ data_in[7] ^ lfsr_q[0] ^ lfsr_q[11] ^ lfsr_q[15];
		 lfsr_c[9] = data_in[4] ^ lfsr_q[1] ^ lfsr_q[12];
		 lfsr_c[10] = data_in[5] ^ lfsr_q[2] ^ lfsr_q[13];
		 lfsr_c[11] = data_in[6] ^ lfsr_q[3] ^ lfsr_q[14];
		 lfsr_c[12] = data_in[0] ^ data_in[4] ^ data_in[7] ^ lfsr_q[4] ^ lfsr_q[8] ^ lfsr_q[12] ^ lfsr_q[15];
		 lfsr_c[13] = data_in[1] ^ data_in[5] ^ lfsr_q[5] ^ lfsr_q[9] ^ lfsr_q[13];
		 lfsr_c[14] = data_in[2] ^ data_in[6] ^ lfsr_q[6] ^ lfsr_q[10] ^ lfsr_q[14];
		 lfsr_c[15] = data_in[3] ^ data_in[7] ^ lfsr_q[7] ^ lfsr_q[11] ^ lfsr_q[15];
			 
		 b_crc_out = {lfsr_c};
		 b_rdy = 1'b1;
	 end 
	  
  end // always
endmodule
