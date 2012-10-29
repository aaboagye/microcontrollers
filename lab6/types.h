typedef unsigned char uint8;
typedef char int8;
typedef unsigned short uint16;
typedef short int16;
typedef unsigned long uint32;
typedef long int32;

void dac2init(void);
void dacrate(uint16 rate);
void dacstereo(uint8 channel);
void dacvolume(int8 ud);
void dacbalance(int8 lr);
void dacout(void) interrupt 0; /* NOTE: 0 is a placeholder for actual interrupt

sfr16 RCAP2 = 0xCA; /* little endian. RCAP2L and RCAP2H */
bit isStereo = 0;
