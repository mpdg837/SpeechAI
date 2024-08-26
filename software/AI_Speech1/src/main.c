/*
 * main.c
 *
 *  Created on: 10 mar 2024
 *      Author: micha
 */
#include "devices.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"

#include "./utils/timer/timer.h"
#include "./utils/printnum.h"
#include "./ai/ai.h"
#include "./processing/utils/scalex.h"
#include "./ai/dma/dma.h"
#include "./processing/normalisation.h"
#include "./processing/spectrogram.h"
#include "./disk/disk.h"
#include "./disk/ai_fs.h"
#include "./microphone/microphone.h"
#include "./processing/utils/loud.h"
#include "./detect.h"
#include "./microphone/recorder.h"
#include "./speaker/speaker.h"
#include "./output/BLE/BLE.h"
#include "./detect_types.h"
#include "./utils/datatypes.h"

#include "./output/exception.h"
#include "./speaker/sound.h"
#include "./selfchecks.h"

#define NO_DETECT			-1
#define NO_LIMIT 			-1
#define WAIT_FOR_COMMAND	5000

#define WAIT_FOR_RETRY_3	3000
#define WAIT_FOR_RETRY_2	3000
#define WAIT_FOR_RETRY_1	3000

#define MAX_RETRIES			3
#define SHEILA_NAME			7
#define CORRECT_WORD		0

#define WORD_LENGTH			16

#define PARTITY(transactions) transactions & 0x1

typedef uint32_t AI_transactions_counter_t;
typedef uint8_t AI_retires_t;

typedef enum Meet_state{
	MEET_STATE_WAIT_FOR_NAME = 0,
	MEET_STATE_WAIT_FOR_COMMAND = 1,
	MEET_STATE_WAIT_FOR_RETRY = 2
}Meet_state_t;


void app(volatile Device_tree_t* tree){

	  Meet_state_t state = MEET_STATE_WAIT_FOR_NAME;

	  BLE_console_t console;

	  uint8_t buffer_word[16];

	  console.word_time = 0;
	  console.buart = tree ->buart;
	  console.timer = tree -> timer;

	  console.word = buffer_word;

	  uint8_t buffer_command[16];
	  console.buffer_out = buffer_command;

	  tree ->speaker ->console = &console;

	  AI_transactions_counter_t transactions = 0;
	  AI_retires_t retry = 0;

	  Detector_t detector;

	  detector.comparer = tree -> comparer;
	  detector.disk = tree-> disk;
	  detector.memories = tree -> memories;
	  detector.microphone = tree -> microphone;
	  detector.normalizer = tree -> normaliser;
	  detector.spectrogramer = tree -> spectrogramer;
	  detector.timer = tree -> timer;
	  detector.gpio = tree -> distancer;
	  detector.buart = tree -> buart;
	  detector.console = &console;

	  if(app_selfcheck(tree,&detector)){
		  return (void)0;
	  }

	  if(gpio_button_buffered_status(detector.gpio)){
		  return (void)0;
	  }


	  init_BLE(tree -> buart);
	  uint8_t word[16];

	  uint8_t buffer[16];

	  str_clr(buffer,16);
	  str_clr(word,16);


	  gpio_stop_flash(tree -> distancer);
	  gpio_set_pin(tree -> distancer,GPIO_PIN_READY,GPIO_PIN_UP);

	  say(tree -> speaker,(uint8_t*)"Hello");

	  Recorder_flag_t flag = RECORDER_FLAG_WAIT_FOR_NAME;
	  Data_bool_t same_detected_word = DATA_FALSE;


	  while(1){

		  if(tree -> disk -> status == DISK_STATUS_READY){

			  Detector_status_t decision_word;

			  if(state == MEET_STATE_WAIT_FOR_COMMAND){
				  decision_word = get_word(&detector,WAIT_FOR_COMMAND,word,flag);
			  }else if(state == MEET_STATE_WAIT_FOR_RETRY){

				  decision_word = get_word(&detector,WAIT_FOR_RETRY_3,word,flag);

			  }else{
				  decision_word = get_word(&detector,NO_LIMIT,word,flag);
			  }

			  if(record_selfcheck(tree ,decision_word) || decision_word == DETECTOR_STATUS_RESET){
				 break;
			  }

			  if(decision_word == DETECTOR_STATUS_COMMAND_CANCEL){
				  say(tree -> speaker,(uint8_t*)"Nodetect");
				  state = MEET_STATE_WAIT_FOR_NAME;
				  retry = 0;

				  flag = RECORDER_FLAG_WAIT_FOR_NAME;
			  }else
			  if(decision_word == DETECTOR_STATUS_CHANGE_VOLUME){

				  tree->speaker->volume --;

				  if(tree->speaker->volume == 4){
					  tree->speaker->volume = 0;
				  }

				  if(tree->speaker->volume == -1){
					  tree->speaker->volume = 15;
				  }
				  say(tree -> speaker,(uint8_t*)"Ok");

			  }else
			  if(decision_word == DETECTOR_STATUS_COMMAND_DIRECTLY){
				  if(PARTITY(transactions))
					  say(tree -> speaker,(uint8_t*)"Hello");
				  else
					  say(tree -> speaker,(uint8_t*)"Yes");

				  retry = 0;
				  state = MEET_STATE_WAIT_FOR_COMMAND;

				  str_clr(buffer,16);
				  same_detected_word = DATA_FALSE;
				  flag = RECORDER_FLAG_WAIT_FOR_COMMAND;
			  }else if(decision_word == DETECTOR_STATUS_OK){

				  if(compare((uint8_t*)"sheila",word,16) && state == MEET_STATE_WAIT_FOR_NAME){
					  if(PARTITY(transactions))
						  say(tree -> speaker,(uint8_t*)"Hello");
					  else
						  say(tree -> speaker,(uint8_t*)"Yes");

					  retry = 0;
					  state = MEET_STATE_WAIT_FOR_COMMAND;
					  flag = RECORDER_FLAG_WAIT_FOR_COMMAND;
					  same_detected_word = DATA_FALSE;

					  str_clr(buffer,16);

				  }else if(state != MEET_STATE_WAIT_FOR_NAME){

					  uint8_t nbuffer[17];
					  nbuffer[0] = 's';
					  str_cpy(word,&nbuffer[1],16);

					  if(state == MEET_STATE_WAIT_FOR_RETRY){
						  if(retry == MAX_RETRIES){
							  say(tree -> speaker,(uint8_t*)"Nodetect");
							  state = MEET_STATE_WAIT_FOR_NAME;
							  flag = RECORDER_FLAG_WAIT_FOR_NAME;
							  retry = 0;
						  }else{

							  if(compare((uint8_t*)word,(uint8_t*)buffer,16)){
								  str_clr(buffer,16);

								  if(retry == MAX_RETRIES){
									  say(tree -> speaker,(uint8_t*)"Nodetect");
								  	  state = MEET_STATE_WAIT_FOR_NAME;
								  	  retry = 0;

								  	  flag = RECORDER_FLAG_WAIT_FOR_NAME;
								  }else{
								  	  say(tree -> speaker,(uint8_t*)"Repeat");
								  }
								  same_detected_word = DATA_TRUE;

							  }else{
								  same_detected_word = DATA_FALSE;
								  say(tree -> speaker,(uint8_t*)"Sorry");
								  say(tree -> speaker,(uint8_t*)nbuffer);

								  state = MEET_STATE_WAIT_FOR_RETRY;
								  same_detected_word = DATA_FALSE;
							  }
							  retry ++;

							  state = MEET_STATE_WAIT_FOR_RETRY;
						  }
					  }else{
						  say(tree -> speaker,(uint8_t*)nbuffer);

						  state = MEET_STATE_WAIT_FOR_RETRY;
					  }

					  str_cpy(word,buffer,16);
				  }


			  }else{

				  if(decision_word == DETECTOR_STATUS_CANT_DETECT && state != MEET_STATE_WAIT_FOR_NAME){
					  str_clr(buffer,16);

					  if(state == MEET_STATE_WAIT_FOR_COMMAND){
						  say(tree -> speaker,(uint8_t*)"Repeat");
						  retry = 0;
						  state = MEET_STATE_WAIT_FOR_RETRY;
						  same_detected_word = DATA_FALSE;

						  str_clr(buffer,16);
					  }else{
						  if(retry == MAX_RETRIES){
							  say(tree -> speaker,(uint8_t*)"Nodetect");
							  state = MEET_STATE_WAIT_FOR_NAME;
							  retry = 0;

							  flag = RECORDER_FLAG_WAIT_FOR_NAME;
						  }else{
							  say(tree -> speaker,(uint8_t*)"Repeat");
							  retry ++;

						  }
					  }
				  }else if(decision_word == DETECTOR_STATUS_NO_FRAGMENT && state != MEET_STATE_WAIT_FOR_NAME){

						  if(!is_empty_str(buffer,16) && !same_detected_word){

							  for(int n=0;n<19;n++){
								  if(buffer[n] == 0){
									  buffer[n] = '\r';
									  buffer[n+1] = '\n';
									  break;
								  }
							  }

							  wait_for_connection(tree);
							  BLE_send_data(tree -> buart,buffer);
							  BLE_add_word(&console,buffer);

							  say(tree -> speaker,(uint8_t*)"Ok");

							  str_clr(buffer,16);

							  flag = RECORDER_FLAG_WAIT_FOR_NAME;

						  }else{
							  say(tree -> speaker,(uint8_t*)"Nodetect");
							  flag = RECORDER_FLAG_WAIT_FOR_NAME;
						  }



						  transactions ++;
						  state = MEET_STATE_WAIT_FOR_NAME;
						  retry = 0;

				  }
			  }
		  }else{

		  }

	  }


}
