/*
 * gpio_distance.h
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */
#include "gpio_distance_types.h"

#ifndef SRC_OUTPUT_GPIO_DISTANCE_H_
#define SRC_OUTPUT_GPIO_DISTANCE_H_

void gpio_set_pin_irq(Gpio_distance_t* gpio, Gpio_pin_select_t select, Gpio_pin_status_t status);
void gpio_set_pin(Gpio_distance_t* gpio, Gpio_pin_select_t select, Gpio_pin_status_t status);
void gpio_init(Gpio_distance_t* gpio);

Gpio_distance_status_t person_detected();
void gpio_flash_pin(Gpio_distance_t* gpio, Gpio_pin_select_t select);
void gpio_pulse_pin(Gpio_distance_t* gpio, Gpio_pin_select_t select,Gpio_timer_t pulse_time);
void gpio_stop_flash(Gpio_distance_t* gpio);

void gpio_start_distance_measure(Gpio_pin_status_t status);
Gpio_pin_status_t gpio_distance_check();

Distance_button_t gpio_button_status();
Distance_button_t gpio_button_buffered_status(Gpio_distance_t* gpio);

#endif /* SRC_OUTPUT_GPIO_DISTANCE_H_ */
