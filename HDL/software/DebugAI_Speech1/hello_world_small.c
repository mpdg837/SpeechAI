
#include "sys/alt_irq.h"
#include "inttypes.h"
#include "math.h"

#include "./src/utils/timer/timer.h"
#include "./src/utils/printnum.h"
#include "./src/ai/ai.h"
#include "./src/processing/utils/scalex.h"
#include "./src/ai/dma/dma.h"
#include "./src/processing/normalisation.h"
#include "./src/processing/spectrogram.h"
#include "./src/disk/disk.h"
#include "./src/microphone/microphone.h"
#include "./src/processing/utils/loud.h"
#include "./src/detect.h"
#include "./src/microphone/recorder.h"
#include "./src/speaker/speaker.h"
#include "./src/output/gpio_distance.h"
#include "./src/output/BLE/BLE.h"
#include "./src/main.h"
#include "./src/output/exception.h"

#include "./src/microphone/queue.h"
#include "./src/output/gpio_distance_measure.h"


#define DEBUG					0
#define SWAP_SIZE_MEM			24000

volatile uint16_t table[SWAP_SIZE_MEM];
volatile uint8_t* swap = (volatile uint8_t*) 0x10000;

int main()
{
  volatile AI_comparer_t comparer;
  volatile DMA_memories_t memories;
  volatile Normaliser_t normaliser;
  volatile Spectrogramer_t spectrogramer;
  volatile Microphone_t microphone;
  volatile Disk_t disk;
  volatile Speaker_t speaker;
  volatile Timer_t timer;
  volatile BLE_UART_t buart;

  Gpio_distance_t distancer;


  while(1){

	  gpio_init(&distancer);

	  timer.gpio = &distancer;

	  Gpio_distance_measure_t mdistance;
	  init_measurement(&mdistance);
	  timer.mdistance = &mdistance;

	  Timer_init(&timer);
	  gpio_flash_pin(&distancer,GPIO_PIN_READY);

	  comparer.flag = AI_FLAG_DOWN;
	  comparer.timer = &timer;
	  comparer.compression = AI_COMPRESSION_FOUR;


	  AI_init(&comparer);


	  memories.flag = DMA_FLAG_DOWN;
	  memories.swap = swap;
	  memories.table = table;

	  memories.table_size = SWAP_SIZE_MEM;
	  memories.swap_size = SWAP_SIZE_MEM;

	  DMA_init(&memories);

	  normaliser.flag = NORMALISATION_FLAG_DOWN;
	  Nor_init(&normaliser);

	  spectrogramer.flag = SPECTROGRAM_FLAG_DOWN;
	  spectrogramer.memories = &memories;
	  spectrogramer.normaliser = &normaliser;
	  Signal_init(&spectrogramer);

	  Microphone_huge_sound_t sounds[STANDARD_QUEUE_SIZE];
	  Queue_t mic_queue;

	  mic_queue.fifo_sound = sounds;

	  microphone.flag = MICROPHONE_FLAG_DOWN;
	  microphone.sound = 0;
	  microphone.mic_queue = &mic_queue;

	  MIC_init(&microphone);

	  disk.card = DISK_SD_ALL_CARD;
	  disk.flag = DISK_FLAG_DOWN;
	  disk.memories = &memories;
	  disk.status = DISK_STATUS_NONE;

	  speaker.flag = SPEAKER_FLAG_DOWN;
	  speaker.disk = &disk;
	  speaker.volume = 15;
	  speaker.gpio = &distancer;
	  Speaker_init(&speaker);

	  disk.timer = &timer;



	  Disk_status_t d_status = init_disk(&disk);

	  Timer_reset(&timer);
	  while(Timer_get_time(&timer) < 500);

	  if(d_status == DISK_STATUS_ERROR){
		  startup_panic(&buart,&distancer ,PANIC_NO_DISK);
		  continue;
	  }

	  Timer_reset(&timer);
	  while(Timer_get_time(&timer) < 500);


	  uint8_t buffer_in[STANDARD_BLE_BUFFER_SIZE];
	  uint8_t buffer_out[STANDARD_BLE_BUFFER_SIZE];

	  buart.message_in = buffer_in;
	  buart.message_out = buffer_out;
	  buart.timer = &timer;

	  volatile Device_tree_t tree;

	  tree.comparer = &comparer;
	  tree.disk = &disk;
	  tree.memories = &memories;
	  tree.microphone = &microphone;
	  tree.normaliser = &normaliser;
	  tree.speaker = &speaker;
	  tree.spectrogramer = &spectrogramer;
	  tree.distancer = &distancer;
	  tree.timer = &timer;
	  tree.buart = &buart;

	  app(&tree);

  }
  return 0;
}

