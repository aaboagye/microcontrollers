/*  File: dacC.c
 *
 *  Description:
 */

#include <c8051f120.h>          // get SFR declarations
#include "types.h"
#include "dac.h"

void dacout(void) interrupt 5;

void dac2init(void){
/*  initalizes any global variables used. */
    isStereo = 0;
    volumeL = 0;
    volumeR = 0;
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
            DACnCN--;
            SFRPAGE = 1;
            DACnCN--;
        }
    }
    else {
      //decrease volume
        if(volumeL > MIN_VOLUME && volumeR > MIN_VOLUME){
            volumeL--; volumeR--;
            SFRPAGE = 0;
            DACnCN++;
            SFRPAGE = 1;
            DACnCN++;
        }
    }
}

void dacbalance(int8 lr) {
    if (lr > 0) { // left++, right--
        if (volumeL < MAX_VOLUME && volumeR > MIN_VOLUME) {
            volumeL++; volumeR--;
            SFRPAGE = 0;
            DACnCN--;
            SFRPAGE = 1;
            DACnCN++;
        }
    }
    else { // left--, right++
        if(volumeL > MIN_VOLUME && volumeR < MAX_VOLUME){
            volumeL--; volumeR++;
            SFRPAGE = 0;
            DACnCN++;
            SFRPAGE = 1;
            DACnCN--;
        }
    }
}

void dacout(void) interrupt 5 {
    //puts bytes in buffer to be played
    if(!dacactive){
        if(bytesleft == 0){
            SFRPAGE = 0;
            DACn = 0x80;
            SFRPAGE = 1;
            DACn = 0x80;
            dacactive = 0;
        } else {
            if(isStereo){
                //write to DAC0 data at bufptr
                SFRPAGE = 0;
                DACn = *bufptr;
                SFRPAGE = 1;
                DACn = *(bufptr + (sizeof *bufptr)); //i think...
            } else {
                SFRPAGE = 0;
                DACn = *bufptr;
                SFRPAGE = 1;
                DACn = *bufptr;
            }
            bytesleft--;
            return;
        }
    }
}
