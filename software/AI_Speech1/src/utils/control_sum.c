/*
 * control_sum.c
 *
 *  Created on: 25 mar 2024
 *      Author: micha
 */
#include "control_sum_types.h"
#include "inttypes.h"

Simple_control_sum_t Control_count_sum(uint8_t* data, Simple_control_sum_size_t size){
	Simple_control_sum_t counted_sum = 0;

	for(Simple_control_sum_size_t n = 0 ; n < size ; n++){

		for(int32_t bitcounter = 7; bitcounter >= 0; bitcounter --){
			counted_sum += (data[n] >> bitcounter) & 0x1;
		}


	}

	return ~counted_sum;
}
