/*
 * detect.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */
#include "detect_types.h"
#include "./microphone/recorder_types.h"

#define DECISION_LEN 		16

#ifndef DETECT_H_
#define DETECT_H_

Detector_status_t get_word(volatile Detector_t* detector, Timer_time_t timeout,uint8_t* word,Recorder_flag_t flag);
Detector_status_diag_t selfcheck(volatile Detector_t* detector);

#endif /* DETECT_H_ */
