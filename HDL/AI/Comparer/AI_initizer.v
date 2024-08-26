
module AI_initizer(
	input clk,
	input	rst,
	
	input	init,
	input[15:0] sector,
	input[15:0] len,
	
	input crc_err,
	input tmr_err,
	input nde_err,
	input fifo_err,
	
	output reg[39:0] avm_m1_dout = 'b0,
	output reg avm_m1_ivalid = 'b0,
	input avm_m1_oready
);

reg[39:0] f_avm_m1_dout = 'b0;
reg f_avm_m1_ivalid = 'b0;

always@(posedge clk)
	if(rst) begin
		f_avm_m1_dout <= 'b0;
		f_avm_m1_ivalid <= 'b0;
	end else
	begin
		f_avm_m1_dout <= avm_m1_dout;
		f_avm_m1_ivalid <= avm_m1_ivalid;	
	end

always@(*) begin
	avm_m1_dout = f_avm_m1_dout;
	avm_m1_ivalid = f_avm_m1_ivalid;	
	
	if(avm_m1_oready) begin
		avm_m1_dout = 'b0;
		avm_m1_ivalid = 'b0;
	end
	
	if(init) begin
		avm_m1_dout = {8'h0,sector,len};
		avm_m1_ivalid = 1'b1;
	end
	
	if(tmr_err | crc_err | nde_err | fifo_err) begin
		avm_m1_dout = {8'hFF,32'h0};
		avm_m1_ivalid = 1'b1;		
	end
	
end

endmodule
