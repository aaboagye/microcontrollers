/*  File: dacC.c
 *
 *  Description:
 */

#include <c8051f120.h>          // get SFR declarations
#include "types.h"
#include "dacC.h"


void dac2init(void){
/*  initalizes any global variables used. */
    isStereo = 0;
    volumeL = 0;
    volumeR = 0;
    RCAP2 = 0xCA;
    DACnCN = 0xD4;
    SFRPAGE = 0x84;
}

void dacrate(uint16 rate) {
    switch(rate){
        case 8000:
            RCAP2 = -128; // 0.47% percent error
            break;
        case 11025:
            RCAP2 = -93; // 0.64% percent error
            break;
        case 22050:
            RCAP2 = -46; // 0.64% percent error
            break;
        default:
            RCAP2 = -128; /* default to 8KHz sampling */
    }
    return;
}

void dacstereo(uint8 channel) {
    isStereo = channel ? 1 : 0;
    return;
}

void dacvolume(int8 ud) {
    if (ud > 0) {
      //increase volume
        if (volumeL < MAX_VOLUME && volumeR < MAX_VOLUME) {
            volumeL++; volumeR++;
            SFRPAGE = 0;
            DACnCN << 1;
            SFRPAGE = 1;
            DACnCN << 1;
        }
    }
    else {
      //decrease volume
        if(volumeL > MIN_VOLUME && volumeR > MIN_VOLUME){
            volumeL--; volumeR--;
            SFRPAGE = 0;
            DACnCN >> 1;
            SFRPAGE = 1;
            DACnCN >> 1;
        }
    }
}

void dacbalance(int8 lr) {
    //
}

void dacout(void) interrupt 0 {
    //
}
