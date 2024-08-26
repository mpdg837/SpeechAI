/*
 * ai_graph.h
 *
 *  Created on: 15 mar 2024
 *      Author: micha
 */

#include "../detect_types.h"

#ifndef SRC_AI_AI_GRAPH_H_
#define SRC_AI_AI_GRAPH_H_

Detector_status_t ai_group_analyse(volatile Detector_t* detector,uint8_t* word);
Detector_status_t ai_group_selfcheck(volatile Detector_t* detector);

#endif /* SRC_AI_AI_GRAPH_H_ */
