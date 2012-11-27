#include "types.h"

#define SD_BLOCKSIZE 512
#define SD_BLOCKSIZE_NBITS 9


uint8 microSDinit( void );
char microSDread (uint32 blockaddr, unsigned char __xdata *_data);

static int sd_initialize( void );
static void sd_wait_notbusy ( void );
static int sd_send_command( unsigned char cmd, unsigned char response_type);
static void sd_delay(char number);
static int sd_set_blocklen (uint32 length);
