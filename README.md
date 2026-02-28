# libasm

![Language](https://img.shields.io/badge/language-x86--64%20Assembly-blue)
![Format](https://img.shields.io/badge/assembler-NASM%20%7C%20Intel%20syntax-orange)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

> A static library of standard C functions reimplemented from scratch in 64-bit x86 assembly, following the System V AMD64 calling convention.

---

## About the Project

`libasm` is a 42 School project that requires reimplementing a set of standard C library functions entirely in x86-64 assembly language, without any high-level abstractions. The goal is to understand what happens at the instruction level when a program calls `strlen`, `write`, or `strdup`.

Every function is written in pure NASM assembly using Intel syntax and compiled into a static archive (`libasm.a`). The project enforces strict constraints: no inline assembly, no external libraries, and full compliance with the System V AMD64 ABI calling convention — meaning register usage, stack alignment, and return values all follow the C ABI precisely.

Syscall wrappers (`ft_read`, `ft_write`) include proper error handling: on failure, the return value is `-1` and `errno` is set correctly by calling `___error` (macOS) or `__errno_location` (Linux).

---

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

### Calling Convention (System V AMD64 ABI)

| Purpose        | Registers used                              |
|----------------|---------------------------------------------|
| Arguments      | `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`     |
| Return value   | `rax`                                       |
| Caller-saved   | `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11` |
| Callee-saved   | `rbx`, `rbp`, `r12`–`r15`                  |

---

## Getting Started

### Prerequisites

**macOS**
```bash
# Install NASM via Homebrew
brew install nasm
```

> **Apple Silicon (M1/M2/M3) note:** This project targets x86-64 assembly. On ARM-based Macs, the Makefile automatically adds the cross-compilation flags (`--target=x86_64-apple-darwin` and `-ld_classic`) to produce a compatible binary via Rosetta 2. You need Xcode Command Line Tools installed.
>
> ```bash
> xcode-select --install
> ```

**Linux (Debian/Ubuntu)**
```bash
sudo apt update && sudo apt install nasm gcc
```

**Linux (Fedora/RHEL)**
```bash
sudo dnf install nasm gcc
```

### Build

```bash
git clone https://github.com/simonwillems/libasm.git
cd libasm
make
```

This produces `libasm.a`, the static library archive.

### Run the tests

```bash
# Compile the test binary against the library
gcc main.c -L. -lasm -o test_libasm

# macOS (Apple Silicon)
gcc main.c -L. -lasm -o test_libasm --target=x86_64-apple-darwin -ld_classic

./test_libasm
```

### Platform differences at a glance

| | macOS | Linux |
|---|---|---|
| NASM format | `-f macho64` | `-f elf64` |
| Symbol prefix | `_ft_strlen` (underscore) | `ft_strlen` (no underscore) |
| errno accessor | `___error` | `__errno_location` |

---

## What I Learned

**x86-64 register mechanics and calling conventions.** Working directly with registers (`rdi`, `rsi`, `rax`, etc.) made the C ABI concrete — not an abstraction but a real contract between caller and callee that breaks visibly if violated.

**Syscall interface vs. libc wrappers.** `read` and `write` aren't magic: they're thin wrappers around `syscall` instructions. Implementing them in assembly required understanding how the kernel returns errors (negative return values) and how `errno` is set via a thread-local pointer returned by `___error` / `__errno_location`.

**Cross-platform assembly: macOS vs Linux.** The same instruction set produces different binaries depending on the OS: symbol naming conventions differ (leading underscore on macOS), output formats differ (`macho64` vs `elf64`), and Apple Silicon adds a cross-compilation layer that doesn't exist on native x86 Linux. Debugging this gap was a significant part of the project.

**Reading system documentation.** Every function here has a man page (`man 2 read`, `man 3 strdup`). This project forced a habit of reading specs before writing code, not after.

**Low-level debugging with lldb/gdb.** Stepping through instructions one at a time, inspecting register values, and reading raw memory — skills that transfer directly to debugging production crashes, not just academic exercises.

---

<!--
## Bonus

> The bonus part requires a perfect mandatory grade to be evaluated.

The following functions are implemented in separate `_bonus.s` files and use the linked list structure below:

```c
typedef struct s_list {
    void        *data;
    struct s_list *next;
} t_list;
```

| Function | Description |
|---|---|
| `ft_atoi_base` | Converts a string to integer in a given base |
| `ft_list_push_front` | Prepends a node to a linked list |
| `ft_list_size` | Returns the number of nodes in a list |
| `ft_list_sort` | Sorts a linked list using a comparator function |
| `ft_list_remove_if` | Removes nodes matching a condition |

Build with:
```bash
make bonus
```
-->

---

## Notes

The project was developed and tested on macOS (Apple Silicon). The cross-compilation setup for ARM64 → x86-64 required investigating linker flags not documented in the 42 subject, as the subject assumes a native Linux x86-64 environment.
