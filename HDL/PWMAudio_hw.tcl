# TCL File Generated by Component Editor 18.1
# Thu Apr 25 10:12:39 CEST 2024
# DO NOT MODIFY


# 
# PWMAudio "PWMAudio" v1.0
#  2024.04.25.10:12:39
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module PWMAudio
# 
set_module_property DESCRIPTION ""
set_module_property NAME PWMAudio
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME PWMAudio
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL Audio_PWM
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file PWM_Audio.v VERILOG PATH PWM_Audio/PWM_Audio.v TOP_LEVEL_FILE
add_fileset_file PWM_DMA.v VERILOG PATH PWM_Audio/PWM_DMA.v
add_fileset_file PWM_FIFO_basi.v VERILOG PATH PWM_Audio/PWM_FIFO_basi.v
add_fileset_file PWM_FIFO_stream.v VERILOG PATH PWM_Audio/PWM_FIFO_stream.v
add_fileset_file PWM_config.v VERILOG PATH PWM_Audio/PWM_config.v
add_fileset_file PWM_filter.v VERILOG PATH PWM_Audio/PWM_filter.v
add_fileset_file PWM_freq.v VERILOG PATH PWM_Audio/PWM_freq.v
add_fileset_file PWM_frequency_mul.v VERILOG PATH PWM_Audio/PWM_frequency_mul.v
add_fileset_file PWM_gen.v VERILOG PATH PWM_Audio/PWM_gen.v
add_fileset_file PWM_loader.v VERILOG PATH PWM_Audio/PWM_loader.v
add_fileset_file PWM_reducer.v VERILOG PATH PWM_Audio/PWM_reducer.v
add_fileset_file PWM_serializer.v VERILOG PATH PWM_Audio/PWM_serializer.v
add_fileset_file PWM_soft_launch.v VERILOG PATH PWM_Audio/PWM_soft_launch.v
add_fileset_file PWM_volumer.v VERILOG PATH PWM_Audio/PWM_volumer.v


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock csi_clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset rsi_reset_n reset_n Input 1


# 
# connection point s0
# 
add_interface s0 avalon end
set_interface_property s0 addressUnits WORDS
set_interface_property s0 associatedClock clock
set_interface_property s0 associatedReset reset
set_interface_property s0 bitsPerSymbol 8
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 burstcountUnits WORDS
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 0
set_interface_property s0 maximumPendingWriteTransactions 0
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0
set_interface_property s0 ENABLED true
set_interface_property s0 EXPORT_OF ""
set_interface_property s0 PORT_NAME_MAP ""
set_interface_property s0 CMSIS_SVD_VARIABLES ""
set_interface_property s0 SVD_ADDRESS_GROUP ""

add_interface_port s0 avs_s0_write write Input 1
add_interface_port s0 avs_s0_read read Input 1
add_interface_port s0 avs_s0_address address Input 3
add_interface_port s0 avs_s0_writedata writedata Input 32
add_interface_port s0 avs_s0_readdata readdata Output 32
set_interface_assignment s0 embeddedsw.configuration.isFlash 0
set_interface_assignment s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point m1
# 
add_interface m1 avalon start
set_interface_property m1 addressUnits SYMBOLS
set_interface_property m1 associatedClock clock
set_interface_property m1 associatedReset reset
set_interface_property m1 bitsPerSymbol 8
set_interface_property m1 burstOnBurstBoundariesOnly false
set_interface_property m1 burstcountUnits WORDS
set_interface_property m1 doStreamReads false
set_interface_property m1 doStreamWrites false
set_interface_property m1 holdTime 0
set_interface_property m1 linewrapBursts false
set_interface_property m1 maximumPendingReadTransactions 0
set_interface_property m1 maximumPendingWriteTransactions 0
set_interface_property m1 readLatency 0
set_interface_property m1 readWaitTime 1
set_interface_property m1 setupTime 0
set_interface_property m1 timingUnits Cycles
set_interface_property m1 writeWaitTime 0
set_interface_property m1 ENABLED true
set_interface_property m1 EXPORT_OF ""
set_interface_property m1 PORT_NAME_MAP ""
set_interface_property m1 CMSIS_SVD_VARIABLES ""
set_interface_property m1 SVD_ADDRESS_GROUP ""

add_interface_port m1 avm_m1_write write Output 1
add_interface_port m1 avm_m1_read read Output 1
add_interface_port m1 avm_m1_waitrequest waitrequest Input 1
add_interface_port m1 avm_m1_readdatavalid readdatavalid Input 1
add_interface_port m1 avm_m1_address address Output 32
add_interface_port m1 avm_m1_writedata writedata Output 32
add_interface_port m1 avm_m1_readdata readdata Input 32


# 
# connection point interrupt_sender
# 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint s0
set_interface_property interrupt_sender associatedClock clock
set_interface_property interrupt_sender associatedReset reset
set_interface_property interrupt_sender bridgedReceiverOffset ""
set_interface_property interrupt_sender bridgesToReceiver ""
set_interface_property interrupt_sender ENABLED true
set_interface_property interrupt_sender EXPORT_OF ""
set_interface_property interrupt_sender PORT_NAME_MAP ""
set_interface_property interrupt_sender CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_sender SVD_ADDRESS_GROUP ""

add_interface_port interrupt_sender avm_s0_irq irq Output 1


# 
# connection point audio
# 
add_interface audio conduit end
set_interface_property audio associatedClock clock
set_interface_property audio associatedReset reset
set_interface_property audio ENABLED true
set_interface_property audio EXPORT_OF ""
set_interface_property audio PORT_NAME_MAP ""
set_interface_property audio CMSIS_SVD_VARIABLES ""
set_interface_property audio SVD_ADDRESS_GROUP ""

add_interface_port audio audio audio Output 8


# 
# connection point audio1
# 
add_interface audio1 conduit end
set_interface_property audio1 associatedClock clock
set_interface_property audio1 associatedReset ""
set_interface_property audio1 ENABLED true
set_interface_property audio1 EXPORT_OF ""
set_interface_property audio1 PORT_NAME_MAP ""
set_interface_property audio1 CMSIS_SVD_VARIABLES ""
set_interface_property audio1 SVD_ADDRESS_GROUP ""

add_interface_port audio1 audio1 audio Output 8

