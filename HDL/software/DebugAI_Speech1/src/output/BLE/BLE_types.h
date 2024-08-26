/*
 * BLE_types.h
 *
 *  Created on: 2 kwi 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "../../utils/timer/timer_types.h"
#include "../../utils/datatypes_types.h"

#define STANDARD_BLE_BUFFER_SIZE 20

#define BLE_FLAG_UP 	1
#define BLE_FLAG_DOWN 0

#ifndef SRC_OUTPUT_BLE_BLE_TYPES_H_
#define SRC_OUTPUT_BLE_BLE_TYPES_H_

typedef uint32_t BLE_UART_flag_t;
typedef uint32_t BLE_UART_position_t;

typedef enum BLE_write_status{
	BLE_WRITE_OK = 0,
	BLE_WRITE_ERROR = 1,
	BLE_WRITE_WAIT_FOR_READY= 2,
	BLE_WRITE_EOL_OK = 3,
	BLE_WRITE_DISCONNECTED = 4
}BLE_write_status_t;

typedef enum BLE_read_status{
	BLE_READ_OK = 0,
	BLE_READ_ERROR = 1,
	BLE_READ_NO_DATA = 2,
	BLE_READ_EOL_OK = 3,
	BLE_READ_DISCONNECTED = 4
}BLE_read_status_t;

typedef enum BLE_operation{
	BLE_NONE = 0,
	BLE_WRITE = 1
}BLE_operation_t;

typedef struct BLE_UART{
	volatile BLE_UART_flag_t flag;
	volatile BLE_UART_flag_t work;

	volatile uint8_t* message_in;
	volatile BLE_UART_position_t read_pos;
	volatile BLE_UART_position_t read_len;

	volatile Data_bool_t read_rdy;

	volatile uint8_t* message_out;
	volatile BLE_UART_position_t write_pos;
	volatile BLE_UART_position_t write_len;

	volatile BLE_operation_t operation;
	volatile Timer_t* timer;

}BLE_UART_t;

#endif /* SRC_OUTPUT_BLE_BLE_TYPES_H_ */
