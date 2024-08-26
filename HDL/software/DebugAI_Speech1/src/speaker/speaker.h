/*
 * speaker.h
 *
 *  Created on: 10 mar 2024
 *      Author: micha
 */

#include "speaker_types.h"

#ifndef SRC_DISK_SPEAKER_H_
#define SRC_DISK_SPEAKER_H_

void Speaker_init(volatile Speaker_t* speaker);

void Speaker_read_first_half(volatile Speaker_t* speaker);
void Speaker_second_first_half(volatile Speaker_t* speaker);
Data_bool_t Speaker_wait_for_finish(volatile Speaker_t* speaker);

#endif /* SRC_DISK_SPEAKER_H_ */
