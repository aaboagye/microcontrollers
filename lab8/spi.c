#include <c8051f120.h>          // get SFR declarations
#include "spi.h"
#include "types.h"

#define SCK P0.0            //SPI SCK signal
#define DO  P0.1            //SPI MISO signal
#define DI  P0.2            //SPI MOSI signal
#define CD	P2.1
#define CS	P2.0

//initializes the SPI module.  It does not need to set the SPI clock speed.
void spiinit(void){
    SFRPAGE = 0;
    SPI0CFG |= 0x40;        //Enable master mode. (operate as master)
    NSSMD1 = 0; NSSMD0 = 0; //Setting 3-wire mode.
    SPIEN = 1;              //Enable the SPI module.
    XBR0 |= 0x02;           //Routing pins to SPI module via the crossbar.
    return;
}

/*  returns the status of the CD signal from the microSD card adapter.
    It should return true (non-zero) when there is a card in the adapter. */
uint8_t spicardpresent(){
    return (uint8_t)CD;		//Assuming is set high when card is in adapter.
}

/*  The remaining procedures are called from the SD card module (note, these procedures all have
    underscores in their names) */

//sets the SPI clock speed.  If spd is 0, the clock is set to approximately 400KHz; otherwise the clock is set to maximum speed.
void spi_set_divisor(uint8_t spd){
	SFRPAGE = 0;
	SPI0CKR = spd ? 0 : 0xE0;
    return;
}

//asserts the CS chip select signal line (sets it low).
void spi_cs_assert(){
	CS = 0;
    return;
}

//de-asserts the CS chip select signal line (sets it high).
void spi_cs_deassert(){
	CS = 1;
    return;
}

//sends one byte over the SPI bus.
void spi_send_byte(uint8_t input){
	SPI0DAT = input;
    return;
}

//receives one byte over the SPI bus
uint8_t spi_rcv_byte(){
    return SPI0DAT;
}

//sends multiple bytes (normally a SD card sector) over the SPI bus.  The code for this procedure was given earlier.
void spi_rcv_buffer(uint16_t len, uint8_t xdata *buffer){
    return;
}

