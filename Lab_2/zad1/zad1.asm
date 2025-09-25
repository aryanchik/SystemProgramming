format ELF64
public _start
public print
public exit

section '.bss' writable
    my db 0xA, "SkhljlJKyZVpMZaXBqERXGiwIlYCEKzY"
    symbol db ?

section '.text' executable
  _start:
    mov rcx, 32
    .iter:
        mov al, [my + rcx]
        mov [symbol], al
        call print
        dec rcx
        cmp rcx, -1
        jne .iter
    call exit



print:
    push rcx
    mov eax, 4
    mov ebx, 1
    mov ecx, symbol
    mov edx, 1
    int 0x80
    pop rcx
    ret


exit:
  mov eax, 1
  mov ebx, 0
  int 0x80
