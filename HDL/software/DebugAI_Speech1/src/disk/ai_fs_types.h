/*
 * ai_fs_types.h
 *
 *  Created on: 27 mar 2024
 *      Author: micha
 */

#ifndef SRC_DISK_AI_FS_TYPES_H_
#define SRC_DISK_AI_FS_TYPES_H_

typedef uint32_t File_system_addr_t;
typedef uint32_t File_system_len_t;

typedef uint32_t File_system_size_t;

typedef enum File_system_status{
	FILE_SYSTEM_OK = 0,
	FILE_SYSTEM_NO_FS = 1,
	FILE_SYSTEM_ERROR = 2,
	FILE_SYSTEM_NO_DISK = 3,
	FILE_SYSTEM_EXISTS = 4,
	FILE_SYSTEM_NOT_EXISTS = 5
}File_system_status_t;

typedef struct File_system_list{

	File_system_addr_t addr;
	File_system_len_t len;

	uint8_t*		  name;
}File_system_list_t;



#endif /* SRC_DISK_AI_FS_TYPES_H_ */
