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

// SFRs: 16-bit little endian. SFRL and SFRH
sfr16 RCAP2 = 0xCA;
sfr16 TMR2  = 0xCC;
sfr16 DACn  = 0xD2;

#define MAX_VOLUME 5
#define MIN_VOLUME 0

#define RATE8K  -1531
#define RATE11K -1111
#define RATE22K -555

#define VOLUMELUP()     do { volumeL++; SFRPAGE=0; DAC0CN--; } while(0)
#define VOLUMERUP()     do { volumeR++; SFRPAGE=1; DAC1CN--; } while(0)
#define VOLUMELDOWN()   do { volumeL--; SFRPAGE=0; DAC0CN++; } while(0)
#define VOLUMERDOWN()   do { volumeR--; SFRPAGE=1; DAC1CN++; } while(0)

#define SETL(data)      do { SFRPAGE=0; DACn=(((uint16_t)(data)) << 4); } while(0)
#define SETR(data)      do { SFRPAGE=1; DACn=(((uint16_t)(data)) << 4); } while(0)

void dac2init(void){
/*  initalizes any global variables used. */
    isStereo = 0;
    volumeL = 0;
    volumeR = 0;
}

void dacrate(uint16_t rate) {
    switch(rate){
        case 8000:
            RCAP2 = TMR2 = RATE8K; // 0.47% percent error
            break;
        case 11025:
            RCAP2 = TMR2 = RATE11K; // 0.64% percent error
            break;
        case 22050:
            RCAP2 = TMR2 = RATE22K; // 0.64% percent error
            break;
        default:
            RCAP2 = TMR2 = RATE8K; /* default to 8KHz sampling */
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
            VOLUMELUP();
            VOLUMERUP();
        }
    }
    else {
      //decrease volume
        if(volumeL > MIN_VOLUME && volumeR > MIN_VOLUME){
            VOLUMELDOWN();
            VOLUMERDOWN();
        }
    }
}

void dacbalance(int8_t lr) {
    if (lr > 0) { // left++, right--
        if (volumeL < MAX_VOLUME && volumeR > MIN_VOLUME) {
            VOLUMELUP();
            VOLUMERDOWN();
        }
    }
    else { // left--, right++
        if(volumeL > MIN_VOLUME && volumeR < MAX_VOLUME){
            VOLUMELDOWN();
            VOLUMERUP();
        }
    }
}

void dacout(void) interrupt 5 {
    TF2 = 0; //##
    //puts bytes in buffer to be played
    if(dacactive){
        if(bytesleft == 0){
            SETL(0x80);
            SETR(0x80);
            dacactive = 0;
        } else {
            if(isStereo){
                //write to DAC0 data at bufptr
                SETL(*bufptr);
                bufptr++;
                SETR(*bufptr);
                bufptr++;
                bytesleft--;
            } else {
                SETL(*bufptr);
                SETR(*bufptr);
                bufptr++;
            }
            bytesleft--;
            return;
        }
    }
}
