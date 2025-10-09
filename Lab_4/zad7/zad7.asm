format elf64
public _start
public printSymbol
public exit


section '.data' writable

   msg rb 255
   symbol db ?

section '.text' executable

_start:
   mov rax, 0
   mov rdi, 0
   mov rsi, msg
   mov rdx, 255
   syscall

    dec rax
    mov rcx, rax
.iter1:
    mov al, [msg+rcx]
   mov [symbol], al
   call printSymbol
    dec rcx
    cmp rcx, -1
    jne .iter1


    call exit


exit:
   mov rax, 60
   mov rdi, 0
   syscall

printSymbol:
push rcx
    mov rax, 1
   mov rdi, 1
   mov rsi, symbol
   mov rdx, 1
   syscall
   pop rcx
   ret
