/*
 * sound.c
 *
 *  Created on: 29 mar 2024
 *      Author: micha
 */
#include "speaker.h"
#include "../output/BLE/communication.h"

#include "../disk/ai_fs.h"
#include "../disk/disk.h"
#include "./speaker_types.h"
#include "../output/gpio_distance.h"

#define SOUND_BUFFER_SIZE	(uint32_t) 8192
#define KB_PACK_SIZE		31

typedef enum Sound_bank{
	SOUND_BANK_1 = 1,
	SOUND_BANK_2 = 2
}Sound_bank_t;

Disk_status_load_t playing(volatile Speaker_t* speaker){

	gpio_pulse_pin((Gpio_distance_t*)speaker ->gpio,GPIO_PIN_READY,0);

	while(Speaker_wait_for_finish(speaker) == DATA_TRUE){
		BLE_console(speaker ->console);
	}

	return DISK_LOAD_OK;
}

Sound_status_t Speaker_play_music(volatile Speaker_t* speaker,Disk_sectors_t sector, Sound_bank_t* bank){

	if(*bank == SOUND_BANK_1){
		load_disk(speaker -> disk, sector, KB_PACK_SIZE, SOUND_BUFFER_SIZE);
		Speaker_read_first_half(speaker);
	}else{
		load_disk(speaker -> disk, sector, KB_PACK_SIZE, 0);
		Speaker_second_first_half(speaker);
	}

	if(playing(speaker) == DISK_LOAD_FAIL){
		return SOUND_STATUS_DISK_ERROR;
	}



	if(*bank == SOUND_BANK_1){
		*bank = SOUND_BANK_2;
	}else{
		*bank = SOUND_BANK_1;
	}

	return SOUND_STATUS_OK;
}

Sound_status_t Speaker_preload(volatile Speaker_t* speaker,Disk_sectors_t sector){

	load_disk(speaker -> disk, sector, KB_PACK_SIZE, 0);

	while(1){
		Disk_status_load_t status = check_disk(speaker -> disk);

		if(status == DISK_LOAD_FAIL){
			return DISK_LOAD_FAIL;
		}

		if(status == DISK_LOAD_OK){
			break;
		}
		BLE_console(speaker ->console);
	}

	return SOUND_STATUS_OK;
}

Sound_status_t start_speaker(volatile Speaker_t* speaker){

	Speaker_read_first_half(speaker);
	return SOUND_STATUS_OK;
}


Sound_status_t say(volatile Speaker_t* speaker,uint8_t* filename){

	File_system_list_t file;

	Sound_bank_t bank = SOUND_BANK_1;
	File_system_status_t status = File_exists(speaker -> disk, &file, filename);


	if(status == FILE_SYSTEM_EXISTS){

		if(Speaker_preload(speaker,file.addr) == SOUND_STATUS_DISK_ERROR){
			return SOUND_STATUS_DISK_ERROR;
		}

		for(int n=file.addr + 2;n<file.addr + file.len;n+=2){
			Sound_status_t status = Speaker_play_music(speaker,n,&bank);

			if(status != SOUND_STATUS_OK){
				return status;
			}
		}

		gpio_stop_flash((Gpio_distance_t*)speaker -> gpio);
		gpio_set_pin((Gpio_distance_t*)speaker -> gpio,GPIO_PIN_READY,GPIO_PIN_UP);

		return SOUND_STATUS_OK;
	}else if(status == FILE_SYSTEM_NOT_EXISTS){
		return SOUND_STATUS_NO_FILE;
	}else{
		return SOUND_STATUS_DISK_ERROR;
	}
}
