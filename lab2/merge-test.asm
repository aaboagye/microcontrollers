array   equ     20H             ; list starts at 20H in RAMory
scratch equ     30H             ; scratch space starts at 30H
stack   equ     47H             ; stack start at 48H

        mov     sp,#stack       ; initialize stack

test1:  mov     r0, #array      ; set all memory to something unique
        mov     r7, #60H
clr1:   mov     @r0,# 0eeH
        inc     r0
        djnz    r7, clr1
        mov     r0, #array      ; load the first list of 6 items to sort
        mov     @r0, #2
        inc     r0
        mov     @r0, #240
        inc     r0
        mov     @r0, #4 
        inc     r0
        mov     @r0, #55 
        inc     r0
        mov     @r0, #1 
        inc     r0
        mov     @r0, #8 
        mov     r0, #array
        mov     r1,#scratch
        mov     r7,#6
        call    mergesort

test2:  mov     r0, #array      ; set all memory to something unique again
        mov     r7, #60H
clr2:   mov     @r0,# 0eeH
        inc     r0
        djnz    r7, clr2
        mov     r0, #array      ; load the second list of 9 items to sort
        mov     @r0, #3
        inc     r0
        mov     @r0, #6 
        inc     r0
        mov     @r0, #5 
        inc     r0
        mov     @r0, #4 
        inc     r0
        mov     @r0, #5 
        inc     r0
        mov     @r0, #2 
        inc     r0
        mov     @r0, #0 
        inc     r0
        mov     @r0, #240
        inc     r0
        mov     @r0, #1 
        mov     r1,#array
        mov     r1,#scratch
        mov     r7,#9
        call    mergesort

        sjmp    $

mergesort:
