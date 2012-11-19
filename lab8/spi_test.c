#include <c8051f120.h>           // Get SFR declarations
#include "types.h"
#include "spi.h"
#include "lcd.h"
#include "sd.h"
#include "dac.h"

#pragma code                        // Include ASM in .LST file

int main(void){
    SD_data xdata dat;
    uint8_t xdata buffer[512];

    //init procedures
    SFRPAGE = 0x0F;
    WDTCN = 0xDE;                   // Disable watchdog timer
    WDTCN = 0xAD;
    OSCICN = 0xC2;
    XBR2 |= 0x40;                   // Enable crossbar and weak pull-up
    EA = 1;                         // Enable all interrupts
    spi_set_divisor(0);
    spiinit();
    lcdinit();
    kbinit();
    dacinit();
    dac2init();
    dacrate(11025);
    dacstereo(0);                   // Set number of channels to mono

    while(1){
        while(!spicardpresent());   // Wait until card is detected
        if(!microSDinit()){         // If initialization fails, print error.
            lcdclear();
            lcdpos(0,0);
            lcdwrite("ERROR: microSD");
            lcdpos(1,0);
            lcdwrite("failure.");
        } else {
            spi_set_divisor(1);     // Set to max speed after initialisation
            microSDread(0x112358, (uint8_t *) dat);
            lcdclear();
            lcdpos(0,0);
            lcdwrite(dat.string);
            while(spicardpresent()){
                PCON |= 1;
                if(!dacbusy()){
                    dacplay(dat.len, dat.wavedata); //output to DAC
                }
            }
        }
    }
    return 0;
}
