section .data
		eq_msg	db		"Equal!", 0x0A
		eq_len	equ		$ - eq_msg
		ne_msg	db		"Not Equal!", 0x0A
		ne_len	equ		$ - ne_msg

section	.bss
		a		resb	1
		b		resb	1

section .text
		global	_start

_start:
		mov		rax,	0
		mov		rdi,	0
		mov		rsi,	a
		mov		rdx,	1
		syscall					; read(STDIN, &a, 1)
		
		sub		rsp,	1

		mov		rax,	0
		mov		rdi,	0
		mov		rsi,	rsp
		mov		rdx,	1
		syscall					; getchar()

		add		rsp,	1

		mov		rax,	0
		mov		rdi,	0
		mov		rsi,	b
		mov		rdx,	1
		syscall					; read(STDIN, &b, 1)

		sub		rsp,	1

		mov		rax,	0
		mov		rdi,	0
		mov		rsi,	rsp
		mov		rdx,	1
		syscall					; getchar()
		
		add		rsp,	1

		mov		al,		[a]
		mov		bl,		[b]
		cmp		al,		bl
		je		equal			; if a == b goto equal

		mov		rax,	1		; else
		mov		rdi,	1
		mov		rsi,	ne_msg
		mov		rdx,	ne_len
		syscall					; write(STDOUT, ne_msg, ne_len)

		mov		rdi,	1		; return code = 1
		jmp		end

equal:
		mov		rax,	1
		mov		rdi,	1
		mov		rsi,	eq_msg
		mov		rdx,	eq_len
		syscall					; write(STDOUT, eq_msg, eq_len)

		mov		rdi,	0		; return code = 0

end:
		mov		rax,	60
		syscall					; exit(rdi)

