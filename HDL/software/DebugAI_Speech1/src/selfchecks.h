/*
 * selfchecks.h
 *
 *  Created on: 30 mar 2024
 *      Author: micha
 */

#include "detect_types.h"
#include "devices.h"

#ifndef SRC_SELFCHECKS_H_
#define SRC_SELFCHECKS_H_

Data_bool_t app_selfcheck(volatile Device_tree_t* tree,Detector_t* detector);
Data_bool_t record_selfcheck(volatile Device_tree_t* tree ,Detector_status_t decision_word);

#endif /* SRC_SELFCHECKS_H_ */
