/*
 * microphone.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "../microphone/microphone_types.h"

#ifndef MICROPHONE_H_
#define MICROPHONE_H_

Microphone_status_t MIC_getSample(volatile Microphone_t* microphone, Microphone_sound_t* sound);
void MIC_init(volatile Microphone_t* microphone);

void MIC_start();
void MIC_stop();

#endif /* MICROPHONE_H_ */
