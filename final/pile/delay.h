#ifndef DELAY_H_
#define DELAY_H_

#include "types.h"

#define CPUCLK  12250000    // SYSCLK in Hz

void delay_ms(const uint8_t t);
void delay_us(const uint8_t t);

#endif