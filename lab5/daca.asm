;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Name:   Aseda Gyeke Aboagye
;           Joe Orr
;           Doug Hewitt
;
;   File:   daca.asm
;
;   Description: Initialisation code as well as code for handling dacplay and
;                   checking to see if the DAC is busy.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
$include (c8051f120.inc)
public bytesleft, bufptr, dacactive, dacinit, dacbusy, _dacplay



dac_bits segment bit
    rseg dac_bits
dacactive:      dbit    1

dacint segment data
    rseg dacint
bytesleft:      ds      2           ;1st byte is the low.
bufptr:         ds      2

daccode segment code
    rseg daccode

dacinit:
;;initialise global vars
            using 0
            clr dacactive
            orl DAC0CN,#98H         ;enable DAC and watch on T2 overflow
            orl DAC1CN,#98H
            setb ET2                ;setup T2 interrupt
            setb PT2
            clr TF2
            orl XBR1,#20H           ;setup T2 toggle output XBR
            mov RCAP2H,#HIGH -128   ;set reload value
            mov RCAP2L,#LOW  -128
            mov DAC0,#80H
            mov DAC1,#80H           ;not sure if we need to put this here?
            ret

dacbusy:
            ;return 0 in R7 if dacactive is not set
            jb      dacactive,notbusy
            mov     R7,#0
  notbusy:  ret


_dacplay:
            ;copy count(R6,R7) to bytesleft
            mov R0,#bytesleft
            mov @R0,R7              ;assuming R7 is low byte.
            inc R0
            mov @R0,R6

            ;copy buffer(R4,R5) to bufptr
            mov R0,#bufptr
            mov @R0,R5              ;assuming R5 is low byte.
            inc R0
            mov @R0,R4

            setb dacactive
            ret
