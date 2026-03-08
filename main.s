%include "asm_header.inc"
extern  SYM(printf)
extern  SYM(ft_strlen)
extern  SYM(ft_strcpy)
extern  SYM(ft_strcmp)
global  SYM(main)
default rel

;main for ft_strlen:
;SYM(main):
;	lea rdi, [message]
;	call SYM(ft_strlen)
;
;	mov rsi, rax
;	lea rdi, [format]
;	xor rax, rax
;	call SYM(printf)
;
;	xor rax, rax
;	ret
;
;section .data
;
;message: db "This is an incredible test", 0
;format:	db "Result: %d", 10, 0

;main for strcpy:
;SYM(main):
;	lea rdi, [dest]
;	lea rsi, [src]
;	call _ft_strcpy
;
;	mov rdi, rax
;	call SYM(printf)
;	xor rax, rax
;	ret
;
;section .data
;
;dest: db "empty", 0
;src: db "this is a test", 0