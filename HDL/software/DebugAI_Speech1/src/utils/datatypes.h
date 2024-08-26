/*
 * datatypes.h
 *
 *  Created on: 24 mar 2024
 *      Author: micha
 */
#include "datatypes_types.h"
#include "inttypes.h"

#ifndef SRC_UTILS_DATATYPES_H_
#define SRC_UTILS_DATATYPES_H_

Data_bool_t from64toBytes(uint8_t* data,uint8_t* string,Parse_size_t size);

Data_bool_t compare(uint8_t* read1,uint8_t* read2,Data_size_t size);
Data_bool_t str_cpy(uint8_t* read1,uint8_t* read2,Data_size_t size);
Data_bool_t is_empty_str(uint8_t* read1,Data_size_t size);
void str_clr(uint8_t* read1,Data_size_t size);

uint16_t read_16_value(uint8_t* read);
uint32_t read_32_value(uint8_t* read);

#endif /* SRC_UTILS_DATATYPES_H_ */
