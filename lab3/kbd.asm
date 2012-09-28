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
        mov     queuesize, #QUEUELEN  ; initialize the queue
        mov     head, #kbdq
        mov     tail, #kbdq
        mov     r0, #kbdq       ; for testing, put "no character" value
        mov     @r0,#0ffH       ;   at the tail of the queue
        ret

kbprocess:
        ret

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
