#ifndef LCD_H_
#define LCD_H_

#include "types.h"

// functions
void lcdinit();
void lcdwritec(uint8_t code *str);
void lcdwritex(uint8_t xdata *str);
void lcdpos(uint8_t row, uint8_t col);
void lcdcursor(uint8_t mode);
void lcdclear();


#endif