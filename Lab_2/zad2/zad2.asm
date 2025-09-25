format ELF64
public _start
public print
public print_newline
public exit

section '.bss' writable
    array db 300 dup ('@')
    symbol db ?
    newline db 0xA


section '.text' executable
    _start:
        xor rcx, rcx
        .iter1:
            xor rbx, rbx
            .iter2:
                mov al, [array + rbx]
                mov [symbol], al
                call print
                inc rbx
                cmp rbx, 12
                jne .iter2
        call print_newline
        inc rcx
        cmp rcx, 25
        jne .iter1
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
    push rcx
    push rbx
    mov eax, 4
    mov ebx, 1
    mov ecx, symbol
    mov edx, 1
    int 0x80
    pop rbx
    pop rcx
    ret


exit:
  mov eax, 1
  mov ebx, 0
  int 0x80
