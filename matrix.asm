section .data
		matrix1_msg	db				"matrix1: ", 0x0A
		m1_msg_len	equ				$ - matrix1_msg
		matrix2_msg	db				"matrix2: ", 0x0A
		m2_msg_len	equ				$ - matrix2_msg

		row_msg		db				"row: "
		row_len		equ				$ - row_msg
		col_msg		db				"col: "
		col_len		equ				$ - col_msg

		newline		db				0x0A
		space		db				" "

section .bss
		m1_rows		resb			1
		m1_cols		resb			1
		m2_rows		resb			1
		m2_cols		resb			1
		matrix1		resb			1000
		matrix2		resb			1000	
		matrix_res	resb			1000
		buf			resb			100			; temporary buffer
		num			resb			1
		pos			resb			1

section .text
global _start


;-----------------------------------
; descript: print string
; params:	rsi: source
;			rdx: len
; return:	void
; bss:		none
;-----------------------------------
print:
		mov			rax,			1
		mov			rdi,			1
		syscall
		ret

;-----------------------------------
; descript: print new line (\n)
; params:	void
; return:	void
; bss:		void
;-----------------------------------
newl:
		mov			rax,			1
		mov			rdi,			1
		mov			rsi,			newline
		mov			rdx,			1
		syscall
		ret

;-----------------------------------
; descript:	read line to buf
; params:	void
; return:	void
; bss:		buf
;-----------------------------------
read_line:
		mov			rax,			0
		mov			rdi,			0
		mov			rsi,			buf
		mov			rdx,			100
		syscall
		ret

;-----------------------------------
; descript:	print num
; params:	rax: number
; return:	void
; bss:		void
;-----------------------------------
print_num:
		push		rbx

		mov			rcx,			10		; divisor
		mov			rbx,			rsp
		sub			rsp,			16
		dec			rbx
		mov			byte [rbx],		0
next:
		xor			rdx,			rdx
		div			rcx						; rax = rax / 10, rdx = rax % 10
		add			dl,				'0'		; dl += '0'
		dec			rbx						; rbx--
		mov			[rbx],			dl		; *rbx = dl
		test		rax,			rax		; if rax != 0
		jnz			next

		mov			rsi,			rbx
		mov			rdx,			rsp
		add			rdx,			16
		sub			rdx,			rbx		; len = rsp - rbx
		dec			rdx

		mov			rax,			1
		mov			rdi,			1
		syscall								; print

		add			rsp,			16		; restore rsp
		pop			rbx
		ret

;-----------------------------------
; descript: parse a number from buffer pos
; params:	void
; return:	rax: number
; bss:		buf, pos
;-----------------------------------
parse_num:
		push		rbx
		mov			rsi,			buf		; rsi -> buf
		xor			rbx,			rbx
		mov			bl,				[pos]
		add			rsi,			rbx		; rsi -> buf + pos
		xor			rax,			rax
skip_space:
		mov			dl,				[rsi]	; current character -> dl
		cmp			dl,				' '
		je			skip_next
		cmp			dl,				0xA
		je			parse_done
		cmp			dl,				0
		je			parse_done
		jmp			parse_loop
skip_next:
		inc			rsi
		jmp			skip_space
parse_loop:
		sub			dl,				'0'
		imul		rax,			10
		movzx		rdx,			dl
		add			rax,			rdx		; rax = 10 * rax + dl

		inc			rsi
		mov			dl,				[rsi]
		cmp			dl,				' '
		je			parse_done
		cmp			dl,				0xA
		je			parse_done
		cmp			dl,				0
		je			parse_done
		jmp			parse_loop
parse_done:
		mov			rbx,			rsi
		sub			rbx,			buf
		mov			[pos],			bl
		
		pop			rbx
		ret


;-----------------------------------
; descript:	main
; params:	void
; return:	void
;-----------------------------------
_start:
		;---------- matrix1 ----------------
		mov			rsi,			matrix1_msg
		mov			rdx,			m1_msg_len
		call		print

		; input rows
		mov			rsi,			row_msg
		mov			rdx,			row_len
		call		print

		call		read_line

		mov			byte [pos],		0
		call		parse_num
		mov			[m1_rows],		al

		; input cols
		mov			rsi,			col_msg
		mov			rdx,			col_len
		call		print

		call		read_line

		mov			byte [pos],		0
		call		parse_num
		mov			[m1_cols],		al
		
		call		newl

		; input matrix1
		mov			r8,				0
input_m1_row:
		mov			r9,				0
		call		read_line
		mov			byte [pos],		0

input_m1_col:
		call		parse_num
		mov			r10,			rax

		movzx		rax,			byte [m1_cols]
		mul			r8
		add			rax,			r9
		; rax = rax * r8 + r9
		mov			rbx,			matrix1
		add			rbx,			rax
		mov			[rbx],			r10b

		inc			r9
		mov			al,				[m1_cols]
		cmp			r9b,			al
		jl			input_m1_col

		inc			r8
		mov			al,				[m1_rows]
		cmp			r8b,			al
		jl			input_m1_row

		call		newl

		;---------- matrix2 ------------------
		mov			rsi,			matrix2_msg
		mov			rdx,			m2_msg_len
		call		print

		; print m2 rows (m2_row = m1_col)
		mov			rsi,			row_msg
		mov			rdx,			row_len
		call		print
		
		movzx		rax,			byte [m1_cols]
		call		print_num
		call		newl

		mov			al,				[m1_cols]
		mov			[m2_rows],		al

		; input cols
		mov			rsi,			col_msg
		mov			rdx,			col_len
		call		print

		call		read_line

		mov			byte [pos],		0
		call		parse_num
		mov			[m2_cols],		al
		
		call		newl

		; input matrix2
		mov			r8,				0
input_m2_row:
		mov			r9,				0
		call		read_line
		mov			byte [pos],		0

input_m2_col:
		call		parse_num
		mov			r10,			rax

		movzx		rax,			byte [m2_cols]
		mul			r8
		add			rax,			r9
		; rax = rax * r8 + r9
		mov			rbx,			matrix2
		add			rbx,			rax
		mov			[rbx],			r10b

		inc			r9
		mov			al,				[m2_cols]
		cmp			r9b,			al
		jl			input_m2_col

		inc			r8
		mov			al,				[m2_rows]
		cmp			r8b,			al
		jl			input_m2_row

		call		newl

		;---------- multiply -----------------
		mov			r8,				0		; i
multi_row:
		mov			r9,				0		; j
multi_col:
		mov			r11,			0		; sum
		mov			r10,			0		; counter
multi_k:
		; matrix1[i][k]
		movzx		rax,			byte [m1_cols]
		mul			r8
		add			rax,			r10		; rax = i * m1_cols + k
		mov			rbx,			matrix1
		add			rbx,			rax
		movzx		rcx,			byte [rbx]	; rcx = matrix1[i][k]

		; matrix2[k][j]
		movzx		rax,			byte[m2_cols]
		mul			r10
		add			rax,			r9		; rax = k * m2_cols + j
		mov			rbx,			matrix2
		add			rbx,			rax
		movzx		rdx,			byte [rbx]	; rdx = matrix2[k][j]

		; multiply and add
		imul		rcx,			rdx
		add			r11,			rcx			; sum += rcx * rdx

		; k++	until k == m1_cols
		inc			r10
		mov			al,				[m1_cols]
		cmp			r10b,			al
		jl			multi_k

		; save sum -> res_matrix[i][j]
		movzx		rax,			byte [m2_cols]
		mul			r8
		add			rax,			r9			; rax = i * m2_cols + j
		mov			rbx,			matrix_res
		add			rbx,			rax
		mov			[rbx],			r11b

		; j++	until j == m2_cols
		inc			r9
		mov			al,				[m2_cols]
		cmp			r9b,			al
		jl			multi_col
		
		; i++	until i == m1_rows
		inc			r8
		mov			al,				[m1_rows]
		cmp			r8b,			al
		jl			multi_row

		; print matrix_res
		; matrix_res_rows = m1_rows
		; matrix_res_cols = m2_cols
		call		newl
		mov			r8,				0
print_row:
		mov			r9,				0
print_col:
		movzx		rax,			byte [m2_cols]
		mul			r8
		add			rax,			r9
		mov			rbx,			matrix_res
		add			rbx,			rax

		mov			al,				[rbx]
		movzx		rax,			al
		call		print_num

		mov			rsi,			space
		mov			rdx,			1
		call		print

		inc			r9
		mov			al,				[m2_cols]
		cmp			r9b,			al
		jl			print_col

		call		newl

		inc			r8
		mov			al,				[m1_rows]
		cmp			r8b,			al
		jl			print_row

exit:
		mov			rax,			60
		mov			rdi,			0
		syscall
