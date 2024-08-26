/*
 * communication.h
 *
 *  Created on: 2 kwi 2024
 *      Author: micha
 */
#include "communication_types.h"

#ifndef SRC_OUTPUT_BLE_COMMUNICATION_H_
#define SRC_OUTPUT_BLE_COMMUNICATION_H_

void BLE_console(BLE_console_t* cosnole);
void BLE_add_word(BLE_console_t* console,uint8_t* word);

#endif /* SRC_OUTPUT_BLE_COMMUNICATION_H_ */
