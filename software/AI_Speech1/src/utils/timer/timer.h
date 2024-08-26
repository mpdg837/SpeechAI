/*
 * timer.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */

#include "timer_types.h"
#include "inttypes.h"

#ifndef TIMER_H_
#define TIMER_H_

void Timer_init(volatile Timer_t* timer);
void Timer_reset(volatile Timer_t* timer);

Timer_time_t Timer_get_time(volatile Timer_t* timer);
Datetime_t Timer_get_datetime(volatile Timer_t* timer);


#endif /* TIMER_H_ */
