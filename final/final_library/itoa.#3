#include "itoa.h"

#define TRUNC(n) if (i > n - 1) { a[p++] = i / n + 0x30; i %= n; }

void itoa8(uint8_t i, char *a) {
    uint8_t p = 0;
    // char* a = "\0\0\0\0";

    TRUNC(100);
    TRUNC(10);
    a[p] = i + 0x30;
}

void itoa16(uint16_t i, char *a) {
    uint8_t p = 0;
    // max is 65,535

    TRUNC(10000);
    TRUNC(1000);
    TRUNC(100);
    TRUNC(10);
    a[p] = i + 0x30;
}

void itoa32(uint32_t i, char *a) {
    uint32_t p = 0;
    // max is 4,294,967,295

    TRUNC(1000000000);
    TRUNC(100000000);
    TRUNC(10000000);
    TRUNC(1000000);
    TRUNC(100000);
    TRUNC(10000);
    TRUNC(1000);
    TRUNC(100);
    TRUNC(10);
    a[p] = i + 0x30;
}
