/*
 * queue.c
 *
 *  Created on: 3 kwi 2024
 *      Author: micha
 */
#include "microphone_types.h"
#include "queue_types.h"


Queue_operation_status_t put_on_queue(Queue_t* queue, Microphone_huge_sound_t value){
	if(queue -> size_fifo < STANDARD_QUEUE_SIZE){

		queue -> fifo_sound[queue -> write_ptr] = value;

		queue -> write_ptr ++;
		if(queue -> write_ptr == STANDARD_QUEUE_SIZE) {
			queue -> write_ptr = 0;
		}

		queue -> size_fifo ++;
		return QUEUE_OPERATION_OK;
	}else{
		return QUEUE_OPERATION_FULL_QUEUE;
	}
}

Queue_operation_status_t pick_from_queue(Queue_t* queue, Microphone_huge_sound_t* value){

	if(queue -> size_fifo > 0){

		if(queue -> size_fifo > STANDARD_QUEUE_SIZE){
			return QUEUE_OPERATION_FULL_QUEUE;
		}

		*value = queue -> fifo_sound[queue -> read_ptr];

		queue -> read_ptr ++;
		if(queue -> read_ptr == STANDARD_QUEUE_SIZE) {
			queue -> read_ptr = 0;
		}

		queue -> size_fifo --;

		return QUEUE_OPERATION_OK;
	}else{
		return QUEUE_OPERATION_EMPTY_QUEUE;
	}
}

void queue_init(Queue_t* queue){
	queue -> write_ptr = 0;
	queue -> read_ptr = 0;

	queue -> size_fifo = 0;

	for(Queue_pos_t n = 0 ; n < STANDARD_QUEUE_SIZE ; n++){
		queue ->fifo_sound[n] = 0;
	}
}
