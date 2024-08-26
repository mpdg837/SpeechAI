/*
 * disk.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "../ai/dma/dma_types.h"
#include "disk_types.h"

#ifndef DISK_H_
#define DISK_H_

void load_disk(volatile Disk_t* disk, Disk_sectors_t sector, Disk_sectors_t len, DMA_position_t start);
Disk_status_load_t wait_for_disk(volatile Disk_t* disk);
Disk_status_t init_disk(volatile Disk_t* disk);
Disk_status_load_t check_disk(volatile Disk_t* disk);

#endif /* DISK_H_ */
