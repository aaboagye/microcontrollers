#ifndef _SPI_H
#define _SPI_H

//These are the procedures you need to write. Only two are called directly from the main module: 

//initializes the SPI module.  It does not need to set the SPI clock speed.
void spiinit();

/*  returns the status of the CD signal from the microSD card adapter.
    It should return true (non-zero) when there is a card in the adapter. */
uint8 spicardpresent();

/*  The remaining procedures are called from the SD card module (note, these procedures all have 
    underscores in their names) */

//sets the SPI clock speed.  If spd is 0, the clock is set to approximately 400KHz; otherwise the clock is set to maximum speed.
void spi_set_divisor(uint8 spd);

//asserts the CS chip select signal line (sets it low).
void spi_cs_assert();

//de-asserts the CS chip select signal line (sets it high).
void spi_cs_deassert();

//sends one byte over the SPI bus.
void spi_send_byte(uint8 input);

//receives one byte over the SPI bus
uint8 spi_rcv_byte();

//sends multiple bytes (normally a SD card sector) over the SPI bus.  The code for this procedure was given earlier.
void spi_rcv_buffer(uint16 len, uint8 xdata *buffer);

#endif