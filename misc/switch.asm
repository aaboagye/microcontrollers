; Reusable switch statement
; Joe Orr- 10/8/2012

switch:                     ; cases, case, and switch should all work together like a switch statement, but who knows
    var     EQU AR0         ; case variable: must be direct memory.
    maxC    EQU 3           ; # of cases
    count   EQU R1          ; counter: must be register
    mov     DPTR,#cases         
    mov     count,#-1
  loop:
    inc     count
    cjne    count,#maxC,continue ; jump to else case if no cases match
    jmp     else
    continue:
    mov     A,count
    movc    A,@A+DPTR
    cjne    A,var,loop
    rl      A
    mov     DPTR,#case
    jmp     @A+DPTR
  cases:    ds      20H     ; different values for case variable
            ds      40H
            ds      14H
            ;etc
  case:     ajmp    case1   ; jump table for cases
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
  else:                     ; else case
    ; code...
    jmp     break
  break:                    ; end
    ; code to run after switch statement