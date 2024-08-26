module Audio_PWM(
	input csi_clk,
	input rsi_reset_n,

	output avm_s0_irq,
	
	// Avalon MM
	
	input avs_s0_write,
	input avs_s0_read,
	input[2:0] avs_s0_address,
	input[31:0] avs_s0_writedata,
	
	output[31:0] avs_s0_readdata = 'b0,

	// DMA
	
	output avm_m1_write,
	output avm_m1_read,
	
	input avm_m1_waitrequest,
	input avm_m1_readdatavalid,
	
	output[31:0] avm_m1_address,
	output[31:0] avm_m1_writedata,
	
	input [31:0] avm_m1_readdata,
	
	// Audio
	output[7:0] audio,
	output[7:0] audio1
	
	
);

wire irq;
wire clk = csi_clk;
wire rst = ~rsi_reset_n;

wire[31:0] startaddr;
wire[31:0] stopaddr;
wire start;

wire[3:0] volume;
wire stop;

PWM_config pcon(
	.clk(clk),
	.rst(rst),
	
	.avs_s0_write(avs_s0_write),
	.avs_s0_read(avs_s0_read),
	.avs_s0_address(avs_s0_address),
	.avs_s0_writedata(avs_s0_writedata),
	
	.startaddr(startaddr),
	.stopaddr(stopaddr),
	.start(start),
	.volume(volume),
	.stop(stop),
	
	.irq(irq),
	.avm_s0_irq(avm_s0_irq)
);





wire[31:0] dma_addr;
wire dma1_read;
wire dma1_write;
wire[31:0] dma_writedata;
wire[31:0] dma_readdata;
wire dma_rdy;

wire[15:0] sound;
wire sound_rdy;
wire sound_valid;

PWM_loader pwmlod(
	.clk(clk),
	.rst(rst),
	
	.start(start),
	.stop(stop),
	
	.startaddr(startaddr),
	.stopaddr(stopaddr),
	
	.sound(sound),
	.sound_rdy(sound_rdy),
	.sound_valid(sound_valid),
	
	// DMA
	
	.dma_addr(dma_addr),
	.dma_read(dma_read),
	.dma_write(dma_write),
	.dma_writedata(dma_writedata),
	.dma_readdata(dma_readdata),
	.dma_rdy(dma_rdy),
	
	.irq(irq)
	
);


PWM_dma ndm1(
	.clk(clk),
	.rst(rst),
	
	.dma_addr(dma_addr),
	.dma_read(dma_read),
	.dma_write(dma_write),
	.dma_writedata(dma_writedata),
	.dma_readdata(dma_readdata),
	.dma_rdy(dma_rdy),
	
	// DMA
	
	.avm_m1_write(avm_m1_write),
	.avm_m1_read(avm_m1_read),
	
	.avm_m1_waitrequest(avm_m1_waitrequest),
	.avm_m1_readdatavalid(avm_m1_readdatavalid),
	
	.avm_m1_address(avm_m1_address),
	.avm_m1_writedata(avm_m1_writedata),
	
	.avm_m1_readdata(avm_m1_readdata)
	
);

wire[15:0] soft;
wire soft_valid;
wire soft_rdy;

PWM_soft_launch psl1(
	.clk(clk),
	.rst(rst),
	
	.start(start),
	
	.audio_in(sound),
	.audio_in_valid(sound_valid),
	.audio_in_rdy(sound_rdy),
	
	.audio_out(soft),
	.audio_out_valid(soft_valid),
	.audio_out_rdy(soft_rdy)
	
);


PWM_sound_dac psd(
	.clk(clk),
	.rst(rst),
	
	.sound(soft),
	.sound_valid(soft_valid),
	.sound_rdy(soft_rdy),
	
	.volume(volume),
	
	.audio1(audio),
	.audio2(audio1)
	
);

endmodule

module PWM_sound_dac(
	input clk,
	input rst,
	
	input[15:0] sound,
	input sound_valid,
	output sound_rdy,
	
	input[3:0] volume,
	
	output[7:0] audio1,
	output[7:0] audio2
);

wire tick;
wire s_tick;
PWM_freq pfreq(
	.clk(clk),
	.rst(rst),
	
	.tick(tick),
	.s_tick(s_tick)
);

wire[15:0] fifo_sound;
wire fifo_sound_rdy;

PWM_fifo_stream pfifo(
	.clk(clk),
	.rst(rst),
	
	.sound(sound),
	.sound_valid(sound_valid),
	.sound_rdy(sound_rdy),
	
	.tick(tick),
	
	.sound_out(fifo_sound),
	.sound_out_rdy(fifo_sound_rdy)
);



wire[15:0] mul_sound;
wire mul_sound_rdy;

PWM_frequency_mul pfem(
	.clk(clk),
	.rst(rst),
	
	.s_tick(s_tick),
	
	.sound(fifo_sound),
	.sound_rdy(fifo_sound_rdy),
	
	.sound_out(mul_sound),
	.sound_out_rdy(mul_sound_rdy)
);

wire[15:0] fil_sound;
wire fil_sound_rdy;

PWM_filter pfil(
	.clk(clk),
	.rst(rst),
	
	.enable(1),
	
	.data_in(mul_sound),
	.data_in_rdy(mul_sound_rdy),
	
	.data_out(fil_sound),
	.data_out_rdy(fil_sound_rdy)
);

wire[15:0] reduced_sound;
wire reduced_sound_rdy;


PWM_reducer pred(
	.clk(clk),
	.rst(rst),
	
	.sound_in(fil_sound),
	.sound_rdy(fil_sound_rdy),
	
	.reduced_out(reduced_sound),
	.reduced_rdy(reduced_sound_rdy)
);


wire[15:0] in_sound;

PWM_serializer pser(
	.clk(clk),
	.rst(rst),
	
	.sound(reduced_sound),
	.sound_rdy(reduced_sound_rdy),
	
	.in_sound(in_sound)
);

wire pwm_out;

PWM_gen pgen(
	.clk(clk),
	.rst(rst),
	.PWM_in(in_sound), 
	.PWM_out(pwm_out)
);


PWM_volumer pvol(
	.clk(clk),
	.rst(rst),
	
	.volume(volume),
	.pwm_in(pwm_out),
	
	.audio1(audio1),
	.audio2(audio2)
);


endmodule
