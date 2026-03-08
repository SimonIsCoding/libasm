%include "asm_header.inc"
global SYM(ft_strcpy)
default rel

section .text

SYM(ft_strcpy):
	xor rax, rax
	xor rdx, rdx

.loop:
	cmp byte [rsi + rax], 0
	je .done

	mov cl, [rsi + rdx]
	mov [rdi + rax], cl
	inc rax
	inc rdx
	jmp .loop

.done:
	mov byte [rdi + rax], 0
	mov rax, rdi
	ret