/*
 * gpio_distance_types.h
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "../utils/datatypes.h"

#ifndef SRC_OUTPUT_GPIO_DISTANCE_TYPES_H_
#define SRC_OUTPUT_GPIO_DISTANCE_TYPES_H_

typedef uint32_t Gpio_distance_content_t;
typedef uint32_t Gpio_timer_t;
typedef int32_t Distance_t;

typedef enum Gpio_distance_status{
	GPIO_DETECTED = 1,
	GPIO_NOT_DETECTED = 0
}Gpio_distance_status_t;

typedef enum Gpio_flashing{
	GPIO_FLASH = 1,
	GPIO_NOT_FLASH = 0,
	GPIO_PULSE = 2
}Gpio_flashing_t;

typedef enum Gpio_pin_status{
	GPIO_PIN_UP = 1,
	GPIO_PIN_DOWN = 0
}Gpio_pin_status_t;

typedef enum Gpio_pin_select{
	GPIO_PIN_READY = 0,
	GPIO_PIN_NO_DISK = 1,
	GPIO_PIN_DISK_ERROR = 2,
	GPIO_PIN_OTHER_ERROR = 3
}Gpio_pin_select_t;

typedef enum Gpio_measure_status{
	GPIO_MEAS_NOT_READY = 0,
	GPIO_MEAS_READY = 1,
	GPIO_MEAS_ERROR = 2
}Gpio_measure_status_t;

typedef struct Gpio_distance_measure{

	Data_size_t tries;

	Data_size_t counter;
	Data_size_t counter_start;

	Distance_t distance;

	Gpio_measure_status_t ready;
	Gpio_timer_t retries;
	Gpio_timer_t errors;
}Gpio_distance_measure_t;

typedef enum Gpio_detection_status{
	GPIO_DETECT_IN_RANGE = 0,
	GPIO_DETECT_NOT_IN_RANGE = 1,
	GPIO_DETECT_ERROR = 2
}Gpio_detection_status_t;

typedef struct Distance_measurement{
	Data_size_t deb_counter;
	Data_bool_t proper_distance;
}Distance_measurement_t;

typedef enum Distance_button{
	BUTTON_PRESSED = 1,
	BUTTON_NOT_PRESSED = 0,
	BUTTON_LISTEN = 2,
	BUTTON_RESET = 3,
	BUTTON_VOLUME = 4
}Distance_button_t;


typedef struct Gpio_distance{
	volatile Gpio_distance_content_t content;


	volatile Gpio_flashing_t flashing;

	volatile Gpio_pin_select_t flash_pin;
	volatile Gpio_timer_t time;
	volatile Gpio_pin_status_t last_pin;


	volatile Gpio_timer_t press_time;

	volatile Distance_button_t last_button;
	volatile Distance_button_t button;

	volatile Gpio_timer_t press_time_v;

	volatile Distance_button_t last_vbutton;
	volatile Distance_button_t vbutton;

	volatile Gpio_timer_t pulse_time;

}Gpio_distance_t;


#endif /* SRC_OUTPUT_GPIO_DISTANCE_TYPES_H_ */
