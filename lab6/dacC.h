#ifndef _DACC_H
#define _DACC_H

void dac2init(void);
void dacrate(uint16 rate);
void dacstereo(uint8 channel);
void dacvolume(int8 ud);
void dacbalance(int8 lr);
void dacout(void) interrupt 0; // NOTE: 0 is a placeholder for actual interrupt

sfr16 RCAP2; /* little endian. RCAP2L and RCAP2H */
bit isStereo;
int8 volumeL;
int8 volumeR;
sfr16 DAC0CN;
sfr16 DAC1CN;
sfr16 SFRPAGE;
#define MAX_VOLUME 3
#define MIN_VOLUME -3

#endif
