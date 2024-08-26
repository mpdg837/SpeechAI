/*
 * speaker.c
 *
 *  Created on: 10 mar 2024
 *      Author: micha
 */
#include "speaker_types.h"
#include "../utils/datatypes_types.h"
#include "../disk/disk.h"
#include "./sound.h"
#include "sys/alt_irq.h"

#define PWMAUDIO_0_IRQ 6
#define PWMAUDIO_0_IRQ_INTERRUPT_CONTROLLER_ID 0

#define AUDIO_IRQ 	   	  	  	(volatile uint32_t*) 0x26000
#define AUDIO_START_ADDR 	  	(volatile uint32_t*) 0x26004
#define AUDIO_STOP_ADDR		  	(volatile uint32_t*) 0x26008
#define AUDIO_VOLUME		  	(volatile uint32_t*) 0x2600c
#define AUDIO_START			  	(volatile uint32_t*) 0x26010
#define AUDIO_STOP			  	(volatile uint32_t*) 0x26014

#define SOUND_BUFFER_SIZE	(uint32_t) 8192

static void audio_isr(void* context){

	Speaker_t* speaker = (Speaker_t*) context;
	speaker -> flag = SPEAKER_FLAG_UP;

	*AUDIO_IRQ = 0;
}

void Speaker_read_first_half(volatile Speaker_t* speaker){

	DMA_table_mem_t* table = (DMA_table_mem_t*) speaker -> disk ->memories ->table;

	*AUDIO_START_ADDR = (uint32_t) &table[0];
	*AUDIO_STOP_ADDR = (uint32_t) &table[SOUND_BUFFER_SIZE - 2];
	*AUDIO_VOLUME = speaker ->volume;

	speaker ->flag = SPEAKER_FLAG_DOWN;

	*AUDIO_START = 1;
}

void Speaker_second_first_half(volatile Speaker_t* speaker){
	DMA_table_mem_t* table = (DMA_table_mem_t*) speaker -> disk ->memories ->table;

	*AUDIO_START_ADDR = (uint32_t) &table[SOUND_BUFFER_SIZE];
	*AUDIO_STOP_ADDR = (uint32_t) &table[(2*SOUND_BUFFER_SIZE) - 2];
	*AUDIO_VOLUME = speaker ->volume;

	speaker ->flag = SPEAKER_FLAG_DOWN;

	*AUDIO_START = 1;
}

Data_bool_t Speaker_wait_for_finish(volatile Speaker_t* speaker){
	if(speaker ->flag == SPEAKER_FLAG_DOWN){
		return DATA_TRUE;
	}else{
		speaker -> flag = SPEAKER_FLAG_DOWN;
		return DATA_FALSE;
	}
}



void Speaker_init(volatile Speaker_t* speaker){
	alt_ic_isr_register(PWMAUDIO_0_IRQ_INTERRUPT_CONTROLLER_ID,PWMAUDIO_0_IRQ,audio_isr,(Speaker_t*)speaker,0);
	start_speaker(speaker);
}

