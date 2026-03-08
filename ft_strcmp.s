%include "asm_header.inc"
global  SYM(main)
global  SYM(ft_strcmp)
extern  SYM(printf)
default rel

section .text

SYM(ft_strcmp):
                    ; on zero eax proprement (pas de dépendance 64-bit)

.loop:
            ; al = *s1 (unsigned)
	        ; cl = *s2 (unsigned)
    
    jne     .done                   ; caractères différents → calcul du résultat
    
    je      .done                   ; '\0' atteint → fin de chaîne, résultat = 0


    jmp     .loop

.done:
    sub     eax, ecx                ; retourne s1[i] - s2[i] (signé, mais valeurs unsigned)
    ret

SYM(main):
    lea     rdi, [s1]
    lea     rsi, [s2]
    call    SYM(ft_strcmp)

    lea     rdi, [result]
                    ; printf arg2 = résultat (32-bit suffit)
                    ; 0 registres vectoriels utilisés (ABI)
    call    SYM(printf)

                    ; exit code 0
    ret

section .data
s1:     db  "abcd", 0
s2:     db  "abcz", 0
result: db  "Result of ft_strcmp is: %d", 10, 0