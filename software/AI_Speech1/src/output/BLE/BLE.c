/*
 * BLE.c
 *
 *  Created on: 28 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "./BLE_types.h"
#include "sys/alt_irq.h"
#include "../../utils/timer/timer.h"

#define BLE_UART_IRQ 							7
#define BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID 	0

#define BLE_IRQ_RET				(volatile uint32_t*) 0x28000
#define BLE_BYTE_SEND			(volatile uint32_t*) 0x28004
#define BLE_STATUS				(volatile uint32_t*) 0x28008
#define BLE_BYTE_READ			(volatile uint32_t*) 0x2800c
#define BLE_ENABLE				(volatile uint32_t*) 0x28010
#define BLE_MODULE_STATUS		(volatile uint32_t*) 0x28010

#define MAX_READS_WRITES_ON_ONE_ISR		4

Data_bool_t Is_connected(){

	alt_ic_irq_disable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);
	if ((*BLE_MODULE_STATUS & 0x2) == 0x0){
		alt_ic_irq_enable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);
		return DATA_FALSE;
	}else{
		alt_ic_irq_enable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);
		return DATA_TRUE;
	}
}

static void ble_isr(void* context){
	BLE_UART_t* ble_uart = (BLE_UART_t*) context;

	for(int n=0;n<MAX_READS_WRITES_ON_ONE_ISR;n++){

		if((*BLE_STATUS & 0x4) == 0){

			if(ble_uart ->operation == BLE_WRITE){

				ble_uart -> read_rdy = DATA_FALSE;

				if((*BLE_STATUS & 0x1)== 0){
					*BLE_BYTE_SEND = ble_uart ->message_out[ble_uart -> write_pos];
					ble_uart -> write_pos ++;

					if((ble_uart -> write_pos == STANDARD_BLE_BUFFER_SIZE) || (ble_uart -> write_pos == ble_uart ->write_len)){
						ble_uart ->operation = BLE_NONE;
					}

				}
			}

			if((*BLE_STATUS & 0x2) == 0x0){

				uint8_t character = *BLE_BYTE_READ & 0xFF;
				ble_uart -> message_in[ble_uart -> read_pos] = character;

				if(character == '\n'){
					ble_uart -> read_len = ble_uart -> read_pos + 2;
					ble_uart -> message_in[ble_uart -> read_pos + 1] = 0;

					ble_uart -> read_rdy = DATA_TRUE;

					ble_uart ->read_pos = 0;
					break;

				}else{
					ble_uart -> read_rdy = DATA_FALSE;
				}

				ble_uart -> read_pos ++;

				if(ble_uart -> read_pos == STANDARD_BLE_BUFFER_SIZE){
					ble_uart ->read_pos = 0;
				}

			}


		}else{
			ble_uart ->flag = BLE_FLAG_DOWN;

			ble_uart ->read_len = 0;
			ble_uart ->read_pos = 0;

			ble_uart -> write_len = 0;
			ble_uart -> write_pos = 0;

			ble_uart ->read_rdy = DATA_FALSE;
			break;
		}
	}
	ble_uart ->flag = BLE_FLAG_UP;

	*BLE_IRQ_RET = 0;
}

BLE_write_status_t BLE_send_data(volatile BLE_UART_t* ble_uart,uint8_t* data){

	if(!Is_connected()){
		return BLE_WRITE_DISCONNECTED;
	}

	Data_bool_t finish = DATA_FALSE;

	if(ble_uart ->operation == BLE_WRITE){
		return BLE_WRITE_WAIT_FOR_READY;
	}

	Data_size_t len = 0;

	for(Data_size_t n=0; n < STANDARD_BLE_BUFFER_SIZE ; n++){

		ble_uart ->message_out[n] = data[n];

		if(data[n] == 0){
			break;
		}

		len ++;

		if(data[n] =='\n'){
			finish = DATA_TRUE;
			break;
		}

	}

	alt_ic_irq_disable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);

	ble_uart -> write_pos = 1;
	ble_uart -> write_len = len;

	ble_uart -> operation = BLE_WRITE;

	*BLE_BYTE_SEND = ble_uart -> message_out[0];

	alt_ic_irq_enable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);
	if(finish){
		return BLE_WRITE_EOL_OK;
	}else{
		return BLE_WRITE_OK;
	}
}

BLE_read_status_t BLE_read_data(volatile BLE_UART_t* ble_uart,uint8_t* data,Data_size_t size){

	if(!Is_connected()){
		return BLE_READ_DISCONNECTED;
	}

	alt_ic_irq_disable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);

	if(ble_uart ->read_rdy == DATA_FALSE){
		alt_ic_irq_enable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);
		return BLE_READ_NO_DATA;
	}



	for(Data_size_t n=0 ; n < ble_uart ->read_len ; n++){
		if(n >= size){
			alt_ic_irq_enable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);

			return BLE_READ_ERROR;
		}else{
			data[n] = ble_uart -> message_in[n];
		}
	}

	ble_uart ->read_rdy = DATA_FALSE;

	alt_ic_irq_enable(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ);


	return BLE_READ_OK;
}

void BLE_print_str(volatile BLE_UART_t* ble_uart, uint8_t* string){
	Data_bool_t finished = DATA_FALSE;

	for(int n=0;n<256;n+=20){
		while(1){
			BLE_write_status_t status = BLE_send_data(ble_uart,&string[n]);

			if(status == BLE_WRITE_EOL_OK){
				finished = DATA_TRUE;
				break;
			}

			if(status == BLE_WRITE_OK){
				break;
			}


		}

		if(finished){
			break;
		}
	}
}



void init_BLE(volatile BLE_UART_t* ble_uart){

	*BLE_ENABLE =1;

	while((*BLE_MODULE_STATUS & 0x2) == 0x0){
	}

	Timer_reset(ble_uart -> timer);
	while(Timer_get_time(ble_uart -> timer) < 1000);

	ble_uart ->flag = BLE_FLAG_DOWN;
	ble_uart -> operation = BLE_NONE;

	ble_uart ->read_len = 0;
	ble_uart ->read_pos = 0;

	ble_uart -> write_len = 0;
	ble_uart -> write_pos = 0;

	ble_uart ->read_rdy = DATA_FALSE;

	alt_ic_isr_register(BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID, BLE_UART_IRQ, ble_isr, (BLE_UART_t*)ble_uart, 0);


	uint8_t buffer[40] = "Speech IoT Node ver 1.0 (C) 2024 PW \r\n";

	BLE_print_str(ble_uart,buffer);
	while(Timer_get_time(ble_uart -> timer) < 500);

}
