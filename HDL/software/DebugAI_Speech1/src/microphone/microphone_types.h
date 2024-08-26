/*
 * microphone_types.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "queue_types.h"

#define MICROPHONE_FLAG_UP 		1
#define MICROPHONE_FLAG_DOWN 	0

#ifndef MICROPHONE_TYPES_H_
#define MICROPHONE_TYPES_H_


typedef uint32_t Microphone_flag_t;
typedef uint16_t Microphone_sound_t;


typedef uint32_t Microphone_bad_sound_amount_t;

typedef enum Microhpone_work{
	MICROPHONE_DISABLE = 0,
	MICROPHONE_ENABLE = 1
}Microhpone_work_t;

typedef struct Microphone{
	volatile Microphone_flag_t flag;
	volatile Microphone_huge_sound_t sound;
	volatile Microhpone_work_t status;

	Queue_t* mic_queue;

	volatile Microphone_bad_sound_amount_t counter;
}Microphone_t;

typedef enum Microphone_status{
	MICROPHONE_STATUS_EMPTY = 0,
	MICROPHONE_STATUS_READY = 1,
	MICROPHONE_STATUS_ERROR = 2,
	MICROPHONE_STATUS_FULL = 3
}Microphone_status_t;

#endif /* MICROPHONE_TYPES_H_ */
