/*
 * dma.h
 *
 *  Created on: 8 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "dma_types.h"

#ifndef DMA_H_
#define DMA_H_

void DMA_init(volatile DMA_memories_t* memories);
void DMA_copy_to_ai(volatile DMA_memories_t* memories,uint8_t minimum);
void DMA_copy_to_swap(volatile DMA_memories_t* memories, DMA_position_t index,DMA_size_t len);
void DMA_paste_from_swap(volatile DMA_memories_t* memories,DMA_size_t len);

#endif /* DMA_H_ */
