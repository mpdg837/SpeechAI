/*
 * timer.c
 *
 *  Created on: 7 mar 2024
 *      Author: micha
 */

#include "timer_types.h"
#include "sys/alt_irq.h"
#include "inttypes.h"

#include "../../output/gpio_status_animations.h"
#include "../../output/gpio_distance_measure.h"

#define TIMER_FLAG_IRQ_RET 						(volatile uint32_t*) 0x22000
#define TIMER_GET_TIME	   						(volatile uint32_t*) 0x22004
#define TIMER_SET_MAX_TIME 						(volatile uint32_t*) 0x22008
#define TIMER_ENABLE_TIMER 						(volatile uint32_t*) 0x2200c

#define BASICTIMER_IRQ 							1
#define BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID 	0

#define TIMER_CYCLE 							(Timer_time_t)10000


#define GPIO_DISTANCE_START_SIGNAL 		(volatile uint32_t*) 0x27000
#define GPIO_DISTANCE_WRTIE 			(volatile uint32_t*) 0x27004
#define GPIO_DISTANCE_CHECK_DIST 		(volatile uint32_t*) 0x27008

static void timer_isr (void * context){

	volatile Timer_t* timer = (Timer_t*) context;
	timer -> nano_timer ++;

	if(timer -> nano_timer == 10){
		timer -> timer ++;
		timer -> milis_timer ++;

		if(timer -> milis_timer ==  1000){
			timer -> datetime ++;

			if(timer -> datetime == 100000000){
				timer -> datetime = 0;
			}
			timer -> milis_timer = 0;
		}


		timer -> nano_timer = 0;

	}

	animate_gpio_status(timer -> gpio,timer -> nano_timer);
	irq_distance_measurement(timer ->mdistance);

	*TIMER_FLAG_IRQ_RET = 0;
}


void Timer_init(volatile Timer_t* timer){
	// Timer config
	*TIMER_SET_MAX_TIME = TIMER_CYCLE;
	*TIMER_ENABLE_TIMER = 1;

	timer -> timer = 0;
	timer -> datetime = 0;
	timer -> nano_timer = 0;
	timer -> milis_timer = 0;

	alt_ic_isr_register(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID, BASICTIMER_IRQ, timer_isr, (Timer_t*) timer, 0);
}

void Timer_reset(volatile Timer_t* timer){
	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
	timer -> timer = 0;
	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
}

int timess = 0;

Datetime_t Timer_get_datetime(volatile Timer_t* timer){
	Datetime_t time = 0;

	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
	time = timer ->datetime;
	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	return time;
}

Timer_time_t Timer_get_time(volatile Timer_t* timer){

	Timer_time_t m_timer = 0;
	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
	m_timer = timer -> timer;
	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	return m_timer;
}
