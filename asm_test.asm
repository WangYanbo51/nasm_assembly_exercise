section .data
		msg		db		"Hello, World!", 0x0A
		len		equ		$ - msg

stime:
		dq		1
		dq		0

section .text
		global	_start

_start:
		mov		rax, 1
		mov		rdi, 1
		mov		rsi, msg
		mov		rdx, len
		syscall				; write(stdout, msg, len)

		mov		rax, 35
		mov		rdi, stime
		syscall				; nanosleep(sleep_time, NULL)

		mov		rax, 60
		xor		rdi, rdi
		syscall				; exit(0)


