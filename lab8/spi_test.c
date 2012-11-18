#include <c8051f120.h>           // Get SFR declarations
#include "types.h"
#include "spi.h"
#include "lcd.h"
#include "sd.h"

typedef struct {
      char string[16];
      uint8_t len;
      uint8_t wavedata[512];
} SD_data;

int main(void){
    SD_data xdata dat;
    uint8_t lol;

    //init procedures
    WDTCN = 0xDE;             // Disable watchdog timer
    WDTCN = 0xAD;
    OSCICN = 0xC2;

    XBR2 = 0x40;              // Enable crossbar and weak pull-up


    spiinit();
    lcdinit();

    while(!spicardpresent());
    lol = microSDinit();

    do {
        lol = microSDread(0x11235813, dat.wavedata);
        lcdwrite(dat.string);
        lcdpos(0, 0);
    } while(!lol);

    while(1);
    return 0;
}
