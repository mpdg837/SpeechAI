/*
 * loud.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "../../ai/dma/dma_types.h"
#include "loud_types.h"

#ifndef LOUD_H_
#define LOUD_H_

Loud_fragment_status_t selectLoud(volatile DMA_memories_t* memories,
		DMA_size_t* select_size,DMA_size_t len);

#endif /* LOUD_H_ */
