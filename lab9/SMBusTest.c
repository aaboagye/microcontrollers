
<!-- saved from url=(0127)https://pacific.rsmart.com/access/content/group/4ea8b18c-4b5b-4c36-92c5-024eea981c29/Fall%202012%20Lecture%20slides/SMBusTest.c -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><script>window["_GOOG_TRANS_EXT_VER"] = "1";</script></head><body class=" hasGoogleVoiceExt"><pre style="word-wrap: break-word; white-space: pre-wrap;">#include &lt;c8051F120.h&gt;

typedef unsigned char uint8;
typedef unsigned short uint16;

void kbinit(void);
void dacinit(void);
void dac2init(void);

void smbus_setup (void);
void smbus_send (uint16 eepromaddr, uint8 len, uint8 xdata * buffer);
void smbus_receive (uint16 eepromaddr, uint8 len, uint8 xdata * buffer);

static uint8 xdata SMBbuf[16];
static uint8 xdata str1[] = "test string #1";
static uint8 xdata str2[] = "smbus test";

void smbus_init( void )
{
// YOUR INITIALIZATION CODE GOES HERE
}

void main(void)
{

// enable other hardware
  WDTCN = 0xde;
  WDTCN = 0xad;
  SFRPAGE = 0x0f;
  XBR2 = 0x40;
  XBR0 = 0x02;
  OSCICN = 0xc2;
  SFRPAGE = 0x00;
  SPI0CFG = 0x40;
  NSSMD1 = NSSMD0 = 0;

// enable your other modules
  kbinit(  );
  dacinit(  );
  dac2init(  );
  smbus_init(  );
  smbus_setup( );

  EA = 1;

  // write two strings to FLASH, then read them back into buffer
  smbus_send (0x107, sizeof(str1), str1);
  smbus_send (0x9eb, sizeof(str2), str2);
  smbus_receive (0x107, sizeof(SMBbuf), SMBbuf);
  smbus_receive (0x9eb, sizeof(SMBbuf), SMBbuf);
  while (1) {}
}
</pre></body></html>