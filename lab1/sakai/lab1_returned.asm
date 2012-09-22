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
		RH		EQU		R4
		RLO		EQU		R5				;remainder
		NH		EQU		40H
		NL		EQU		41H				;numerator
		DH		EQU		30H
		DL		EQU		31H				;denominator
		I		EQU 	R3				;iterations register

        clr     a
test0:  push    acc
        mov     40H, #071h
        mov     41H, #001h
        mov     30H, #001h
        mov     31H, #023h
        call    subtract
        pop     acc
        setb    acc.0
        cjne    r4, #000h, test1
        cjne    r5, #078h, test1
        cjne    r6, #000h, test1
        cjne    r7, #063h, test1
        clr     acc.0
test1:  push    acc
        mov     40H, #0beh
        mov     41H, #0efh
        mov     30H, #00ch
        mov     31H, #0a1h
        call    subtract
        pop     acc
        setb    acc.1
        cjne    r4, #001h, test2
        cjne    r5, #080h, test2
        cjne    r6, #000h, test2
        cjne    r7, #00fh, test2
        clr     acc.1
test2:  push    acc
        mov     40H, #0d6h
        mov     41H, #0d8h
        mov     30H, #000h
        mov     31H, #063h
        call    subtract
        pop     acc
        setb    acc.2
        cjne    r4, #000h, test3
        cjne    r5, #037h, test3
        cjne    r6, #002h, test3
        cjne    r7, #02bh, test3
        clr     acc.2
test3:  push    acc
        mov     40H, #000h
        mov     41H, #020h
        mov     30H, #000h
        mov     31H, #004h
        call    subtract
        pop     acc
        setb    acc.3
        cjne    r4, #000h, test4
        cjne    r5, #000h, test4
        cjne    r6, #000h, test4
        cjne    r7, #008h, test4
        clr     acc.3
test4:  push    acc
        mov     40H, #007h
        mov     41H, #0a9h
        mov     30H, #000h
        mov     31H, #003h
        call    subtract
        pop     acc
        setb    acc.4
        cjne    r4, #000h, eot
        cjne    r5, #002h, eot
        cjne    r6, #002h, eot
        cjne    r7, #08dh, eot
        clr     acc.4
eot:  
uFail:   jnz     $
uPass:   sjmp    $

subtract:


start:	MOV		RH, 	#0
		MOV 	RLO,		#0			;set remainder to 0
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
		RET 	 						;halt the program

END
