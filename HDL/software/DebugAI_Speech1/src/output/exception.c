/*
 * exception.c
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */
#include "gpio_distance.h"
#include "../utils/datatypes_types.h"
#include "../devices.h"
#include "exceptions.h"
#include "./BLE/BLE.h"
#include "../utils/timer/timer.h"
#include "../utils/reset.h"

void startup_panic(volatile BLE_UART_t* buart,Gpio_distance_t* gpio ,Exceptions_t exception){



	gpio_stop_flash(gpio);
	gpio_set_pin(gpio,GPIO_PIN_READY,GPIO_PIN_DOWN);

	if(exception == PANIC_NO_DISK){
		gpio_flash_pin(gpio,GPIO_PIN_NO_DISK);
	}else if(exception == PANIC_FILE_ERROR){
		gpio_flash_pin(gpio,GPIO_PIN_DISK_ERROR);
	}else{
		gpio_flash_pin(gpio,GPIO_PIN_OTHER_ERROR);
	}

	while(1){
		Distance_button_t button = gpio_button_buffered_status(gpio);

		if(button == BUTTON_RESET){
			break;
		}
	}
}


void panic(volatile BLE_UART_t* buart,Gpio_distance_t* gpio ,Exceptions_t exception){



	gpio_stop_flash(gpio);
	gpio_set_pin(gpio,GPIO_PIN_READY,GPIO_PIN_DOWN);

	if(exception == PANIC_NO_DISK){
		gpio_flash_pin(gpio,GPIO_PIN_NO_DISK);
		BLE_send_data(buart,(uint8_t*)"No disk in node\r\n");
	}else if(exception == PANIC_FILE_ERROR){
		gpio_flash_pin(gpio,GPIO_PIN_DISK_ERROR);
		BLE_send_data(buart,(uint8_t*)"SD Storage error\r\n");
	}else{
		gpio_flash_pin(gpio,GPIO_PIN_OTHER_ERROR);
		BLE_send_data(buart,(uint8_t*)"Mic/Dist broken\r\n");
	}

	while(1){
		Distance_button_t button = gpio_button_buffered_status(gpio);

		if(button == BUTTON_RESET){
			break;
		}
	}
}

void wait_for_connection(volatile Device_tree_t* tree){
	gpio_flash_pin(tree -> distancer,GPIO_PIN_READY);

	Data_bool_t one_time = DATA_TRUE;
	while(1){
		if(Is_connected()){
			break;
		}


		one_time = DATA_FALSE;
	}


	if(one_time == DATA_FALSE){
		Timer_reset(tree -> timer);
		while(Timer_get_time(tree -> timer) < 1000);
	}

	gpio_stop_flash(tree -> distancer);
	gpio_set_pin(tree -> distancer,GPIO_PIN_READY,GPIO_PIN_UP);
}

Data_bool_t wait_for_connection_recorder(volatile Recorder_t* record){

	Data_bool_t one_time = DATA_TRUE;
	while(1){
		if(Is_connected()){

			if(one_time){
				return DATA_FALSE;
			}

			break;
		}

		if(one_time)
			gpio_flash_pin(record -> gpio,GPIO_PIN_READY);

		Distance_button_t button = gpio_button_buffered_status(record ->gpio);

		if(button == BUTTON_RESET){
			return DATA_TRUE;
		}

		one_time = DATA_FALSE;
	}



	for(int n=0;n < record ->memories ->table_size ; n++){
		record ->memories ->table[n] = 0;
	}

	if(one_time == DATA_FALSE){
		Timer_reset(record -> timer);
		while(Timer_get_time(record -> timer) < 900);
	}

	gpio_stop_flash(record -> gpio);
	gpio_set_pin(record -> gpio,GPIO_PIN_READY,GPIO_PIN_UP);

	return DATA_FALSE;
}

