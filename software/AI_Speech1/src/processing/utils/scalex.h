/*
 * scalex.h
 *
 *  Created on: 7 mar 2024
 *      Author: micha
 */
#include "../../ai/dma/dma_types.h"

#ifndef SCALEX_H_
#define SCALEX_H_

void Scale_scaleX(volatile DMA_table_mem_t* table,DMA_size_t height, DMA_size_t width, DMA_position_t stoppos);

#endif /* SCALEX_H_ */
