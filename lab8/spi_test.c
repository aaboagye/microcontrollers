#include <c8051f120.h>           // Get SFR declarations
#include "types.h"
#include "spi.h"
#include "lcd.h"
#include "sd.h"

typedef struct {
      char string[16];
      unsigned short len;
      uint8_t wavedata[512];
} SD_data;

int main(void){
    SD_data xdata dat;
    uint8_t lol;
    uint8_t xdata buffer[512];

    SFRPAGE = 0x0F;
    //init procedures
    WDTCN = 0xDE;             // Disable watchdog timer
    WDTCN = 0xAD;
    OSCICN = 0xC2;
    XBR2 |= 0x40;              // Enable crossbar and weak pull-up

    spi_set_divisor(0);
    spiinit();
    lcdinit();

    while(1){
        while(!spicardpresent());
        if(!microSDinit()){
            lcdclear();
            lcdpos(0,0);
            lcdwrite("ERROR: microSD");
            lcdpos(1,0);
            lcdwrite("failure.");
        } else {
            microSDread(0x112358, buffer);
            lcdclear();
            lcdpos(0,0);
            lcdwrite(buffer);
            while(spicardpresent()){
//              dat = (SD_data) buffer;

                //output data to DAC
            }
        }
    }
    lol = microSDinit();

    do {
        lol = microSDread(0x112358, dat.wavedata);
        lcdwrite(dat.string);
        lcdpos(0, 0);
    } while(!lol);

    while(1);
    return 0;
}
