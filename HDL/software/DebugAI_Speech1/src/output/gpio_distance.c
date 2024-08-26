/*
 * gpio_distance.c
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */

#include "sys/alt_irq.h"
#include "inttypes.h"
#include "gpio_distance_types.h"

#define MASK 			(uint32_t) 0xFFFFFFEF
#define SIZE_OF_GPIO 	4

#define BASICTIMER_IRQ 1
#define BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID 0

#define GPIO_DISTANCE_START_SIGNAL 		(volatile uint32_t*) 0x27000
#define GPIO_DISTANCE_WRTIE 			(volatile uint32_t*) 0x27004
#define GPIO_DISTANCE_CHECK_DIST 		(volatile uint32_t*) 0x27008
#define GPIO_DISTANCE_BUTTON	 		(volatile uint32_t*) 0x2700c


void gpio_start_distance_measure(Gpio_pin_status_t status){
	*GPIO_DISTANCE_START_SIGNAL = status;
}

Distance_button_t gpio_button_status(){
	return *GPIO_DISTANCE_BUTTON;
}

Distance_button_t gpio_button_buffered_status(Gpio_distance_t* gpio){


	Distance_button_t button;

	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
	button = gpio -> button;

	if(gpio -> button != BUTTON_PRESSED){
		gpio -> button = BUTTON_NOT_PRESSED;
	}

	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	return button;
}

Gpio_pin_status_t gpio_distance_check(){
	return (Gpio_pin_status_t) *GPIO_DISTANCE_CHECK_DIST;
}

void gpio_set_pin_irq(Gpio_distance_t* gpio, Gpio_pin_select_t select, Gpio_pin_status_t status){

	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
	Gpio_distance_content_t content = gpio -> content;
	content = status << select;

	*GPIO_DISTANCE_WRTIE = content;
	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	gpio -> content = content;
}
void gpio_set_pin(Gpio_distance_t* gpio, Gpio_pin_select_t select, Gpio_pin_status_t status){

	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
	gpio_set_pin_irq(gpio,select, status);
	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
}

void gpio_flash_pin(Gpio_distance_t* gpio, Gpio_pin_select_t select){
	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	gpio->last_pin = GPIO_PIN_DOWN;
	gpio->flash_pin = select;

	gpio->flashing = GPIO_FLASH;

	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
}

void gpio_pulse_pin(Gpio_distance_t* gpio, Gpio_pin_select_t select,Gpio_timer_t pulse_time){
	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	gpio->last_pin = GPIO_PIN_DOWN;
	gpio -> pulse_time = pulse_time;
	gpio->flash_pin = select;

	gpio->flashing = GPIO_PULSE;

	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
}

void gpio_stop_flash(Gpio_distance_t* gpio){
	alt_ic_irq_disable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);

	gpio->flashing= GPIO_NOT_FLASH;

	alt_ic_irq_enable(BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID,BASICTIMER_IRQ);
}


Gpio_distance_status_t person_detected(){
	if(*GPIO_DISTANCE_CHECK_DIST){
		return GPIO_NOT_DETECTED;
	}else{
		return GPIO_DETECTED;
	}

}

void gpio_init(Gpio_distance_t* gpio){
	gpio -> content = 0x0;
	gpio -> time = 0;

	gpio->last_pin = GPIO_PIN_DOWN;
	gpio->flash_pin = GPIO_PIN_READY;

	gpio->flash_pin = GPIO_NOT_FLASH;

	gpio ->press_time = 0;
	gpio -> button = BUTTON_NOT_PRESSED;
	gpio -> last_button = BUTTON_NOT_PRESSED;

	gpio -> press_time_v = 0;

	gpio -> last_vbutton = BUTTON_NOT_PRESSED;
	gpio -> vbutton = BUTTON_NOT_PRESSED;

	*GPIO_DISTANCE_START_SIGNAL = 1;
	*GPIO_DISTANCE_WRTIE = 0;
}


