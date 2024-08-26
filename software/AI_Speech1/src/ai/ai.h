/*
 * ai.h
 *
 *  Created on: 7 mar 2024
 *      Author: micha
 */
#include "ai_types.h"

#ifndef AI_H_
#define AI_H_

void AI_init(volatile AI_comparer_t* comparer);
AI_state_t AI_compare(AI_decision_result_t* decision, volatile AI_comparer_t* comparer, AI_comparasion_t* comparasion);

#endif /* AI_H_ */
