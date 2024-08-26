/*
 * gpio_distance_measure.c
 *
 *  Created on: 5 kwi 2024
 *      Author: micha
 */
#include "gpio_distance_types.h"
#include "gpio_distance.h"
#include "sys/alt_irq.h"

#define BASICTIMER_IRQ 							1
#define BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID 	0

#define MAX_MEASURE_DISTANCE 					128
#define NO_DISTANCE								-1

#define MAX_DISTANCE							0x47
#define MIN_DISTANCE							0x7

#define MAX_DEBOUNCER							64
#define MIN_DEBOUNCER							8

#define MAX_MEASURE_RETRIES						16
void init_measurement(Gpio_distance_measure_t* measure){

	measure -> counter = 0;
	measure -> counter_start = 0;
	measure -> distance = 0;

	measure -> retries = 0;

	measure ->ready = GPIO_MEAS_NOT_READY;
	measure ->tries = 0;

}

void irq_distance_measurement(Gpio_distance_measure_t* measure){

	measure ->tries ++;


	if(measure ->tries == MAX_MEASURE_DISTANCE){

		if(measure -> counter_start == 0x0){
			measure -> ready = GPIO_MEAS_ERROR;
		}

		measure -> tries = 0;
		measure -> counter = 0;
		measure -> counter_start = 0;

		gpio_start_distance_measure(GPIO_PIN_UP);
	}else{
		gpio_start_distance_measure(GPIO_PIN_DOWN);


			if(gpio_distance_check()){
				if(measure -> counter == 0){
					measure -> counter_start =measure -> tries;
				}
				measure -> counter ++;
			}else{
				if(measure -> counter != 0){

					if(measure -> counter_start == 0x1 || measure -> counter_start == 0x18){
						if(measure -> ready != GPIO_MEAS_ERROR){
							measure ->ready = GPIO_MEAS_READY;
							measure ->distance = measure -> counter;
						}

						measure -> retries = 0;
					}else{
						measure -> retries ++;

						if(measure -> retries == MAX_MEASURE_RETRIES){
							measure -> ready = GPIO_MEAS_ERROR;
						}
					}

				}
				measure -> counter = 0;
			}


	}

}

Gpio_measure_status_t distance_measurement(Gpio_distance_measure_t* measure,Distance_t* value){

	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	if(measure -> ready == GPIO_MEAS_READY){
		*value = measure -> distance;
		measure -> ready = GPIO_MEAS_NOT_READY;

	}else if(measure -> ready == GPIO_MEAS_NOT_READY){
		alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
		return GPIO_MEAS_NOT_READY;
	}else{
		alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
		return GPIO_MEAS_ERROR;

	}

	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);


	return GPIO_MEAS_READY;
}

void init_distance_measurement(Distance_measurement_t* meas){
	meas ->deb_counter = 0;
	meas ->proper_distance = DATA_FALSE;
}

Gpio_detection_status_t in_proper_distance(Gpio_distance_measure_t* measure,Distance_measurement_t* meas){

	Distance_t distance = 0;
	Gpio_measure_status_t status = distance_measurement(measure,&distance);

	if(status == GPIO_MEAS_ERROR){
		return GPIO_DETECT_ERROR;
	}

	if(status == GPIO_MEAS_READY){
		if(distance <= MAX_DISTANCE && distance >= MIN_DISTANCE){

			meas -> deb_counter = MAX_DEBOUNCER;

		}else{
			if(meas -> deb_counter > 0){
				meas -> deb_counter --;
			}
		}

		if(meas -> deb_counter > MIN_DEBOUNCER){

			meas ->proper_distance = DATA_TRUE;
			return GPIO_DETECT_IN_RANGE;
		}else{
			meas ->proper_distance = DATA_FALSE;
			return GPIO_DETECT_NOT_IN_RANGE;
		}



	}else if(status == GPIO_MEAS_NOT_READY){

		if(meas ->proper_distance){

			return GPIO_DETECT_IN_RANGE;
		}else{
			return GPIO_DETECT_NOT_IN_RANGE;
		}
	}

	meas ->proper_distance = DATA_FALSE;
	return GPIO_DETECT_ERROR;

}


