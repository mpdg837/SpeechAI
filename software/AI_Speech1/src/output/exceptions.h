/*
 * exceptions.h
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */

#ifndef SRC_OUTPUT_EXCEPTIONS_H_
#define SRC_OUTPUT_EXCEPTIONS_H_

typedef enum Exceptions{
	PANIC_NO_PANIC = 0,
	PANIC_NO_DISK = 1,
	PANIC_FILE_ERROR = 2,
	PANIC_NO_MIC_ERROR = 3,
	PANIC_BLE_ERROR = 4,
	PANIC_NO_BLE_ERROR = 5,
	PANIC_OTHER_ERROR = 6
}Exceptions_t;

#endif /* SRC_OUTPUT_EXCEPTIONS_H_ */
