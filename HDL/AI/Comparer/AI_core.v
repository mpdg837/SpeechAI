
module AI_core(
	input clk,
	input rst,
	
	input compress,
	input init,
	// RAM
	output[15:0] c1_ram_addr,
	output c1_ram_read,
	
	input c1_ram_rdy,
	input[31:0] c1_ram_data,
	
	// Parameters
	input[15:0] load_len,
	
	// Data in
	
	input[7:0] card_data,
	input card_rdy,
	
	// Data out
	
	output[31:0] fsum_out,
	output fsum_empty,
	input fsum_read,
	
	// Control
	
	output tmr_err,
	output crc_err,
	output nde_err,
	output fifo_err,
	
	output[31:0] crc_out,
	
	output irq_in,
	
	// Config
	input[23:0] max,
	input[14:0] sample_size,
	input[7:0] packet_size
	
);

reg b_compress = 'b0;

always@(posedge clk)
	if(rst)
		b_compress <= 'b0;
	else
		b_compress <= compress;

wire[7:0] b_card_data;
wire b_card_rdy;

AI_wait aiw(.clk(clk),
				.rst(rst),
				  
				
				.card_in(card_data),
				.card_in_rdy(card_rdy),
				
				.card_out(b_card_data),
				.card_out_rdy(b_card_rdy)
);


wire[7:0] b_data_out;
wire b_data_rdy;

AI_buffer aib(.clk(clk),
				  .rst(rst),
				  
				  .init(init),
				  
				  .card_data(b_card_data),
				  .card_rdy(b_card_rdy),
								
				  .b_data_out(b_data_out),
				  .b_data_rdy(b_data_rdy),

				  .crc_err(crc_err),
				  .tmr_err(tmr_err)
);


AI_QCRC64_ISO aicrci(
	.clk(clk),
	.rst(rst),
  
   .data_in(b_data_out),
   .start(b_data_rdy),
   .clr(init),
  
   .crc_out(crc_out)
);

wire[63:0] l_data_out;
wire l_data_rdy;

AI_loader ail(.clk(clk),
				  .rst(rst),
	
				  .compress(b_compress),
				  .init(init),
	
				  .sample_size(sample_size),
				  .stream_in(b_data_out),
				  .stream_rdy(b_data_rdy),
	
				  .c_ram_addr(c1_ram_addr),
				  .c_ram_read(c1_ram_read),
				  .c_ram_rdy(c1_ram_rdy),
				  .c_ram_data(c1_ram_data),
	
				  .data_out(l_data_out),
				  .rdy_out(l_data_rdy)
	
);

wire[63:0] des4_data_out;
wire des4_data_rdy;

AI_decompressor_4 aide4(
	.clk(clk),
	.rst(rst),
	
	.compress(b_compress),
	.init(init),
	
	.data_in(l_data_out),
	.data_in_rdy(l_data_rdy),
	
	.data_out(des4_data_out),
	.data_out_rdy(des4_data_rdy)
);

wire[63:0] des2_data_out;
wire des2_data_rdy;

AI_decompressor_2 aide2(
	.clk(clk),
	.rst(rst),
	
	.compress(b_compress),
	.init(init),
	
	.data_in(l_data_out),
	.data_in_rdy(l_data_rdy),
	
	.data_out(des2_data_out),
	.data_out_rdy(des2_data_rdy)
);


wire[9:0] c_data_out;
wire c_rdy_out;

AI_crosser aic(.clk(clk),
				   .rst(rst),
					
					.init(init),

				   .data2_in(des2_data_out),
				   .rdy2_in(des2_data_rdy),
					
				   .data4_in(des4_data_out),
				   .rdy4_in(des4_data_rdy),
		
				   .data_out(c_data_out),
				   .rdy_out(c_rdy_out)
);

wire[31:0] in_sum_sum;
wire in_sum_rdy;

AI_sum ais(.clk(clk),
			  .rst(rst),
				
			  .c_data(c_data_out),
			  .c_rdy(c_rdy_out),
	
			  .sample_size(sample_size),
			  .init(init),
				
				.sum_out(in_sum_sum),
				.sum_rdy(in_sum_rdy)
);

wire sum_b_rdy;
wire[31:0] sum_b_sum;

AI_category aica(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	
	.packet_size(packet_size),
	
	.in_sum_sum(in_sum_sum),
	.in_sum_rdy(in_sum_rdy),
	
	.sum_b_sum(sum_b_sum),
	.sum_b_rdy(sum_b_rdy)
);

wire sum_f_rdy;
wire[31:0] sum_f_sum;
wire full;

AI_filter aifil(
	.clk(clk),
	.rst(rst),
	
	.max(max),
	
	.data_in(sum_b_sum),
	.data_in_rdy(sum_b_rdy),
	
	.data_out(sum_f_sum),
	.data_out_rdy(sum_f_rdy)
);



AI_FIFO_basic aifb(
	  .clk(clk), 
	  .rst(rst | init),
	  
	  .full(full),
	  
	  .w_en(sum_f_rdy), 
	  .data_in(sum_f_sum),
	  
	  .r_en(fsum_read),
	  .data_out(fsum_out),
	  .empty(fsum_empty)
);

AI_final aif(.clk(clk),
				 .rst(rst),
				 
				 .init(init),
				 .len(load_len),
				 .nde_err(nde_err),
				 
				 .char_rdy(c_rdy_out),
	
				 .irq(irq_in)
);

AI_error_catcher(
	.clk(clk),
	.rst(rst),
	
	.init(init),
	.full(full),
	
	.error(fifo_err)
);

endmodule
