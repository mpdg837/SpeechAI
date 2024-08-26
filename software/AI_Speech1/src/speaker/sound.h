/*
 * sound.h
 *
 *  Created on: 29 mar 2024
 *      Author: micha
 */
#include "speaker_types.h"
#ifndef SRC_SPEAKER_SOUND_H_
#define SRC_SPEAKER_SOUND_H_

Sound_status_t say(volatile Speaker_t* speaker,uint8_t* filename);
Sound_status_t start_speaker(volatile Speaker_t* speaker);

#endif /* SRC_SPEAKER_SOUND_H_ */
