#include "delay.h"

void delay_ms(const uint8_t t) {
    const int cycles = ((uint32_t)t * (uint32_t)CPUCLK) / (uint32_t)1000 + 1;

    int i;
    for (i = 0; i <= cycles; ++i) {} // wait
}

void delay_us(const uint8_t t) {
    const int cycles = ((uint32_t)t * (uint32_t)CPUCLK) / (uint32_t)1000000 + 1;

    int i;
    for (i = 0; i <= cycles; ++i) {} // wait
}