;split(list, sizeof(list))
;
;size   :r7     mov     r1,30h
                mov     r7,8
                mov     r0,20h
                push    ar1
                push    ar0
                push    ar7

split:          pop     ar7
                cjne    r7,#2,else          ;if list has a size of 2 return. I'll come back to this.
                ret
else:           mov     r6,ar7              ;else, copy the right side of the list
                clr     c                   ;to the scratch space
                rrc     r6
                mov     r5,ar6
                dec     r6                  ;address of the end of left
                pop     ar0
                mov     a,r0
                add     a,r6
                mov     r0,a
                inc     r0
                pop     ar1
r_toscratch:    mov     a,@r0               ;copy the right side of the list into the scratch space.
                mov     @r1,a
                inc     r1
                inc     r0
                cjne    r0,ar7,r_toscratch
                push    ar1
                push    ar0
                push    ar5
                lcall   split
