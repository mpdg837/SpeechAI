/*
 * spectrogram_types.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */

#include "../ai/dma/dma_types.h"
#include "normalisation_types.h"

#define SPECTROGRAM_FLAG_UP 	0
#define SPECTROGRAM_FLAG_DOWN 	1

#ifndef SPECTROGRAM_TYPES_H_
#define SPECTROGRAM_TYPES_H_

typedef uint32_t Spectrogram_flag_t;

typedef struct Spectrogramer{
	volatile Spectrogram_flag_t flag;

	volatile DMA_memories_t* memories;
	volatile Normaliser_t* normaliser;
}Spectrogramer_t;

#endif /* SPECTROGRAM_TYPES_H_ */
