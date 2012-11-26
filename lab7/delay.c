#include "delay.h"

void delay_ms(const float t) {
    const int cycles = (t * (1. / 1000.) * (float)CPUCLK) + 1;

    int i;
    for (i = 0; i <= cycles; ++i) {} // wait
}

void delay_us(const float t) {
    const int cycles = (t * (1. / 1000000.) * (float)CPUCLK) + 1;

    int i;
    for (i = 0; i <= cycles; ++i) {} // wait
}
