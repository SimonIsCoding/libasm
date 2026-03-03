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
	lea rdi, [message]
	call _ft_strlen

	mov rsi, rax
	lea rdi, [format]
	xor rax, rax
	call _printf

	xor rax, rax
	ret

section .data

message: db "This is an incredible test", 0
format:
	db "Result: %d", 10, 0