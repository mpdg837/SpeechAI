
module SPI_QCRC64_ISO(
  input rst,
  input clk,
  
  input [7:0] data_in,
  input start,
  input clr,
  
  output reg[31:0] crc_out,
  output reg rdy
);

  reg [31:0] lfsr_c = 'b0;
  reg [31:0] lfsr_q = 'b0;

  reg b_rdy = 'b0;
  reg[31:0] b_crc_out = 'b0;
  
  reg[7:0] b_data_in = 'b0;
  reg b_start = 'b0;
  
  always @(posedge clk) begin
    if(rst) begin
      lfsr_q <= {31{1'b0}};
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
	
	
  always@(posedge clk)
	if(rst) begin
		b_start <= 'b0;
		b_data_in <= 'b0;
	end else
	begin
		b_start <= start;
		b_data_in <= data_in;
	end
	
  always @(*) begin
	 lfsr_c = lfsr_q;
	 
    b_crc_out = lfsr_q;
	 b_rdy = 1'b0;
	 
    if(clr) begin
		 lfsr_c = 'b0;
	 end
	 
    if(b_start) begin
		 lfsr_c[0] = b_data_in[2] ^ lfsr_q[2] ^ lfsr_q[8];
		 lfsr_c[1] = b_data_in[0] ^ b_data_in[3] ^ lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[9];
		 lfsr_c[2] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[4] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[4] ^ lfsr_q[10];
		 lfsr_c[3] = b_data_in[1] ^ b_data_in[2] ^ b_data_in[5] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[5] ^ lfsr_q[11];
		 lfsr_c[4] = b_data_in[0] ^ b_data_in[2] ^ b_data_in[3] ^ b_data_in[6] ^ lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[12];
		 lfsr_c[5] = b_data_in[1] ^ b_data_in[3] ^ b_data_in[4] ^ b_data_in[7] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[7] ^ lfsr_q[13];
		 lfsr_c[6] = b_data_in[4] ^ b_data_in[5] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[14];
		 lfsr_c[7] = b_data_in[0] ^ b_data_in[5] ^ b_data_in[6] ^ lfsr_q[0] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[15];
		 lfsr_c[8] = b_data_in[1] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[1] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[16];
		 lfsr_c[9] = b_data_in[7] ^ lfsr_q[7] ^ lfsr_q[17];
		 lfsr_c[10] = b_data_in[2] ^ lfsr_q[2] ^ lfsr_q[18];
		 lfsr_c[11] = b_data_in[3] ^ lfsr_q[3] ^ lfsr_q[19];
		 lfsr_c[12] = b_data_in[0] ^ b_data_in[4] ^ lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[20];
		 lfsr_c[13] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[5] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[5] ^ lfsr_q[21];
		 lfsr_c[14] = b_data_in[1] ^ b_data_in[2] ^ b_data_in[6] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[6] ^ lfsr_q[22];
		 lfsr_c[15] = b_data_in[2] ^ b_data_in[3] ^ b_data_in[7] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[7] ^ lfsr_q[23];
		 lfsr_c[16] = b_data_in[0] ^ b_data_in[2] ^ b_data_in[3] ^ b_data_in[4] ^ lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[24];
		 lfsr_c[17] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[3] ^ b_data_in[4] ^ b_data_in[5] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[25];
		 lfsr_c[18] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[2] ^ b_data_in[4] ^ b_data_in[5] ^ b_data_in[6] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[26];
		 lfsr_c[19] = b_data_in[1] ^ b_data_in[2] ^ b_data_in[3] ^ b_data_in[5] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[27];
		 lfsr_c[20] = b_data_in[3] ^ b_data_in[4] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[28];
		 lfsr_c[21] = b_data_in[2] ^ b_data_in[4] ^ b_data_in[5] ^ b_data_in[7] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7] ^ lfsr_q[29];
		 lfsr_c[22] = b_data_in[2] ^ b_data_in[3] ^ b_data_in[5] ^ b_data_in[6] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[30];
		 lfsr_c[23] = b_data_in[3] ^ b_data_in[4] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[31];
		 lfsr_c[24] = b_data_in[0] ^ b_data_in[2] ^ b_data_in[4] ^ b_data_in[5] ^ b_data_in[7] ^ lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7];
		 lfsr_c[25] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[2] ^ b_data_in[3] ^ b_data_in[5] ^ b_data_in[6] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[6];
		 lfsr_c[26] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[2] ^ b_data_in[3] ^ b_data_in[4] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ lfsr_q[7];
		 lfsr_c[27] = b_data_in[1] ^ b_data_in[3] ^ b_data_in[4] ^ b_data_in[5] ^ b_data_in[7] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7];
		 lfsr_c[28] = b_data_in[0] ^ b_data_in[4] ^ b_data_in[5] ^ b_data_in[6] ^ lfsr_q[0] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6];
		 lfsr_c[29] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[5] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7];
		 lfsr_c[30] = b_data_in[0] ^ b_data_in[1] ^ b_data_in[6] ^ b_data_in[7] ^ lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[6] ^ lfsr_q[7];
		 lfsr_c[31] = b_data_in[1] ^ b_data_in[7] ^ lfsr_q[1] ^ lfsr_q[7];
		 
		 b_crc_out = {lfsr_c};
		 b_rdy = 1'b1;
	 end 
	  
  end // always
endmodule
