/*
 * disk_types.h
 *
 *  Created on: 10 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "../utils/timer/timer_types.h"
#include "../ai/dma/dma.h"

#define DISK_FLAG_UP 	1
#define DISK_FLAG_DOWN	0

#ifndef SRC_DISK_DISK_TYPES_H_
#define SRC_DISK_DISK_TYPES_H_

typedef uint32_t Disk_flag_t;
typedef uint16_t Disk_sectors_t;

typedef enum Disk_status{
	DISK_STATUS_NONE = 0,
	DISK_STATUS_READY = 1,
	DISK_STATUS_ERROR = 2
}Disk_status_t;

typedef enum Disk_sd_card{
	DISK_SD_ALL_CARD = 0,
	DISK_SD_CARD_1 = 1,
	DISK_SD_CARD_2 = 2,
	DISK_SD_CARD_3 = 3,
	DISK_SD_CARD_4 = 4
}Disk_sd_card_t;

typedef enum Disk_status_load{
	DISK_LOAD_OK = 0,
	DISK_LOAD_FAIL = 1,
	DISK_LOAD_IN_PROGRESS = 2
}Disk_status_load_t;

typedef struct Disk{
	volatile Timer_t* timer;
	volatile Disk_flag_t flag;
	Disk_status_t status;
	Disk_sd_card_t card;
	volatile DMA_memories_t* memories;
}Disk_t;


#endif /* SRC_DISK_DISK_TYPES_H_ */
