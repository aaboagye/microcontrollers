#include <c8051f120.h>          // get SFR declarations
#include "lcd.h"

int main() {
    lcdinit();
    lcdwrite("lol test");
    
    return 0;
}