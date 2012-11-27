#include <C8051F120.h>
#include "types.h"
#include "sdmodule-f11.h"
#include "sdcomm_spi.h"
#include "spi.h"

//#pragma optimize(9,size)
#pragma opt_code_size

static uint8 __idata response[5];
static int32 __xdata argument_l;

uint32 ntohl(uint32 netlong);
uint16 ntohs(uint16 netshort);

// static sd_context_t __xdata sdc;
static uint16 sdc_timeout_write;
static uint16 sdc_timeout_read;
static uint8 sdc_busyflag;

/* This function initializes the SD card. It returns 1 if initialization
was successful, 0 otherwise.
   sd_context_t *sdc -- pointer to a data structure containing
                      information about the card. For now, the
                      timeouts MUST be specified in advance. This
                      function does not yet calculate them from the
                      card data.
*/

uint8 microSDinit( void )
{
  uint8 i = SD_INIT_TRY;
  spi_set_divisor(0);
  while (sd_initialize() != 1) {
     --i;
     if (i == 0) return 0;
  }
  spi_set_divisor(1);
  return 1;
}

static int sd_initialize( void )
{
  char j;
/* SPI SD initialization sequence:
 * CMD0
 * CMD55
 * ACMD41
 * CMD58
 * (Note there is no CMD2 or CMD3 in SPI mode. These
 * instructions are devoted to addressing on the SD bus.)
 *
 * SD memory card SD initialization sequence:
 * CMD0
 * CMD55
 * ACMD41
 * CMD2
 * CMD3
*/

  sdc_busyflag = 0;
  sdc_timeout_write = 1023; /// unknown values
  sdc_timeout_read = 1023;
  argument_l = 0;
/* Delay for at least 74 clock cycles. This means to actually
* *clock* out at least 74 clock cycles with no data present on
* the clock. In SPI mode, send at least 10 idle bytes (0xFF). */
  spi_cs_assert();
  sd_delay(500);
  spi_cs_deassert();
  sd_delay(10);
/* Put the card in the idle state */
  if (sd_send_command(CMD0, CMD0_R) == 0)
    return 0;
/* Now wait until the card goes idle. Retry at most SD_IDLE_WAIT_MAX
times */
  j = 0;
  do {
    j++;
    /* Flag the next command as an application-specific command */
    if (sd_send_command(CMD55, CMD55_R) == 1) {
    /* Tell the card to send its OCR */
      sd_send_command(ACMD41, ACMD41_R);
    } else {
    /* No response, bail early */
      j = SD_IDLE_WAIT_MAX;
    }
  }
  while ((response[0] & MSK_IDLE) == MSK_IDLE && j < SD_IDLE_WAIT_MAX);
  /* As long as we didn't hit the timeout, assume we're OK. */
  if (j >= SD_IDLE_WAIT_MAX) return 0;
  if (sd_send_command(CMD58, CMD58_R) == 0) return 0;
  /* At a very minimum, we must allow 3.3V. */
  if ((response[2] & MSK_OCR_33) != MSK_OCR_33) return 0;
  /* Set the block length */
  if (sd_set_blocklen (SD_BLOCKSIZE) != 1) return 0;
/* If we got this far, initialization was OK. */
  return 1;
}

/* This function reads a single block from the SD card at block
blockaddr. The buffer must be preallocated. Returns 1 if the
command was successful, zero otherwise.
This is an ASYNCHRONOUS call. The transfer will not be complete
when the function returns. If you want to explicitly wait until
any pending transfers are finished, use the command
sd_wait_notbusy(sdc).
sd_context_t *sdc -- a pointer to an sd device context structure,
populated by the function sd_initialize()
u32 blockaddr -- The block address to read from the card.
This is a block address, not a linear address.
unsigned char *data -- The data, a pointer to an array of unsigned
chars.
*/
char microSDread (uint32 blockaddr, unsigned char __xdata *_data)
{
  unsigned char i = 0;
  unsigned char tmp;
  unsigned char blank = 0xFF;
  /* Adjust the block address to a linear address */
  blockaddr <<= SD_BLOCKSIZE_NBITS;
  /* Wait until any old transfers are finished */
  sd_wait_notbusy ();
  /* Pack the address */
  argument_l = blockaddr;
  /* Need to add size checking */
  if (sd_send_command(CMD17, CMD17_R) == 0) return 0;
  /* Check for an error, like a misaligned read */
  if (response[0] != 0) return 0;
  /* Re-assert CS to continue the transfer */
  spi_cs_assert();
  /* Wait for the token */
  i=0;
  do {
    tmp = spi_rcv_byte();
    i++;
  }
  while ((tmp == 0xFF) && i < sdc_timeout_read );
  if ((tmp & MSK_TOK_DATAERROR) == 0) {
    /* Clock out a byte before returning */
    spi_send_byte(0xFF);
    /* The card returned an error response. Bail and return 0 */
    return 0;
  }

  spi_rcv_buffer(512, _data);

  return 1;
}

/* This function synchronously waits until any pending block transfers
are finished. If your program needs to ensure a block has finished
transferring, call this function.
Note that sd_read_block() and sd_write_block() already call this
function internally before attempting a new transfer, so there are
only two times when a user would need to use this function.
1) When the processor will be shutting down. All pending
writes should be finished first.
2) When the user needs the results of an sd_read_block() call
right away.
*/
static void sd_wait_notbusy ( void )
{
  /* Ignore the checksum */
  sd_delay(4);
  /* Check for the busy flag (set on a write block) */
  if (sdc_busyflag == 1) {
    while (spi_rcv_byte() != 0xFF);
    sdc_busyflag = 0;
  }
  /* Deassert CS */
  spi_cs_deassert();
  /* Send some extra clocks so the card can resynchronize on the next
  transfer */
  sd_delay(2);
}

static int sd_send_command(
  unsigned char cmd, unsigned char response_type)
{
  char i;
  char response_length;
  unsigned char tmp;
  unsigned char __xdata *ptr = (unsigned char *)&argument_l;
  spi_cs_assert();
  /* All data is sent MSB first, and MSb first */
  /* Send the header/command */
  /* Format:
  cmd[7:6] : 01
  cmd[5:0] : command */
  spi_send_byte((cmd & 0x3F) | 0x40);
  for (i=3; i>=0; i--)
  {
    // spi_send_byte(argument.c[i]);
    spi_send_byte(*ptr++);
  }
  /* This is the CRC. It only matters what we put here for the first
  command. Otherwise, the CRC is ignored for SPI mode unless we
  enable CRC checking. */
  spi_send_byte(0x95);
  response_length = 0;
  switch (response_type)
  {
    case R1:
    case R1B:
      response_length = 1;
      break;
    case R2:
      response_length = 2;
      break;
    case R3:
      response_length = 5;
      break;
    default:
      break;
  }
  /* Wait for a response. A response can be recognized by the
  start bit (a zero) */
  i=0;
  do {
    tmp = spi_rcv_byte();
    i++;
  }
  while (((tmp & 0x80) != 0) && i < SD_CMD_TIMEOUT);
  /* Just bail if we never got a response */
  if (i >= SD_CMD_TIMEOUT) {
    spi_cs_deassert();
    return 0;
  }
  for (i=response_length-1; i>=0; i--) {
    response[i] = tmp;
    /* This handles the trailing-byte requirement. */
    tmp = spi_rcv_byte();
  }
  /* If the response is a "busy" type (R1B), then there's some
  * special handling that needs to be done. The card will
  * output a continuous stream of zeros, so the end of the BUSY
  * state is signaled by any nonzero response. The bus idles
  * high.
  */
  if (response_type == R1B) {
    do {
      tmp = spi_rcv_byte();
    }
    while (tmp != 0xFF);
    spi_send_byte(0xFF);
  }
  spi_cs_deassert();
  return 1;
}

static void sd_delay(char number)
{
  char i;
  /* Null for now */
  for (i=number; i; --i) {/* Clock out an idle byte (0xFF) */
    spi_send_byte(0xFF);
  }
}

/* Set the block length for all future block transactions */
/* Returns 1 if the function was successful */
static int sd_set_blocklen (uint32 length)
{
/* Pack the block length */
  argument_l = length;
  return (sd_send_command(CMD16, CMD16_R));
}

// compiler stores things big endian
// sd_packarg takes uint32 and stores it little endian in argument.
// sd_send_command transmit it MSB first.
// so it we have a uint32, just transmit from first byte
