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
uint8_t song;
bit paused;

#define RESET_LCD() lcdclear(); lcdpos(0, 0)

#define EDITOR 0

int main(void){
    // variable declarations
    char idata foo;
    main_init();

    while(1){
        wait_for_sdcard();

        if(!microSDinit()){         // If initialization fails, print error.
            microSD_error();
        } else {
            spi_set_divisor(1);     // Set to max speed after initialisation
            readdir();              // Fill in numSongs and songSector[32]
            while(spicardpresent()){
                PCON |= 1;          // Power management setting
                play_song();
                query_kb();
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
}

void set_song(uint8_t song_num) {
    song = song_num;
    microSDread(songSector[song], (uint8_t *) header_ptr);

    // set stereo/mono
    switch(ntohs(header_ptr->numChannels)){
        case 2:
            dacstereo(1); // Stereo
            break;
        case 1:
        default:
            dacstereo(0); // Mono
            break;
    }

    // set sample rate
    dacrate(ntohl(header_ptr->sampleRate));
}

void play_song() {
    static int ping, pong;
    static uint32_t bytestoplay;
    static uint8_t xdata buffer[2][512];
    static uint32_t increment;
    static uint8_t mysong = -1;

    if (paused) {
        return;
    }

    // if it's a new song
    if (mysong != song) {
        bytestoplay = ntohl(header_ptr->subchunk2Size) - 404;
        increment = 0;
        ping = 0;
        pong = 1;

        if(!dacbusy()){
            //RIFF header + artist&title strings out of 512 B block
            dacplay(404, (uint8_t xdata *)(header_ptr + 108));
            mysong = song;
            show_track_name();
            microSDread(songSector[mysong] + (++increment), buffer[ping]);
        }
    }
    else {
        if(!dacbusy()){
            ping = pong;
            pong = 1-ping;  // To keep ahead of the DAC
            if(bytestoplay >= 512){
                dacplay(512, buffer[pong]);
                bytestoplay -= 512;
                microSDread(songSector[mysong] + (++increment), buffer[ping]);
            }else{
                dacplay(bytestoplay, buffer[pong]);
                bytestoplay = 0; // Done playing song.
                set_song(get_next_song(0));
            }
        }
    }
}

void get_next_song(uint8_t back) {
    if (back) {
        // loop around
        if (!song) {
            return numSongs - 1;
        }
        return (--song) % numSongs;
    }
    return (++song) % numSongs;
}

void show_track_name() {
    RESET_LCD();
    lcdwritei8(song);
    lcdwrite(":");
    lcdwrite(header_ptr->artist);
    lcdpos(1,0);
    lcdwrite(header_ptr->title);
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

void microSD_error() {
    RESET_LCD();
    lcdwrite("ERROR: microSD");
    lcdpos(1, 0);
    lcdwrite("failure.");
}

void displaySongInfo() {
    RESET_LCD();
    lcdwritei8(song); lcdwrite(":");
    lcdwrite(header_ptr->artist);
    lcdpos(1,0);
    lcdwrite(header_ptr->title);
}

void displayRateInfo() {
    RESET_LCD();
    lcdwritei16((uint16_t)ntohs(header_ptr->numChannels));
    lcdwrite(" ch");
    lcdpos(1,0);
    lcdwritei16((uint16_t)ntohl(header_ptr->sampleRate));
    lcdwrite(" bps.");
}

void query_kb() {
    static bit displayToggle = 0;

    switch(kbcheck()){
        case ' ':
            paused ^= 1;
            break;
        case 'd':
        case 'D':
            displayToggle ^= 1;
            if(displayToggle){
                displaySongInfo();
            } else {
                displayRateInfo();
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
            get_next_song(0);
            break;
        case 'l':
        case 'L':
            get_next_song(1);
            break;
        case '0':
        case ')':
            set_song(0);
            break;
        case '1':
        case '!':
            set_song(1);
            break;
        case '2':
        case '@':
            set_song(2);
            break;
        case '3':
        case '#':
            set_song(3);
            break;
        case '4':
        case '$':
            set_song(4);
            break;
        case '5':
        case '%':
            set_song(5);
            break;
        case '6':
        case '^':
            set_song(6);
            break;
        case '7':
        case '&':
            set_song(7);
            break;
        case '8':
        case '*':
            set_song(8);
            break;
        case '9':
        case '(':
            set_song(9);
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