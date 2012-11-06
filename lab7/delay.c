#include "delay.h"

void delay_ms(const double t) {
    const int cycles = (t * (1. / 1000.) * (double)CPUCLK) + 1;

    for (int i = 0; i <= cycles; ++i) {
        // waiting!
    }
}

void delay_us(const double t) {
    const int cycles = (t * (1. / 1000000.) * (double)CPUCLK) + 1;

    for (int i = 0; i <= cycles; ++i) {
        // waiting!
    }
}