/*
 * ai_db.c
 *
 *  Created on: 24 mar 2024
 *      Author: micha
 */
#include "ai_types.h"
#include "../detect_types.h"
#include "../disk/disk.h"
#include "../utils/timer/timer.h"

#include "../utils/datatypes.h"
#include "../utils/control_sum.h"

#include "./vendor.h"


#define PACKET_SIZE 					64

#define SPECTS_IN_BASE					8

#define MAXIMUM_DIFF					(uint32_t) 400000
#define SPECT_SIZE						20 / 2

#define MAX_HEADER						4
#define KB_PACK_SIZE					2

#define PHASE_PATTERN_1					0xAA
#define PHASE_PATTERN_2					0xBB

#define SIZE_OF_AI_RAM					32

#define LIST_DATABSE_START				70
#define AI_HEADER						(uint8_t*) "AIDB"

#define IS_DATABASE_LINKER(character) 	( character == 'B' )
#define IS_DECISION_NAME(character) 	( character == 'L' )
#define IS_EOF(character) 				( character == 'F' )

#define AI_DB_PAGE_SECTOR 				(AI_size_t) 512
#define CRC_BLOCK_LEN					(AI_size_t) 511

#define IS_CORRECT_SECTOR(sector)		(sector < 0xFFFF)




AI_bool_t isDatabase(uint8_t* read){

	if(compare(AI_HEADER,read,MAX_HEADER)){
		uint8_t version = (VERSION << 4) | SUBVERSION;

		if(read[4] >= version){

			if(read[6] != PHASE_PATTERN_1){
				return AI_FALSE;
			}

			if(read[7] != PHASE_PATTERN_2){
				return AI_FALSE;
			}

			return AI_TRUE;
		}else{
			return AI_FALSE;
		}
	}else{
		return AI_FALSE;
	}

}

AI_bool_t isProperDatabase(uint8_t* read){
	uint8_t app_name[16];
	uint8_t vendor_name[32];
	uint8_t database_name[32];

	if(from64toBytes(&read[8],app_name,12)){
		return AI_FALSE;
	}

	if(!compare(APP_NAME,app_name,16)){
		return AI_FALSE;
	}

	if(from64toBytes(&read[21],vendor_name,24)){
		return AI_FALSE;
	}

	if(!compare(VENDOR_NAME,vendor_name,32)){
		return AI_FALSE;
	}


	if(from64toBytes(&read[45],database_name,24)){
		return AI_FALSE;
	}

	if(!compare(DATABASE_NAME,database_name,32)){
		return AI_FALSE;
	}

	return AI_TRUE;
}

AI_database_status_t load_linker_list(volatile Detector_t* detector, uint8_t** linkers){

	uint8_t* read = (uint8_t*) detector ->memories ->table;

	AI_position_t p = LIST_DATABSE_START;

	AI_size_t base_size = 0;
	AI_bool_t finished = AI_FALSE;

	AI_amount_t all_spects = 0;
	AI_amount_t named_spects = 0;

	AI_position_t pos = 0;

	uint8_t** m_linkers = linkers;
	while(!finished){

		if(IS_EOF(read[p])){
			break;
		}else if(IS_DATABASE_LINKER(read[p])){


			if(base_size >= BASES){
				return AI_DATABASE_ERROR;
			}
			p+=21;
			all_spects += read[p];
			p+=2;

			base_size ++;
		}else if(IS_DECISION_NAME(read[p])){

			if(all_spects > MAX_AI_DECISIONS){
				return AI_DATABASE_ERROR;
			}

			uint8_t* linker = *m_linkers;

			p++;
			if(from64toBytes(&read[p],linker,12)){
				return AI_DATABASE_ERROR;
			}

			p+=12;

			named_spects++;
			pos++;
			m_linkers ++;
		}else{
			finished = AI_TRUE;
		}

	}

	if(named_spects != all_spects){
		return AI_DATABASE_ERROR;
	}

	return AI_DATABASE_OK;
}

AI_database_status_t load_list(uint8_t* read,
		AI_CRC32_t* crcs,
		AI_position_t* bases,
		AI_amount_t* packet_sizes,
		AI_amount_t* spect_sizes,
		AI_amount_t* spects_in_base,
		AI_compression_t* compressions,
		AI_size_t* size,
		AI_amount_t* decisions
	){

	AI_position_t p = LIST_DATABSE_START;

	AI_size_t base_size = 0;
	AI_amount_t potetntional_decisions = 0;

	AI_bool_t finished = AI_FALSE;

	while(!finished){

		if(IS_EOF(read[p])){
			break;
		}else if(IS_DATABASE_LINKER(read[p])){

			if(base_size >= BASES){
				return AI_DATABASE_ERROR;
			}
			p++;

			uint8_t name[16];

			if(from64toBytes(&read[p],name,12)){
				return AI_DATABASE_ERROR;
			}

			p+=12;

			bases[base_size] = read_16_value(&read[p]);
			p+=2;

			crcs[base_size] = read_32_value(&read[p]);
			p+=4;

			packet_sizes[base_size] = read[p];
			p++;

			spect_sizes[base_size] = read[p];
			p++;

			spects_in_base[base_size] = read[p];
			potetntional_decisions  += read[p];
			p++;

			compressions[base_size] = read[p];
			p++;

			if(compressions[base_size] == AI_COMPRESSION_FOUR){
				if(spect_sizes[base_size] > (SIZE_OF_AI_RAM / 4)){
					return AI_DATABASE_ERROR;
				}
			}else{
				if(spect_sizes[base_size] > (SIZE_OF_AI_RAM / 2)){
					return AI_DATABASE_ERROR;
				}
			}

			base_size ++;
		}else{
			finished = AI_TRUE;
		}

	}

	if(potetntional_decisions > MAX_AI_DECISIONS){
		return AI_DATABASE_ERROR;
	}

	*decisions = potetntional_decisions;
	*size = base_size;


	return AI_DATABASE_OK;
}



Detector_status_t readDatabase(volatile Detector_t* detector,AI_bases_t* mbases, AI_comparasion_t* comparasion){

	AI_position_t real_position = (detector -> start) << (4);

	if(!IS_CORRECT_SECTOR(real_position)){
		return DETECTOR_STATUS_FILE_ERROR;
	}

	load_disk(detector -> disk, real_position, KB_PACK_SIZE, 0);

	if(wait_for_disk(detector -> disk) == DISK_LOAD_FAIL){
		return DETECTOR_STATUS_DISK_ERROR;
	}

	uint8_t* read = (uint8_t*) detector ->memories ->table;

	if(isDatabase(read)){


		AI_CRC32_t* crcs = mbases -> crcs;
		AI_position_t* bases = mbases -> bases;

		AI_amount_t* packet_sizes = mbases -> packet_sizes;
		AI_amount_t* spect_sizes = mbases -> spect_sizes;
		AI_amount_t* spects_in_base = mbases -> spects_in_base;

		AI_compression_t* compressions = mbases -> compressions;

		if(isProperDatabase(read)){

			AI_size_t size = 0;
			AI_amount_t decisions = 0;

			if(load_list(read, crcs, bases,packet_sizes,spect_sizes,spects_in_base,compressions, &size , &decisions) == AI_DATABASE_OK){


				if(decisions > MAX_AI_DECISIONS){
					return DETECTOR_STATUS_FILE_ERROR;
				}

				mbases -> decisions = decisions;
				mbases -> size = size;

				Simple_control_sum_t csum  = Control_count_sum(read, CRC_BLOCK_LEN);

				if(read[CRC_BLOCK_LEN] == csum){
					return DETECTOR_STATUS_OK;
				}else{
					return DETECTOR_STATUS_FILE_ERROR;
				}
			}
		}
	}

	return DETECTOR_STATUS_FILE_ERROR;

}

