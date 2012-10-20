;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Name:	Aseda Gyeke Aboagye
;			Joe Orr
;			Doug Hewitt
;
;	File:	daca.asm
;
;	Description: TODO!!!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
$include (c8051f120.inc)
public bytesleft, bufptr, dacactive,  dacinit


dac_bits segment bit
	rseg dac_bits
dacactive: 		dbit	1

dacint segment data
	rseg dacint
bytesleft: 		ds		2
bufptr:			ds		2

daccode	segment code
	rseg daccode

dacinit:
;;initialise global vars
			clr dacactive
;;setup dac
			using 0
			orl DAC0CN,#98			;enable DAC and watch on T2 overflow
			orl DAC1CN,#98			;enable DAC and watch on T2 overflow
;;setup T2 interrupt
			setb ET2
;;setup T2 toggle output XBR

