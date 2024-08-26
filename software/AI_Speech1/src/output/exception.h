/*
 * exception.h
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */
#include "exceptions.h"
#include "../devices.h"

#ifndef SRC_OUTPUT_EXCEPTION_H_
#define SRC_OUTPUT_EXCEPTION_H_

void panic(volatile BLE_UART_t* buart, Gpio_distance_t* gpio ,Exceptions_t exceptions);
void startup_panic(volatile BLE_UART_t* buart, Gpio_distance_t* gpio ,Exceptions_t exceptions);
void wait_for_connection(volatile Device_tree_t* gpio);
Data_bool_t wait_for_connection_recorder(volatile Recorder_t* record);

#endif /* SRC_OUTPUT_EXCEPTION_H_ */
