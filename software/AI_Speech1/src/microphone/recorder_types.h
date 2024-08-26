/*
 * recorder_types.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */

#include "../microphone/microphone_types.h"
#include "../ai/dma/dma_types.h"
#include "../processing/normalisation_types.h"
#include "../utils/timer/timer_types.h"
#include "../output/BLE/BLE_types.h"
#include "../output/BLE/communication.h"

#ifndef RECORDER_TYPES_H_
#define RECORDER_TYPES_H_

typedef enum Recorder_flag{
	RECORDER_FLAG_WAIT_FOR_NAME = 0,
	RECORDER_FLAG_WAIT_FOR_COMMAND = 1
}Recorder_flag_t ;

typedef enum Recorder_status{
	RECORDER_RECORDED_FRAGMENT = 0,
	RECORDER_TIMEOUT = 1,
	RECORDER_ERROR = 2,
	RECORDER_START = 3,
	RECORDER_VOLUME = 4,
	RECORDER_CANCEL = 5,
	RECORDER_RESET = 6,
}Recorder_status_t;

typedef struct Recorder{
	volatile Timer_t* timer;
	volatile DMA_memories_t* memories;
	volatile Normaliser_t* normaliser;
	volatile Microphone_t* microphone;
	volatile BLE_UART_t* buart;

	BLE_console_t* console;

	Gpio_distance_t* gpio;
}Recorder_t;

#endif /* RECORDER_TYPES_H_ */
