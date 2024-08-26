/*
 * normalisation.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "inttypes.h"
#include "../ai/dma/dma_types.h"
#include "../processing/normalisation_types.h"

#define NORMALIZER_IRQ 	   	  	(volatile uint32_t*) 0x25000
#define NORMALIZER_MAX_VAL 	  	(volatile uint32_t*) 0x25004
#define NORMALIZER_START_ADDR 	(volatile uint32_t*) 0x25008
#define NORMALIZER_STOP_ADDR  	(volatile uint32_t*) 0x2500c
#define NORMALIZER_START	  	(volatile uint32_t*) 0x25010
#define NORMALIZER_LOGNOR	  	(volatile uint32_t*) 0x25014
#define NORMALIZER_AREAS	  	(volatile uint32_t*) 0x25018

#define NORMALIZER_0_IRQ 						 4
#define NORMALIZER_0_IRQ_INTERRUPT_CONTROLLER_ID 0

#define MASK_SAMPLE								 (uint32_t) 0x1FF
#define MASK_SPECTROGRAM 						 (uint32_t) 0xFFFF

#define EMPTY_SPACE_END_OF_TABLE				 100

volatile int nor_flag = 0;

static void nor_isr(void* context){

	Normaliser_t* normaliser = (Normaliser_t*) context;
	normaliser -> flag = NORMALISATION_FLAG_UP;
	*NORMALIZER_IRQ = 0;
}

void Nor_normalizeSamples(volatile Normaliser_t* normaliser,volatile DMA_memories_t* memories){

	DMA_table_mem_t* table = (DMA_table_mem_t*) memories -> table;

	*NORMALIZER_MAX_VAL = MASK_SAMPLE;
	*NORMALIZER_START_ADDR = (uint32_t) &table[0];
	*NORMALIZER_STOP_ADDR = (uint32_t) &table[(memories ->table_size) - 4];
	*NORMALIZER_LOGNOR = 0;

	for(uint32_t n=((memories ->table_size) - EMPTY_SPACE_END_OF_TABLE);
			n<(memories ->table_size);n++){
		table[n] = 0;
	}

	normaliser -> flag = NORMALISATION_FLAG_DOWN;
	*NORMALIZER_START = 1;
	while(normaliser -> flag == NORMALISATION_FLAG_DOWN){}
}

void Nor_log_normalisation(volatile Normaliser_t* normaliser,volatile DMA_memories_t* memories,
		DMA_table_mem_t* stop_ptr){

	DMA_table_mem_t* table = (DMA_table_mem_t*) memories -> table;

	*NORMALIZER_MAX_VAL = MASK_SPECTROGRAM;
	*NORMALIZER_START_ADDR = (uint32_t) &table[0];
	*NORMALIZER_STOP_ADDR = (uint32_t) stop_ptr;
	*NORMALIZER_LOGNOR = 1;
	*NORMALIZER_AREAS = (  64 << 16 ) | (256);

	normaliser -> flag = NORMALISATION_FLAG_DOWN;
	*NORMALIZER_START = 1;
	while(normaliser -> flag == NORMALISATION_FLAG_DOWN){}
}


void Nor_init(volatile Normaliser_t* normaliser){
	alt_ic_isr_register(NORMALIZER_0_IRQ_INTERRUPT_CONTROLLER_ID, NORMALIZER_0_IRQ, nor_isr, (Normaliser_t*)normaliser, 0);
}


