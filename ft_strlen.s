global _ft_strlen
global _main
extern _printf

section .text

_ft_strlen:
	xor rax, rax

strlen_loop:
	mov al, [rdi + rax]
	cmp al, 0
	je strlen_end

	inc rax
	jmp strlen_loop
strlen_end:
	ret

_main:
	mov rdi, message
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