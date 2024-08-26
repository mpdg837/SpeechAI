/*
 * detect.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "sys/alt_stdio.h"
#include "sys/alt_stdio.h"
#include "./utils/timer/timer.h"
#include "./utils/printnum.h"
#include "./ai/dma/dma.h"
#include "./processing/normalisation.h"
#include "./processing/spectrogram.h"
#include "./microphone/recorder.h"
#include "./processing/utils/loud.h"
#include "./processing/utils/scalex.h"
#include "./disk/disk.h"
#include "./ai/ai_group.h"

#include "detect_types.h"

#define MINUMUM_VALUE_SPECT		16
#define PACKET_SIZE 			64
#define SPECT_LINE_SIZE 		(uint16_t) 320

Detector_status_diag_t selfcheck(volatile Detector_t* detector){

	Detector_status_t status = ai_group_selfcheck(detector);

	if(status == DETECTOR_STATUS_CANT_DETECT || status == DETECTOR_STATUS_OK){
		return DETECTOR_STATUS_DIAGNOSTIC_READY;
	}else{
		return DETECTOR_STATUS_DIAGNOSTIC_ERROR;
	}
}

Detector_status_t get_word(volatile Detector_t* detector, Timer_time_t timeout,uint8_t* word,Recorder_flag_t flag){

	DMA_table_mem_t* table = (DMA_table_mem_t*) detector -> memories -> table;
	Recorder_t recorder;

	recorder.memories = detector -> memories;
	recorder.microphone = detector -> microphone;
	recorder.normaliser = detector -> normalizer;
	recorder.timer = detector -> timer;
	recorder.gpio = detector -> gpio;
	recorder.buart = detector -> buart;
	recorder.console = detector -> console;
	Timer_time_t return_time = 0;

	Recorder_status_t rstatus = Recorder_record(&recorder,&return_time,timeout,flag);

	if(rstatus == RECORDER_VOLUME){
		return DETECTOR_STATUS_CHANGE_VOLUME;
	}
	if(rstatus == RECORDER_START){
		return DETECTOR_STATUS_COMMAND_DIRECTLY;
	}
	if(rstatus == RECORDER_CANCEL){
		return DETECTOR_STATUS_COMMAND_CANCEL;
	}

	if(rstatus == RECORDER_TIMEOUT){
		return DETECTOR_STATUS_NO_FRAGMENT;
	}else if(rstatus == RECORDER_ERROR){
		return DETECTOR_STATUS_MICROPHONE_ERROR;
	}

	if(rstatus == RECORDER_RESET){
		return DETECTOR_STATUS_RESET;
	}
	alt_printf("Detecting test \n");
	alt_printf("==== \n");
	alt_printf(" Measure key features: \n");

	Timer_reset(detector -> timer);

	DMA_size_t select_size = 0;
	if(selectLoud(detector -> memories,&select_size,return_time) == LOUD_FRAGMENT_NO_FRAGMENT){
		return DETECTOR_STATUS_NOISE;
	}

	alt_printf("Select loud fragment time: ");
	printnum(Timer_get_time(detector -> timer));
	alt_printf(" ms \n");


	DMA_size_t for_len = Signal_spectrogram(detector -> spectrogramer,select_size);



	Timer_reset(detector -> timer);
	Scale_scaleX(table,PACKET_SIZE, SPECT_LINE_SIZE, for_len/SPECT_LINE_SIZE);

	alt_printf("Time scaleing time: ");
	printnum(Timer_get_time(detector -> timer));
	alt_printf(" ms \n");

	Timer_reset(detector -> timer);
	DMA_copy_to_ai(detector -> memories,MINUMUM_VALUE_SPECT);

	alt_printf("DMA time: ");
	printnum(Timer_get_time(detector -> timer));
	alt_printf(" ms \n");

	alt_printf("----\n");
	return ai_group_analyse(detector,word);

}
