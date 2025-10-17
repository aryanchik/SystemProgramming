format ELF64

public _start

section '.bss' writable
    buffer db 0, 0, 0, 0, 0, 0, 0, 0, 10

section '.text' executable
_start:

    mov rsi, [rsp + 16]
    call str_to_number
    mov r12, rax

    xor r13, r13
    mov r14, r12

.sum_loop:
    cmp r14, 0
    jle .print_result


    mov rax, r14
    call first_digit


    imul rax, r14
    add r13, rax

    dec r14
    jmp .sum_loop

.print_result:

    mov rax, r13
    call print_number

    call exit



first_digit:
    push rbx
    mov rbx, 10

.find_first:
    cmp rax, 10
    jl .done
    xor rdx, rdx
    div rbx
    jmp .find_first

.done:
    pop rbx
    ret


str_to_number:
    push rcx
    push rbx
    push rdx

    xor rax, rax
    xor rcx, rcx

.convert_loop:
    mov bl, byte [rsi + rcx]
    test bl, bl
    jz .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done

    sub bl, '0'
    imul rax, 10
    add rax, rbx
    inc rcx
    jmp .convert_loop

.done:
    pop rdx
    pop rbx
    pop rcx
    ret

print_number:
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

    mov rsi, buffer
    lea rdx, [buffer + rcx - 1]

.reverse_loop:
    cmp rsi, rdx
    jge .print
    mov al, [rsi]
    mov bl, [rdx]
    mov [rsi], bl
    mov [rdx], al
    inc rsi
    dec rdx
    jmp .reverse_loop

.print:
    mov byte [buffer + rcx], 10
    inc rcx


    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, rcx
    syscall
    ret

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
