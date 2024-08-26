/*
 * normalisation_types.h
 *
 *  Created on: 9 mar 2024
 *      Author: micha
 */

#include "inttypes.h"

#define NORMALISATION_FLAG_UP 	1
#define NORMALISATION_FLAG_DOWN 0


#ifndef NORMALISATION_TYPES_H_
#define NORMALISATION_TYPES_H_

typedef uint32_t Normalisation_flag_t;

typedef struct Normaliser{
	volatile Normalisation_flag_t flag;
}Normaliser_t;

#endif /* NORMALISATION_TYPES_H_ */
