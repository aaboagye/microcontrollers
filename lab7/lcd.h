#ifndef LCD_H_
#define LCD_H_

#include "types.h"

// functions
void lcdinit();
void lcdwrite(uint8_t *str);
void lcdwritec(uint8_t __code *str);
void lcdwritex(uint8_t __xdata *str);
void lcdpos(uint8_t row, uint8_t col);
void lcdcursor(uint8_t mode);
void lcdclear();


#endif
