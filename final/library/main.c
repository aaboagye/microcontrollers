#include <c8051f120.h>           // Get SFR declarations
#include "types.h"
#include "spi.h"
#include "lcd.h"
#include "sd.h"
#include "dac.h"
#include "readdir.h"
#include "wav.h"

//#pragma code                        // Include ASM in .LST file
void kbinit ( void );
uint8_t kbcheck ( void );
void dacinit ( void );

extern uint8_t  xdata numSongs;      // Number of songs found
extern uint32_t xdata songSector[32];// Starting sector of each file.

int main(void){
    wav_header header;
    wav_header* header_ptr = &header;
    int current_sector = songSector[0];
    int i, ping, pong;
    uint32_t bytestoplay, bytesread;
    uint8_t xdata buffer[2][512];

    //init procedures
    SFRPAGE = 0x0F;
    WDTCN = 0xDE;                   // Disable watchdog timer
    WDTCN = 0xAD;
    OSCICN = 0xC2;
    XBR2 |= 0x40;                   // Enable crossbar and weak pull-up
    EA = 1;                         // Enable all interrupts
    spi_set_divisor(0);
    spiinit();
    lcdinit();
    kbinit();
    dacinit();
    dac2init();
    dacrate(11025);
    dacstereo(0);                   // Set number of channels to mono

/*
    while(1) {
        uint8_t temp[1];
        PCON |= 1;
        temp[0] = kbcheck();
        if (temp[0] == 13) {
            lcdclear();
            lcdpos(0,0);
        }
        else if (temp[0] == 8) {
            _lcdcmd(0x10);
            lcdwrite(" ");
            _lcdcmd(0x10);
        }
        else if (temp[0] != 255)
            lcdwrite(temp);
    }
*/

    while(1){
        while(!spicardpresent()){   // Wait until card is detected
            lcdpos(0,0);
            lcdwrite("Insert microSD");
            lcdpos(1,0);
            lcdwrite("card...");
        };
        if(!microSDinit()){         // If initialization fails, print error.
            lcdclear();
            lcdpos(0,0);
            lcdwrite("ERROR: microSD");
            lcdpos(1,0);
            lcdwrite("failure.");
        } else {
            spi_set_divisor(1);     // Set to max speed after initialisation
            readdir();              // Fill in numSongs and songSector[32]

            while(spicardpresent()){
                PCON |= 1;          // Power management setting
                for(i=0; i<numSongs; i++){
                    current_sector = songSector[i];
                    microSDread(current_sector, (uint8_t *) &header);
                    switch(ntohs(header.numChannels)){
                        case 2:
                            dacstereo(1); // Stereo
                        case 1:
                        default:
                            dacstereo(0); // Mono
                    }
                    dacrate(ntohl(header.sampleRate));
                    bytestoplay = ntohl(header.subchunk2Size);
                    lcdclear();
                    lcdpos(0,0);
                    lcdwrite((uint8_t *) i); lcdwrite(":");
                    lcdwrite(header.artist);
                    lcdpos(1,0);
                    lcdwrite(header.title);
                    if(!dacbusy()){
                        dacplay(404, (uint8_t xdata *)(header_ptr + 108));
                        //RIFF header + artist&title strings out of 512 B block
                    }
                    bytesread = 404;
                    bytestoplay -= 404;
                    ping = 0;
                    microSDread(current_sector + bytesread, buffer[ping]);
                    // Well, we stop playing when bytestoplay = 0. If not, read
                    while(bytestoplay > 0){
                        pong = ping;
                        ping = 1-pong;  // To keep ahead of the DAC
                        if(!dacbusy()){
                            if(bytestoplay >= 512){
                                dacplay(512, buffer[pong]);
                                bytestoplay -= 512;
                                bytesread += 512;
                            }else{
                                dacplay(bytestoplay, buffer[pong]);
                                bytestoplay = 0; // Done playing song.
                            }
                            microSDread(current_sector + bytesread, buffer[ping]);
                            switch(kbcheck()){
                                case '+':
                                    dacvolume(1);
                                    break;
                                case '-':
                                    dacvolume(0);
                                    break;
                                case '>':
                                    dacbalance(0);
                                    break;
                                case '<':
                                    dacbalance(1);
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
            }
        }
    }
    return 0;
}
