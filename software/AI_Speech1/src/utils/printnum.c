/*
 * printnum.c
 *
 *  Created on: 7 mar 2024
 *      Author: micha
 */
#include "sys/alt_stdio.h"
#include "inttypes.h"
#define MAX_RANGE (int)100000000

void printnum(int number){

	int numbuf = number;

	char started = 0;

	for(int n= MAX_RANGE ; n>0 ; n/=10 ){
		int num = numbuf / n;
		int eq = n * num;

		if(num != 0){
			started = 1;
		}

		if(started){
			alt_printf("%x",num);
		}


		numbuf -= eq;
	}
}

void snprintnum(uint8_t* buffer, int number){

	int numbuf = number;
	int index = 0;
	char started = 0;

	for(int n= MAX_RANGE ; n>0 ; n/=10 ){
		int num = numbuf / n;
		int eq = n * num;

		if(num != 0){
			started = 1;
		}

		if(started){
			buffer[index] = num + '0';
			index ++;
		}


		numbuf -= eq;
	}
	buffer[index] = 0;
}
