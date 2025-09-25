format ELF64
public _start
public print
public print_newline
public exit

section '.bss' writable
    array db 300 dup ('@')
    newline db 0xA

section '.text' executable
    _start:
        xor r12, r12
        inc r12
        .iter1:
            xor r13, r13
            .iter2:
                mov rax, r12
                imul rax, 12
                add rax, r13

                mov rcx, array
                add rcx, rax

                call print

                inc r13
                cmp r13, r12
                jne .iter2
            call print_newline

            inc r12
            cmp r12, 25
            jle .iter1

        call exit

print_newline:
    push rcx
    push rbx
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop rbx
    pop rcx
    ret

print:
    push rbx
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80
    pop rbx
    ret

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80
