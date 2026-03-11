# libasm — x86-64 Assembly Library

![Language](https://img.shields.io/badge/language-x86--64%20Assembly-blue)
![Format](https://img.shields.io/badge/assembler-NASM%20%7C%20Intel%20syntax-orange)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

A 42 School project implementing standard C library functions from scratch in x86-64 NASM assembly.
Built and tested on **macOS (Apple Silicon)** and **Linux (Ubuntu)**. Not tested on Windows.

> Personal notes that helped build this project (registers, syscalls, stack alignment, instructions reference):
> [Assembly Notes — Notion](https://www.notion.so/Assembly-3116fbb80b5a809d92e3d991554c5205?source=copy_link)

## Final score
<div align="center">
	<img src="https://github.com/SimonIsCoding/utils_and_random/blob/main/100_100.png" width="50"/>
</div>
---

## Functions implemented

| Function | C prototype |
|----------|-------------|
| `ft_strlen` | `size_t strlen(const char *s)` |
| `ft_strcpy` | `char *strcpy(char *dst, const char *src)` |
| `ft_strcmp` | `int strcmp(const char *s1, const char *s2)` |
| `ft_write` | `ssize_t write(int fd, const void *buf, size_t nbyte)` |
| `ft_read` | `ssize_t read(int fd, void *buf, size_t nbyte)` |
| `ft_strdup` | `char *strdup(const char *s1)` |


## Architecture

```
libasm/
├── Makefile
├── ft_strlen.s       # String length
├── ft_strcpy.s       # String copy
├── ft_strcmp.s       # String comparison
├── ft_strdup.s       # String duplication (calls malloc)
├── ft_read.s         # read(2) syscall wrapper with errno
├── ft_write.s        # write(2) syscall wrapper with errno
└── main.c            # Test program (not submitted, for validation)
```

Each function lives in its own `.s` file and is exposed as a global symbol. The Makefile handles platform detection (macOS vs Linux) to select the correct output format (`macho64` or `elf64`) and linking flags.

---

## How to compile

### Prerequisites

**macOS**
```bash
brew install nasm
xcode-select --install
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt update && sudo apt install nasm gcc
```


### Build

```bash
git clone https://github.com/simoniscoding/libasm.git
cd libasm
make		# produces libasm.a
```

This produces `libasm.a`, the static library archive.

```bash
make test   # builds and runs the test binary
make clean  # remove object files
make fclean # remove object files + libasm.a
make re     # fclean + full rebuild
```

The Makefile automatically detects the OS and applies the correct flags — no manual configuration needed.

### Platform differences at a glance

| | macOS | Linux |
|--|-------|-------|
| NASM format | `-f macho64` | `-f elf64` |
| Preprocessor flag | `-D __APPLE__` | _(none)_ |
| Symbol prefix | `_ft_strlen` (with underscore) | `ft_strlen` (no underscore) |
| errno accessor | `___error()` | `__errno_location()` |
| Error detection after syscall | Carry Flag (`CF=1`) | Negative `rax` |
| Compiler command | `arch -x86_64 cc` | `cc` |

---

## What happens during compilation — step by step

In C, `gcc main.c -o program` handles everything silently in one command. In assembly, you see each step explicitly. Here is what `make` actually does and why.

### Step 1 — `nasm` : source → object file

```bash
nasm -f macho64 -D __APPLE__ ft_strlen.s -o ft_strlen.o
```

NASM reads the `.s` source file and produces a **binary object file** (`.o`).

An object file contains machine code that the CPU can execute — but it is **not a complete program yet**. It has unresolved references: `ft_strlen.o` does not know where `malloc` or `printf` live in memory. These will be resolved later.

Flags:
- `-f macho64` / `-f elf64` — output format (macOS vs Linux binary format)
- `-D __APPLE__` — defines a preprocessor macro, so `%ifdef __APPLE__` blocks in the source are activated

### Step 2 — `ar` : object files → static library

```bash
ar rcs libasm.a ft_strlen.o ft_strcpy.o ft_strcmp.o ft_write.o ft_read.o ft_strdup.o
```

`ar` (archiver) bundles multiple `.o` files into a single **static library** file (`libasm.a`).
A static library is essentially a zip file of object files with a symbol index.

When you later link against it, the linker picks only the `.o` files it actually needs — it does not blindly include everything.

Flags:
- `r` — insert/replace members in the archive
- `c` — create the archive if it does not exist
- `s` — write a symbol index (speeds up linking)

### Step 3 — `cc` : link everything into an executable

```bash
arch -x86_64 cc main.o libasm.a -o test_libasm
```

The **linker** resolves all unresolved references:
- `ft_strlen` referenced in `main.o` → found in `libasm.a`
- `malloc`, `printf` → found in the system's `libc` (linked automatically)
- `___error` (macOS) / `__errno_location` (Linux) → also in `libc`

It then combines everything into a single self-contained executable.

### Why so many steps compared to C?

In C, `gcc main.c` runs four internal phases: preprocessor → compiler → assembler → linker. You never see them.

In this project, your `.s` files **are** the assembly — there is no higher-level compilation. NASM is only an assembler: it converts text to machine code. Archiving and linking are separate, explicit operations. Writing in assembly means working at the level that C compilers target.

---

## Cross-platform strategy

A single `asm_header.inc` handles all OS differences at compile time:

```nasm
%ifdef __APPLE__
    %define SYM(x)    _ %+ x          ; macOS requires a leading underscore on symbols
    %define CALL(x)   call x
    %define SYS_READ  0x2000003
    %define SYS_WRITE 0x2000004
%else
    %define SYM(x)    x
    %define CALL(x)   call x WRT ..plt ; Linux requires PLT for shared library calls
    %define SYS_READ  0
    %define SYS_WRITE 1
%endif
```

The Makefile passes `-D __APPLE__` on macOS, so the preprocessor selects the right block at compile time. There is no runtime branching — zero overhead.

---

## Functions — logic and implementation

### `ft_strlen`

```c
size_t strlen(const char *s);
```

- Initializes a counter (`rax`) to 0
- Reads one byte at a time via `[rdi]` (dereferencing the pointer)
- Increments the counter until `'\0'` is found
- Returns the count in `rax`

```nasm
SYM(ft_strlen):
    xor   rax, rax          ; counter = 0
.loop:
    cmp   byte [rdi], 0     ; is current byte '\0' ?
    je    .done
    inc   rdi               ; move to next character
    inc   rax               ; increment length
    jmp   .loop
.done:
    ret                     ; rax = length
```

---

### `ft_strcpy`

```c
char *strcpy(char *dst, const char *src);
// Copies src into dst byte by byte, including '\0'
// Returns the original dst pointer
```

- Saves the original `dst` address in `rax` immediately (it is the return value)
- Copies each byte from `src` (`rsi`) to `dst` (`rdi`)
- Uses `test cl, cl` to check if the just-copied byte was `'\0'` — this handles the null terminator inside the loop, with no separate cleanup needed

```nasm
SYM(ft_strcpy):
    mov   rax, rdi          ; save original dst for return
.loop:
    mov   cl, [rsi]         ; read one byte from src
    mov   [rdi], cl         ; write it to dst
    inc   rsi
    inc   rdi
    test  cl, cl            ; was it '\0' ?
    jnz   .loop             ; if not, continue
    ret                     ; rax = original dst
```

---

### `ft_strcmp`

```c
int strcmp(const char *s1, const char *s2);
// Returns 0 if equal, positive if s1 > s2, negative if s1 < s2
```

- Uses `movzx` (Move with Zero eXtend) to read each byte into a 32-bit register — this avoids sign-extension issues with bytes above 127
- Compares the two bytes with `cmp`
- Stops when they differ or when `'\0'` is reached
- Returns `s1[i] - s2[i]`

```nasm
SYM(ft_strcmp):
.loop:
    movzx eax, byte [rdi]   ; read byte from s1, zero-extended to 32 bits
    movzx ecx, byte [rsi]   ; read byte from s2
    cmp   eax, ecx
    jne   .done             ; characters differ → stop
    test  eax, eax
    je    .done             ; '\0' reached → stop
    inc   rdi
    inc   rsi
    jmp   .loop
.done:
    sub   eax, ecx          ; return difference
    ret
```

---

### `ft_write`

```c
ssize_t write(int fd, const void *buf, size_t nbyte);
// Returns bytes written, or -1 on error (errno is set)
```

- `write` is a **syscall** — a direct request to the OS kernel, not a libc function
- The syscall number goes into `rax` before `syscall` is executed
- Arguments `rdi`, `rsi`, `rdx` are already set by the caller — no move needed
- Error detection differs by OS:
  - **macOS**: the kernel sets the Carry Flag (`CF=1`) on error; `rax` contains the error code
  - **Linux**: the kernel returns a negative value in `rax` (specifically `-errno`)
- On error: calls `___error()` (macOS) or `__errno_location()` (Linux) to get a pointer to `errno`, stores the error code there, then returns `-1`

```nasm
SYM(ft_write):
    mov   rax, SYS_WRITE    ; syscall number (OS-dependent via macro)
    syscall
%ifdef __APPLE__
    jc    .error            ; Carry Flag set = error on macOS
%else
    test  rax, rax
    js    .error            ; negative rax = error on Linux
%endif
    ret                     ; success: rax = bytes written

.error:
%ifdef __APPLE__
    push  rax               ; save error code (rax will be overwritten by ___error)
    call  ___error          ; returns pointer to errno in rax
%else
    neg   rax               ; make error code positive
    push  rax
    call  __errno_location WRT ..plt
%endif
    pop   rcx               ; restore error code into rcx
    mov   dword [rax], ecx  ; *errno = error_code (errno is a 32-bit int → dword)
    mov   rax, -1
    ret
```

---

### `ft_read`

```c
ssize_t read(int fd, void *buf, size_t nbyte);
// Returns bytes read, or -1 on error (errno is set)
```

Identical structure to `ft_write`. The only difference is the syscall number (`SYS_READ`):
- macOS: `0x2000003`
- Linux: `0`

Everything else — argument registers, error detection, errno handling — is the same.

---

### `ft_strdup`

```c
char *strdup(const char *s1);
// Allocates a copy of s1. Returns the new pointer, or NULL if malloc fails.
```

Chains three operations: `ft_strlen` → `malloc` → `ft_strcpy`.

The central challenge: `rdi` (the pointer to `s1`) is destroyed by each function call. It must be saved before the first call and restored before the last one.

Strategy:
- `push rdi` saves `s1` on the stack — this also realigns `RSP` to 16 bytes for the subsequent calls
- After `malloc`, `pop rsi` restores `s1` as the source for `ft_strcpy`
- After the `pop`, `RSP` is back to `16n+8` (misaligned) — a `sub rsp, 8` re-aligns it before the final call

```nasm
SYM(ft_strdup):
    push  rdi               ; save s1 — also aligns RSP from 16n+8 to 16n
    CALL(SYM(ft_strlen))    ; rax = strlen(s1)
    mov   rdi, rax
    inc   rdi               ; rdi = strlen + 1  (room for '\0')
    CALL(SYM(malloc))       ; rax = new buffer (or NULL)
    test  rax, rax
    jz    .error            ; malloc failed → return NULL
    pop   rsi               ; restore s1 as source for strcpy
    mov   rdi, rax          ; destination = malloc result
    sub   rsp, 8            ; re-align stack (RSP is 16n+8 after the pop)
    CALL(SYM(ft_strcpy))    ; copy s1 into new buffer; rax = buffer pointer
    add   rsp, 8
    ret

.error:
    pop   rdi               ; restore stack balance
    xor   rax, rax          ; return NULL
    ret
```

---

## What I learned — Registers explained from the ground up

### What is a register?

Imagine the CPU as a chef in a kitchen. The chef can only cook with ingredients that are on the counter in front of them — not in the fridge (RAM) or the pantry (disk). **Registers are that counter.**

More precisely:
- A register is a tiny memory slot built directly into the CPU chip
- The CPU can only perform operations (add, compare, copy) on values that are in registers
- They are roughly 100x faster than RAM
- There are a fixed number of them — around 16 general-purpose registers on x86-64

When you write a C variable like `int x = 5;`, the compiler decides when to load `5` into a register to do math on it, and when to store the result back to RAM. In assembly, **you decide everything yourself**.

---

### The main registers and their roles

The System V AMD64 ABI (the calling convention used on Linux and macOS) assigns a purpose to each register:

| Register | Role |
|----------|------|
| `rax` | Return value / syscall number |
| `rdi` | 1st function argument |
| `rsi` | 2nd function argument |
| `rdx` | 3rd function argument |
| `rcx` | 4th function argument |
| `r8` | 5th function argument |
| `r9` | 6th function argument |
| `rsp` | Stack pointer — always points to the top of the call stack |
| `rbp` | Base pointer — marks the bottom of the current function's stack frame |
| `rip` | Instruction pointer — holds the address of the next instruction to execute |

This means that when C code calls `write(1, buf, 40)`:
- `1` goes into `rdi`
- `buf` goes into `rsi`
- `40` goes into `rdx`
- The return value comes back in `rax`

Your assembly function receives them already in the right registers.

---

### Register sizes — adapting to C variable types

Every 64-bit register has four "windows" that let you access different portions of it:

```
rax  (64 bits — 8 bytes)
╔══════════════════════════════════════════════════════════════╗
║                                          eax (32 bits)       ║
║                                    ┌──────────────────────┐  ║
║                                    │      ax (16 bits)    │  ║
║                                    │  ┌───────────────┐   │  ║
║                                    │  │   al (8 bits) │   │  ║
║                                    │  └───────────────┘   │  ║
║                                    └──────────────────────┘  ║
╚══════════════════════════════════════════════════════════════╝
```

These are **not separate registers** — they are different views into the same hardware.
Writing to `al` modifies the low byte of `rax`. Writing to `eax` modifies the low 32 bits of `rax`.

Full register size table:

| 64-bit | 32-bit | 16-bit | 8-bit | Typical C type |
|--------|--------|--------|-------|----------------|
| `rax` | `eax` | `ax` | `al` | `long` / pointer |
| `rbx` | `ebx` | `bx` | `bl` | `long` / pointer |
| `rcx` | `ecx` | `cx` | `cl` | `long` / pointer |
| `rdx` | `edx` | `dx` | `dl` | `long` / pointer |
| `rsi` | `esi` | `si` | `sil` | `long` / pointer |
| `rdi` | `edi` | `di` | `dil` | `long` / pointer |
| `r8` | `r8d` | `r8w` | `r8b` | `long` / pointer |
| `r9` | `r9d` | `r9w` | `r9b` | `long` / pointer |

### Choosing the right size to match C types

| C type | Size | Register portion | Memory size keyword |
|--------|------|-----------------|---------------------|
| `char` | 1 byte | `al`, `cl`, `bl` | `byte` |
| `short` | 2 bytes | `ax`, `cx` | `word` |
| `int` | 4 bytes | `eax`, `ecx` | `dword` |
| `long` / pointer | 8 bytes | `rax`, `rdi` | `qword` |

**Concrete example from this project:** `errno` is a C `int` (4 bytes). Writing it incorrectly:

```nasm
mov qword [rax], rcx   ; writes 8 bytes → corrupts 4 bytes beyond errno ❌
mov dword [rax], ecx   ; writes exactly 4 bytes → correct ✓
```

---

### Stack alignment rule (ABI)

The x86-64 ABI requires that `RSP` (the stack pointer) is **16-byte aligned** immediately before any `call` instruction.

At function **entry**, `RSP` is always misaligned by 8 — because the `call` that got you here pushed an 8-byte return address onto the stack.

```
Before call (in caller): RSP = 16n     ← aligned
call executes:           RSP = 16n - 8  ← pushes return address
At function entry:       RSP = 16n - 8  ← misaligned by 8
```

This is why `push rbp` at the start of a function is almost universal — it pushes 8 more bytes, restoring alignment, while also saving the base pointer.

Violating this rule causes crashes in functions that use SSE/AVX instructions (which require 16-byte alignment) — including `malloc` on some platforms.

---
