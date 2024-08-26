/*
 * devices.h
 *
 *  Created on: 10 mar 2024
 *      Author: micha
 */
#include "./utils/timer/timer_types.h"
#include "./utils/printnum.h"
#include "./ai/ai_types.h"
#include "./processing/utils/scalex.h"
#include "./ai/dma/dma_types.h"
#include "./processing/normalisation_types.h"
#include "./processing/spectrogram_types.h"
#include "./disk/disk_types.h"
#include "./microphone/microphone_types.h"
#include "./processing/utils/loud_types.h"
#include "./detect_types.h"
#include "./microphone/recorder_types.h"
#include "./speaker/speaker_types.h"
#include "./output/gpio_distance.h"
#include "./output/BLE/BLE_types.h"

#ifndef SRC_DEVICES_H_
#define SRC_DEVICES_H_

typedef struct Device_tree{
	volatile AI_comparer_t* comparer;
	volatile DMA_memories_t* memories;
	volatile Normaliser_t* normaliser;
	volatile Spectrogramer_t* spectrogramer;
	volatile Microphone_t* microphone;
	volatile Disk_t* disk;
	volatile Speaker_t* speaker;
	volatile Timer_t* timer;
	volatile BLE_UART_t* buart;
	Gpio_distance_t* distancer;
}Device_tree_t;

#endif /* SRC_DEVICES_H_ */
