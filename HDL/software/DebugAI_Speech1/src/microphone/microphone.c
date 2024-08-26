/*
 * microphone.c
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "sys/alt_irq.h"
#include "inttypes.h"
#include "queue.h"

#include "../microphone/microphone_types.h"

#define MIC_IRQ_RET		    	(volatile uint32_t*) 0x29000
#define MIC_ENABLE			   	(volatile uint32_t*) 0x29004
#define MIC_VALUE		    	(volatile uint32_t*) 0x29008
#define MIC_STATUS		    	(volatile uint32_t*) 0x2900c


#define MICROPHONE_0_IRQ 							8
#define MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID 	0

#define BIT_16_MASK		(Microphone_sound_t) 0xFFFF
#define SOUND_SHIFT 	4
#define MAX_VALUE		(Microphone_sound_t) 0x7FFF
#define MIN_VALUE		(Microphone_sound_t) 0x8000

#define NEGATIVE_MAX_VALUE	0x8
#define POSITIVE_MAX_VALUE  0x7

#define POTENTIONAL_ERROR_SOUND (Microphone_status_t) 0xFFFF
#define MAX_POT_ERRORS								  16000

#define MAX_SAMPLES_IN_ONE_ISR				     		4
typedef uint8_t Microphone_minus_t;

Queue_t queue;

static void mic_isr(void* context){

	Microphone_t* microphone = (Microphone_t*) context;

	for(Queue_pos_t n = 0 ; n < MAX_SAMPLES_IN_ONE_ISR ; n ++){

		if((*MIC_STATUS & 0x1) == 0){
			if((*MIC_STATUS & 0x2) == 0){
				microphone -> flag = MICROPHONE_FLAG_UP;

				put_on_queue(microphone ->mic_queue,*MIC_VALUE);
			}else{
				*MIC_ENABLE = 0;
				*MIC_ENABLE = 1;
			}
		}else{
			break;
		}

	}

	*MIC_IRQ_RET = 0;
}

Microphone_sound_t value_reducer(Microphone_huge_sound_t hsound){

	Microphone_minus_t max_value= (hsound >> 20)&0xF;

	Microphone_sound_t value = 0;

	if(max_value == 0xF){
		// minus
		value = (hsound >> SOUND_SHIFT);
	}else if(max_value == POSITIVE_MAX_VALUE){
		// overflow
		value = MAX_VALUE;
	}else if(max_value == NEGATIVE_MAX_VALUE){
		// overflow
		value = MIN_VALUE;
	}else{
		value = (hsound >> SOUND_SHIFT);
	}

	return value;
}

Microphone_status_t MIC_getSample(volatile Microphone_t* microphone, Microphone_sound_t* sound){

	microphone -> flag = MICROPHONE_FLAG_DOWN;
	Microphone_huge_sound_t hsound =0;

	alt_ic_irq_disable(MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID,MICROPHONE_0_IRQ);

	Queue_operation_status_t status = pick_from_queue(microphone ->mic_queue,&hsound);

	if(status == QUEUE_OPERATION_EMPTY_QUEUE){
		alt_ic_irq_enable(MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID,MICROPHONE_0_IRQ);
		return MICROPHONE_STATUS_EMPTY;
	}else if(status == QUEUE_OPERATION_FULL_QUEUE){
		alt_ic_irq_enable(MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID,MICROPHONE_0_IRQ);
		return MICROPHONE_STATUS_FULL;
	}

	alt_ic_irq_enable(MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID,MICROPHONE_0_IRQ);


	Microphone_sound_t value = value_reducer(hsound);
	*sound = value & BIT_16_MASK;

	if(*sound == POTENTIONAL_ERROR_SOUND){
		microphone -> counter ++;

		if(microphone -> counter >= MAX_POT_ERRORS){
			return MICROPHONE_STATUS_ERROR;
		}
	}else{
		microphone -> counter =0;
	}

	return MICROPHONE_STATUS_READY;
}

void MIC_start(){
	 *MIC_ENABLE = 1;
}

void MIC_stop(){
	 *MIC_ENABLE = 0;
}

void MIC_init(volatile Microphone_t* microphone){

	microphone ->counter = 0;

	queue_init(microphone ->mic_queue);

	  alt_ic_isr_register(MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID,MICROPHONE_0_IRQ,
			  mic_isr,(Microphone_t*) microphone,0);
}
