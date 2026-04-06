section	.data
		arr			dd			1, 2, 3, 4
		len			equ			($ - arr) / 4
		msg			db			"sum = "
		msg_len		equ			$ - msg
		newline		db			0x0A


section .bss
		buffer		resb		16

section	.text
global	_start

_start:
		xor			eax,		eax		; eax: sum
		mov			rcx,		len		; rcx: counter
		mov			rsi,		arr		; rsi = arr

_loop:
		add			eax,		[rsi]	; sum += a[i]
		add			rsi,		4		; i++ double word
		loop		_loop				

		mov			r8,			buffer + 15		; fill from buffer tail
		mov			byte [r8],	0				; fill with '\0'
		mov			ecx,		10				; divisor
		mov			ebx,		eax

		test		ebx,		ebx		; if sum != 0
		jnz			convert
										; else
		dec			r8
		mov			byte [r8],	'0'		; buffer[14] = '0', buffer[15] = '\0'
		jmp			output

convert:
		xor			edx,		edx		; edx = 0
		div			ecx					; eax = eax / 10, edx = eax % 10
		add			dl,			'0'		; dl += '0'

		dec			r8					; i --
		mov			[r8],		dl		; dl -> *edi
		test		eax,		eax		; if eax != 0
		jnz			convert

output:
		mov			rax,		1
		mov			rdi,		1
		mov			rsi,		msg
		mov			rdx,		msg_len
		syscall

		mov			rax,		1
		mov			rdi,		1
		mov			rsi,		r8
		mov			rdx,		buffer + 15
		sub			rdx,		r8
		syscall

		mov			rax,		1
		mov			rdi,		1
		mov			rsi,		newline
		mov			rdx,		1
		syscall

exit:
		mov			rax,		60
		mov			rdi,		0
		syscall

