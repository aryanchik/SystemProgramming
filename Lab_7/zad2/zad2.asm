format elf64
public _start

COUNT = 530
NUMBERS_PER_LINE = 10

section '.bss' writable
    array_ptr      rq 1
    sorted_ptr     rq 1
    buffer         rb 256

section '.data' writable
    dev_urandom    db "/dev/urandom", 0
    space_char     db " ", 0
    newline        db 10, 0

    msg_gen        db "Сгенерированный массив из ", 0
    msg_count      db " чисел (0-999):", 10, 10, 0
    msg_primes     db "1. Количество простых чисел: ", 0
    msg_third_max  db "2. Третье после максимального: ", 0
    msg_quant      db "3. 0.75 квантиль: ", 0
    msg_sum3       db "4. Количество чисел, сумма цифр которых кратна 3: ", 0

section '.text' executable

_start:
    mov rax, 9
    xor rdi, rdi
    mov rsi, COUNT * 4
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    xor r9, r9
    syscall
    mov [array_ptr], rax

    mov rax, 9
    xor rdi, rdi
    mov rsi, COUNT * 4
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    xor r9, r9
    syscall
    mov [sorted_ptr], rax

    call fill_random_array
    call create_sorted_copy

    mov rsi, msg_gen
    call print_string
    mov rax, COUNT
    call print_number
    mov rsi, msg_count
    call print_string

    call print_array

    mov rax, 57
    syscall
    cmp rax, 0
    je do_task1
    call wait_child

    mov rax, 57
    syscall
    cmp rax, 0
    je do_task2
    call wait_child

    mov rax, 57
    syscall
    cmp rax, 0
    je do_task3
    call wait_child

    mov rax, 57
    syscall
    cmp rax, 0
    je do_task4
    call wait_child

    call free_memory
    call exit

wait_child:
    push rax
    push rdi
    push rsi
    push rdx
    push r10
    mov rax, 61
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    pop r10
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

free_memory:
    mov rax, 11
    mov rdi, [array_ptr]
    mov rsi, COUNT * 4
    syscall

    mov rax, 11
    mov rdi, [sorted_ptr]
    mov rsi, COUNT * 4
    syscall
    ret

fill_random_array:
    mov rax, 2
    mov rdi, dev_urandom
    xor rsi, rsi
    syscall
    mov rbx, rax

    xor rax, rax
    mov rdi, rbx
    mov rsi, [array_ptr]
    mov rdx, COUNT * 4
    syscall

    mov rax, 3
    mov rdi, rbx
    syscall

    mov rcx, COUNT
    mov rbx, [array_ptr]
.norm_loop:
    mov eax, [rbx]
    and eax, 0x7FFFFFFF
    xor edx, edx
    mov edi, 1000
    div edi
    mov [rbx], edx
    add rbx, 4
    loop .norm_loop
    ret

create_sorted_copy:
    mov rsi, [array_ptr]
    mov rdi, [sorted_ptr]
    mov rcx, COUNT
    rep movsd

    mov rbx, [sorted_ptr]
    mov rcx, COUNT
    dec rcx
.outer_loop:
    push rcx
    mov rsi, rbx
    mov rdi, rbx
    add rdi, 4
.inner_loop:
    mov eax, [rsi]
    cmp eax, [rdi]
    jle .no_swap
    mov r8d, [rdi]
    mov [rdi], eax
    mov [rsi], r8d
.no_swap:
    add rsi, 4
    add rdi, 4
    loop .inner_loop
    pop rcx
    loop .outer_loop
    ret

print_array:
    mov rcx, COUNT
    mov rbx, [array_ptr]
    xor r14, r14

.print_loop:
    mov eax, [rbx]
    call print_number

    mov r15, rcx
    dec r15
    test r15, r15
    jz .no_space

    mov rsi, space_char
    call print_string

.no_space:
    add rbx, 4
    inc r14

    cmp r14, NUMBERS_PER_LINE
    jl .check_next

    call print_newline
    xor r14, r14

.check_next:
    loop .print_loop

    cmp r14, 0
    je .no_extra_newline
    call print_newline

.no_extra_newline:
    call print_newline
    ret

do_task1:
    mov rsi, msg_primes
    call print_string

    mov rbx, [array_ptr]
    mov rcx, COUNT
    xor r12, r12

.check_loop:
    mov eax, [rbx]
    cmp eax, 2
    jl .not_prime
    je .is_prime
    test eax, 1
    jz .not_prime

    mov r8d, 3
.div_loop:
    mov r9d, r8d
    imul r9d, r9d
    cmp r9d, eax
    jg .is_prime

    push rax
    xor edx, edx
    div r8d
    test edx, edx
    pop rax
    jz .not_prime

    add r8d, 2
    jmp .div_loop

.is_prime:
    inc r12
.not_prime:
    add rbx, 4
    loop .check_loop

    mov rax, r12
    call print_number
    call print_newline
    call print
