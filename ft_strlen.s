%include "asm_header.inc"
global  SYM(ft_strlen)
default rel

section .text

SYM(ft_strlen):
	xor 	rax, rax

.loop:
	cmp 	byte [rdi], 0
	je 		.done
	inc 	rdi
	inc		rax
	jmp 	.loop

.done:
	ret