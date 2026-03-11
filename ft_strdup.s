%include "asm_header.inc"
global	SYM(ft_strdup)
extern	SYM(malloc)
extern	SYM(ft_strlen)
extern	SYM(ft_strcpy)

section	.text
SYM(ft_strdup):
	push	rdi
	CALL(SYM(ft_strlen))
	mov		rdi, rax
	inc		rdi
	CALL(SYM(malloc))
	test	rax, rax
	jz		.error
	pop		rsi
	mov		rdi, rax
	sub     rsp, 8
	CALL(SYM(ft_strcpy))
	add     rsp, 8
	ret

.error:
	pop		rdi
	xor		rax, rax
	ret