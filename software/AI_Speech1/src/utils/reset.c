/*
 * reset.c

 *
 *  Created on: 27 kwi 2024
 *      Author: micha
 */
#include "nios2.h"

#define ALT_CPU_RESET_ADDR 0x00060000

void reset_processor(){

	  NIOS2_WRITE_STATUS(0);
	  NIOS2_WRITE_IENABLE(0);

}
