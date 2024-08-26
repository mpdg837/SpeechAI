/*
 * spectrogram.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "spectrogram_types.h"
#include "../ai/dma/dma_types.h"

#ifndef SPECTROGRAM_H_
#define SPECTROGRAM_H_

DMA_size_t Signal_spectrogram(volatile Spectrogramer_t* spectrogramer,int len);
void Signal_init(volatile Spectrogramer_t* spectrogramer);

#endif /* SPECTROGRAM_H_ */
