$NOMOD51

$include (c8051f120.inc)        ; Include register definition file.
public  kbinit, kbcheck

        using   0

QUEUELEN EQU    4               ; queue holds four characters

kbdidat segment idata
        rseg    kbdidat
kbdq:   ds      QUEUELEN        ; the actual queue

kbddata segment data            ; variable storage
        rseg    kbddata
queuesize: ds   1               ; count of items in the queue
head:   ds      1               ; address of queue head (insertion)
tail:   ds      1               ; address of queue tail (extraction)

kbdbits segment bit             ; bit variables
        rseg    kbdbits
parity:     dbit    1
cparity:    dbit    1           ; calculated parity
start_bit:  dbit    1
stop_bit:   dbit    1
char_ready: dbit    1           ; kbchar is valid and ready
shifted:    dbit    1
ctrled:     dbit    1
breaked:    dbit    1

        cseg    at 0*8+3        ; interrupt is priority 0
        ljmp    kbprocess       ; these aren't the droids you're looking for
 
kbdcode segment code
        rseg    kbdcode         ; your code

kbinit:
        extrn   code(keytab, keytab2), number(minkey, maxkey)
        using       1
        state       EQU     AR0                     ; what do we put here?
        scan_code   EQU     AR1
        kbchar      EQU     AR3                     ; ascii char grabbed from kb
        count       EQU     AR2                     ; used in switch statement
        aparity     EQU     PSW.0                   ; psw even parity bit for A
        kbpin       EQU     P2.2
        sc_error    EQU     000H                    ; error code? i'm really just making stuff up at this point
        shift       EQU     080H
        ctrl        EQU     081H
        break       EQU     0F0H
        mov         state,#0
        using       0

        mov     queuesize, #QUEUELEN  ; initialize the queue
        mov     head, #kbdq
        mov     tail, #kbdq
        mov     r0, #kbdq       ; for testing, put "no character" value
        mov     @r0,#0ffH       ;   at the tail of the queue
        ret

kbprocess:
        push    ACC     ; save general registers' state
        push    B
        push    DPH
        push    DPL
        push    PSW
        using   1
        mov     A,state
        rl      A               ; x2 to account for ajmp in table
        mov     DPTR,#table
        jmp     @A+DPTR
  table:  ajmp  rx_start_bit    ; state 0
          ajmp  rx_data         ; state 1
          ajmp  rx_parity       ; state 2
          ajmp  rx_stop_bit     ; state 3
  rx_start_bit:
        mov     C,kbpin
        mov     start_bit,C
        mov     scan_code,#80H   ; same as 10000000B (MSB set for flagging rx_data as done)
        mov     kbchar,#00H
        inc     state
        jmp     done
  rx_data:
        mov     C,kbpin
        mov     A,scan_code
        rrc     A               ; add bit to carry, shift right into MSB
        mov     scan_code,A
        jnc     hack            ; if carry is set, we're done with data, otherwise repeat this state
        inc     state
        jmp     done
    hack: jmp done
  rx_parity:
        mov     C,kbpin
        mov     parity,C
        mov     A,scan_code
        mov     C,aparity
        cpl     C
        mov     cparity,C       ; calculated odd parity
        inc     state
        jmp     done
  rx_stop_bit:
        mov     C,kbpin
        mov     stop_bit,C
  valid_chk:                    ; for a valid scan_code: start_bit = 0 && cparity = parity && stop_bit = 1
        mov     C,parity
        anl     C,cparity       ; check if cparity = parity
        jnc     rx_error
        mov     C,stop_bit
        anl     C,/start_bit    ; check if start_bit = 0 && stop_bit = 1
        jnc     rx_error
  lookup:
        mov     A,scan_code         ; get scancode
        clr     C
        subb    A,#minkey           ; check if scancode is smaller than minkey
        jc      rx_error
        mov     DPTR,#keytab        ; assume no control key
        jnb     ctrled,next         ; if ctrl was pressed, use keytab2 instead
        mov     DPTR,#keytab2
    next:
        mov     C,shifted
        rlc     A
        movc    A,@A+DPTR
        mov     kbchar,A
        jb      ACC.7,special_key
        jnb     breaked,reset_state
        mov     kbchar,#sc_error    ; if the breaked flag is set, ignore char
        clr     breaked
  reset_state:
        mov     state,#0
        jmp     done
  rx_error:
        mov     scan_code,#sc_error
        mov     kbchar,#sc_error
        sjmp    reset_state
  special_key:
        mov     DPTR,#cases     ; cases, case, and switch should all work together like a switch statement, but who knows
        maxC    EQU 3           ; # of cases      
        mov     count,#-1
    case:
        inc     count
        mov     A,count
        cjne    A,#maxC,continue ; jump to else case if no cases match
        jmp     case_end
        continue:
        movc    A,@A+DPTR
        cjne    A,kbchar,case
        rl      A
        mov     DPTR,#switch
        jmp     @A+DPTR
    cases:  db      shift
            db      ctrl
            db      break
    switch: ajmp    case_shift
            ajmp    case_ctrl
            ajmp    case_break
    case_shift:
        setb    shifted
        jnb     breaked,nobreaks    ; if break code is flagged, unset shift and break flags
        clr     shifted
        clr     breaked
      nobreaks:
        jmp     case_end
    case_ctrl:
        setb    ctrled
        jnb     breaked,nobreakc    ; if break code is flagged, unset ctrl and break flags
        clr     ctrled
        clr     breaked
      nobreakc:
        jmp     case_end
    case_break:
        setb    breaked
        jmp     case_end
    case_end:                   ; end of case statement
        mov     kbchar,#00H
        jmp     reset_state
done:
        using   0       ; restore general registers
        pop     PSW
        pop     DPL
        pop     DPH
        pop     B
        pop     ACC
        ret ;from kbprocess

kbcheck:
        push    acc
;;;;    REMOVE THESE 4 LINES WHEN YOU HAVE IMPLEMENTED RING BUFFER INSERTION
        mov     a,#0ffH         ; get "no character" value
        mov     r0, #kbdq
        xch     a, @r0          ; swap actual character with "no character"
        mov     R7,a            ; move into return register
        jmp     wraptail        ; exit
;;;;
        mov     a, queuesize    ; see if there are chars in queue
        cjne    a, #QUEUELEN, gotchar; not equal means yes
        mov     r7, #-1          ; return "no char" value
        pop     acc
        ret
gotchar:
        ;; clr     EA              ; avoid race condition
        mov     r0,tail         ; get queue tail pointer
        mov     a,@r0           ; get from queue
        mov     r7,a            ; put in register to return
        inc     queuesize       ; adjust free count
        ;; setb    EA
        inc     tail            ; update tail pointer
        mov     a, tail
        cjne    a, #kbdq+QUEUELEN, wraptail ; check for queue wrap
        mov     tail, #kbdq
wraptail:
        pop     acc
        ret

        end
