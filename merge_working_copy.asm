                list1 equ 30h
                list2 equ 40h
                size equ 6
                mov r0,#list1
                mov r1,#list2
                mov r7,#size
                push ar0
                push ar1
                push ar7
                lcall merge

merge:          mov a,r7
                rrc a               ;determine the size of each half
                mov r6,a            ;store this in another register

                ;need 3 iterators:
                ; i = index of last item in list 1
                ; j = index of last item in list 2
                ; k = index of last item in original list

                add a,#list1        ;this is i.
                dec a
                mov r5,a            ;store i.
                mov a,#list2
                add a,r6
                dec a
                mov r4,a            ;storing j.
                mov a,r5
                add a,r6
                mov r3,a            ;storing k.
                ;essentially at this point,i need to compare the two values and store them in
                ;the list.
loop:           mov a,r5            ;i
                mov r0,a
                mov a,@r0           ;next item in list 1 is in the accumulator.
                mov r0,a            ;store temporarily.
                mov a,r4            ;j
                mov r1,a
                mov a,@r1           ;next item in list 2 is in the accumulator.
                clr c
                cjne a,ar0,eval     ;compare the two
eval:           jc store_list1
                mov r1,a
                push ar1            ;temp storing the item of list2
                mov a,r3
                mov r0,a            ;loading the index of k.
                pop ar1
                mov a,r1
                mov @r0,a           ;stored the value in the original list
                mov a,r4
                dec a
                mov r4,a            ;decrement j
                jmp next
store_list1:    push ar0            ;saving list 1
                mov a,r3
                mov r1,a
                pop ar0
                mov a,r0
                mov @r1,a           ;stored the value in the original list
                mov a,r5
                dec a
                mov r5,a            ;decrement i
next:           mov a,r3
                dec a
                mov r3,a            ;decrement the original list pointer.
                jmp loop