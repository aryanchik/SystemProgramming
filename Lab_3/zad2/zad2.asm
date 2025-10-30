format ELF64

public _start

section '.bss' writable
    ans dq ?
    buffer db 0, 0, 0, 0, 0, 0, 0, 0, 10

section '.text' executable
_start:

    mov rsi, [rsp + 16]
    call str_number                  ;(((((b+a)+a)+c)-c)+c)
    mov r8, rax

    mov rsi, [rsp + 24]
    call str_number
    mov r9, rax

    mov rsi, [rsp + 32]
    call str_number
    mov r10, rax


    mov rax, r9
    add rax, r8

    add rax, r8
    add rax, r10

    mov [ans], rax


    call print_number
    call exit

print_number:

    mov rax, [ans]
    mov rdi, buffer
    mov rbx, 10
    mov rcx, 0

.convert_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi + rcx], dl
    inc rcx
    test rax, rax
    jnz .convert_loop


    mov rsi, rdi
    lea rdx, [rdi + rcx - 1]
.reverse:
    cmp rsi, rdx
    jge .print
    mov al, [rsi]
    mov bl, [rdx]
    mov [rsi], bl
    mov [rdx], al
    inc rsi
    dec rdx
    jmp .reverse

.print:

    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, rcx
    syscall
    ret

str_number:
    push rcx
    push rbx
    push rdx

    xor rax, rax
    xor rcx, rcx
.loop:
    xor rbx, rbx
    mov bl, byte [rsi + rcx]
    test bl, bl
    jz .finished
    cmp bl, '0'
    jl .finished
    cmp bl, '9'
    jg .finished

    sub bl, '0'
    imul rax, 10
    add rax, rbx
    inc rcx
    jmp .loop

.finished:
    pop rdx
    pop rbx
    pop rcx
    ret

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
