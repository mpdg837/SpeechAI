/*
 * ai_fs.c
 *
 *  Created on: 27 mar 2024
 *      Author: micha
 */

#include "disk.h"
#include "ai_fs_types.h"
#include "inttypes.h"

#include "../utils/datatypes.h"
#include "../utils/control_sum.h"

#include "../ai/vendor.h"

#define AI_FS_HEADER					(uint8_t*) "AIFS"
#define KB_PACK_SIZE					2
#define TABLE_START						29

#define END_OF_ADDRMAP(character)		(character == 'E')
#define FILE(character)					(character == 'F')

#define MAX_FILE_NAME_SIZE				16
#define MAX_FILE_NAME_SIZE_IN_64		12

#define PAGE_SIZE						(Simple_control_sum_size_t) 511

Data_bool_t isProperFilesystem(uint8_t* read){
	uint8_t filesystem_name[32];

	if(from64toBytes(&read[5],filesystem_name,24)){
		return DATA_FALSE;
	}

	if(!compare(FS_NAME,filesystem_name,32)){
		return DATA_FALSE;
	}


	return DATA_TRUE;
}


Data_bool_t Is_filesystem(uint8_t* read){

	if(compare(AI_FS_HEADER,&read[0],4)){

		uint8_t version = read[4];
		uint8_t compare = (VERSION << 4) | SUBVERSION;

		if(version > compare){
			return DATA_FALSE;
		}


		return DATA_TRUE;
	}else{
		return DATA_FALSE;
	}
}

Data_bool_t Prepare_file_system_list(File_system_list_t* list, uint8_t* buffer, Data_size_t size,Data_size_t max_files){
	uint8_t* ptr = buffer;

	Data_size_t buffer_allocated_size = 0;

	for(int n=0;n<max_files;n++){

		list[n].addr = 0;
		list[n].len = 0;
		list[n].name = ptr;

		ptr += MAX_FILE_NAME_SIZE;
		buffer_allocated_size += MAX_FILE_NAME_SIZE;

		if(buffer_allocated_size > size){
			return DATA_FALSE;
		}
	}

	return DATA_TRUE;
}



File_system_status_t File_exists(volatile Disk_t* disk, File_system_list_t* list,uint8_t* name){

	load_disk(disk, 0, KB_PACK_SIZE, 0);



	if(wait_for_disk(disk) == DISK_LOAD_FAIL){
		return FILE_SYSTEM_NO_DISK;
	}

	uint8_t* read = (uint8_t*) disk -> memories -> table;

	if(Is_filesystem(read)){
		if(isProperFilesystem(read)){

			Data_size_t index = TABLE_START;

			Data_bool_t finished = DATA_FALSE;

			while(!finished){

				if(END_OF_ADDRMAP(read[index])){

					Simple_control_sum_t csum = Control_count_sum(read, PAGE_SIZE);

					if(csum == read[PAGE_SIZE]){
						return FILE_SYSTEM_NOT_EXISTS;
					}else{
						return FILE_SYSTEM_ERROR;
					}


				}else if(FILE(read[index])){

					index += 1;

					uint8_t buffer[16];

					if(from64toBytes(&read[index],buffer,MAX_FILE_NAME_SIZE_IN_64)){
						return DATA_FALSE;
					}

					index +=MAX_FILE_NAME_SIZE_IN_64;

					list -> addr = read_16_value(&read[index]);
					index += 2;
					list -> len = read_16_value(&read[index]);
					index += 2;

					if(compare(name,buffer, MAX_FILE_NAME_SIZE)){
						Simple_control_sum_t csum = Control_count_sum(read, PAGE_SIZE);

						if(csum == read[PAGE_SIZE]){
							return FILE_SYSTEM_EXISTS;
						}else{
							return FILE_SYSTEM_ERROR;
						}
					}


					continue;
				}
				break;
			}



		}

		return FILE_SYSTEM_ERROR;


	}else{
		return FILE_SYSTEM_NO_FS;
	}


}


File_system_status_t Read_file_system(volatile Disk_t* disk, File_system_list_t* list,Data_size_t size, Data_size_t* recv_size_r){

	load_disk(disk, 0, KB_PACK_SIZE, 0);

	if(wait_for_disk(disk) == DISK_LOAD_FAIL){

		return FILE_SYSTEM_NO_DISK;
	}

	uint8_t* read = (uint8_t*) disk -> memories -> table;

	if(Is_filesystem(read)){

		if(isProperFilesystem(read)){

			Data_size_t index = TABLE_START;
			Data_size_t recv_size = 0;

			Data_bool_t finished = DATA_FALSE;

			while(!finished){

				if(END_OF_ADDRMAP(read[index])){

					*recv_size_r = recv_size;

					Simple_control_sum_t csum = Control_count_sum(read, PAGE_SIZE);

					if(csum == read[PAGE_SIZE]){

						return FILE_SYSTEM_OK;
					}else{
						return FILE_SYSTEM_ERROR;
					}


				}else if(FILE(read[index])){

					index += 1;

					if(from64toBytes(&read[index],list[recv_size].name,MAX_FILE_NAME_SIZE_IN_64)){
						return DATA_FALSE;
					}

					index +=MAX_FILE_NAME_SIZE_IN_64;

					list[recv_size].addr = read_16_value(&read[index]);
					index += 2;
					list[recv_size].len = read_16_value(&read[index]);
					index += 2;

					recv_size ++;
					if(recv_size > size){
						return FILE_SYSTEM_ERROR;
					}

					continue;
				}
				break;
			}



		}

		return FILE_SYSTEM_ERROR;


	}else{
		return FILE_SYSTEM_NO_FS;
	}


}


