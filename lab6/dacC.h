#ifndef _DACC_H
#define _DACC_H

void dac2init(void);
void dacrate(uint16 rate);
void dacstereo(uint8 channel);
void dacvolume(int8 ud);
void dacbalance(int8 lr);
void dacout(void) interrupt 0; /* NOTE: 0 is a placeholder for actual interrupt

sfr16 RCAP2 = 0xCA; /* little endian. RCAP2L and RCAP2H */
bit isStereo = 0;
#endif
