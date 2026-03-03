ft_strlen(const char *dest, const char *src)

const char dest[512];
const char src[512]	= "this is a test";
ft_strcpy(dest, src)
printf("dest = %s\n", dest);
printf("src = %s\n", src);

En gros le but est de copier s2, dans s1 et de retourner s1 bien redefinie a la fin

global _main
global _ft_strcpy
extern _printf
default rel

section .text

_ft_strcpy:
;	lea rdi [dest] // pas besoin de les ecrire car lors de l'appel de la fonction, ca sera directement charge par main
;	lea rsi [src]
	xor rax, rax

strcpy_loop:
	cmp byte [rsi + rax], 0
	je strcpy_end

	mov cl, [rsi + rdx]
	mov [rdi + rax], cl
	inc rax
	jmp strcpy_loop

strcpy_end:
	mov byte [rdi + rax], 0
	mov rax, rdi
	ret

_main:
	

section .data

src: db "this is a test", 0
dest: db "empty", 0