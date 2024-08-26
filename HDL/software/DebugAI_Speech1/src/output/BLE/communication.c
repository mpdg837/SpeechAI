/*
 * communication.c
 *
 *  Created on: 2 kwi 2024
 *      Author: micha
 */

#include "../../utils/timer/timer.h"
#include "./BLE.h"
#include "communication_types.h"
#include "../../utils/printnum.h"

#define BUFFER_SIZE 16

typedef enum BLE_console_command{
	BLE_COMMAND_ERROR = 0,
	BLE_COMMAND_TIME = 1,
	BLE_COMMAND_WORD = 2,
	BLE_COMMAND_ECHO = 3,
	BLE_COMMAND_INFO = 4,
	BLE_COMMAND_RANGE = 5,
	BLE_COMMAND_RESET = 6
}BLE_console_command_t;

BLE_console_command_t parse_command(uint8_t* command){

	if(compare(command,(uint8_t*)"time\r\n",16)){
		return BLE_COMMAND_TIME;
	}

	if(compare(command,(uint8_t*)"word\r\n",16)){
		return BLE_COMMAND_WORD;
	}

	if(compare(command,(uint8_t*)"echo\r\n",16)){
		return BLE_COMMAND_ECHO;
	}

	if(compare(command,(uint8_t*)"inrange\r\n",16)){
		return BLE_COMMAND_RANGE;
	}


	return BLE_COMMAND_ERROR;
}

void BLE_add_word(BLE_console_t* console,uint8_t* word){

	console -> word_time = Timer_get_datetime(console ->timer);
	str_cpy(word, console ->word,16);

	for(int n=0;n<15;n++){
		if(console -> word[n] == 0){
			console -> word[n] = '\r';
			console -> word[n] = '\n';
		}
	}

}

void BLE_console(BLE_console_t* console){
	uint8_t buffer[BUFFER_SIZE];
	BLE_read_status_t status = BLE_read_data(console -> buart,buffer,BUFFER_SIZE);

	if(status ==BLE_READ_OK){

		BLE_console_command_t comm = parse_command(buffer);
		uint8_t buff[16];

		Datetime_t time;

		switch(comm){
			case BLE_COMMAND_WORD:

				if(console ->word_time != 0){
					uint8_t num_buff[10];

					snprintnum(num_buff,console ->word_time);

					console -> buffer_out[0] = 32;
					console -> buffer_out[1] = 32;
					console -> buffer_out[2] = 32;
					console -> buffer_out[3] = '.';

					for(int n=0;n<10;n++)
					{
						if(num_buff[n] == 0){
							n--;
							if(n == -1){
								break;
							}
							console -> buffer_out[2] = num_buff[n];
							n--;
							if(n == -1){
								break;
							}
							console -> buffer_out[1] = num_buff[n];
							n--;
							if(n == -1){
								break;
							}
							console -> buffer_out[0] = num_buff[n];
							break;
						}

					}


					str_cpy(console ->word,&console -> buffer_out[4],12);
					BLE_send_data(console -> buart,console ->buffer_out);
				}else{
					str_cpy((uint8_t*)"No detecion\r\n",console -> buffer_out,16);
					BLE_send_data(console -> buart,console ->buffer_out);
				}
				break;
			case BLE_COMMAND_TIME:
				time = Timer_get_datetime(console -> timer);

				snprintnum(buff,time);
				int index = 0;

				for(int n = 0 ; n < BUFFER_SIZE ; n++){
					if(buff[n] == 0){
						index = n;
						break;
					}
				}

				buff[index] = '\r';
				buff[index + 1] = '\n';

				str_cpy(buff,console -> buffer_out,16);
				BLE_send_data(console -> buart,console ->buffer_out);

				break;
			case BLE_COMMAND_RANGE:
				if(console ->in_range){
					str_cpy((uint8_t*)"T\r\n",console -> buffer_out,16);
				}else{
					str_cpy((uint8_t*)"N\r\n",console -> buffer_out,16);
				}
				BLE_send_data(console -> buart,console ->buffer_out);
				break;
			case BLE_COMMAND_ECHO:

				str_cpy((uint8_t*)"Echo\r\n",console -> buffer_out,16);
				BLE_send_data(console -> buart,console ->buffer_out);

				break;
			case BLE_COMMAND_RESET:
				break;
			default:

				str_cpy((uint8_t*)"Bad command\r\n",console -> buffer_out,16);
				BLE_send_data(console -> buart,console ->buffer_out);

				break;
		}

	}

}

// time
// word
// echo
// info
// pin:
// range
// reset
