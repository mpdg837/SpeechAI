/*
 * communication_types.h
 *
 *  Created on: 7 kwi 2024
 *      Author: micha
 */
#include "../../utils/timer/timer_types.h"
#include "./BLE_types.h"

#ifndef SRC_OUTPUT_BLE_COMMUNICATION_TYPES_H_
#define SRC_OUTPUT_BLE_COMMUNICATION_TYPES_H_

typedef struct BLE_console{
	volatile Timer_t* timer;
	volatile BLE_UART_t* buart;

	uint8_t* buffer_out;

	uint8_t* word;
	Datetime_t word_time;

	Data_bool_t in_range;
}BLE_console_t;

#endif /* SRC_OUTPUT_BLE_COMMUNICATION_TYPES_H_ */
