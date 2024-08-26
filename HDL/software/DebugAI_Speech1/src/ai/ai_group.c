/*
 * ai_graph.c

 *
 *  Created on: 15 mar 2024
 *      Author: micha
 */
#include "./ai.h"
#include "../detect_types.h"
#include "./ai_db.h"
#include "./ai_types.h"

#define MAXIMUM_DIFF				(uint32_t) 400000
#define SPECTS_IN_BASE				8


#define MAX_RETRIES					3

#define MAX_32BIT					(AI_amount_t) 0xFFFFFFFF
#define IS_CORRECT_SECTOR(sector)	((uint32_t)sector < 0xFFFF)
#define LINKERS_LEN					16

void make_linker_table(uint8_t* buffer,uint8_t** linkers){
	uint8_t* ptr = buffer;

	for(AI_amount_t n =0; n < 16; n++){
		linkers[n] = ptr;
		ptr += LINKERS_LEN;
	}
}


AI_bool_t isDetected(AI_state_t* state, AI_amount_t size){
	for(AI_amount_t n = 0; n < size; n ++){
		if(state[n] == AI_OK){
			return AI_TRUE;
		}
	}

	return AI_FALSE;
}

AI_bool_t isNotDetected(AI_state_t* state, AI_amount_t size){
	for(AI_amount_t n = 0; n < size; n ++){
		if(state[n] == AI_CANT_DETECT){
			return AI_TRUE;
		}
	}

	return AI_FALSE;

}

AI_decision_t selectBestSuit(AI_amount_t* score,
		AI_state_t* state,
		AI_decision_result_t* decision,
		AI_amount_t* spects_in_base,
		AI_amount_t size)
{

	AI_amount_t min = MAX_32BIT;

	AI_decision_t offset = 0;
	AI_decision_t dec = 0;

	for(AI_amount_t n = 0 ; n < size ; n++){
		if(state[n] == AI_OK){
			if(min > score[n]){
				min = score[n];

				dec = decision[n].decision + offset;
			}
		}

		offset += spects_in_base[n];
	}

	return dec;
}

Detector_status_t analyse_load_errors(AI_state_t state, volatile Detector_t* detector,
		AI_decision_result_t* result, AI_CRC32_t crc){

	if(state == AI_DISK_ERROR){
		detector -> disk ->status = DISK_STATUS_ERROR;
		return DETECTOR_STATUS_DISK_ERROR;
	}else if(state == AI_NO_DISK_DETECT){
		detector -> disk ->status = DISK_STATUS_NONE;
		return DETECTOR_STATUS_DISK_ERROR;
	}else{
		if(crc != result -> crc){
			//return DETECTOR_STATUS_CRC_ERROR;
		}

		return DETECTOR_STATUS_OK;
	}
}

Detector_status_t ai_group_selfcheck(volatile Detector_t* detector){


	AI_state_t state[BASES];
	AI_decision_result_t decision[BASES];

	AI_CRC32_t crcs[BASES];
	AI_position_t bases[BASES];

	AI_amount_t packet_sizes[BASES];
	AI_amount_t spect_sizes[BASES];
	AI_amount_t spects_in_base[BASES];

	AI_compression_t compressions[BASES];

	AI_comparasion_t comparasion;
	AI_bases_t aibases;

	aibases.state = state;
	aibases.decision = decision;

	aibases.crcs = crcs;
	aibases.bases = bases;

	aibases.packet_sizes = packet_sizes;
	aibases.spect_sizes = spect_sizes;
	aibases.spects_in_base = spects_in_base;

	aibases.compressions = compressions;

	Detector_status_t status = readDatabase(detector,&aibases, &comparasion);

	if(status == DETECTOR_STATUS_FILE_ERROR ){
		return DETECTOR_STATUS_FILE_ERROR;
	}


	AI_amount_t size = aibases.size;

	for(AI_amount_t n=0 ; n < size ; n ++){

		if(IS_CORRECT_SECTOR(detector -> start)){
			bases[n] += detector -> start;
		}

		AI_amount_t tries = 0;

		comparasion.spects = aibases.packet_sizes[n] * aibases.spects_in_base[n];

		comparasion.packet_size = aibases.packet_sizes[n];
		comparasion.max_diffrence = MAXIMUM_DIFF;
		comparasion.kb_spect_size = aibases.spect_sizes[n];

		while(tries < MAX_RETRIES){
			comparasion.start = bases[n];

			state[n] = AI_compare(&decision[n],detector -> comparer,&comparasion);

			Detector_status_t ostatus = analyse_load_errors(state[n],detector,&decision[n],crcs[n]);
			if(ostatus != DETECTOR_STATUS_OK){

				if(ostatus == DETECTOR_STATUS_CRC_ERROR){
					tries ++;

					if(tries == MAX_RETRIES){
						return ostatus;
					}else{
						continue;
					}
				}
				return ostatus;
			}

			break;
		}

	}

	for(int n=0;n<detector ->memories->table_size;n++){
		detector ->memories->table[n] = 0;
	}


	if(isDetected(state,size)){
		return DETECTOR_STATUS_OK;
	}else{

		if(isNotDetected(state,size)){
			return DETECTOR_STATUS_CANT_DETECT;
		}else{
			return DETECTOR_STATUS_BAD_CONFIG;
		}
	}
}


Detector_status_t ai_group_analyse(volatile Detector_t* detector,uint8_t* word){

	uint8_t buffer[MAX_AI_DECISIONS * LINKERS_LEN];
	uint8_t* linkers[MAX_AI_DECISIONS];

	make_linker_table(buffer,linkers);

	AI_state_t state[BASES];
	AI_amount_t score[BASES];
	AI_decision_result_t decision[BASES];

	AI_CRC32_t crcs[BASES];
	AI_position_t bases[BASES];

	AI_amount_t packet_sizes[BASES];
	AI_amount_t spect_sizes[BASES];
	AI_amount_t spects_in_base[BASES];

	AI_compression_t compressions[BASES];

	AI_comparasion_t comparasion;
	AI_bases_t aibases;

	aibases.state = state;
	aibases.score = score;
	aibases.decision = decision;

	aibases.crcs = crcs;
	aibases.bases = bases;

	aibases.packet_sizes = packet_sizes;
	aibases.spect_sizes = spect_sizes;
	aibases.spects_in_base = spects_in_base;

	aibases.compressions = compressions;

	Detector_status_t status = readDatabase(detector,&aibases, &comparasion);



	if(status == DETECTOR_STATUS_FILE_ERROR ){

		return DETECTOR_STATUS_FILE_ERROR;
	}

	if(status == DETECTOR_STATUS_DISK_ERROR ){
		return DETECTOR_STATUS_DISK_ERROR;
	}

	AI_size_t size = aibases.size;
	AI_amount_t decisions = aibases.decisions;

	for(AI_amount_t n=0 ; n < size ; n ++){

		AI_amount_t tries = 0;

		if(IS_CORRECT_SECTOR(detector -> start)){
			bases[n] += detector -> start;
		}

		comparasion.spects = aibases.packet_sizes[n] * aibases.spects_in_base[n];

		comparasion.packet_size = aibases.packet_sizes[n];
		comparasion.max_diffrence = MAXIMUM_DIFF;
		comparasion.kb_spect_size = aibases.spect_sizes[n];

		while(tries < MAX_RETRIES){
			comparasion.start = bases[n];

			Timer_reset(detector -> timer);

			state[n] = AI_compare(&decision[n],detector -> comparer,&comparasion);
			score[n] = comparasion.diffrence;

			int time = Timer_get_time(detector -> timer);
			alt_printf("Classifier working for database (20 MB -> 80 MB decompressed) %x : ",n);
			printnum(time);

			alt_printf(" ms \n");

			Detector_status_t ostatus = analyse_load_errors(state[n],detector,&decision[n],crcs[n]);
			if(ostatus != DETECTOR_STATUS_OK){

				if(ostatus == DETECTOR_STATUS_CRC_ERROR){
					tries ++;

					if(tries == MAX_RETRIES){
						return ostatus;
					}else{
						continue;
					}
				}
				return ostatus;
			}

			break;
		}

	}

	if(load_linker_list(detector,linkers) == AI_DATABASE_ERROR){
		return DETECTOR_STATUS_FILE_ERROR;
	}

	if(isDetected(state,size)){

		Detector_word_decision_t m_word = selectBestSuit(score,state,decision,spects_in_base,size);

		if(m_word > decisions){
			return DETECTOR_STATUS_FILE_ERROR;
		}

		uint8_t* text_word = linkers[m_word];

		for(AI_position_t pos = 0; pos < LINKERS_LEN; pos ++){
			word[pos] = text_word[pos];

			if(text_word[pos] == 0){
				return DETECTOR_STATUS_OK;
			}
		}


		return DETECTOR_STATUS_FILE_ERROR;
	}else{

		if(isNotDetected(state,size)){
			return DETECTOR_STATUS_CANT_DETECT;
		}else{
			return DETECTOR_STATUS_BAD_CONFIG;
		}
	}
}
