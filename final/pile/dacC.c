// all __code seems to be functional

// volume control:  take 8-bit value DAC and shift left 4 bits; write these
// bits into DACnH and DACnL.   volume then controls bits 0-2 of DACnCN.  max
// volume = 000, min volume = 100;

#include <C8051F120.h>
#include "types.h"

extern __bit dacactive;
extern uint16_t bytesleft;
extern uint8_t __xdata *bufptr;

static __bit isStereo;
static int8_t volumeL, volumeR;

/*sfr16 RCAP2 = 0xca;
sfr16 TMR2 = 0xcc;*/
__sfr16 __at (0xD2) DAC;

#define RATE8K   -1531          // 12.25MHz/1531 = 8.001KHz (0.16% error)
#define RATE11K  -1111          // 12.25MHz/1111 = 11.026KHz (0.01% error)
#define RATE22K  -555           // 12.25MHz/555 = 22.072KHz (0.10% error)

static void dacout (void) __interrupt (5)
{
  uint8_t valL = 0x80;
  uint8_t valR = 0x80;
  TF2 = 0;                      // clear interrupt flag
  if( dacactive ) {             // if more data to send
    valL = *bufptr++;
    if (isStereo) {
      valR = *bufptr++;
      bytesleft -= 2;           // dec the byte count
    } else {
      valR = valL;
      bytesleft -= 1;           // dec the byte count
    }
    if ( !bytesleft ) {
      dacactive = 0;            // clear busy flag
    }
  }
  SFRPAGE = DAC1_PAGE;
  DAC = ((uint16_t)valR) << 4;    // set the right DAC
  SFRPAGE = DAC0_PAGE;
  DAC = ((uint16_t)valL) << 4;    // set the left DAC
}

#define MAXVOL   4

static void setVolL( int8_t vol )
{
  if (volumeL+vol >= 0 && volumeL+vol <= MAXVOL) {
    volumeL += vol;
    SFRPAGE = DAC0_PAGE;
    DAC0CN &= 0xf8;
    DAC0CN |= (MAXVOL-volumeL);
  }
}

static void setVolR( int8_t vol )
{
  if (volumeR+vol >= 0 && volumeR+vol <= MAXVOL) {
    volumeR += vol;
    SFRPAGE = DAC1_PAGE;
    DAC1CN &= 0xf8;
    DAC1CN |= (MAXVOL-volumeR);
    SFRPAGE = DAC0_PAGE;
  }
}

// This procedure initializes global variables used by for your C __code.
void dac2init (void)
{
  volumeL = volumeR = 2;
  setVolL( 0 );
  setVolR( 0 );
  isStereo = 0;
}

// This procedure sets the Timer 2 reload value based on the frequency
// parameter. rate will be one of 8000, 11025, or 22050.

void dacrate( uint16_t rate ) {
  if ( rate == 8000 ) {
    RCAP2 = TMR2 = RATE8K;
  } else if ( rate == 11025 ) {
    RCAP2 = TMR2 = RATE11K;
  } else if ( rate == 22050 ) {
    RCAP2 = TMR2 = RATE22K;
  }
  dacactive = 0;
}

// This procedure sets the number of channels (1 or 2) for the song in the
// global variable isStereo. If channel is zero then the sound is set for
// mono, otherwise it is set for stereo.

void dacstereo( uint8_t channels )
{
  isStereo = !(channels == 0);
  dacactive = 0;
}


// This routine increases or decreases the volume level and sets global
// variables volumeL and volumeR (i.e., the amplitude of the DAC outputs). A
// positive value increases the volume, a negative value decreases it. If
// the volume of either channels is at the maximum or minimum, it has no
// effect. Your __code should support at least three volume levels (you may
// want to include more, which is OK, just don't go nuts).

void dacvolume(int8_t ud)
{
  if (ud > 0) {
    setVolL( +1 );
    setVolR( +1 );
  } else if (ud < 0) {
    setVolL( -1 );
    setVolR( -1 );
  }
}

// This procedure changes the balance between the left and right
// channels. A positive value increases the difference of the left over
// the right, a negative value increases the difference of the right over
// the left. It examines the left and right volumes and if the change would
// set a channel past the minimum or maximum, it has no effect.

void dacbalance(int8_t lr)
{
  if (lr >= 0) {
    if (volumeL <= MAXVOL && volumeR >= 0) {
      setVolL( +1 );
      setVolR( -1 );
    }
  } else {
    if (volumeR <= MAXVOL && volumeL >= 0) {
      setVolL( -1 );
      setVolR( +1 );
    }
  }
}

