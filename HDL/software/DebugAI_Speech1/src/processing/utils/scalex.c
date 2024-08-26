/*
 * scalex.c

 *
 *  Created on: 7 mar 2024
 *      Author: micha
 */

#include "../../utils/printnum.h"
#include "../../ai/dma/dma_types.h"
#include "inttypes.h"

#define DEBUG 0
#define FIXED_POINT_POS 16

#define INT_TO_FIXED_POINT(number) (uint32_t) (number << (FIXED_POINT_POS - 1))
#define FIXED_TO_INT_POINT(number) (uint32_t) (number >> (FIXED_POINT_POS - 1))

typedef uint32_t fixed_t;

void Scale_scaleX(volatile DMA_table_mem_t* table,DMA_size_t height, DMA_size_t width, DMA_position_t stoppos) {


	fixed_t delta =  INT_TO_FIXED_POINT(height)/ stoppos;
	fixed_t deltar = delta;

    for (uint32_t no =0 ; no < width; no++) {
        int offset = no;

        uint16_t old_border[height];
        uint16_t new_border[height];

        for (uint32_t n = 0; n < height; n++) {

            if (n < stoppos) {
                old_border[n] = table[offset];
                offset += width;
            } else {
                old_border[n] = 0;
            }

            new_border[n] = 0;
        }

        int posX = 0;
        for (uint32_t n = 0; n < stoppos; n++) {

        	fixed_t startPos = posX;
        	fixed_t stopPos = posX + deltar;

            for (uint32_t k = FIXED_TO_INT_POINT(startPos); k < FIXED_TO_INT_POINT(stopPos); k++) {

				if(k < height){
					if (new_border[k] < old_border[n])
						new_border[k] = old_border[n];
            	}
            }


            posX += deltar;
        }

        offset = no;
        for (uint32_t n = 0; n < height; n++) {

            table[offset] = new_border[n];
            offset += width;

        }

    }

}
