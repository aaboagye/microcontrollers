#include <C8051F120.h>          // get SFR declarations
#include "lcd.h"

int main() {
    lcdinit();
    lcdwritec("newstring");
    lcdpos(1,0);
    lcdwrite("!@#$");
    while(1);
    return 0;
}
