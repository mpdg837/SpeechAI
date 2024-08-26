/*
 * normalisation.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "normalisation_types.h"
#include "../ai/dma/dma_types.h"

#ifndef NORMALISATION_H_
#define NORMALISATION_H_

void Nor_normalizeSamples(volatile Normaliser_t* normaliser,volatile DMA_memories_t* mem);
void Nor_log_normalisation(volatile Normaliser_t* normaliser,volatile DMA_memories_t* mem,DMA_table_mem_t* stop_ptr);
void Nor_init();


#endif /* NORMALISATION_H_ */
