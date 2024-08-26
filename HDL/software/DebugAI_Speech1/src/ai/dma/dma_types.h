/*
 * dma_types.h
 *
 *  Created on: 8 mar 2024
 *      Author: micha
 */
#include "inttypes.h"

#define DMA_FLAG_UP 1
#define DMA_FLAG_DOWN 0

#ifndef DMA_TYPES_H_
#define DMA_TYPES_H_

typedef uint16_t DMA_table_mem_t;
typedef uint8_t DMA_swap_mem_t;
typedef uint32_t DMA_flag;

typedef int32_t DMA_position_t;
typedef int32_t DMA_size_t;

typedef struct DMA_memories{
	volatile DMA_table_mem_t* table;
	volatile DMA_swap_mem_t* swap;
	volatile DMA_flag flag;

	DMA_size_t table_size;
	DMA_size_t swap_size;
}DMA_memories_t;

#endif /* DMA_TYPES_H_ */
