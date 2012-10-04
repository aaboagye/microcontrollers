$NOMOD51

$include (c8051f120.inc)        ; Include register definition file.

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

        cseg    at 0*8+3        ; interrupt is priority 0
        ljmp    kbprocess       ; these aren't the droids you're looking for
 
kbdcode segment code
        rseg    kbdcode         ; your code

kbinit:
        extrn   code(keytab, keytab2), number(minkey, maxkey)
        state       EQU     ???                     ; what do we put here?
        char        EQU     ???
        parity      EQU     ???
        cparity     EQU     ???                     ; calculated parity
        aparity     EQU     PSW.0                   ; psw even parity bit for A
        start_bit   EQU     ???
        stop_bit    EQU     ???
        kbpin       EQU     ???
        char_error  EQU     FFH                     ; error code? i'm really just making stuff up at this point
        mov         state,#0

        mov     queuesize, #QUEUELEN  ; initialize the queue
        mov     head, #kbdq
        mov     tail, #kbdq
        mov     r0, #kbdq       ; for testing, put "no character" value
        mov     @r0,#0ffH       ;   at the tail of the queue
        ret

kbprocess:
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
        mov     char,#40H   ; same as 10000000 => rr (MSB set for flagging rx_data as done)
        inc     state
        jmp     done
  rx_data:
        mov     C,kbpin
        mov     A,char
        mov     ACC.7,C         ; add bit to MSB, shift right
        clr     C
        rrc     A
        mov     char,A
        jnc     done            ; if carry is set, we're done with data, otherwise repeat this state
        inc     state
        jmp     done
  rx_parity:
        mov     C,kbpin
        mov     parity,C
        mov     A,char
        mov     C,aparity
        cpl     C
        mov     cparity,C       ; calculated odd parity
        inc     state
        jmp     done
  rx_stop_bit:
        mov     C,kbpin
        mov     stop_bit,C
  valid_chk:                    ; for a valid char: start_bit = 0 && cparity = parity && stop_bit = 1
        mov     C,parity
        anl     C,cparity       ; check if cparity = parity
        jnc     rx_error
        mov     C,stop_bit
        anl     C,/start_bit    ; check if start_bit = 0 && stop_bit = 1
        jnc     rx_error
  reset_state:
        mov     state,#0
        jmp     done
  rx_error:
        mov     char,#char_error
        sjmp    reset_state
done:
        ret  ; from kbprocess

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
