;assuming scancode is in R2.
;assuming shift status in R1. Shift = 0, unshifted = 1

		mov a,r2
		clr c
		subb a,#minkey
		rlc a				;multiply by two due to cols
		add a,#keytab			;adding address of keytab(offset)
		add a,r1
		mov r0,a
		mov a,@r0
		;at this point, A has the value in the table.
