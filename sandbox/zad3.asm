format ELF64

public _start

section '.text' executable


section '.bss' writeable
    dir_path       dq ?
    buffer         rb 32768
    file_list      rq 100
    file_count     dq 0
    temp_name      rb 16
    random_buffer  dq ?
    heap_ptr       dq ?

section '.data' writeable
    error_argc     db "Error", 10, 0
    error_opendir  db "Error: Cannot open directory", 10, 0
    error_nofiles  db "Error: No files in directory", 10, 0

section '.text' executable

_start:

    pop rcx
    cmp rcx, 2
    jne argc_error


    pop rsi
    pop rsi
    mov [dir_path], rsi


    mov rax, 2
    mov rdi, [dir_path]
    mov rsi, 0
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl opendir_error
    mov r8, rax


    mov rax, 78
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 32768
    syscall

    cmp rax, 0
    jl close_dir

    mov r9, rax
    xor r10, r10

scan_directory:
    cmp r10, r9
    jge close_dir


    lea r11, [buffer + r10]


    movzx r12, word [r11 + 16]


    mov al, [r11 + 18]
    cmp al, 8
    jne next_entry

    lea rdi, [r11 + 19]
    call skip_dots
    test rax, rax
    jnz next_entry


    mov rax, [file_count]
    cmp rax, 100
    jge close_dir

    lea rsi, [r11 + 19]
    call strdup
    mov rbx, [file_count]
    mov [file_list + rbx*8], rax
    inc qword [file_count]

next_entry:
    add r10, r12
    jmp scan_directory

close_dir:

    mov rax, 3
    mov rdi, r8
    syscall


    mov rax, [file_count]
    cmp rax, 0
    jle nofiles_error


    mov rcx, 3
rename_loop:
    push rcx


    call get_random
    mov rbx, [file_count]
    xor rdx, rdx
    div rbx
    mov r12, rdx


    call generate_random_name

    mov rdi, [file_list + r12*8]
    lea rsi, [temp_name]          ;
    mov rax,  82
    syscall

    pop rcx
    dec rcx
    jnz rename_loop


    mov rax,  60
    xor rdi, rdi
    syscall


argc_error:
    mov rsi, error_argc
    call print_string
    mov rax,  60
    mov rdi, 1
    syscall

opendir_error:
    mov rsi, error_opendir
    call print_string
    mov rax,  60
    mov rdi, 1
    syscall

nofiles_error:
    mov rsi, error_nofiles
    call print_string
    mov rax,  60
    mov rdi, 1
    syscall


print_string:
    push rdi
    push rsi
    mov rdi, rsi
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    pop rsi
    pop rdi
    ret


strlen:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret


strcpy:
    push rdi
    push rsi
.loop:
    mov al, [rsi]
    mov [rdi], al
    inc rdi
    inc rsi
    test al, al
    jnz .loop
    pop rsi
    pop rdi
    ret


strdup:
    push rsi
    call strlen
    mov rdi, rax
    inc rdi
    call malloc
    test rax, rax
    jz .fail
    mov rdi, rax
    pop rsi
    push rdi
    call strcpy
    pop rax
    ret
.fail:
    pop rsi
    xor rax, rax
    ret


malloc:
    mov rdi, [heap_ptr]
    test rdi, rdi
    jnz .alloc


    mov rax, 12
    xor rdi, rdi
    syscall
    mov [heap_ptr], rax
    mov rdi, rax

.alloc:
    mov rax, [heap_ptr]
    add rax, rdi
    mov rsi, rax
    mov rax, 12
    syscall
    cmp rax, rsi
    jne .fail
    mov rax, [heap_ptr]
    add [heap_ptr], rdi
    ret
.fail:
    xor rax, rax
    ret


skip_dots:
    cmp byte [rdi], '.'
    jne .not_dot
    cmp byte [rdi+1], 0
    je .is_dot
    cmp byte [rdi+1], '.'
    jne .not_dot
    cmp byte [rdi+2], 0
    je .is_dot
.not_dot:
    xor rax, rax
    ret
.is_dot:
    mov rax, 1
    ret


get_random:
    mov rax,  318
    mov rdi, random_buffer
    mov rsi, 8
    xor rdx, rdx
    syscall
    mov rax, qword [random_buffer]
    ret


generate_random_name:
    push rdi
    push rsi
    push rcx

    lea rdi, [temp_name]
    mov byte [rdi], 'f'
    mov byte [rdi+1], '_'
    add rdi, 2


    mov rcx, 8
.loop:
    push rcx
    call get_random
    and rax, 0xF
    cmp al, 10
    jb .digit
    add al, 'a' - 10
    jmp .store
.digit:
    add al, '0'
.store:
    mov [rdi], al
    inc rdi
    pop rcx
    loop .loop

    mov byte [rdi], 0

    pop rcx
    pop rsi
    pop rdi
    ret
