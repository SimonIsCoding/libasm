%include "asm_header.inc"
global SYM(ft_strcpy)
default rel

section .text

SYM(ft_strcpy):
	mov		rax, rdi

.loop:
	mov		cl, [rsi]
	mov		[rdi], cl
	inc		rsi
	inc		rdi
	test	cl, cl
	jnz		.loop	;jump if not Zero

	ret