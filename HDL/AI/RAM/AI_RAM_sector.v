
module AI_RAM_sector#(
	parameter SECTOR = 1'b0
)(
	
	input clk,
	input rst,
	
	// Avalon
	input avs_s1_write,
	input avs_s1_read,
	input avs_s1_byteenable,
	input[13:0] avs_s1_address,
	input[7:0] avs_s1_writedata,
	
	output reg[7:0] avs_s1_readdata = 'b0,
	
	// DMA Writing
	
	input q_write,
	input[13:0] q_addr,
	input[7:0] q_data,
	
	// Inside
	
	input read,
	
	input[15:0] in_addr,
	output reg[7:0] out_data,

	input[15:0] in_addr2,
	output reg[7:0] out_data2
	
);

wire[7:0] b_out_data1;
reg [15:0] b_addr1;
 
wire[7:0] b_out_data2;
reg [15:0] b_addr2;

always@(posedge clk)
	if(rst) begin
		b_addr1 <= 'b0;
		b_addr2 <= 'b0;
	end else
	begin
		b_addr1 <= in_addr;
		b_addr2 <= in_addr2;	
	end

reg write = 'b0;
reg[12:0] addr = 'b0;
reg[7:0] data = 'b0;

reg write_r = 'b0;
reg[12:0] addr_r = 'b0;
reg[7:0] data_r = 'b0;

always@(*)
	if((avs_s1_read | avs_s1_write) & avs_s1_byteenable) begin
		write = avs_s1_write;
		addr = avs_s1_address[12:0];
		data = avs_s1_writedata;
	end else
	begin
		write = 'b0;
		addr = in_addr[13:0];	
		data = 'b0;	
	end

always@(*)
	if(q_write) begin
		write_r = q_write;
		addr_r = q_addr;
		data_r = q_data;
	end else
	begin
		write_r = 'b0;
		addr_r = in_addr2[13:0];	
		data_r = 'b0;	
	end
	
RAMl raml1(
	.clock(clk),
	
	.address_a(addr),
	.q_a(b_out_data1),
	
	.data_a(data),
	.wren_a(write),
	
	
	.address_b(addr_r),
	.q_b(b_out_data2),
	
	.data_b(data_r),
	.wren_b(write_r)
	
);

always@(*) begin
	avs_s1_readdata <= b_out_data1;
end

always@(*) begin
	out_data <= b_out_data1;
end	

always@(*) begin
	out_data2 <= b_out_data2;
end	
	
	
endmodule
