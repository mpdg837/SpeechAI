/*
 * dma.c
 *
 *  Created on: 8 mar 2024
 *      Author: micha
 */
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "inttypes.h"
#include "dma_types.h"

#define AI_DMA_IRQ		 		(volatile uint32_t*) 0x00000
#define AI_DMA_START_ADDR_BLOCK	(volatile uint32_t*) 0x00004
#define AI_DMA_STOP_ADDR_BLOCK	(volatile uint32_t*) 0x00008
#define AI_DMA_DATA_LEN 		(volatile uint32_t*) 0x0000c
#define	AI_DMA_MINIMUM	 		(volatile uint32_t*) 0x00010
#define	AI_DMA_WAGE		 		(volatile uint32_t*) 0x00014
#define	AI_DMA_START_ADDR	 	(volatile uint32_t*) 0x00018
#define	AI_DMA_START	 		(volatile uint32_t*) 0x0001c

#define	AI_DMA_LINE_WIDTH	 	(volatile uint32_t*) 0x00020
#define	AI_DMA_REGION_WIDTH	 	(volatile uint32_t*) 0x00024


#define AI_DMA_0_IRQ 							10
#define AI_DMA_0_IRQ_INTERRUPT_CONTROLLER_ID 	0

#define DMA_COPY_TO_SWAP_SIZE    (DMA_size_t) 23900
#define DMA_AI_COPY_TO_SWAP_SIZE (DMA_size_t) 20480

#define MINUS_12_BITS			 (uint16_t) 0xFC00

volatile int dma_flag = 0;

static void dma_isr(void* context){

	DMA_memories_t* memories = (DMA_memories_t*) context;
	memories -> flag = DMA_FLAG_UP;

	*AI_DMA_IRQ = 0;
}

void DMA_init(volatile DMA_memories_t* memories){
	alt_ic_isr_register(AI_DMA_0_IRQ_INTERRUPT_CONTROLLER_ID,AI_DMA_0_IRQ,dma_isr, (DMA_memories_t*)memories , 0);
}

void DMA_copy_to_ai(volatile DMA_memories_t* memories,uint8_t minimum){

	volatile DMA_table_mem_t* table = memories -> table;

	*AI_DMA_START_ADDR_BLOCK = (uint32_t) &table[0];
	*AI_DMA_STOP_ADDR_BLOCK = (uint32_t) &table[DMA_AI_COPY_TO_SWAP_SIZE];
	*AI_DMA_START_ADDR = (uint32_t) &table[0];

	*AI_DMA_DATA_LEN = DMA_AI_COPY_TO_SWAP_SIZE * 2;
	*AI_DMA_MINIMUM = minimum;

	*AI_DMA_LINE_WIDTH = 320;
	*AI_DMA_REGION_WIDTH = 256;

	*AI_DMA_WAGE = 0xFFFF;

	memories -> flag = DMA_FLAG_DOWN;
	*AI_DMA_START = 1;
	while(memories -> flag == DMA_FLAG_DOWN);
}


void DMA_copy_to_swap(volatile DMA_memories_t* memories, DMA_position_t index,DMA_size_t len){

	volatile DMA_table_mem_t* table = memories -> table;

	*AI_DMA_START_ADDR_BLOCK = (uint32_t) &table[0];
	*AI_DMA_STOP_ADDR_BLOCK = (uint32_t) &table[DMA_COPY_TO_SWAP_SIZE];
	*AI_DMA_START_ADDR = (uint32_t) &table[(index >> 1) << 1];

	*AI_DMA_DATA_LEN = len;
	*AI_DMA_MINIMUM = 1 << 16;

	*AI_DMA_WAGE = 0xFFFF;

	memories -> flag = DMA_FLAG_DOWN;
	*AI_DMA_START = 1;
	while(memories -> flag == DMA_FLAG_DOWN);

}

void DMA_paste_from_swap(volatile DMA_memories_t* memories,DMA_size_t len){

	volatile DMA_table_mem_t* table = memories -> table;
	volatile DMA_swap_mem_t* swap = memories -> swap;

	for(int k=0;k<len/2;k++){
		DMA_swap_mem_t get = swap[k];
		DMA_table_mem_t value = 0;

		if(get >> 7 == 0x1){
			value = ((get << 2) | 0x3) | MINUS_12_BITS;
		}else{
			value = get << 2;
		}

		table[k] = value;
	}

}
