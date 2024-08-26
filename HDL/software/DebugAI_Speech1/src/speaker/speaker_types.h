/*
 * speaker_types.h
 *
 *  Created on: 10 mar 2024
 *      Author: micha
 */
#include "../disk/disk_types.h"
#include "../output/gpio_distance.h"
#include "../output/BLE/communication.h"

#define SPEAKER_FLAG_UP 	1
#define SPEAKER_FLAG_DOWN 	0


#ifndef SRC_DISK_SPEAKER_TYPES_H_
#define SRC_DISK_SPEAKER_TYPES_H_

typedef uint8_t Speaker_volume_t;
typedef uint32_t Speaker_flag_t;

typedef enum Sound_status{
	SOUND_STATUS_OK = 0,
	SOUND_STATUS_DISK_ERROR = 1,
	SOUND_STATUS_TIMEOUT = 2,
	SOUND_STATUS_NO_FILE = 3
}Sound_status_t;

typedef struct Speaker{
	BLE_console_t* console;
	volatile Speaker_flag_t flag;
	volatile Disk_t* disk;
	volatile Gpio_distance_t* gpio;
	Speaker_volume_t volume;

}Speaker_t;


#endif /* SRC_DISK_SPEAKER_TYPES_H_ */
