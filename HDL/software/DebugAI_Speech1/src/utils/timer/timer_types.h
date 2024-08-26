/*
 * timer_types.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "../../output/gpio_distance.h"

#ifndef TIMER_TYPES_H_
#define TIMER_TYPES_H_

typedef uint32_t Timer_time_t;
typedef uint64_t Datetime_t;

typedef struct Timer{
	volatile Timer_time_t nano_timer;
	volatile Timer_time_t milis_timer;
	volatile Timer_time_t timer;

	volatile Datetime_t datetime;

	Gpio_distance_measure_t* mdistance;
	Gpio_distance_t* gpio;
}Timer_t;

#endif /* TIMER_TYPES_H_ */
