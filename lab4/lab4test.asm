$NOMOD51

$include (c8051f120.inc)                ; Include register definition file.

extrn   code(kbinit, kbcheck)

?STACK  segment idata 
        rseg    ?STACK                  ; Reserve one byte 
        ds      1

chars segment data
        rseg chars
char: 	ds      1                     ; storage for timer values

        using   0

        cseg    at 0
        ljmp    main
 
test segment code
        rseg    test
main:
        mov     WDTCN, #0deh    ; disable watchdog timer
        mov     WDTCN, #0adh
        mov     sp, #?STACK-1   ; set up the stack

        mov     SFRPAGE, #0fh   ; set up crossbar and oscillator
        orl     XBR2,   #040h
        mov     OSCICN, #0c2h
        mov     SFRPAGE, #0h    ; 

        mov     SFRPAGE, #0fh   ; set crossbar to enable pin
        orl     XBR0,   #11b    ; enable SMBUS, SPI
				orl     XBR1,   #100000b ; enable timer 2
        mov     SFRPAGE, #0h    ; put SPI into 3-wire mode
				mov			SPI0CFG, #40h
				clr			NSSMD1
				clr			NSSMD0

        lcall   kbinit          ; perform keyboard initialization
        mov     SFRPAGE, #0fh   ; set crossbar to enable pin
badXBR0:
				mov			a, XBR0
				cjne		a, #3h, badXBR0
badXBR1:
				mov			a, XBR1
				cjne		a, #24h, badXBR1
        mov     SFRPAGE, #0
badIE:
				mov			a, IE
				cjne		a, #1h, badIE
badIP:
				mov			a, IP
				cjne		a, #0c1h, badIP

				setb    ea

        clr     a               ; set all registers to the same value
loop:   mov     r0, a           ; set all the registers
        mov     r1, a           
        mov     r2, a
        mov     r3, a
        mov     r4, a
        mov     r5, a
        mov     r6, a
        mov     r7, a
        mov     b, a
        mov     dph, a
        mov     dpl, a

				orl		PCON, #1
        jnb     P0.5, loop1     ; clock is still low
        jmp     loop1            ; if clock is high, that might be bad

        ; now ascertain whether the keyboard code changed any registers

loop1:
        cjne    a,ar1, $        ; r1 changed
        cjne    a,ar2, $        ; r2 changed
        cjne    a,ar3, $        ; r3 changed
        cjne    a,ar4, $        ; r4 changed
        cjne    a,ar5, $        ; r5 changed
        cjne    a,ar6, $        ; r6 changed
        cjne    a,ar7, $        ; r7 changed
        cjne    a,dph, $        ; dph changed
        cjne    a,dpl, $        ; dpl changed
        cjne    a,b, $          ; b changed
        cjne    a,ar0, $        ; r0 changed

        push    acc             ; save count
        push    ar0             ; save pointer
        lcall   kbcheck
				cjne		r7, #0ffh, $+5
				sjmp		cont
				mov			char, r7
cont:   pop     ar0
        pop     acc
        inc     a               ; change register check value

        jmp     loop

        end
