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
    //
}

void dacbalance(int8 lr) {
    //
}

void dacout(void) interrupt 0 {
    //
}
