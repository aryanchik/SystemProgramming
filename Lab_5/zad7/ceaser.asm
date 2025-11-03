format elf64
public _start
include 'func.asm'

section '.data' writable
    buffer rb 100

section '.text' executable
_start:
    pop rcx
    cmp rcx, 4
    jne .l1


    mov rdi, [rsp+8]
    mov rax, 2
    mov rsi, 0o
    syscall
    cmp rax, 0
    jl .l1
    mov r8, rax


    mov rdi, [rsp+16]
    mov rax, 2
    mov rsi, 1101o
    mov rdx, 0644o
    syscall
    cmp rax, 0
    jl .l1
    mov r9, rax


    mov rdi, [rsp+24]
    call str_to_int
    mov r10, rax

.loop_read:

    mov rax, 0
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 100
    syscall
    cmp rax, 0
    jle .next
    mov r11, rax
    mov rcx, r11
    mov rdi, buffer
.process_loop:
    mov al, [rdi]


    sub al, r10b

    mov [rdi], al
    inc rdi
    dec rcx
    jnz .process_loop


    mov rax, 1
    mov rdi, r9
    mov rsi, buffer
    mov rdx, r11
    syscall
    jmp .loop_read

.next:

    mov rdi, r9
    mov rax, 3
    syscall


    mov rdi, r8
    mov rax, 3
    syscall

.l1:
    call exit
str_to_int:
    push rbx
    push rcx
    push rdx

    xor rax, rax
    xor rcx, rcx
.s2i_loop:
    xor rbx, rbx
    mov bl, [rdi+rcx]

    cmp bl, '0'
    jl .s2i_done
    cmp bl, '9'
    jg .s2i_done

    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rcx
    jmp .s2i_loop

.s2i_done:
    pop rdx
    pop rcx
    pop rbx
    ret
