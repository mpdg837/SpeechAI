/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'CPU' in SOPC Builder design 'system'
 * SOPC Builder design path: ../../system.sopcinfo
 *
 * Generated: Sat May 25 21:30:03 CEST 2024
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * AI_Comparer_0 configuration
 *
 */

#define AI_COMPARER_0_BASE 0x40000
#define AI_COMPARER_0_IRQ 3
#define AI_COMPARER_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define AI_COMPARER_0_NAME "/dev/AI_Comparer_0"
#define AI_COMPARER_0_SPAN 64
#define AI_COMPARER_0_TYPE "AI_Comparer"
#define ALT_MODULE_CLASS_AI_Comparer_0 AI_Comparer


/*
 * AI_DMA_0 configuration
 *
 */

#define AI_DMA_0_BASE 0x0
#define AI_DMA_0_IRQ 10
#define AI_DMA_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define AI_DMA_0_NAME "/dev/AI_DMA_0"
#define AI_DMA_0_SPAN 64
#define AI_DMA_0_TYPE "AI_DMA"
#define ALT_MODULE_CLASS_AI_DMA_0 AI_DMA


/*
 * AI_RAM_0 configuration
 *
 */

#define AI_RAM_0_BASE 0x10000
#define AI_RAM_0_IRQ -1
#define AI_RAM_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define AI_RAM_0_NAME "/dev/AI_RAM_0"
#define AI_RAM_0_SPAN 65536
#define AI_RAM_0_TYPE "AI_RAM"
#define ALT_MODULE_CLASS_AI_RAM_0 AI_RAM


/*
 * BLE_UART configuration
 *
 */

#define ALT_MODULE_CLASS_BLE_UART BLE_UART
#define BLE_UART_BASE 0x28000
#define BLE_UART_IRQ 7
#define BLE_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define BLE_UART_NAME "/dev/BLE_UART"
#define BLE_UART_SPAN 32
#define BLE_UART_TYPE "BLE_UART"


/*
 * BasicTimer configuration
 *
 */

#define ALT_MODULE_CLASS_BasicTimer BasicTimer
#define BASICTIMER_BASE 0x22000
#define BASICTIMER_IRQ 1
#define BASICTIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define BASICTIMER_NAME "/dev/BasicTimer"
#define BASICTIMER_SPAN 16
#define BASICTIMER_TYPE "BasicTimer"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00020820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x13
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00060020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x13
#define ALT_CPU_NAME "CPU"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00060000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00020820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x13
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00060020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x13
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00060000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __AI_COMPARER
#define __AI_DMA
#define __AI_RAM
#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_NIOS2_GEN2
#define __ALTPLL
#define __BASICTIMER
#define __BLE_UART
#define __DISTANCE
#define __MICROPHONE
#define __NORMALIZER
#define __PWMAUDIO
#define __SIGNAL_PROCESSOR
#define __SPIQUICK


/*
 * Distance_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Distance_0 Distance
#define DISTANCE_0_BASE 0x27000
#define DISTANCE_0_IRQ 9
#define DISTANCE_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define DISTANCE_0_NAME "/dev/Distance_0"
#define DISTANCE_0_SPAN 32
#define DISTANCE_0_TYPE "Distance"


/*
 * JUART configuration
 *
 */

#define ALT_MODULE_CLASS_JUART altera_avalon_jtag_uart
#define JUART_BASE 0x21000
#define JUART_IRQ 0
#define JUART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JUART_NAME "/dev/JUART"
#define JUART_READ_DEPTH 64
#define JUART_READ_THRESHOLD 8
#define JUART_SPAN 8
#define JUART_TYPE "altera_avalon_jtag_uart"
#define JUART_WRITE_DEPTH 64
#define JUART_WRITE_THRESHOLD 8


/*
 * Microphone_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Microphone_0 Microphone
#define MICROPHONE_0_BASE 0x29000
#define MICROPHONE_0_IRQ 8
#define MICROPHONE_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define MICROPHONE_0_NAME "/dev/Microphone_0"
#define MICROPHONE_0_SPAN 32
#define MICROPHONE_0_TYPE "Microphone"


/*
 * Normalizer_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Normalizer_0 Normalizer
#define NORMALIZER_0_BASE 0x25000
#define NORMALIZER_0_IRQ 4
#define NORMALIZER_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define NORMALIZER_0_NAME "/dev/Normalizer_0"
#define NORMALIZER_0_SPAN 32
#define NORMALIZER_0_TYPE "Normalizer"


/*
 * PLL configuration
 *
 */

#define ALT_MODULE_CLASS_PLL altpll
#define PLL_BASE 0x20000
#define PLL_IRQ -1
#define PLL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define PLL_NAME "/dev/PLL"
#define PLL_SPAN 16
#define PLL_TYPE "altpll"


/*
 * PWMAudio_0 configuration
 *
 */

#define ALT_MODULE_CLASS_PWMAudio_0 PWMAudio
#define PWMAUDIO_0_BASE 0x26000
#define PWMAUDIO_0_IRQ 6
#define PWMAUDIO_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define PWMAUDIO_0_NAME "/dev/PWMAudio_0"
#define PWMAUDIO_0_SPAN 32
#define PWMAUDIO_0_TYPE "PWMAudio"


/*
 * SPIQuick_0 configuration
 *
 */

#define ALT_MODULE_CLASS_SPIQuick_0 SPIQuick
#define SPIQUICK_0_BASE 0x23000
#define SPIQUICK_0_IRQ 2
#define SPIQUICK_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SPIQUICK_0_NAME "/dev/SPIQuick_0"
#define SPIQUICK_0_SPAN 32
#define SPIQUICK_0_TYPE "SPIQuick"


/*
 * Signal_Processor_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Signal_Processor_0 Signal_Processor
#define SIGNAL_PROCESSOR_0_BASE 0x30000
#define SIGNAL_PROCESSOR_0_IRQ 5
#define SIGNAL_PROCESSOR_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SIGNAL_PROCESSOR_0_NAME "/dev/Signal_Processor_0"
#define SIGNAL_PROCESSOR_0_SPAN 32
#define SIGNAL_PROCESSOR_0_TYPE "Signal_Processor"


/*
 * SysRAM configuration
 *
 */

#define ALT_MODULE_CLASS_SysRAM altera_avalon_onchip_memory2
#define SYSRAM_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define SYSRAM_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define SYSRAM_BASE 0x60000
#define SYSRAM_CONTENTS_INFO ""
#define SYSRAM_DUAL_PORT 1
#define SYSRAM_GUI_RAM_BLOCK_TYPE "M9K"
#define SYSRAM_INIT_CONTENTS_FILE "system_SysRAM"
#define SYSRAM_INIT_MEM_CONTENT 1
#define SYSRAM_INSTANCE_ID "NONE"
#define SYSRAM_IRQ -1
#define SYSRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSRAM_NAME "/dev/SysRAM"
#define SYSRAM_NON_DEFAULT_INIT_FILE_ENABLED 1
#define SYSRAM_RAM_BLOCK_TYPE "M9K"
#define SYSRAM_READ_DURING_WRITE_MODE "DONT_CARE"
#define SYSRAM_SINGLE_CLOCK_OP 0
#define SYSRAM_SIZE_MULTIPLE 1
#define SYSRAM_SIZE_VALUE 81920
#define SYSRAM_SPAN 81920
#define SYSRAM_TYPE "altera_avalon_onchip_memory2"
#define SYSRAM_WRITABLE 1


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "MAX 10"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/JUART"
#define ALT_STDERR_BASE 0x21000
#define ALT_STDERR_DEV JUART
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/JUART"
#define ALT_STDIN_BASE 0x21000
#define ALT_STDIN_DEV JUART
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/JUART"
#define ALT_STDOUT_BASE 0x21000
#define ALT_STDOUT_DEV JUART
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "system"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 4
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none

#endif /* __SYSTEM_H_ */
