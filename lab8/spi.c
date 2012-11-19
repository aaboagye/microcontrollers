#include <c8051f120.h>          // get SFR declarations
#include "spi.h"
#include "types.h"

// pin manip: manip them pins
#define SCK_PORT    P0            //SPI SCK signal
#define SCK_POS     0
#define DO_PORT     P0            //SPI MISO signal
#define DO_POS      1
#define DI_PORT     P0            //SPI MOSI signal
#define DI_POS      2
#define CD_PORT     P2
#define CD_POS      1
#define CS_PORT     P2
#define CS_POS      0

// use these like SETB(SCK); etc.
#define SETB(bit)   (bit##_PORT |= (1 << bit##_POS))    // set dat b
#define CLRB(bit)   (bit##_PORT &= ~(1 << bit##_POS))   // clr dat b
#define TOGB(bit)   (bit##_PORT ^= (1 << bit##_POS))    // tog dat b
#define CHKB(bit)   (bit##_PORT & (1 << bit##_POS))     // chk dat b
                                                        // where b == bit.
//Pin declarations
sbit CS     = P2^0;
sbit CD     = P2^1;
sbit DO     = P0^1;
sbit DI     = P0^2;
sbit SCK    = P0^0;

//initializes the SPI module.  It does not need to set the SPI clock speed.
void spiinit(void){
    SFRPAGE = 0;
    SPI0CFG |= 0x40;        //Enable master mode. (operate as master)
    NSSMD1 = 0; NSSMD0 = 0; //Setting 3-wire mode.
    SPIEN = 1;              //Enable the SPI module.
    SFRPAGE = 0x0F;
    XBR0 |= 0x03;           //Routing pins to SPI module via the crossbar.
    XBR1 |= 0x20;           //Enabling timer 2
    P0MDOUT |= 0x07;
    P2MDOUT |= 0x02;        //Setting push-pull mode for needed pins
    SFRPAGE = 0;
    return;
}

/*  returns the status of the CD signal from the microSD card adapter.
    It should return true (non-zero) when there is a card in the adapter. */
uint8_t spicardpresent(){
    return (uint8_t) CHKB(CD);   //Assuming is set high when card is in adapter.
}

/*  The remaining procedures are called from the SD card module (note, these
    procedures all have underscores in their names) */

//sets the SPI clock speed. If spd is 0, the clock is set to approximately 400KHz; otherwise the clock is set to maximum speed.
void spi_set_divisor(uint8_t spd){
    SFRPAGE = 0;
    SPI0CKR = spd ? 0 : 0x0F;
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
    SPIF = 0;
    SPI0DAT = input;
    while(!SPIF);
    return;
}

//receives one byte over the SPI bus
uint8_t spi_rcv_byte(){
    SPIF = 0;
    SPI0DAT = 0xFF;
    while(!SPIF);
    return SPI0DAT;
}

//sends multiple bytes (normally a SD card sector) over the SPI bus.
void spi_rcv_buffer(uint16_t len, uint8_t xdata *buffer){
    int i;
    spi_cs_assert();
    for(i = 0; i < len; i++)
        buffer[i] = spi_rcv_byte();
    spi_cs_deassert();
    return;
}
