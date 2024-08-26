/*
 * queue.h
 *
 *  Created on: 3 kwi 2024
 *      Author: micha
 */

#include "microphone_types.h"
#include "queue_types.h"

#ifndef SRC_MICROPHONE_QUEUE_H_
#define SRC_MICROPHONE_QUEUE_H_

Queue_operation_status_t put_on_queue(Queue_t* queue, Microphone_huge_sound_t value);
Queue_operation_status_t pick_from_queue(Queue_t* queue, Microphone_huge_sound_t* value);

void queue_init(Queue_t* queue);

#endif /* SRC_MICROPHONE_QUEUE_H_ */
