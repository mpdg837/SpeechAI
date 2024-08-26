/*
 * recorder.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "../ai/dma/dma.h"
#include "../utils/timer/timer.h"
#include "../processing/normalisation.h"
#include "inttypes.h"
#include "../microphone/microphone.h"
#include "../microphone/recorder_types.h"
#include "../output/gpio_distance.h"
#include "../output/gpio_distance_measure.h"
#include "../output/BLE/communication.h"
#include "../output/exception.h"
#include "../utils/reset.h"

#define MIC_DETECT_MIN 		(int32_t)  (1024 + 512)
#define MAX_16_BIT_VALUE 	(uint16_t) 0xFFFF

#define MAX_EMPTY_END_SPACE  100
#define MAX_SIZE 			(uint32_t) 24000
#define MAX_SIZE_WITH_SPACE (uint32_t) MAX_SIZE - 100

#define MAX_MARGIN_SIZE		(uint32_t) 11950

typedef uint32_t Sample_counter_t;

#define INITIAL_SAMPLES		(Sample_counter_t)2048

typedef uint32_t Distance_tries_counter_t;


Recorder_status_t Recorder_record(volatile Recorder_t* recorder,volatile Timer_time_t* time, Timer_time_t timeout,Recorder_flag_t flag){

	DMA_table_mem_t* table = (DMA_table_mem_t*) recorder -> memories -> table;

	Sample_counter_t n=0;
	Sample_counter_t mmargin = 0;

	Sample_counter_t initial = 0;

	Timer_reset(recorder -> timer);


	Distance_measurement_t meas;
	init_distance_measurement(&meas);

	Gpio_timer_t schedulder = 0;
	Gpio_detection_status_t rstatus = GPIO_DETECT_IN_RANGE;

	for(int n=0;n<recorder ->memories -> table_size ; n++){
		recorder ->memories ->table[n] = 0;
	}

	MIC_start();

	while(1){

		Microphone_sound_t sound = 0;
		Microphone_status_t status = MIC_getSample((Microphone_t*)recorder -> microphone, &sound);

		if(status == MICROPHONE_STATUS_FULL){

			for(int n=0;n<recorder ->memories -> table_size ; n++){
				recorder ->memories ->table[n] = 0;
			}

			for(int n=0;n<16;n++){
				if(MIC_getSample((Microphone_t*)recorder -> microphone, &sound) == MICROPHONE_STATUS_EMPTY){
					break;
				}
			}

			continue;
		}

		if(status == MICROPHONE_STATUS_EMPTY){
			continue;
		}

		if(status == MICROPHONE_STATUS_ERROR){

			return RECORDER_ERROR;
		}

		if(rstatus == GPIO_DETECT_IN_RANGE){
			recorder -> console -> in_range = DATA_TRUE;

			if(status == MICROPHONE_STATUS_READY){
				if(initial < INITIAL_SAMPLES){
					initial ++;
				}else{

					table[n] = (DMA_table_mem_t) sound;

					if(mmargin == 0){
						if(sound > MIC_DETECT_MIN && sound < MAX_16_BIT_VALUE - MIC_DETECT_MIN){
							mmargin = 1;
						}
					}else{
						mmargin ++;
					}


					if(mmargin >= MAX_MARGIN_SIZE){
						MIC_stop();
						Nor_normalizeSamples(recorder -> normaliser,recorder -> memories);

						// swapping

						uint32_t index = n + 1;

						DMA_copy_to_swap(recorder -> memories,index,(MAX_SIZE_WITH_SPACE) * 2);
						DMA_paste_from_swap(recorder -> memories,(MAX_SIZE_WITH_SPACE) * 2);

						break;
					}else{
						if((Timer_get_time(recorder -> timer) > timeout) && (timeout != -1)){
							MIC_stop();
							return RECORDER_TIMEOUT;
						}
					}

					n++;

					if(n == MAX_SIZE_WITH_SPACE){
						n = 0;
					}
				}
			}
		}else{
			if(recorder -> console -> in_range){
				for(int n=0;n<recorder ->memories -> table_size ; n++){
					recorder ->memories ->table[n] = 0;
				}

				n=0;
				mmargin = 0;

				initial = 0;
			}

			recorder -> console -> in_range = DATA_FALSE;

			if(rstatus == GPIO_DETECT_ERROR){
				return RECORDER_ERROR;
			}

			n=0;
			mmargin = 0;
			initial = 0;

			if((Timer_get_time(recorder -> timer) > timeout) && (timeout != -1)){
				MIC_stop();
				return RECORDER_TIMEOUT;
			}

		}

		Distance_button_t button = BUTTON_NOT_PRESSED;
		switch(schedulder){
			case 0:
				if(wait_for_connection_recorder(recorder)){
					return RECORDER_RESET;
				}
				break;
			case 1:
				BLE_console(recorder -> console);
				break;
			case 2:

				button = gpio_button_buffered_status(recorder -> timer ->gpio);
				if(button == BUTTON_LISTEN){

					MIC_stop();

					if(flag == RECORDER_FLAG_WAIT_FOR_NAME){

						return RECORDER_START;
					}else{

						return RECORDER_CANCEL;
					}

				}else if(button == BUTTON_RESET){

					MIC_stop();
					return RECORDER_RESET;

				}else if(button == BUTTON_VOLUME){
					MIC_stop();
					return RECORDER_VOLUME;
				}

				break;
			case 3:
				rstatus = in_proper_distance(recorder -> timer -> mdistance,&meas);
				break;

		}

		schedulder ++;

		if(schedulder == 10){
			schedulder = 0;
		}


	}

	*time =  MAX_SIZE;

	return RECORDER_RECORDED_FRAGMENT;
}
