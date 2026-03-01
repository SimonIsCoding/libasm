global _ft_strlen
global _main
extern _printf
default rel

section .text

_ft_strlen:
	xor rax, rax

strlen_loop:
	cmp byte [rdi + rax], 0
	je strlen_end

	inc rax
	jmp strlen_loop
strlen_end:
	ret

_main:
	lea rdi, [rel message]
	call _ft_strlen

	; print the value
	mov rsi, rax
	lea rdi, [rel format]
	xor rax, rax
	call _printf

	xor rax, rax
	ret

section .data

message: db "TEST123", 0
format:
	db "%d", 0