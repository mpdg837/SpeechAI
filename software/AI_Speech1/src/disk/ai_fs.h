/*
 * ai_fs.h
 *
 *  Created on: 27 mar 2024
 *      Author: micha
 */
#include "ai_fs_types.h"
#include "disk_types.h"
#include "../utils/datatypes_types.h"

#ifndef SRC_DISK_AI_FS_H_
#define SRC_DISK_AI_FS_H_

File_system_status_t Read_file_system(volatile Disk_t* disk, File_system_list_t* list,Data_size_t size, Data_size_t* recv_size_r);
File_system_status_t File_exists(volatile Disk_t* disk, File_system_list_t* list,uint8_t* name);

Data_bool_t Prepare_file_system_list(File_system_list_t* list, uint8_t* buffer, Data_size_t size,Data_size_t max_files);


#endif /* SRC_DISK_AI_FS_H_ */
