/*
 * queue_types.h
 *
 *  Created on: 3 kwi 2024
 *      Author: micha
 */


#define STANDARD_QUEUE_SIZE	16

#ifndef SRC_MICROPHONE_QUEUE_TYPES_H_
#define SRC_MICROPHONE_QUEUE_TYPES_H_

typedef uint16_t Queue_pos_t;
typedef uint32_t Microphone_huge_sound_t;

typedef enum Queue_operation_status{
	QUEUE_OPERATION_OK = 0,
	QUEUE_OPERATION_FULL_QUEUE = 1,
	QUEUE_OPERATION_EMPTY_QUEUE = 2
}Queue_operation_status_t;

typedef struct Queue{
	Microphone_huge_sound_t* fifo_sound;
	Queue_pos_t read_ptr;
	Queue_pos_t write_ptr;

	Queue_pos_t size_fifo;
}Queue_t;

#endif /* SRC_MICROPHONE_QUEUE_TYPES_H_ */
