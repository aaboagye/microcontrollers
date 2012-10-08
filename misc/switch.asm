; Reusable switch statement
; Joe Orr- 10/8/2012

case:                       ; cases, case, and switch should all work together like a switch statement, but who knows
    var     EQU AR0         ; case variable: must be direct memory.
    mov     DPTR,#cases         
    mov     A,#-1
  loop:
    inc     A
    movc    A,@A+DPTR
    cjne    A,var,loop
    rl      A
    mov     DPTR,#switch
    jmp     @A+DPTR
  cases:    ds      20H     ; different values for case variable
            ds      40H
            ds      10H
            ;etc
  switch:   ajmp    case1   ; jump table for cases
            ajmp    case2   ; NOTE: must be in same order as cases
            ajmp    case3
            ;etc
  case1:
    ; code...
    jmp     break
  case2:
    ; code...
    jmp     break
  case3:
    ; code...
    jmp     break
  break:                      ; end
    ; code to run after switch statement