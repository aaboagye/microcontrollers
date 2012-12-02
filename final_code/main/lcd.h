#ifndef LCD_H_
#define LCD_H_

#include "types.h"

// functions
void lcdinit();
void lcdwrite(uint8_t *str);
void lcdwritec(uint8_t code *str);
void lcdwritex(uint8_t xdata *str);
void lcdwritei8(uint8_t i);         // display an 8-bit number
void lcdwritei16(uint16_t i);       // display a 16-bit number

void lcdpos(uint8_t row, uint8_t col);
void lcdcursor(uint8_t mode);
void lcdclear();

void _lcddata(uint8_t d);           // write data to MPU, wait for busy state to complete
void _lcdcmd(uint8_t d);

#endif
