
<!-- saved from url=(0123)https://pacific.rsmart.com/access/content/group/4ea8b18c-4b5b-4c36-92c5-024eea981c29/Fall%202012%20Lecture%20slides/prefs.h -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><script>window["_GOOG_TRANS_EXT_VER"] = "1";</script></head><body class=" hasGoogleVoiceExt"><pre style="word-wrap: break-word; white-space: pre-wrap;">#ifndef _PREFSH
#define _PREFSH
#include &lt;types.h&gt;

typedef struct {
  uint16 backupBlock;           // block where current backup data is stored
} prefData;

typedef struct {
  uint8 backupCount2;           // block write counter, byte 2
  uint16 backupCount;           // block write counter, bytes 1-0
  uint8 status;                 // status bits: playing, etc
  uint8 song;                   // active song number
  uint16 time;                  // time in seconds for current song
  uint8 cksum;                  // checksum
} backupData;

// Initialize Flash EEPROM for project.  This only need to be called once, or
// if things get messed up.
void blockInit(void);

// read preferences to Flash EEPROM
void prefRead(prefData xdata *ptr); 
// write preferences from Flash EEPROM
void prefWrite(prefData xdata *ptr); 

// read backup data from block
void backupRead(uint16 block, backupData xdata* buffer);
// write backup data from block, updating if necessary
uint8 backupWrite(uint16 block, backupData xdata* buffer);
// enable backup timer
void backupTimer(uint8 enable);



#endif          // _PREFSH
</pre></body></html>