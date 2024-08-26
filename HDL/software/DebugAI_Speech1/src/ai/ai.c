#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "ai_types.h"
#include "../utils/timer/timer.h"
#include "../utils/printnum.h"
#define DEBUG 					0

#define AI_REG					(volatile uint32_t*) 0x40000
#define AI_LIMIT				(volatile uint32_t*) 0x40004
#define AI_CONFIG				(volatile uint32_t*) 0x40008
#define AI_ERROR				(volatile uint32_t*) 0x4000c
#define AI_MAX_VAL				(volatile uint32_t*) 0x4000c
#define AI_SUM1					(volatile uint32_t*) 0x40010
#define AI_COMPRESS				(volatile uint32_t*) 0x40010
#define AI_RET_IRQ				(volatile uint32_t*) 0x40014
#define AI_CRC_32				(volatile uint32_t*) 0x4003c
#define AI_RESULT				(volatile uint32_t*) 0x40038

#define AI_COMPARER_0_IRQ 							3
#define AI_COMPARER_0_IRQ_INTERRUPT_CONTROLLER_ID 	0

#define DIFF_MAX_SPECTS								8

#define AI_KB_SIZE 									(uint32_t)1024
#define AI_MAX_DIFFRENCE 							(uint32_t)450000
#define AI_SPECTS_AMOUNT 							8


typedef struct AI_comparasion_operation{
	AI_size_t size;
	AI_size_t kB_size;
	AI_size_t sectors;
	AI_size_t packet;
}AI_comparasion_operation_t;

typedef uint8_t AI_enum_t;

typedef int32_t AI_speed_t;
typedef uint8_t AI_SD_card_t;
typedef uint8_t AI_spect_num_t;
typedef int32_t AI_delta_t;

typedef uint32_t AI_properties_t;

typedef struct AI_comparasion_result{
	AI_speed_t speed;
}AI_comparasion_result_t;



static void ai_isr(void* context){

	AI_comparer_t* comparer = (AI_comparer_t*) context;
	comparer -> flag = AI_FLAG_UP;

	*AI_RET_IRQ = 0;
}

void AI_init(volatile AI_comparer_t* comparer){
	alt_ic_isr_register(AI_COMPARER_0_IRQ_INTERRUPT_CONTROLLER_ID, AI_COMPARER_0_IRQ, ai_isr, (AI_comparer_t*)comparer, 0);

}

void AI_debug_report(AI_comparasion_operation_t* operation){
#if DEBUG == 1

	  AI_comparasion_result_t report;

	  report.speed = (operation -> kB_size * AI_KB_SIZE)/ Timer_get_time() * 4;
	  alt_printf("Compare : ");
	  printnum(Timer_get_time());
	  alt_printf(" ms\n");


	  alt_printf("====================\n");
	  alt_printf("Results: \n");

	  alt_printf("Transfer: ");
	  printnum(report.speed);
	  alt_printf(" kB/s \n");
	  alt_printf("Unpacked transfer: ");
	  printnum(report.speed*4);
	  alt_printf(" kB/s \n");
	  alt_printf("--------------------\n");
	  alt_printf("Best suit: \n");

	  volatile AI_properties_t* mem = (unsigned int*) AI_SUM1;

	  for(AI_enum_t n=0;n<8;n++){
		  AI_spect_num_t spect = (*mem >> 24) & 0xF;
		  AI_SD_card_t sdcard = (*mem >> 28) & 0x3;
		  AI_delta_t delta = (*mem) & 0xFFFFFF;

		  alt_printf("%x) card: %x spect: %x sum: ",(n+1),sdcard,spect);
		  printnum(delta);
		  alt_printf("\n");

		  mem ++;
	  }

	  alt_printf(" Scores : \n");

	  AI_enum_t p = 1;
	  for(AI_enum_t k = 0; k < 2 ; k++){
		  for(AI_enum_t n=1;n<=4;n++){
			int score = ( (*mem) >> (8*(4-n)) ) & 0xFF;
			alt_printf("%x)",p);
			printnum(score);
			alt_printf("\n");
			p++;
		  }
		  mem ++;
	  }
#endif

}

AI_amount_t count_diffrence(){
	AI_amount_t diff = 0;

	AI_decision_t decision_inside = *AI_RESULT;
	AI_amount_t number = 0;

	AI_delta_t last_delta = 0x0;

	volatile AI_properties_t* mem = (AI_properties_t*) AI_SUM1;

	for(AI_enum_t n=0;n<8;n++){
		AI_spect_num_t spect = (*mem >> 24) & 0xF;
		AI_delta_t delta = (*mem) & 0xFFFFFF;

		if(spect == decision_inside){
			  diff += delta;
			  number ++;

			  if(number == DIFF_MAX_SPECTS){
				  return diff;
			  }
			  last_delta = delta;
		 }

		 mem ++;

	}

	while(number < DIFF_MAX_SPECTS){
		number ++;
		diff += last_delta;
	}

	return diff;
}

AI_state_t AI_compare(AI_decision_result_t* decision, volatile AI_comparer_t* comparer, AI_comparasion_t* comparasion){

	AI_comparasion_operation_t operation = {0,0,0,0};

	operation.packet = comparasion -> packet_size - 1;
	operation.size = ((comparasion -> kb_spect_size) * AI_KB_SIZE) - 1;
	operation.kB_size = (comparasion -> kb_spect_size) * comparasion -> spects;

	*AI_LIMIT = 15;
	*AI_COMPRESS = comparer -> compression;

	*AI_CONFIG = (operation.packet << 16) | operation.size;
	*AI_MAX_VAL = comparasion -> max_diffrence;


	operation.sectors = (operation.kB_size << 1) + 1;

	*AI_REG = ( comparasion -> start << 16) | (operation.sectors);

	 Timer_reset(comparer ->timer);
	 comparer -> flag = AI_FLAG_DOWN;
	 while(comparer -> flag == AI_FLAG_DOWN){
		  if(*AI_ERROR != 0){
			  if((*AI_ERROR & 0x1) == 0x1){

				  return AI_DISK_ERROR;
			  }
			  if((*AI_ERROR & 0x2) == 0x2){
				  return AI_NO_DISK_DETECT;
			  }
			  if((*AI_ERROR & 0x4) == 0x4){
				  return AI_DISK_ERROR;
			  }
			  if((*AI_ERROR & 0x8) == 0x8){
				  return AI_FIFO_OVERFLOW;
			  }


		  }

	 }

	 AI_debug_report(&operation);

	 AI_decision_t decision_inside = *AI_RESULT;

	  if(decision_inside < AI_SPECTS_AMOUNT){
		  comparasion -> diffrence = count_diffrence();

		  decision -> decision = decision_inside;
		  decision -> crc = *AI_CRC_32;

		  return AI_OK;
	  }else{
		  decision -> decision = 0;
		  decision -> crc = *AI_CRC_32;

		  comparasion -> diffrence = 0;
	  }

	  return AI_CANT_DETECT;
}

