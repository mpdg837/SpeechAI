/*
 * recorder.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "../microphone/microphone_types.h"
#include "../microphone/recorder_types.h"
#include "../ai/dma/dma_types.h"
#include "../utils/timer/timer_types.h"

#ifndef RECORDER_H_
#define RECORDER_H_

Recorder_status_t Recorder_record(volatile Recorder_t* recorder,volatile Timer_time_t* time, Timer_time_t timeout, Recorder_flag_t flag);

#endif /* RECORDER_H_ */
