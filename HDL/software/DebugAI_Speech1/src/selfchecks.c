/*
 * selfchecks.c
 *
 *  Created on: 30 mar 2024
 *      Author: micha
 */

#include "devices.h"

#include "./utils/timer/timer.h"
#include "./utils/printnum.h"
#include "./ai/ai.h"
#include "./processing/utils/scalex.h"
#include "./ai/dma/dma.h"
#include "./processing/normalisation.h"
#include "./processing/spectrogram.h"
#include "./disk/disk.h"
#include "./disk/ai_fs.h"
#include "./microphone/microphone.h"
#include "./processing/utils/loud.h"
#include "./detect.h"
#include "./microphone/recorder.h"
#include "./speaker/speaker.h"

#include "./detect_types.h"
#include "./utils/datatypes.h"

#include "sys/alt_stdio.h"

#include "./output/exception.h"
#include "./speaker/sound.h"

#define SIZE_FS 		23

Data_bool_t check_files(File_system_list_t* files, Data_size_t size){


	if(size != SIZE_FS){
		return DATA_FALSE;
	}


	return DATA_TRUE;
}

Data_bool_t app_selfcheck(volatile Device_tree_t* tree,Detector_t* detector){

	MIC_start();

	File_system_list_t files[32];
	uint8_t name_buffer[256];

	if(Prepare_file_system_list(files, name_buffer, 256, 16) == DATA_FALSE){
		panic(tree -> buart,tree -> distancer ,PANIC_OTHER_ERROR);
		return DATA_TRUE;
	}


	Data_size_t recv_size = 0;


	if(Read_file_system(tree -> disk, files,32,&recv_size) != FILE_SYSTEM_OK){

		panic(tree -> buart,tree -> distancer ,PANIC_FILE_ERROR);
		return DATA_TRUE;
	}

	if(!check_files(files,recv_size)){
		panic(tree -> buart,tree -> distancer ,PANIC_FILE_ERROR);
		return DATA_TRUE;
	}


	if(recv_size != 0){
		detector -> start = files[recv_size - 1].addr >> 4;
	}else{
		panic(tree -> buart,tree -> distancer ,PANIC_FILE_ERROR);
		return DATA_TRUE;
	}

	if(selfcheck(detector) == DETECTOR_STATUS_DIAGNOSTIC_ERROR){

		Disk_status_t d_status = init_disk(tree -> disk);

		if(d_status == DISK_STATUS_ERROR){
			 panic(tree -> buart,tree -> distancer ,PANIC_NO_DISK);
			 return DATA_TRUE;
		}else{
			 panic(tree -> buart,tree -> distancer ,PANIC_FILE_ERROR);
			 return DATA_TRUE;
		}

	}

	return DATA_FALSE;
}

Data_bool_t record_selfcheck(volatile Device_tree_t* tree ,Detector_status_t decision_word){
	if(decision_word == DETECTOR_STATUS_CRC_ERROR){
		panic(tree -> buart,tree -> distancer ,PANIC_NO_DISK);
		return DATA_TRUE;
	}

	if(decision_word == DETECTOR_STATUS_MICROPHONE_ERROR){
		panic(tree -> buart,tree -> distancer ,PANIC_NO_MIC_ERROR);
		return DATA_TRUE;
	}

	if(decision_word == DETECTOR_STATUS_DISK_ERROR){
		panic(tree -> buart,tree -> distancer ,PANIC_NO_DISK);
		return DATA_TRUE;
	}

	if(decision_word == DETECTOR_STATUS_FILE_ERROR || decision_word == DETECTOR_STATUS_CRC_ERROR){


		Disk_status_t d_status = init_disk(tree -> disk);

		if(d_status == DISK_STATUS_ERROR){
			panic(tree -> buart,tree -> distancer ,PANIC_NO_DISK);
		}else{
			panic(tree -> buart,tree -> distancer ,PANIC_FILE_ERROR);
		}
		return DATA_TRUE;

	}

	return DATA_FALSE;
}
