?_MICROSDREAD?BYTE		EQU		0023H
public		?_MICROSDREAD?BYTE
CSEG AT 0003H
DS      3
CSEG AT 002BH
DS      3
BUFPTR		EQU		0046H
public		BUFPTR
BYTESLEFT		EQU		0044H
public		BYTESLEFT
DACACTIVE		EQU		0022H.2
public		DACACTIVE
DACBUSY		EQU		4BC0H
public		DACBUSY
DACINIT		EQU		4B7CH
public		DACINIT
_DACPLAY		EQU		4BC9H
public		_DACPLAY
dacout		EQU		4884H
public		dacout
ADC0CN		EQU		00E8H
public		ADC0CN
SFRPAGE		EQU		0084H
public		SFRPAGE
IE		EQU		00A8H
public		IE
dac2init		EQU		4E35H
public		dac2init
PCA0CN		EQU		00D8H
public		PCA0CN
IP		EQU		00B8H
public		IP
_dacstereo		EQU		4E0EH
public		_dacstereo
SMB0CN		EQU		00C0H
public		SMB0CN
_dacvolume		EQU		4ABCH
public		_dacvolume
CPT0CN		EQU		0088H
public		CPT0CN
SPI0CN		EQU		00F8H
public		SPI0CN
DACn		EQU		00D2H
public		DACn
_dacrate		EQU		4CC9H
public		_dacrate
TMR2CN		EQU		00C8H
public		TMR2CN
DACnCN		EQU		00D4H
public		DACnCN
TF2		EQU		00C8H.7
public		TF2
isStereo		EQU		0022H.3
public		isStereo
_dacbalance		EQU		4B1DH
public		_dacbalance
RCAP2		EQU		00CAH
public		RCAP2
SCON0		EQU		0098H
public		SCON0
volumeL		EQU		0052H
public		volumeL
volumeR		EQU		0053H
public		volumeR
PSW		EQU		00D0H
public		PSW
_delay_ms		EQU		4C5EH
public		_delay_ms
_delay_us		EQU		4C26H
public		_delay_us
_itoa8		EQU		49D1H
public		_itoa8
_itoa16		EQU		4535H
public		_itoa16
KBCHECK		EQU		47A5H
public		KBCHECK
KBINIT		EQU		4687H
public		KBINIT
P4MDOUT		EQU		009CH
public		P4MDOUT
__lcddata		EQU		4E18H
public		__lcddata
P6MDOUT		EQU		009EH
public		P6MDOUT
P7MDOUT		EQU		009FH
public		P7MDOUT
EMI0CF		EQU		00A3H
public		EMI0CF
lcdrs		EQU		002BH
public		lcdrs
EMI0CN		EQU		00A2H
public		EMI0CN
lcdrw		EQU		002CH
public		lcdrw
_busy		EQU		4E3DH
public		_busy
_lcdwritec		EQU		4D56H
public		_lcdwritec
__mpuwdata		EQU		4E58H
public		__mpuwdata
__lcdcmd		EQU		4E22H
public		__lcdcmd
_lcdcursor		EQU		4E2CH
public		_lcdcursor
_lcdwritex		EQU		4D73H
public		_lcdwritex
lcdclear		EQU		4E53H
public		lcdclear
__mpuwcmd		EQU		4E5DH
public		__mpuwcmd
_mpurdata		EQU		4E62H
public		_mpurdata
_lcdwrite		EQU		4CF6H
public		_lcdwrite
lcdrdata		EQU		002DH
public		lcdrdata
lcdwdata		EQU		002EH
public		lcdwdata
lcdbase		EQU		002FH
public		lcdbase
_mpurcmd		EQU		4E67H
public		_mpurcmd
lcdrcmd		EQU		0030H
public		lcdrcmd
lcdwcmd		EQU		0031H
public		lcdwcmd
_lcdpos		EQU		4DAAH
public		_lcdpos
lcdinit		EQU		4BDAH
public		lcdinit
KEYTAB		EQU		4236H
public		KEYTAB
KEYTAB2		EQU		430AH
public		KEYTAB2
MAXKEY		EQU		0076H
public		MAXKEY
MINKEY		EQU		000DH
public		MINKEY
SPI0CKR		EQU		009DH
public		SPI0CKR
P0		EQU		0080H
public		P0
SPIEN		EQU		00F8H.0
public		SPIEN
P2		EQU		00A0H
public		P2
spiinit		EQU		4D38H
public		spiinit
P0MDOUT		EQU		00A4H
public		P0MDOUT
P2MDOUT		EQU		00A6H
public		P2MDOUT
spi_rcv_byte		EQU		4DF8H
public		spi_rcv_byte
CS		EQU		00A0H.0
public		CS
XBR0		EQU		00E1H
public		XBR0
XBR1		EQU		00E2H
public		XBR1
SPIF		EQU		00F8H.7
public		SPIF
NSSMD0		EQU		00F8H.2
public		NSSMD0
NSSMD1		EQU		00F8H.3
public		NSSMD1
_spi_rcv_buffer		EQU		4C95H
public		_spi_rcv_buffer
_spi_set_divisor		EQU		4DCDH
public		_spi_set_divisor
spi_cs_deassert		EQU		4E6FH
public		spi_cs_deassert
_spi_send_byte		EQU		4E45H
public		_spi_send_byte
SPI0CFG		EQU		009AH
public		SPI0CFG
spicardpresent		EQU		4E4DH
public		spicardpresent
SPI0DAT		EQU		009BH
public		SPI0DAT
spi_cs_assert		EQU		4E6CH
public		spi_cs_assert
songSector		EQU		0200H
public		songSector
readdir		EQU		43DEH
public		readdir
numSongs		EQU		0280H
public		numSongs
_microSDread		EQU		4A48H
public		_microSDread
microSDinit		EQU		4D19H
public		microSDinit
_NTOHL		EQU		4E03H
public		_NTOHL
_NTOHS		EQU		4E0AH
public		_NTOHS
?C?CLDPTR		EQU		4000H
public		?C?CLDPTR
?C?CSTOPTR		EQU		4019H
public		?C?CSTOPTR
?C?UIDIV		EQU		403BH
public		?C?UIDIV
?C?LMUL		EQU		4090H
public		?C?LMUL
?C?ULDIV		EQU		411BH
public		?C?ULDIV
?C?LSHL		EQU		41ADH
public		?C?LSHL
?C?LLDXDATA		EQU		41C0H
public		?C?LLDXDATA
?C?LSTXDATA		EQU		41CCH
public		?C?LSTXDATA
?C?LSTKXDATA		EQU		41D8H
public		?C?LSTKXDATA
?C?ICASE		EQU		4209H
public		?C?ICASE
end
