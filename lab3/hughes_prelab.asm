		mov		a,scancode			; get scancode
		clr		c
		subb	a,#minkey			; smaller than minkey?
		jc		done				: yes
		mov		dptr,#keytab		; assume no control key
		jnb		cntlstate,next		; control key not be
		mov		dptr,#keytab
next:	mov		c shiftstate
		rlc		a
		movc	a,@a+dptr
		jbc		acc.7,special
		
