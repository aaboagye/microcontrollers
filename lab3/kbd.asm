;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       Name:   Aseda Gyeke Aboagye
;               Joe Orr
;               Doug Hewitt
;
;       kbd.asm --  This module is for handling the scancodes generated from
;                   the PS/2 keyboard. Implemented is a state machine which
;                   checks the framing of the transaction and checks to
;                   ensure that the parity is set correctly.
;
;                   Once the scancode is received, it inserts the value
;                   from the lookup table into a ringbuffer to be used by
;                   the main program.
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$NOMOD51

$include (c8051f120.inc)                            ; Include register definition file.
public  kbinit, kbcheck

        using   0

QUEUELEN EQU    4                                   ; queue holds four characters

kbdidat segment idata
        rseg    kbdidat
kbdq:   ds      QUEUELEN                            ; the actual queue

kbddata segment data                                ; variable storage
        rseg    kbddata
queuesize: ds   1                                   ; count of items in the queue
head:   ds      1                                   ; address of queue head (insertion)
tail:   ds      1                                   ; address of queue tail (extraction)

kbdbits segment bit                                 ; bit variables
        rseg    kbdbits
parity:     dbit    1
cparity:    dbit    1                               ; calculated parity
start_bit:  dbit    1
stop_bit:   dbit    1
char_ready: dbit    1                               ; kbchar is valid and ready
shifted:    dbit    1
ctrled:     dbit    1
breaked:    dbit    1
state:      ds      1                               ; state variable
scan_code:  ds      1                               ; scan code from kb
kbchar:     ds      1                               ; ascii char from scan code
count:      ds      1                               ; used in switch statement

        cseg    at 0*8+3                            ; interrupt is priority 0
        ljmp    kbprocess                           ; these aren't the droids you're looking for
 
kbdcode segment code
        rseg    kbdcode                             ; your code

kbinit:
        extrn   code(keytab, keytab2), number(minkey, maxkey)
        aparity     EQU     PSW.0                   ; psw even parity bit for A
        kbpin       EQU     P2.2
        sc_error    EQU     000H                    ; error code? i'm really just making stuff up at this point
        mov         state,#0
        clr         shifted
        clr         ctrled
        clr         breaked

        mov     queuesize, #QUEUELEN                ; initialize the queue
        mov     head, #kbdq
        mov     tail, #kbdq
        mov     r0, #kbdq                           ; for testing, put "no character" value
        mov     @r0,#0ffH                           ;   at the tail of the queue
        ret

kbprocess:
        push    ACC                                 ; save general registers' state
        push    B
        push    DPH
        push    DPL
        push    PSW
        mov     A,state
        rl      A                                   ; x2 to account for ajmp in table
        mov     DPTR,#table
        jmp     @A+DPTR
table:  ajmp  rx_start_bit                          ; state 0
        ajmp  rx_data                               ; state 1
        ajmp  rx_parity                             ; state 2
        ajmp  rx_stop_bit                           ; state 3
  rx_start_bit:
        mov     C,kbpin
        mov     start_bit,C
        mov     scan_code,#80H                      ; same as 10000000B (MSB set for flagging rx_data as done)
        mov     kbchar,#sc_error
        inc     state
        jmp     done
  rx_data:
        mov     C,kbpin
        mov     A,scan_code
        rrc     A                                   ; add bit to carry, shift right into MSB
        mov     scan_code,A
        jnc     hack                                ; if carry is set, we're done with data, otherwise repeat this state
        inc     state
        jmp     done
hack:   jmp done
  rx_parity:
        mov     C,kbpin
        mov     parity,C
        mov     A,scan_code
        mov     C,aparity
        cpl     C
        mov     cparity,C                           ; calculated odd parity
        inc     state
        jmp     done
  rx_stop_bit:
        mov     C,kbpin
        mov     stop_bit,C
  valid_chk:                                        ; for a valid scan_code: start_bit = 0 && cparity = parity && stop_bit = 1
        mov     C,parity
        anl     C,cparity
        jc      framing                             ; check if cparity == 1 && parity == 1
        mov     C,parity
        orl     C,cparity                           ; check if cparity == 0 && parity == 0     
        jc      rx_error
    framing:
        mov     C,stop_bit
        anl     C,/start_bit                        ; check if start_bit = 0 && stop_bit = 1
        jnc     rx_error
  lookup:
        mov     A,scan_code                         ; get scancode
        clr     C
        subb    A,#minkey                           ; check if scancode is smaller than minkey
        jc      rx_error
        mov     DPTR,#keytab                        ; assume no control key
        jnb     ctrled,next                         ; if ctrl was pressed, use keytab2 instead
        mov     DPTR,#keytab2
    next:
        mov     C,shifted
        cpl     C
        rlc     A
        movc    A,@A+DPTR
        mov     kbchar,A
        jb      ACC.7,special_key
        jb      breaked,clrbreak
        jmp     valid_char                          ; value in kbchar is ready for whatever (ring buffer)
    clrbreak:
        mov     kbchar,#sc_error                    ; if the breaked flag is set, ignore char
        clr     breaked
  reset_state:
        mov     state,#0
        jmp     done
  rx_error:
        mov     scan_code,#sc_error
        mov     kbchar,#sc_error
        sjmp    reset_state
  special_key:
        mov     DPTR,#cases                         ; cases, case, and switch should all work together like a switch statement, but who knows
        maxC    EQU 4                               ; # of cases      
        mov     count,#-1
    case:
        inc     count
        mov     A,count
        cjne    A,#maxC,continue                    ; jump to else case if no cases match
        jmp     case_end
        continue:
        movc    A,@A+DPTR
        cjne    A,scan_code,case
        mov     A,count
        rl      A
        mov     DPTR,#switch
        jmp     @A+DPTR
    cases:  db      012H                            ; left shift
            db      059H                            ; right shift
            db      014H                            ; ctrl
            db      0F0H                            ; break
    switch: ajmp    case_shift
            ajmp    case_shift
            ajmp    case_ctrl
            ajmp    case_break
    case_shift:
        setb    shifted
        jnb     breaked,nobreaks                    ; if break code is flagged, unset shift and break flags
        clr     shifted
        clr     breaked
      nobreaks:
        jmp     case_end
    case_ctrl:
        setb    ctrled
        jnb     breaked,nobreakc                    ; if break code is flagged, unset ctrl and break flags
        clr     ctrled
        clr     breaked
      nobreakc:
        jmp     case_end
    case_break:
        setb    breaked
        jmp     case_end
    case_end:                                       ; end of case statement
        mov     kbchar,#sc_error
        jmp     reset_state
valid_char:
        push    AR0                                 ; save R0
        mov     R0,head
        mov     @R0,kbchar                          ; ring[head] = item(kbchar)
        inc     head
        dec     queuesize                           ; how much is free in ring buffer
        mov     B,#QUEUELEN
        mov     A,head
        div     AB
        mov     head,B                              ; head = head % buffer_size
        pop     AR0
        jmp     reset_state
done:
        pop     PSW                                 ; restore general registers
        pop     DPL
        pop     DPH
        pop     B
        pop     ACC
        ret                                         ;from kbprocess

kbcheck:
        push    acc
;;;;    REMOVE THESE 4 LINES WHEN YOU HAVE IMPLEMENTED RING BUFFER INSERTION
;        mov     a,#0ffH         ; get "no character" value
;        mov     r0, #kbdq
;        xch     a, @r0          ; swap actual character with "no character"
;        mov     R7,a            ; move into return register
;        jmp     wraptail        ; exit
;;;;
        mov     a, queuesize                        ; see if there are chars in queue
        cjne    a, #QUEUELEN, gotchar               ; not equal means yes
        mov     r7, #-1                             ; return "no char" value
        pop     acc
        ret
gotchar:
        ;; clr     EA                               ; avoid race condition
        mov     r0,tail                             ; get queue tail pointer
        mov     a,@r0                               ; get from queue
        mov     r7,a                                ; put in register to return
        inc     queuesize                           ; adjust free count
        ;; setb    EA
        inc     tail                                ; update tail pointer
        mov     a, tail
        cjne    a, #kbdq+QUEUELEN, wraptail         ; check for queue wrap
        mov     tail, #kbdq
wraptail:
        pop     acc
        ret

        end
