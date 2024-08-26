module Microphone(
	input csi_clk,
	input rsi_reset_n,
	
	output avm_s0_irq,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output avs_s0_waitrequest = 'b0,
	output[31:0] avs_s0_readdata = 'b0,

	// Microphone
	inout da,
	output sck,
	output sel,
	output ws
);

wire clk = csi_clk;
wire rst = ~rsi_reset_n;


wire[23:0] out_audio;
wire out_read;

wire in_enable;
wire out_irq;

wire full;
wire empty;

mic_parameters npar(
	.clk(clk),
	.rst(rst),
	
	.avm_s0_irq(avm_s0_irq),
	.irq(out_irq),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.avs_s0_waitrequest(avs_s0_waitrequest),
	.avs_s0_readdata(avs_s0_readdata),	
	
	// Registers
	.enable(in_enable),
	
	.audio(out_audio),
	.read_audio(out_read),
	
	.full(full),
	.empty(empty)
);

wire irq;
wire[23:0] audio;
wire enable;


mic_buffer micb(
	.clk(clk),
	.rst(rst),
	
	.out_audio(out_audio),
	.out_read(out_read),
	
	.out_irq(out_irq),
	.in_enable(in_enable),
	
	.enable(enable),
	.audio(audio),
	.irq(irq),
	
	.full(full),
	.empty(empty)
);

wire[23:0] audio_in;
wire audio_rdy;

mic_filter mif(
	.clk(clk),
	.rst(rst),
	
	.enable(enable),
	
	.data_in(mic_dir_data),
	.data_in_rdy(mic_dir_rdy),
	
	.data_out(audio_in),
	.data_out_rdy(audio_rdy)
);

wire tick;

wire[23:0] mic_dir_data;
wire mic_dir_rdy;

mic_divider micd(
	.clk(clk),
	.rst(rst),
	
	.tick(tick)
);


mic_collector micc(
	.clk(clk),
	.rst(rst),
	
	.enable(enable),
	
	.mic_dir_data(audio_in),
	.mic_dir_rdy(audio_rdy),
	
	.irq(irq),
	.out_audio(audio)
);

mic_recv micr(
	.clk(clk),
	.rst(rst),
	
	.enable(enable),
	.tick(tick),
	
	.out(mic_dir_data),
	.rdy(mic_dir_rdy),
	
	// I2S
	
	.da(da),
	.sck(sck),
	.sel(sel),
	.ws(ws),
	
);


endmodule
