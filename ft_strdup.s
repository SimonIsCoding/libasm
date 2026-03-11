%include "asm_header.inc"
global	SYM(ft_strdup)
extern	SYM(malloc)
extern	SYM(ft_strlen)
extern	SYM(ft_strcpy)

;void *malloc(size_t size);
;char *strdup(const char *s1);
;Calcule la longueur de s1 (strlen + 1 pour le '\0')
;Alloue cette taille avec malloc
;Copie s1 dans la mémoire allouée
;Retourne le pointeur vers la nouvelle chaîne (ou NULL si malloc échoue)

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