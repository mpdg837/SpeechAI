/*
 * disk.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "inttypes.h"
#include "../ai/dma/dma_types.h"
#include "disk_types.h"
#include "../utils/timer/timer.h"
#include "disk_types.h"


#define SPI_IRQ_RET		    	(volatile uint32_t*) 0x23000
#define SPI_CARD1				(volatile uint32_t*) 0x23004
#define SPI_CARD2				(volatile uint32_t*) 0x23008
#define SPI_CARD3				(volatile uint32_t*) 0x2300c
#define SPI_CARD4				(volatile uint32_t*) 0x23010
#define SPI_STARTADDR			(volatile uint32_t*) 0x23014
#define SPI_SDSECTOR			(volatile uint32_t*) 0x23018
#define SPI_START				(volatile uint32_t*) 0x2301c
#define SPI_CRC32				(volatile uint32_t*) 0x2301c
#define SPI_Q2_ERROR			(volatile uint32_t*) 0x23018


#define SPIQUICK_0_IRQ 								 2
#define SPIQUICK_0_IRQ_INTERRUPT_CONTROLLER_ID 		 0


#define SPI_CARDS_NUMBER							 4
#define SPI_MINUMUM_DELAY_BEETWEN_INIT				 5

#define MAX_RETRIES_AMOUNT 							 3
#define DELAY_BEETWEN_INIT 							 100

volatile int audio_flag = 0;

typedef uint8_t Tries_counter_t;

typedef enum SD_card_status{
	SD_CARD_OK = 0,
	SD_CARD_ERROR = 1
}SD_card_status_t;


static void spi_isr (void * context){

	Disk_t* disk = (Disk_t*) context;

	disk ->flag = DISK_FLAG_UP;
	*SPI_IRQ_RET = 0;
}

SD_card_status_t q_start_cards(volatile Disk_t* disk, volatile Disk_sd_card_t* card){
	volatile uint32_t* offset = (uint32_t*) 0x23004;

	for(Tries_counter_t n=0 ; n<SPI_CARDS_NUMBER ; n++){
		volatile uint32_t* wsk = offset;

		Timer_reset(disk -> timer);
		while(Timer_get_time(disk -> timer) < DELAY_BEETWEN_INIT);

		disk -> flag = DISK_FLAG_DOWN;
		*wsk = 1;
		while(disk -> flag == DISK_FLAG_DOWN);


		if(*wsk == 1){



			if(n == (SPI_CARDS_NUMBER - 1)){
				break;
			}
			offset +=1;
		}else{

			*card = n + 1;


			return SD_CARD_ERROR;
		}


	}

	*card = DISK_SD_ALL_CARD;
	return SD_CARD_OK;
}


void load_disk(volatile Disk_t* disk, Disk_sectors_t sector, Disk_sectors_t len, DMA_position_t start){

	DMA_memories_t* memories = (DMA_memories_t*) disk -> memories;
	DMA_table_mem_t* table = (DMA_table_mem_t*) memories -> table;

	*SPI_STARTADDR = (uint32_t) &table[start];
	*SPI_SDSECTOR = (sector << 16) | len;

	disk -> flag = DISK_FLAG_DOWN;
	*SPI_START = 1;

}

Disk_status_load_t wait_for_disk(volatile Disk_t* disk){
	while(disk -> flag == DISK_FLAG_DOWN);

	if(*SPI_Q2_ERROR == SD_CARD_ERROR){
		return DISK_LOAD_FAIL;
	}else{
		return DISK_LOAD_OK;
	}

}

Disk_status_load_t check_disk(volatile Disk_t* disk){
	if(disk -> flag == DISK_FLAG_DOWN){
		return DISK_LOAD_IN_PROGRESS;
	}else{

		if(*SPI_Q2_ERROR == SD_CARD_ERROR){
			return DISK_LOAD_FAIL;
		}else{
			return DISK_LOAD_OK;
		}
	}

}



Disk_status_t init_disk(volatile Disk_t* disk){

	alt_ic_isr_register(SPIQUICK_0_IRQ_INTERRUPT_CONTROLLER_ID, SPIQUICK_0_IRQ, spi_isr, (Disk_t*) disk, 0);


	Tries_counter_t tries = 0;

	while(1){


		Disk_sd_card_t card = DISK_SD_ALL_CARD;

		if(q_start_cards(disk,&card) != SD_CARD_OK){
			tries ++;

			if(tries == MAX_RETRIES_AMOUNT){


				disk -> status = DISK_STATUS_ERROR;
				return DISK_STATUS_ERROR;
			}

		}else{
			break;
		}
	}




	disk -> status = DISK_STATUS_READY;
	return DISK_STATUS_READY;
}
