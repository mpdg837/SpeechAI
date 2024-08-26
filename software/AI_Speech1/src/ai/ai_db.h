/*
 * ai_db.h
 *
 *  Created on: 24 mar 2024
 *      Author: micha
 */
#include "ai_types.h"
#include "../detect_types.h"

#ifndef SRC_AI_DMA_AI_DB_H_
#define SRC_AI_DMA_AI_DB_H_

Detector_status_t readDatabase(volatile Detector_t* detector,AI_bases_t* mbases, AI_comparasion_t* comparasion);
AI_database_status_t load_linker_list(volatile Detector_t* detector, uint8_t** linkers);

#endif /* SRC_AI_DMA_AI_DB_H_ */
