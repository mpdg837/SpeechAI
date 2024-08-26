/*
 * ai_types.h
 *
 *  Created on: 7 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "../utils/timer/timer.h"
#define AI_FLAG_UP  			1
#define AI_FLAG_DOWN  			0
#define MAX_AI_DECISIONS 		32

#define BASES					8

#ifndef AI_TYPES_H_
#define AI_TYPES_H_

typedef uint32_t AI_flag_t;
typedef uint32_t AI_position_t;
typedef uint32_t AI_size_t;
typedef uint32_t AI_amount_t;
typedef uint32_t AI_CRC32_t;

typedef uint32_t AI_decision_t;

typedef enum AI_database_status{
	AI_DATABASE_OK = 0,
	AI_DATABASE_NO_DATA = 1,
	AI_DATABASE_ERROR = 2
}AI_database_status_t;

typedef struct AI_decision_result{
	AI_decision_t decision;
	AI_CRC32_t crc;
}AI_decision_result_t;

typedef enum AI_compression{
	AI_COMPRESSION_TWO = 0,
	AI_COMPRESSION_FOUR = 1
}AI_compression_t;

typedef enum AI_state{
	AI_OK = 0,
	AI_DISK_ERROR = -1,
	AI_CANT_DETECT = -2,
	AI_NO_DISK_DETECT = -3,
	AI_FIFO_OVERFLOW = -4
}AI_state_t;

typedef struct AI_comparer{
	volatile Timer_t* timer;
	volatile AI_flag_t flag;
	AI_compression_t compression;
}AI_comparer_t;

typedef struct AI_comparasion{
	AI_position_t start;
	AI_amount_t spects;

	AI_size_t packet_size;
	AI_size_t max_diffrence;
	AI_size_t kb_spect_size;

	AI_amount_t diffrence;
}AI_comparasion_t;

typedef struct AI_bases{
	AI_state_t* state;
	AI_amount_t* score;
	AI_decision_result_t* decision;

	AI_CRC32_t* crcs;
	AI_position_t* bases;

	AI_amount_t* packet_sizes;
	AI_amount_t* spect_sizes;
	AI_amount_t* spects_in_base;

	AI_compression_t* compressions;

	AI_amount_t decisions;
	AI_amount_t size;
}AI_bases_t;

typedef enum AI_bool{
	AI_TRUE = 1,
	AI_FALSE = 0
}AI_bool_t;


#endif /* AI_TYPES_H_ */
