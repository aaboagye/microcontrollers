; lab3test.asm
;
; main process which tests keyboard module
;
$NOMOD51

$include (c8051f120.inc)                ; Include register definition file.

extrn   code(kbinit, kbcheck)

?STACK  segment idata 
        rseg    ?STACK                  ; Reserve one byte 
        ds      1

buf segment idata
        rseg buf
buffer: ds      20H                     ; storage for timer values


chars segment data
        rseg chars
char:   ds      1                       ; storage for keyboard character

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
        orl     XBR1,   #10b    ; enable timer 0 input (for counter)
        mov     SFRPAGE, #0h    ; 
        ; enable timer 0 as a counter (mode 1), timer 1 as timer (mode 1)
        mov     TMOD, #00010101b
        ; let timer 1 run at sysclock rate
        mov     CKCON, #00010000b
        setb    TR0             ; start counter 0
        lcall   kbinit          ; perform keyboard initialization

        clr     a               ; set all registers to the same value
        mov     th0, a          ; zero the timer
        mov     tl0, a
        dec     th0             ; the first "count" will increment, so pre-
        dec     tl0             ;  decrement to make it really start at 0
        mov     r0,#buffer      ; store timer values between 80H and BFH

loop:   push    ar0             ; save buffer pointer
        mov     r0, a           ; set all the registers
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

        mov     th1,#0          ; clear timer 1 
        mov     tl1,#0          ; 
        jnb     P0.5, $         ; wait while clock input is low
        jb      P0.5, $         ; wait while clock input is high
        setb    tr1             ; start timing
        call    0*8+3           ; call the interrupt
        clr     tr1             ; stop timing
        jnb     P0.5, loop1     ; clock is still low
        jmp     $               ; if clock is high, that might be bad

        ; now ascertain whether the keyboard code changed any registers

loop1:
        cjne    a, tl0, $       ; either acc changed, or the keyboard code
                                ;   took much too long to execute
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
        pop     ar0             ; restore pointer
        mov     @r0,th1         ; save timer values (big endian)
        inc     r0
        mov     @r0, tl1
        inc     r0
        xch     a,r0            ; wrap pointer after 32 bytes
        clr     c
        subb    a,#buffer
        anl     a,#1fh
        add     a,#buffer
        xch     a,r0

        push    acc             ; save count
        push    ar0             ; save pointer
        lcall   kbcheck         ; check for key
        cjne    r7, #0ffh, $+5  ; if there is a key, save it
        sjmp    cont
        mov     char, r7        ; saved ASCII code
cont:   pop     ar0
        pop     acc
        inc     a               ; change register check value
        jmp     loop

        end
