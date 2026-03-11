%include "asm_header.inc"
extern  SYM(printf)
extern  SYM(ft_strlen)
extern  SYM(ft_strcpy)
extern  SYM(ft_strcmp)
global  SYM(main)
default rel

SYM(main):
    push rbp
    mov rbp, rsp

	lea rdi, [message]
	call SYM(ft_strlen)
	mov rsi, rax
	lea rdi, [format]
	xor rax, rax
	CALL(SYM(printf))
	xor rax, rax

	lea rdi, [dest]
	lea rsi, [src]
	call SYM(ft_strcpy)
	mov rdi, rax
	CALL(SYM(printf))
	xor rax, rax

    lea     rdi, [s1]
    lea     rsi, [s2]
    call    SYM(ft_strcmp)
    lea     rdi, [result]
    mov		esi, eax
    xor		eax, eax
    CALL(SYM(printf))
    xor eax, eax
	pop rbp
    ret

section .data
message: db "This is an incredible test", 0
format:	db "Result: %d", 10, 0

;dest: db "abcdefghijklmno", 10, 0
dest: times 64 db 0
src: db "this is a test", 10, 0

s1:     db  "abcd", 0
s2:     db  "abcz", 0
result: db  "Result of ft_strcmp is: %d", 10, 0
