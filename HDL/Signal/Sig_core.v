
module sig_core(
	input clk,
	input rst,
	
	input init,
	
	input[15:0] audio_data,
	input audio_valid,

	output audio_rdy,

	output[15:0] profile_data,
	output profile_valid,
	input profile_rdy	
);


wire[15:0] zcr_window_data;
wire zcr_window_valid;
wire zcr_window_rdy;

wire[15:0] window_data;
wire window_rdy;
wire window_valid;

sig_hamming_window wham(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.audio_out(audio_data),
	.audio_rdy(audio_rdy),
	.audio_valid(audio_valid),
	
	.window_out(window_data),
	.window_rdy(window_rdy),
	.window_valid(window_valid),
	
	.zcr_window_out(zcr_window_data),
	.zcr_window_valid(zcr_window_valid),
	.zcr_window_rdy(zcr_window_rdy)
);

wire[7:0] zcr_data;
wire zcr_valid;

wire zcr_rdy;

signal_zcr zcr(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.window_data(zcr_window_data),
	.window_valid(zcr_window_valid),
	.window_rdy(zcr_window_rdy),
	
	.zcr_data(zcr_data),
	.zcr_valid(zcr_valid),
	.zcr_rdy(zcr_rdy)
	
);


wire[15:0] transform1_real;
wire[15:0] transform1_imag;
wire transform1_valid;
wire transform1_rdy;

wire[15:0] transform2_real;
wire[15:0] transform2_imag;
wire transform2_valid;
wire transform2_rdy;

singal_fft fft1(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.window_data(window_data),
	.window_valid(window_valid),
	.window_rdy(window_rdy),
	
	.transform1_real(transform1_real),
	.transform1_imag(transform1_imag),
	.transform1_valid(transform1_valid),
	.transform1_rdy(transform1_rdy),
	
	.transform2_real(transform2_real),
	.transform2_imag(transform2_imag),
	.transform2_valid(transform2_valid),
	.transform2_rdy(transform2_rdy),	

);

wire[31:0] power1_data;
wire power1_valid;
wire power1_rdy;

wire[31:0] power2_data;
wire power2_valid;
wire power2_rdy;


signal_power pow1(
	.clk(clk),
	.rst(rst),
	
	.transform_real(transform1_real),
	.transform_imag(transform1_imag),
	
	.transform_valid(transform1_valid),
	.transform_rdy(transform1_rdy),
	
	.power_data(power1_data),
	.power_valid(power1_valid),
	.power_rdy(power1_rdy)
	
);

signal_power pow2(
	.clk(clk),
	.rst(rst),
	
	.transform_real(transform2_real),
	.transform_imag(transform2_imag),
	
	.transform_valid(transform2_valid),
	.transform_rdy(transform2_rdy),
	
	.power_data(power2_data),
	.power_valid(power2_valid),
	.power_rdy(power2_rdy)
	
);

wire[15:0] spect1_data;
wire spect1_valid;
wire spect1_rdy;

wire[15:0] spect2_data;
wire spect2_valid;
wire spect2_rdy;

signal_modulus modulus_1(
	.clk(clk),
	.rst(rst),
	
	.power_data(power1_data),
	.power_valid(power1_valid),
	.power_rdy(power1_rdy),
	
	.spect_data(spect1_data),
	.spect_valid(spect1_valid),
	.spect_rdy(spect1_rdy)
);

signal_modulus modulus_2(
	.clk(clk),
	.rst(rst),
	
	.power_data(power2_data),
	.power_valid(power2_valid),
	.power_rdy(power2_rdy),
	
	.spect_data(spect2_data),
	.spect_valid(spect2_valid),
	.spect_rdy(spect2_rdy)
);

wire[15:0] spect_data;
wire spect_valid;
wire spect_rdy;

sig_collector col1(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.audio1(spect1_data),
	.audio1_valid(spect1_valid),
	.audio1_rdy(spect1_rdy),
	
	.audio2(spect2_data),
	.audio2_valid(spect2_valid),
	.audio2_rdy(spect2_rdy),
	
	.audio(spect_data),
	.audio_valid(spect_valid),
	.audio_rdy(spect_rdy)
);

wire[15:0] mel_spect_data;
wire mel_spect_valid;
wire mel_spect_rdy;

sig_mel_spect mes(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.spect_data(spect_data),
	.spect_valid(spect_valid),
	.spect_rdy(spect_rdy),
	
	.mel_spect_data(mel_spect_data),
	.mel_spect_valid(mel_spect_valid),
	.mel_spect_rdy(mel_spect_rdy)

);

signal_combiner prof(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.spect_data(mel_spect_data),
	.spect_valid(mel_spect_valid),
	.spect_rdy(mel_spect_rdy),
	
	.zcr_data(zcr_data),
	.zcr_valid(zcr_valid),
	.zcr_rdy(zcr_rdy),
	
	.profile_data(profile_data),
	.profile_valid(profile_valid),
	.profile_rdy(profile_rdy)
);

endmodule
