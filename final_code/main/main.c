#include <c8051f120.h>           // Get SFR declarations
#include "types.h"
#include "spi.h"
#include "lcd.h"
#include "sd.h"
#include "dac.h"
#include "readdir.h"
#include "utils.h"
#include "wav.h"

//#pragma code                        // Include ASM in .LST file
void kbinit ( void );
uint8_t kbcheck ( void );
void dacinit ( void );
//void run_ed(char *buffer, uint8_t size);
void wait_for_sdcard();
void main_init();
void query_kb();

extern uint8_t  xdata numSongs;       // Number of songs found
extern uint32_t xdata songSector[32]; // Starting sector of each file.
wav_header xdata *header_ptr;
bit displayToggle;
uint8_t song;

#define RESET_LCD() lcdclear(); lcdpos(0, 0)

#define EDITOR 0

int main(void){
    // variable declarations
    char idata foo;
    uint32_t xdata current_sector = songSector[0];
    int ping, pong;
    uint32_t bytestoplay, bytesread;
    uint8_t xdata buffer[2][512];
    uint32_t increment = 1;
    main_init();

    while(1){
        wait_for_sdcard();

        if(!microSDinit()){         // If initialization fails, print error.
            RESET_LCD();
            lcdwrite("ERROR: microSD");
            lcdpos(1, 0);
            lcdwrite("failure.");
        } else {
            spi_set_divisor(1);     // Set to max speed after initialisation
            readdir();              // Fill in numSongs and songSector[32]
            while(spicardpresent()){
                PCON |= 1;          // Power management setting
                for(song; song<numSongs; song++){
                    current_sector = songSector[song];
                    microSDread(current_sector, (uint8_t *) header_ptr);
                    switch(ntohs(header_ptr->numChannels)){
                        case 2:
                            dacstereo(1); // Stereo
                            break;
                        case 1:
                        default:
                            dacstereo(0); // Mono
                            break;
                    }
					dacrate(ntohl(header_ptr->sampleRate));
                    //dacrate(ntohs(header_ptr->sampleRate));
                    bytestoplay = ntohl(header_ptr->subchunk2Size);
                    RESET_LCD();
                    lcdwritei8(song);
                    lcdwrite(":");
                    lcdwrite(header_ptr->artist);
                    lcdpos(1,0);
                    lcdwrite(header_ptr->title);
                    if(!dacbusy()){
                        dacplay(404, (uint8_t xdata *)(header_ptr + 108));
                        //RIFF header + artist&title strings out of 512 B block
                    }
                    bytesread = 404;
                    bytestoplay -= 404;
                    ping = 0;
                    microSDread(current_sector + bytesread, buffer[pong]);
                    increment = 1;
                    // Well, we stop playing when bytestoplay = 0. If not, read
                    while(bytestoplay > 0){
                        if(!dacbusy()){
                            if(bytestoplay >= 512){
                                dacplay(512, buffer[pong]);
                                ping = pong;
                                pong = 1-ping;  // To keep ahead of the DAC
                                bytestoplay -= 512;
                                bytesread += 512;
                            }else{
                                dacplay(bytestoplay, buffer[pong]);
                                bytestoplay = 0; // Done playing song.
                            }
                            microSDread(current_sector + increment, buffer[ping]);
                            ++increment;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

void main_init() {
    SFRPAGE = 0x0F;
    WDTCN = 0xDE;
    WDTCN = 0xAD;
    XBR2 |= 0x40;
    XBR1 |= 0x20;
    XBR0 |= 0x03;
    OSCICN = 0xC2;
    EA = 1;
    kbinit();
    dacinit();
    dac2init();
    lcdinit();
    spiinit();
    spi_set_divisor(0);
    displayToggle = 0;
}

void wait_for_sdcard() {
    if(!spicardpresent()){
            lcdpos(0,0);
            lcdwrite("Insert microSD");
            lcdpos(1,0);
            lcdwrite("card...");    // Only write once.
        }

    while(!spicardpresent());   // Wait until card is detected
}

void query_kb() {
    switch(kbcheck()){
        case 'd':
        case 'D':
            RESET_LCD();
            displayToggle ^= 1;
            if(displayToggle){
                lcdwritei8(song); lcdwrite(":");
                lcdwrite(header_ptr->artist);
                lcdpos(1,0);
                lcdwrite(header_ptr->title);
            } else {
                lcdwritei16((uint16_t)ntohs(header_ptr->numChannels));
                lcdpos(1,0);
                lcdwritei16((uint16_t)ntohl(header_ptr->sampleRate));
                lcdwrite(" bps.");
            }
            break;
        case '+':
        case '=':
            dacvolume(1);
            break;
        case '-':
        case '_':
            dacvolume(0);
            break;
        case '>':
        case '.':
            dacbalance(0);
            break;
        case '<':
        case ',':
            dacbalance(1);
            break;
        case 'n':
        case 'N':
            ++song;
            song %= numSongs-1; //next song with wrap around
            break;
        case 'l':
        case 'L':
            --song;
            song %= numSongs-1; //previous song with wrap
            break;
        case '0':
        case ')':
            song = 0;
            break;
        case '1':
        case '!':
            song = 1;
            break;
        case '2':
        case '@':
            song = 2;
            break;
        case '3':
        case '#':
            song = 3;
            break;
        case '4':
        case '$':
            song = 4;
            break;
        case '5':
        case '%':
            song = 5;
            break;
        case '6':
        case '^':
            song = 6;
            break;
        case '7':
        case '&':
            song = 7;
            break;
        case '8':
        case '*':
            song = 8;
            break;
        case '9':
        case '(':
            song = 9;
            break;
        default:
            break;
    }
}

#if EDITOR
void run_ed(char *buffer, uint8_t size) {
    uint8_t temp;
    uint8_t i = 0;

    do {
        temp = kbcheck();
        if (temp == 8 && i > 0) {
            _lcdcmd(0x10);
            _lcddata(' ');
            _lcdcmd(0x10);
            buffer[--i] = temp;
        }
        else if (temp != 255 && i < size) {
            buffer[i++] = temp;
            _lcddata(temp);
        }
    } while(temp != 13);

    RESET_LCD();
}
#endif