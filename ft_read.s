;ssize_t     read(int fildes, void *buf, size_t nbyte);
%include "asm_header.inc"
global	SYM(ft_read)
extern	___error

section .text
SYM(ft_read):
	mov		rax, SYS_READ
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