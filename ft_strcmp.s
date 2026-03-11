%include "asm_header.inc"
global  SYM(ft_strcmp)
extern  SYM(printf)
default rel

section .text

SYM(ft_strcmp):

.loop:
    movzx	eax, byte [rdi]
	movzx	ecx, byte [rsi]
    cmp		eax, ecx
    jne     .done
    test	eax, eax
    je      .done
	inc		rdi
	inc		rsi
    jmp     .loop

.done:
    sub     eax, ecx
    ret