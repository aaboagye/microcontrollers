#ifndef _DACC_H
#define _DACC_H

void dac2init(void);
void dacrate(uint16 rate);
void dacstereo(uint8 channel);
void dacvolume(int8 ud);
void dacbalance(int8 lr);
void dacout(void) interrupt 0; // NOTE: 0 is a placeholder for actual interrupt

bit isStereo;
int8 volumeL;
int8 volumeR;

// SFRs: 16-bit little endian. SFRL and SFRH
sfr16 RCAP2   = 0xCA;
sfr16 DACnCN  = 0xD4;
sfr16 DACn    = 0xD2;

#define MAX_VOLUME 3
#define MIN_VOLUME -3

#endif
