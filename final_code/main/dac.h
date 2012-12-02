#ifndef _DAC_H
#define _DAC_H
#include "types.h"

void dac2init(void);
void dacrate(uint16_t rate);
void dacstereo(uint8_t channel);
void dacvolume(int8_t ud);
void dacbalance(int8_t lr);
void dacinit(void);
uint8_t dacbusy(void);
void dacplay(uint16_t count, uint8_t xdata *buffer);

#endif
