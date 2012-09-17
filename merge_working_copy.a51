merge(in1,in2,out):
while both in1 and in2 contains items:
  if in1[0] < in2[0]:
  	out.append (in1[0])
  	remove in1[0]
  else:
  	out.append (in2[0])
  	remove in2[0]
append any remaining items to out


		MOV		R0,#list1
		MOV		R1,#list2
		MOV		R7,#size
		PUSH	AR0
		PUSH	AR1
		PUSH	AR7
		LCALL	merge

;	merge:	merge 2 sorted lists.

merge:	MOV		A,R7		
		RRC		A 			;determine the size of each half
		MOV		R6,A 		;store this in another register

		;need 3 iterators:
		; i = index of last item in list 1
		; j = index of last item in list 2
		; k = index of last item in original list

		ADD		A,#list1	;this is i.
		DEC		A
		MOV		R5,A 		;store i.
		MOV 	A,#list2
		ADD 	A,R6		
		DEC		A 			
		MOV		R4,A 		;storing j.
		MOV		A,R5
		ADD		A,R6
		MOV		R3,A 		;storing k.

;essentially at this point, I need to compare the two values and store them in
;the list.
loop:			MOV		A,R5		;i
				MOV		R0,A
				MOV		A,@R0		;next item in list 1 is in the accumulator.
				MOV		R0,A 		;store temporarily.
				MOV		A,R4		;j
				MOV		R1,A
				MOV		A,@R1 		;next item in list 2 is in the accumulator.
				CLR		C
				CJNE	A,AR0,eval	;compare the two


eval:			JC		store_list1
				MOV		R1,A 		
				PUSH	AR1			;temp storing the item of list2
				MOV		A,R3
				MOV		R0,A 		;loading the index of k.
				POP 	AR1
				MOV		A,R1
				MOV		@R0,A 		;stored the value in the original list
				MOV		A,R4
				DEC 	A
				MOV		R4,A 		;decrement j
				JMP		next
store_list1:	PUSH	AR0 		;saving list 1
				MOV		A,R3
				MOV		R1,A
				POP		AR0
				MOV		A,R0
				MOV		@R1,A 		;stored the value in the original list
				MOV		A,R5
				DEC 	A
				MOV		R5,A 		;decrement i
next:			MOV		A,R3
				DEC		A
				MOV		R3,A 		;decrement the original list pointer.
				JMP 	loop


				ADD		A, R7		
				DEC		A 			;at the index of the last element in original list
				MOV		R2, A		;store this index
				MOV		
				; rotate right to divide by 2 in order to find the size of the halves
				MOV		A, R0
				RR		A
				MOV		R3, A		;store this value
				; I need 3 iterators: 1 for original list, 1 for list2, 1 for list 1
				MOV		A, R3
			ADD		A, R1		; at the end of list 2
			PUSH	AR0
			MOV		R0, A
			MOV		A, @R0		; value at the end of list 2
			POP		AR0