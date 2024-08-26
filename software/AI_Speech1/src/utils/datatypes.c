/*
 * datatypes.c
 *
 *  Created on: 24 mar 2024
 *      Author: micha
 */
#include "inttypes.h"
#include "datatypes_types.h"

#define TRIPLETS 			3

#define BASE_64_BASE 		6
#define IN_PACKET 			4

#define BYTE_OFFSET 		8
#define BIT_6_MASK 			0x3f

#define END_OF_STRING 		0

typedef uint32_t Data_position_t;

uint8_t from64toChar(uint8_t character){
    if(character <= 9){
        return character + '0';
    }else if(character >= 10 && character <= 25 + 10){
        return character - 10 + 'A';
    }else if(character >= 26 + 10 && character <= 26 + 25 + 10){
        return character - 26 - 10 + 'a';
    }else if(character == 26+26+10){
        return ' ';
    }else{
        return 0;
    }
}

Data_bool_t from64toBytes(uint8_t* data,uint8_t* string,Parse_size_t size){

    Parse_buffer_t buffer = 0;
    Parse_size_t index = 0;

    Parse_size_t k = 0;

    for(Parse_size_t n = 0 ; n < size ; n++){

        buffer = (buffer << BYTE_OFFSET) | data[n];
        index ++;

        if(index == TRIPLETS){

            Parse_size_t shift = 3 * BASE_64_BASE;
            for(Parse_size_t p = 0; p < IN_PACKET ; p++){

                uint8_t base = (buffer >> shift) & BIT_6_MASK;
                string[k] = from64toChar(base);

                if(string[k] == END_OF_STRING){
                    return DATA_FALSE;
                }

                k++;
                shift -= BASE_64_BASE;
            }

            index = 0;
            buffer = 0;
        }
    }

    return DATA_TRUE;
}

uint16_t read_16_value(uint8_t* read){
	uint16_t value = 0;
	uint8_t* ptr = read;

	for(Data_position_t n=0; n < 2 ; n++){

		value = (value << 8) | *ptr;

		ptr++;
	}

	return value;
}

uint32_t read_32_value(uint8_t* read){
	uint32_t value = 0;
	uint8_t* ptr = read;

	for(Data_position_t n=0; n < 4 ; n++){

		value = (value << 8) | *ptr;

		ptr++;
	}

	return value;
}

Data_bool_t is_empty_str(uint8_t* read1,Data_size_t size){
	for(Data_position_t n = 0 ; n < size ; n++){
		if(read1[n] != 0)
			return DATA_FALSE;

	}
	return DATA_TRUE;

}

void str_clr(uint8_t* read1,Data_size_t size){
	for(Data_position_t n = 0 ; n < size ; n++){
		read1[n] = 0;

	}

}

Data_bool_t str_cpy(uint8_t* read1,uint8_t* read2,Data_size_t size){
	for(Data_position_t n = 0 ; n < size ; n++){

		if(read1[n] == 0){
			read2[n] = 0;
			return DATA_TRUE;
		}

		read2[n] = read1[n];

	}

	return DATA_FALSE;
}

Data_bool_t compare(uint8_t* read1,uint8_t* read2,Data_size_t size){
	for(Data_position_t n = 0 ; n < size ; n++){

		if(read1[n] == 0){
			break;
		}

		if(read1[n] != read2[n]){
			return DATA_FALSE;
		}

	}

	return DATA_TRUE;
}
