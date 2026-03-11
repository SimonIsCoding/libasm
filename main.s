%include "asm_header.inc"
extern  SYM(printf)
extern  SYM(ft_strlen)
extern  SYM(ft_strcpy)
extern  SYM(ft_strcmp)
extern	SYM(ft_write)
global  SYM(main)
default rel

SYM(main):
    push	rbp
    mov		rbp, rsp

	lea		rdi, [message]
	call	SYM(ft_strlen)
	mov		rsi, rax
	lea		rdi, [result_strlen]
	CALL(SYM(printf))
	xor		rax, rax

	lea		rdi, [dest]
	lea		rsi, [src]
	call	SYM(ft_strcpy)
	lea		rdi, [result_strcpy]
	mov		rsi, rax
	CALL(SYM(printf))
	xor		rax, rax

    lea     rdi, [s1]
    lea     rsi, [s2]
    call    SYM(ft_strcmp)
    lea     rdi, [result_strcmp]
    mov		esi, eax
    xor		eax, eax
    CALL(SYM(printf))
    xor		eax, eax

	mov		edi, 1
	lea		rsi, [buf]
	mov		edx, 40
	CALL(SYM(ft_write))
	xor 	eax, eax
	
	pop		rbp
    ret

section .data
message: 		db "This is an incredible test", 0
result_strlen:	db "Result of ft_strlen: %d", 10, 0

dest:			db "abcdef", 0
src:			db "this is a test", 0
result_strcpy:	db "Result of ft_strcpy: %s", 10, 0

s1:				db "abcd", 0
s2:				db "abcz", 0
result_strcmp:	db "Result of ft_strcmp: %d", 10, 0

buf:			db "I am using write function to write this", 10