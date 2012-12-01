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
$NOMOD51
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
            mov sfrpage,#0
            clr dacactive
            orl DAC0CN,#98H         ;enable DAC and watch on T2 overflow
            mov sfrpage,#1
            orl DAC1CN,#98H
            mov sfrpage,#0
            setb ET2                ;setup T2 interrupt
            orl P1MDOUT,#40H        ;fixes "shark-fin" square wave
            orl REF0CN,#03H
            setb PT2
            clr TF2
            setb TR2
            orl TMR2CF,#02H
            mov sfrpage,#0FH
            orl XBR1,#20H           ;setup  T2 toggle output XBR
            mov sfrpage,#0
            mov RCAP2H,#HIGH(-128)   ;set reload value
            mov RCAP2L,#LOW(-128)
            mov DAC0H,#08H
            mov DAC0L,#00H           ;not sure if we need to put this here?
            mov sfrpage,#1
            mov DAC1H,#08H
            mov DAC1L,#00H           ;not sure if we need to put this here?
            mov sfrpage,#0

            ret

dacbusy:
            ;return 0 in R7 if dacactive is not set
            jb      dacactive,notbusy
            mov     R7,#0
            ret
  notbusy:  mov     R7,#1
            ret


_dacplay:
            ;copy count(R6,R7) to bytesleft
            using 0
            mov R0,#bytesleft
            mov @R0,AR6              ;assuming R7 is low byte.
            inc R0
            mov @R0,AR7

            ;copy buffer(R4,R5) to bufptr
            mov R0,#bufptr
            mov @R0,AR4              ;assuming R5 is low byte.
            inc R0
            mov @R0,AR5

            setb dacactive
            ret

end
