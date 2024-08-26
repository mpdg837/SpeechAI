/*
 * detect_types.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "./ai/dma/dma_types.h"
#include "./processing/spectrogram_types.h"
#include "./processing/normalisation_types.h"
#include "./microphone/microphone_types.h"
#include "./ai/ai_types.h"
#include "./disk/disk.h"
#include "output/BLE/BLE.h"
#include "output/BLE/communication.h"

#ifndef DETECT_TYPES_H_
#define DETECT_TYPES_H_

typedef uint8_t Detector_word_decision_t;

typedef struct Detector{
	volatile DMA_memories_t* memories;
	volatile Spectrogramer_t* spectrogramer;
	volatile Normaliser_t* normalizer;
	volatile Microphone_t* microphone;
	volatile AI_comparer_t* comparer;
	volatile Disk_t* disk;
	volatile Timer_t* timer;
	volatile BLE_UART_t* buart;

	Gpio_distance_t* gpio;
	BLE_console_t* console;

	AI_position_t start;
}Detector_t;

typedef enum Detector_status{
	DETECTOR_STATUS_OK = 0,
	DETECTOR_STATUS_DISK_ERROR = 1,
	DETECTOR_STATUS_CANT_DETECT = 2,
	DETECTOR_STATUS_NO_FRAGMENT = 3,
	DETECTOR_STATUS_BAD_CONFIG = 4,
	DETECTOR_STATUS_NOISE = 5,
	DETECTOR_STATUS_MICROPHONE_ERROR = 6,
	DETECTOR_STATUS_CRC_ERROR = 7,
	DETECTOR_STATUS_FILE_ERROR = 8,
	DETECTOR_STATUS_COMMAND_DIRECTLY = 9,
	DETECTOR_STATUS_CHANGE_VOLUME = 10,
	DETECTOR_STATUS_COMMAND_CANCEL = 11,
	DETECTOR_STATUS_RESET = 12
}Detector_status_t;

typedef enum Detector_diag_status{
	DETECTOR_STATUS_DIAGNOSTIC_READY = 0,
	DETECTOR_STATUS_DIAGNOSTIC_ERROR = 1
}Detector_status_diag_t;

#endif /* DETECT_TYPES_H_ */
