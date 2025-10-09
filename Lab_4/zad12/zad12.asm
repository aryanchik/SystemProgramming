format elf64

public _start
public enterNumber
public printSuccess
public exit

section '.data' writable
    msg rb 255
    fail db "Failure", 0xA
    success db "Success", 0xA

section '.text' executable
_start:
    call enterNumber
    dec rax
    xor rcx, rcx
    dec rax
    .iter:
        cmp rcx, rax
        jge .success

        mov dl, [msg+rcx]
        inc rcx
        mov bl, [msg+rcx]

        cmp dl, bl
        ja .failure

        jmp .iter

.failure:
    call printFail
    jmp .exit_program

.success:
    call printSuccess

.exit_program:
    call exit

enterNumber:
    mov rax, 0
    mov rdi, 0
    mov rsi, msg
    mov rdx, 255
    syscall
    ret

printFail:
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, fail
    mov rdx, 8
    syscall
    pop rcx
    ret

printSuccess:
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, success
    mov rdx, 8
    syscall
    pop rcx
    ret

exit:
    mov rax, 60
    mov rdi, 0
    syscall
