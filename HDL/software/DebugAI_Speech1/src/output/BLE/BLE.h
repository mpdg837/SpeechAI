/*
 * BLE.h
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */
#include "./BLE_types.h"

#ifndef SRC_OUTPUT_BLE_BLE_H_
#define SRC_OUTPUT_BLE_BLE_H_

void init_BLE(volatile BLE_UART_t* ble_uart);

BLE_write_status_t BLE_send_data(volatile BLE_UART_t* ble_uart,uint8_t* data);
BLE_read_status_t BLE_read_data(volatile BLE_UART_t* ble_uart,uint8_t* data,Data_size_t size);
void BLE_print_str(volatile BLE_UART_t* ble_uart, uint8_t* string);
Data_bool_t Is_connected();

#endif /* SRC_OUTPUT_BLE_BLE_H_ */
