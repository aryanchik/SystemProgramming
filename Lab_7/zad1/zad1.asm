format elf64

public _start
include 'func.asm'

section '.data' writable
    msg db "Enter the name of program", 0xa, 0

    arg1 db "text1.txt", 0
    arg2 db "text2.txt", 0

section '.bss' writable
    buffer rb 200
    env_ptr rq 1
    argv_ptrs rq 4

section '.text' executable

_start:
    mov rcx, [rsp]
    lea rax, [rsp + 16 + rcx*8]
    mov [env_ptr], rax

main_loop:
    mov rsi, msg
    call print_str

    mov rsi, buffer
    call input_keyboard

    mov rdi, buffer
    mov al, 0xA
    mov rcx, 200
    repne scasb
    jne fork_start
    mov byte [rdi-1], 0

fork_start:
    mov rax, 57
    syscall

    cmp rax, 0
    je child_process
    jl main_loop


    mov rdi, -1
    mov rsi, 0
    mov rdx, 0
    mov r10, 0
    mov rax, 61
    syscall

    jmp main_loop

child_process:

    mov rax, buffer
    mov [argv_ptrs], rax


    mov rax, arg1
    mov [argv_ptrs + 8], rax


    mov rax, arg2
    mov [argv_ptrs + 16], rax


    mov qword [argv_ptrs + 24], 0


    mov rdi, buffer
    mov rsi, argv_ptrs
    mov rdx, [env_ptr]
    mov rax, 59
    syscall


    neg rax
    mov rdi, rax
    mov rax, 60
    syscall
