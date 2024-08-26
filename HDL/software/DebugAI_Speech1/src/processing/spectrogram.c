/*
 * spectrogram.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "normalisation.h"
#include "inttypes.h"
#include "../ai/dma/dma_types.h"

#include "spectrogram_types.h"

#define SIGNAL_IRQ_RET		    (volatile uint32_t*) 0x30000
#define SIGNAL_READ_ADDR		(volatile uint32_t*) 0x30004
#define SIGNAL_WRITE_ADDR		(volatile uint32_t*) 0x30008
#define SIGNAL_START			(volatile uint32_t*) 0x3000c

#define SIGNAL_PROCESSOR_0_IRQ 5
#define SIGNAL_PROCESSOR_0_IRQ_INTERRUPT_CONTROLLER_ID 0

#define MAX_RANGE	(int32_t) 23900
volatile int sig_flag = 0;

static void sig_isr (void * context){

	Spectrogramer_t* spectrogramer = (Spectrogramer_t*) context;
	spectrogramer ->flag = SPECTROGRAM_FLAG_UP;

	*SIGNAL_IRQ_RET = 0;
}

DMA_size_t Signal_spectrogram(volatile Spectrogramer_t* spectrogramer,int len){

	DMA_size_t height = 0;
	DMA_size_t mlen = 0;
	Timer_reset(spectrogramer-> timer);



	DMA_memories_t* memories = (DMA_memories_t*) spectrogramer -> memories;
	Normaliser_t* normaliser = (Normaliser_t*) spectrogramer -> normaliser;

	DMA_table_mem_t* table = (DMA_table_mem_t*) memories -> table;

	uint32_t* read_ptr = (uint32_t*) &table[0];
	uint32_t* write_ptr = (uint32_t*) &table[0];

	for(int n=0;n<len;n+=512){

		*SIGNAL_READ_ADDR = (uint32_t) read_ptr;
		*SIGNAL_WRITE_ADDR = (uint32_t) write_ptr;

		spectrogramer ->flag = SPECTROGRAM_FLAG_DOWN;
		*SIGNAL_START = 1;
		while(spectrogramer ->flag == SPECTROGRAM_FLAG_DOWN){}

		read_ptr += 256;
		write_ptr += 160;

		mlen += 320;

		height ++;

		if(mlen >= MAX_RANGE){
			break;
		}
	}

	alt_printf("Profile time: ");
	printnum(Timer_get_time(spectrogramer-> timer));
	alt_printf(" ms \n");

	Timer_reset(spectrogramer-> timer);

	Nor_log_normalisation(normaliser,memories,(DMA_table_mem_t*)write_ptr);

	alt_printf("Normalization time: ");
	printnum(Timer_get_time(spectrogramer-> timer));
	alt_printf(" ms \n");

	return mlen;
}

void Signal_init(volatile Spectrogramer_t* spectrogramer){
	alt_ic_isr_register(SIGNAL_PROCESSOR_0_IRQ_INTERRUPT_CONTROLLER_ID, SIGNAL_PROCESSOR_0_IRQ,
			sig_isr, (Spectrogramer_t*) spectrogramer, 0);
}
