%include "asm_header.inc"
global SYM(ft_write)
extern ___error
default rel

;ssize_t		write(int fildes, const void *buf, size_t nbyte);

section .text
SYM(ft_write):
	mov		rax, SYS_WRITE
	syscall
	jc		.error
	ret

.error:
	push	rax
	call	___error
	pop		rcx
	mov     dword [rax], ecx
	mov		rax, -1
	ret