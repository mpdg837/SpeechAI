/*
 * loud.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */

#include "../../ai/dma/dma.h"
#include "inttypes.h"
#include "loud_types.h"

#define SELECT_SIZE (int32_t)5120
#define SELECT_DETECTION (int32_t)128

#define MIN_SIZE (int32_t)11000
#define MAX_SIZE (int32_t)18000

#define MAX_RANGE (int32_t) 23900
#define DETECT_NO_DETECT -1

#define ROUND_TO_FOUR (uint32_t) 0xFFFFFFFC
#define FFT_SIZE				 512

Loud_fragment_status_t selectLoud(volatile DMA_memories_t* memories,DMA_size_t* select_size,
		DMA_size_t len){

	DMA_table_mem_t* table = (DMA_table_mem_t*) memories -> table;

	DMA_size_t start = 0;
	DMA_size_t stop = 0;

	DMA_size_t lena = DETECT_NO_DETECT;
	DMA_size_t lenb = 0;

	DMA_size_t sector_512_c = 0;

	for(DMA_size_t n=0;n<MAX_RANGE;n++){

		sector_512_c ++;

		if(sector_512_c == FFT_SIZE){
			sector_512_c = 0;
		}

		int16_t sample = table[n];

		if(sample >= SELECT_DETECTION || sample <= -SELECT_DETECTION){

			if( lena == DETECT_NO_DETECT ){
				if(n - SELECT_SIZE < 0){
					start = 1;

					sector_512_c = 0;
				}else{
					start = n - SELECT_SIZE;
					sector_512_c = 0;
				}
			}


			lena = 0;
		}

		if(lena != DETECT_NO_DETECT){
			lena++;

			if(sector_512_c == (FFT_SIZE - 1)){
				if(lena >= SELECT_SIZE){

					stop = n;
					lenb = stop - start;

					if(lenb < MIN_SIZE){
						start = 0;
						stop = 0;
						lena = DETECT_NO_DETECT;
					}else if(lenb > MAX_SIZE){
						start = 0;
						stop = 0;
						lena = DETECT_NO_DETECT;
					}else{
						stop = n;
						break;
					}
				}
			}
		}
	}


	if(stop == 0){
		stop = MAX_RANGE - 1;

		lenb = stop - start;

		if(lenb > MAX_SIZE || lenb < MIN_SIZE){
			stop = 0;
			start = 0;
			lenb = DETECT_NO_DETECT;
		}
	}

	if(lenb <= 0){
		return LOUD_FRAGMENT_NO_FRAGMENT;
	}

	if(lenb >= MAX_RANGE - 1){
		return LOUD_FRAGMENT_NO_FRAGMENT;
	}

	DMA_size_t index = start;

	lenb = lenb & ROUND_TO_FOUR;

	DMA_copy_to_swap(memories,index,lenb * 2);
	DMA_paste_from_swap(memories,lenb * 2);

	*select_size = lenb;
	return LOUD_FRAGMENT_DETECT;
}
