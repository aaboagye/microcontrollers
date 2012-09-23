                left    equ 30h         ;left list must be >= right
                right   equ 40h
                size    equ 6
                mov     r0,#left
                mov     r1,#right
                mov     r7,#size
                push    ar0
                push    ar1
                push    ar7
                lcall   merge

merge:          mov     a,r7
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
                add     a,#left         ;this is i.
                dec     a
                mov     r5,a            ;store i.
                add     a,r2
                mov     r3,a            ;storing k.
                mov     a,#right
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
halt:           sjmp    $