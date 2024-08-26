/*
 * gpio_status_animations.c
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */

#include "gpio_distance.h"
#include "gpio_distance_types.h"

#define MAX_TIME_CYCLE 		(Gpio_timer_t) 100
#define MAX_TIME_PULSE 		(Gpio_timer_t) 16

#define WAIT_FOR_BUTTON_CHECK 			   50
#define WAIT_FOR_BUTTON_CHECK_VOLUMER 	   500

void do_button(Gpio_distance_t* gpio){

	Distance_button_t button = gpio_button_status() & 0x1;

	if(button == BUTTON_PRESSED && gpio -> last_button == BUTTON_NOT_PRESSED){
		gpio -> press_time  = 1;
	}

	if(gpio -> press_time > 0){
		gpio -> press_time ++;

		if(gpio -> press_time == WAIT_FOR_BUTTON_CHECK){

			if(button == BUTTON_PRESSED && gpio -> last_button == BUTTON_PRESSED){
				gpio -> button = BUTTON_PRESSED;
			}else{
				gpio -> press_time  = 0;
			}
		}

		if(gpio -> button == BUTTON_PRESSED){
			if(gpio -> press_time == WAIT_FOR_BUTTON_CHECK_VOLUMER){

				if(button == BUTTON_PRESSED && gpio -> last_button == BUTTON_PRESSED){
					gpio -> button = BUTTON_RESET;
				}else{
					gpio -> button = BUTTON_LISTEN;
				}

				gpio -> press_time  = 0;

			}
		}
	}

	gpio -> last_button = button;
}

void do_vbutton(Gpio_distance_t* gpio){

	Distance_button_t vbutton = (gpio_button_status() >> 1) & 0x1;

	if(vbutton == BUTTON_PRESSED && gpio -> last_vbutton ==  BUTTON_NOT_PRESSED){
		gpio -> press_time_v = 1;
	}

	if(gpio -> press_time_v > 0){
		gpio -> press_time_v ++;

		if(gpio -> press_time_v == WAIT_FOR_BUTTON_CHECK){

			if(vbutton == BUTTON_PRESSED && gpio -> last_vbutton == BUTTON_PRESSED){
				gpio -> button = BUTTON_VOLUME;
			}

			gpio -> press_time_v = 0;
		}
	}

	gpio -> last_vbutton = vbutton;

}

void animate_pulse(Gpio_distance_t* gpio){
	if(gpio ->flashing == GPIO_FLASH){

		if(gpio -> time == MAX_TIME_CYCLE){
			gpio ->time = 0;
		}

		if(gpio -> time == 0){
			if(gpio -> last_pin == GPIO_PIN_DOWN){
				gpio_set_pin_irq(gpio, (Gpio_pin_select_t) gpio ->flash_pin ,GPIO_PIN_UP);
				gpio -> last_pin = GPIO_PIN_UP;
			}else{
				gpio_set_pin_irq(gpio, (Gpio_pin_select_t) gpio ->flash_pin ,GPIO_PIN_DOWN);
				gpio -> last_pin = GPIO_PIN_DOWN;
			}
		}
	}
}

void animate_flash(Gpio_distance_t* gpio){
	if(gpio -> flashing == GPIO_PULSE){

		if(gpio -> time == MAX_TIME_PULSE){
			gpio -> time = 0;

			gpio -> pulse_time ++;
			if(gpio -> pulse_time >= MAX_TIME_PULSE << 2){
				gpio -> pulse_time = 0;
			}

			gpio_set_pin_irq(gpio, (Gpio_pin_select_t) gpio ->flash_pin ,GPIO_PIN_UP);
		}


		if(gpio -> time == (gpio -> pulse_time >> 2)){
			gpio_set_pin_irq(gpio, (Gpio_pin_select_t) gpio ->flash_pin ,GPIO_PIN_DOWN);

		}
	}
}

void animate_gpio_status(Gpio_distance_t* gpio,Gpio_timer_t time){



	switch(time){
		case 0:
			if(gpio ->flashing == GPIO_FLASH || gpio ->flashing == GPIO_PULSE){
				gpio -> time ++;
			}else{
				gpio ->time  = 0;
			}
			break;
		case 1:
			animate_pulse(gpio);
			break;
		case 2:
			animate_flash(gpio);
			break;
		case 3:
			do_vbutton(gpio);
			break;
		case 4:
			do_button(gpio);
			break;
	}


}
