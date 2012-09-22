;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Name: 	Aseda Gyeke Aboagye
;			Doug Hewitt
;			Joe Orr
;
;	Lab 1: Restoring Division
;
;		This program performs a 16 bit division using the restoring
;		division algorithm. The memory addresses are shown below.
;
;		Quotient: 		R6  R7
;		Numerator:		40h 41h
;		Denominator:	30h 31h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		QH		EQU		R6				;most-significant byte of the quotient
		QL		EQU		R7				;least-significant byte of quotient
		RH		EQU		R5
		RLO		EQU		R4				;remainder
		NH		EQU		40H
		NL		EQU		41H				;numerator
		DH		EQU		30H
		DL		EQU		31H				;denominator
		I		EQU 	R3				;iterations register


start:	MOV		RH, 	#0
		MOV 	0,		#RLO 			;set remainder to 0
		MOV 	QH,		#0
		MOV 	QL, 	#0 				;set quotient to 0

		MOV		I,		#16				;iterations counter


shift:	CLR 	C
		MOV		A,		QL
		RLC		A
		MOV		QL,		A 				;shift in a 0 and store the lower byte

		MOV		A,		QH
		RLC 	A
		MOV		QH,		A 				;complete the shift and store the higher
										;byte

		CLR 	C
		MOV		A,		NL	
		RLC 	A
		MOV 	NL,		A 				;shift the numerator one place to the 
										;left and store the lower byte
		MOV		A,		NH
		RLC		A
		MOV		NH,		A 				;shift and store the high byte moving 
										;the most significant bit in the carry

		MOV		A,		RLO
		RLC		A
		MOV 	RLO,	A 				;rotate through the carry into the remainder

		MOV		A,		RH
		RLC		A
		MOV		RH,		A 				;at this point, the shifts are complete.

		MOV 	A,		RH
		CJNE	A,		DH,		less_h	;Is the remainder greater than the denominator?(high byte)
less_h:	JC		loop					;If it's not, repeat the algorithm.
		CJNE	A,		DH,		bitset	;If the remainder is equal to the denomitator,
		CLR		C 						;check the lower byte.
		MOV		A,		RLO
		CJNE 	A,		DL,		less_l
less_l:	JC		loop

bitset:	MOV		A,		QL				;Since QL is not bit addressable, using a logical or with
		ORL		A,		#01H			;the value of 0x01 forces the LSB to be 1.
		MOV		QL,		A 		

		CLR 	C 						;Before using the SUBB instruction, you must clear the carry.
		MOV		A,		RLO				;Subtract the lower byte of the denominator from the remainder.
		SUBB	A,		DL
		MOV		RLO,	A

		MOV		A,		RH 				;Repeat for the higher byte.
		SUBB	A,		DH
		MOV		RH,		A
loop:	DJNZ	I,		shift 			;Decrease the iteration count and continue the algorithm.
		SJMP 	$						;halt the program

END