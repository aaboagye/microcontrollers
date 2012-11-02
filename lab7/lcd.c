#include <avr/io.h>
#include <stdint.h>
#include <util/delay.h>

// pin declarations
#define RS_POS      PC5
#define RS_PORT     PORTC
#define RS_DDR      DDRC

#define RW_POS      PC4
#define RW_PORT     PORTC
#define RW_DDR      DDRC

#define E_POS       PC3
#define E_PORT      PORTC
#define E_DDR       DDRC

#define DATA_POS    0
#define DATA_PORT   PORTD
#define DATA_DDR    DDRD
#define DATA_PIN    PIND

// useful macros
#define SET_E()     (E_PORT |=(1<<E_POS))
#define SET_RS()    (RS_PORT|=(1<<RS_POS))
#define SET_RW()    (RW_PORT|=(1<<RW_POS))

#define CLEAR_E()   (E_PORT &=(~(1<<E_POS)))
#define CLEAR_RS()  (RS_PORT&=(~(1<<RS_POS)))
#define CLEAR_RW()  (RW_PORT&=(~(1<<RW_POS)))

#define SET_DATA(d) (DATA_PORT=((d)<<DATA_POS))
#define GET_DATA()  (DATA_PIN)

#define _lcddata(d) (_lcdw(1, d))
#define _lcdcmd(d)  (_lcdw(0, d))
#define LCDClear()  (_lcdcmd(0x01))
#define LCDHome()   (_lcdcmd(0x02))


// timings in us
#define T_AS        0.06
#define PW_EH       0.5
#define T_DSW       0.2
#define T_AH        0.02
#define T_DDR       0.4

void _mpuw(uint8_t rs, uint8_t data);  // write data to MPU
uint8_t _mpur(uint8_t rs);             // read data from MPU
void _lcdw(uint8_t rs, uint8_t data);  // write data to MPU, wait for busy state to complete
void busyWait();
void LCDInit();

void _mpuw(uint8_t rs, uint8_t data) {
    if (rs == 1) {
        SET_RS();
    }
    else {
        CLEAR_RS();
    }
    CLEAR_RW();
    _delay_us(T_AS);

    SET_E();
    _delay_us(PW_EH - T_DSW);
    
    SET_DATA(data);
    _delay_us(T_DSW);

    CLEAR_E();
    _delay_us(T_AH);
}

uint8_t _mpur(uint8_t rs) {
    if (rs == 1) {
        SET_RS();
    }
    else {
        CLEAR_RS();
    }
    SET_RW();
    _delay_us(T_AS);

    SET_E();
    _delay_us(T_DDR);
    
    uint8_t data = GET_DATA();
    _delay_us(PW_EH - T_DDR);

    CLEAR_E();
    _delay_us(T_AH);

    return data;
}

void _lcdw(uint8_t rs, uint8_t data) {
    busyWait();
    _mpuw(rs, data);
}

void busyWait() {
    uint8_t data;
    do {
        data = _mpur(0); // read data with RS = 0
    } while (data & 0x80); // we only care about the MSB (busy flag), loop while busy
}

void LCDInit() {
    const uint8_t setup_flags = 0x38; // function set: 8-bit mode, 2 lines, 5x8 font

    // set up ports in write mode
    DATA_DDR|=(0xFF<<DATA_POS);
    E_DDR   |=(1<<E_POS);
    RS_DDR  |=(1<<RS_POS);
    RW_DDR  |=(1<<RW_POS);

    // initialization stuff
    _delay_ms(45);
    _mpuw(0, setup_flags);

    _delay_ms(5);
    _mpuw(0, setup_flags);

    _delay_ms(0.2);
    _mpuw(0, setup_flags);

    // set up modes
    _delay_us(50);
    _mpuw(0, setup_flags);

    _delay_us(50);
    _mpuw(0, 0x08); // display off

    _delay_us(50);
    _mpuw(0, 0x01); // display clear

    _delay_us(50);
    _mpuw(0, 0x06); // entry mode set: increment, S=0?

    busyWait();
    _lcdcmd(0x0F); // display on, cursor on, blinking cursor
    LCDHome();
}

void main() {
    LCDInit();
    _lcddata('a');
}