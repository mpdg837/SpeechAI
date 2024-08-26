/*
 * gpio_distance_measure.h
 *
 *  Created on: 5 kwi 2024
 *      Author: micha
 */

#include "gpio_distance_types.h"

#ifndef SRC_OUTPUT_GPIO_DISTANCE_MEASURE_H_
#define SRC_OUTPUT_GPIO_DISTANCE_MEASURE_H_

void init_measurement(Gpio_distance_measure_t* measure);
void irq_distance_measurement(Gpio_distance_measure_t* measure);
Gpio_measure_status_t distance_measurement(Gpio_distance_measure_t* measure,Distance_t* value);

void init_distance_measurement(Distance_measurement_t* meas);
Gpio_detection_status_t in_proper_distance(Gpio_distance_measure_t* measure,Distance_measurement_t* meas);

#endif /* SRC_OUTPUT_GPIO_DISTANCE_MEASURE_H_ */

