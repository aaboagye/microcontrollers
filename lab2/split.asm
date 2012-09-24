;split(list, sizeof(list))
;
;size   :r7     
                offset  equ 10h
                mov     offset,#2
                mov     r1,#30h
                mov     r7,#8
                mov     r0,#20h
                mov     sp,#4fh
                push    ar1
                push    ar0
                push    ar7
                lcall   split
                sjmp    $

split:          mov     a,sp
                clr     c
                subb    a,offset
                mov     sp,a
                pop     ar7
                cjne    r7,#1,else          ;if list has a size of 1 return.
                inc     sp                  ;undo the pop we just did to check
                mov     a,sp
                add     a,offset
                mov     sp,a
                ret
else:           mov     r6,ar7              ;else, copy the right side of the list
                clr     c                   ;to the scratch space
                mov     a,r6
                rrc     a
                mov     r6,a
                mov     r5,ar6
                dec     r6                  ;address of the end of left
                pop     ar0
                mov     r2,ar0
                mov     a,r7
                add     a,r0
                mov     r7,a
                mov     a,r0
                add     a,r6
                mov     r0,a
                inc     r0
                pop     ar1
r_toscratch:    mov     a,@r0               ;copy the right side of the list into the scratch space.
                mov     @r1,a
                inc     r1
                inc     r0
                mov     a,r0
                cjne    a,ar7,r_toscratch
                push    ar1                 ;scratch index
                push    ar2                 ;list index
                push    ar5                 ;size
                mov     a,sp
                add     a,offset
                mov     sp,a
                inc     offset
                inc     offset
                lcall   split
                ;here after it has split the left side, it needs to do the same to the right side.
                push    ar1                     ;scratch
                mov     a,r1
                clr     c
                subb    a,r5
                push    acc                     ;address of right list
                push    ar5                     ;size of right list?
                mov     offset,#2               ;resetting the offset
                mov     a,sp
                add     a,offset
                mov     sp,a
                inc     offset
                inc     offset
                lcall   split
                mov     offset,#2
                mov     a,sp
                clr     c
                subb    a,offset
                mov     sp,a
                pop     ar0                     ;removing size of right list
                pop     ar5                     ;addr of right list
                ;pop     acc                     ;scratch loc
;here we must place: left addr, right addr, total size then call merge
                push    ar2
                push    ar5                     ;address of right list
                mov     a,r7
                add     a,r0
                push    acc
               ; inc     offset
               ; inc     offset
                lcall   merge
                dec     sp
                dec     sp
                dec     sp
                pop     acc
                mov     r1,a
                ret

merge:          ;here i need to move the SP accordingly
                mov     a,sp
                clr     c
                subb    a,offset
                mov     sp,a
                pop     ar7             ;size
                pop     ar1             ;right
                pop     ar0             ;left
                mov     a,r7
                rrc     a               ;determine the size of left half
                mov     r6,a            ;store this in another register
                mov     a,r7
                clr     c
                subb    a,r6            ;right half = total - left
                mov     r2,a            ;determine the size of the right half and store it.

                ;need 3 iterators:
                ; i = index of last item in left
                ; j = index of last item in right
                ; k = index of last item in original list
                
                mov     a,r6
                add     a,r0            ;this is i.
                dec     a
                mov     r5,a            ;store i.
                add     a,r2
                mov     r3,a            ;storing k.
                mov     a,r1
                add     a,r2
                dec     a
                mov     r4,a            ;storing j.
loop:           mov     r0,ar5          ;i
                mov     a,@r0           ;next item in left is in the accumulator.
                mov     r0,a            ;store temporarily.
                mov     r1,ar4          ;j
                mov     a,@r1           ;next item in right is in the accumulator.
                clr     c
                cjne    a,ar0,eval      ;if left > right, jump to store_left
eval:           jc      store_left
                mov     r1,a
                mov     r0,ar3          ;loading the index of k.
                mov     @r0,ar1         ;stored the value in the original list
                dec     r4              ;decrement j
                dec     r3              ;decrement k
                djnz    r2,loop         ;is the right list empty? if so, we are done
                jmp     halt
store_left:     mov     r1,ar3
                mov     @r1,ar0         ;stored the value in the original list
                dec     r5              ;decrement i
                dec     r3              ;decrement the original list pointer.
                djnz    r6,loop         ;is the left list empty? if so, copy right
copy_right:     mov     r0,ar4
                mov     a,@r0
                mov     r1,ar3
                mov     @r1,a
                dec     r3
                dec     r4
                djnz    r2,copy_right
halt:           inc     sp
                inc     sp
                inc     sp
                mov     a,sp
                add     a,offset
                mov     sp,a
                ret
