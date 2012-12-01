/* ###
### bufptr type declared wrong
### TF2 not cleared
### glitch when bytesleft=0
### output could be scaled better
### balance, volume work partially
### */

/*  File: dacC.c
 *
 *  Description:
 */

#include <c8051f120.h>          // get SFR declarations
#include "types.h"
#include "dac.h"

void dacout(void);
extern bit dacactive;
extern uint16_t bytesleft;
extern uint8_t xdata *bufptr;     //##

bit isStereo;
int8_t volumeL;
int8_t volumeR;

void dac2init(void){
/*  initalizes any global variables used. */
    isStereo = 0;
    volumeL = 0;
    volumeR = 0;
}

void dacrate(uint16_t rate) {
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

void dacstereo(uint8_t channel) {
    isStereo = channel ? 1 : 0;
    return;
}

void dacvolume(int8_t ud) {
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

void dacbalance(int8_t lr) {
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
    TF2 = 0; //##
    //puts bytes in buffer to be played
    if(dacactive){
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
                bufptr++;
                SFRPAGE = 1;
                DACn = *bufptr;
                bufptr++;
                bytesleft--;
            } else {
                SFRPAGE = 0;
                DACn = *bufptr;
                SFRPAGE = 1;
                DACn = *bufptr;
                bufptr++;
            }
            bytesleft--;
            return;
        }
    }
}
