#ifndef _DAC_H
#define _DAC_H
#include "types.h"

void dac2init(void);
void dacrate(uint16 rate);
void dacstereo(uint8 channel);
void dacvolume(int8 ud);
void dacbalance(int8 lr);
void dacinit(void);
uint8 dacbusy(void);
void dacplay(uint16 count, uint8 xdata *buffer);

// SFRs: 16-bit little endian. SFRL and SFRH
sfr16 RCAP2  = 0xCA;
sfr16 DACnCN = 0xD4; // DAC0: SFRPAGE 0, DAC1: SFRPAGE 1
sfr16 DACn   = 0xD2;

#define MAX_VOLUME 2
#define MIN_VOLUME -2

#endif
