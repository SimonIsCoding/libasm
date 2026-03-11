%include "asm_header.inc"
global SYM(ft_write)
extern ___error
default rel

;ssize_t		write(int fildes, const void *buf, size_t nbyte);

section .text
	lea		[rdi]