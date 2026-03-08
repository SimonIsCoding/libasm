global  _main
global  _ft_strcmp
extern  _printf
default rel

section .text

_ft_strcmp:
    xor     eax, eax                ; on zero eax proprement (pas de dépendance 64-bit)

.loop:
    movzx   eax, byte [rdi]         ; al = *s1 (unsigned)
    movzx   ecx, byte [rsi]         ; cl = *s2 (unsigned)
    cmp     eax, ecx
    jne     .done                   ; caractères différents → calcul du résultat
    test    eax, eax
    je      .done                   ; '\0' atteint → fin de chaîne, résultat = 0
    inc     rdi
    inc     rsi
    jmp     .loop

.done:
    sub     eax, ecx                ; retourne s1[i] - s2[i] (signé, mais valeurs unsigned)
    ret

; --- main de test ---
_main:
    lea     rdi, [s1]
    lea     rsi, [s2]
    call    _ft_strcmp

    lea     rdi, [result]
    mov     esi, eax                ; printf arg2 = résultat (32-bit suffit)
    xor     eax, eax                ; 0 registres vectoriels utilisés (ABI)
    call    _printf

    xor     eax, eax                ; exit code 0
    ret

section .data
s1:     db  "abcd", 0
s2:     db  "abcz", 0
result: db  "Result of ft_strcmp is: %d", 10, 0