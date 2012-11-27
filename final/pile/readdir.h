#ifndef _READDIR_H
#define _READDIR_H
#include "types.h"

void readdir();
extern uint8_t __xdata numSongs; // number of songs found
extern uint32_t __xdata songSector[32]; // starting sector of each file

#endif
