global _main
global _ft_strcpy
extern _printf
default rel

section .text

_ft_strcpy:
	xor rax, rax
	xor rdx, rdx

strcpy_loop:
	cmp byte [rsi + rax], 0
	je strcpy_end

	mov cl, [rsi + rdx]
	mov [rdi + rax], cl
	inc rax
	inc rdx
	jmp strcpy_loop

strcpy_end:
	mov byte [rdi + rax], 0
	mov rax, rdi
	ret

_main:
	lea rdi, [dest]
	lea rsi, [src]
	call _ft_strcpy

	mov rdi, rax
	call _printf
	xor rax, rax
	ret

section .data

dest: db "empty", 0
src: db "this is a test", 0