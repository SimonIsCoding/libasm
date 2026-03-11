%include "asm_header.inc"
global SYM(ft_write)
%ifdef __APPLE__
	extern	___error
%else
	extern	__errno_location
%endif

section .text
SYM(ft_write):
	mov		rax, SYS_WRITE
	syscall
	%ifdef __APPLE__
		jc		.error
	%else
		test	rax, rax
		js		.error
	%endif
	ret

.error:
	%ifdef __APPLE__
		push	rax
		call	___error
	%else
		neg		rax
		push	rax
		call	__errno_location WRT ..plt
	%endif
	pop		rcx
	mov     dword [rax], ecx
	mov		rax, -1
	ret