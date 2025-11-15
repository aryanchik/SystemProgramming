format elf64


public array_begin
public count
public count_remainder_1
public prime_count
public create_array
public add_end
public delete_begin
public count_num_end_one
public count_prime_number
public get_odd_numbers
public check_prime
public odd_array_count
public get_odd_numbers_addr
public get_odd_numbers_count

section '.bss' writable
    array_begin rq 1
    count rq 1
    count_remainder_1 rq 1
    prime_count rq 1
    odd_array_count rq 1
    total_bytes rq 1

section '.text' executable


create_array:
    mov rsi, rdi

    mov rax, 9
    mov rdi, 0
    mov rdx, 0x3
    mov r10, 0x22
    mov r8, -1
    mov r9, 0

    syscall

    mov [ array_begin], rax
    mov qword [ count], 0

    ret


add_end:
    mov rax, [ count]
    shl rax, 3

    mov rbx, [ array_begin]
    add rbx, rax

    mov [rbx], rdi

    inc qword [ count]

    ret


delete_begin:
    cmp qword [ count], 0
    jle .end_delete_simple

    mov rax, [ array_begin]
    add rax, 8
    mov [ array_begin], rax

    dec qword [ count]

.end_delete_simple:
    ret


count_num_end_one:
    mov qword [ count_remainder_1], 0
    mov rcx, 0

.iter:
    cmp rcx, [ count]
    jae .iter_end

    mov rbx, [ array_begin]
    mov rax, [rbx + rcx*8]

    mov rdx, 0
    mov rbx, 10
    div rbx

    cmp rdx, 1
    jne .skip_increment

    inc qword [ count_remainder_1]

.skip_increment:
    inc rcx
    jmp .iter

.iter_end:
    ret


count_prime_number:
    push rbp
    push rbx
    push r12

    mov r12, 0
    mov rcx, 0

.array_loop:
    cmp rcx, [ count]
    jae .end_count

    mov rbx, [ array_begin]
    mov rax, [rbx + rcx * 8]

    mov rdi, rax
    call check_prime

    cmp rax, 1
    jne .skip_count

    inc r12

.skip_count:
    inc rcx
    jmp .array_loop

.end_count:
    mov [ prime_count], r12

    pop r12
    pop rbx
    pop rbp
    ret


check_prime:
    push rdx
    push rbx

    cmp rdi, 2
    jl .not_prime
    cmp rdi, 3
    jle .is_prime
    test rdi, 1
    jz .not_prime

    mov rbx, 3

.loop_check:
    mov rax, rbx
    mul rbx

    cmp rdx, 0
    jg .is_prime
    cmp rax, rdi
    jg .is_prime

    mov rax, rdi
    mov rdx, 0
    div rbx

    cmp rdx, 0
    je .not_prime

    add rbx, 2
    jmp .loop_check

.is_prime:
    mov rax, 1
    jmp .epilog

.not_prime:
    mov rax, 0

.epilog:
    pop rbx
    pop rdx
    ret


get_odd_numbers:
    mov r12, [ array_begin]
    mov r13, [ count]

    push rbp
    push rbx
    push r12
    push r13

    mov rax, r13
    shl rax, 3
    mov r8, rax

    mov rsi, rax
    mov rdi, 0
    mov rdx, 0x3
    mov r10, 0x22
    mov r9, 0
    mov r8, -1
    mov rax, 9
    syscall

    cmp rax, 0
    jl .error_exit

    mov rbp, rax

    mov rcx, 0
    mov rbx, 0

.loop_start_odd:
    cmp rcx, r13
    jae .loop_end_odd

    mov rax, [r12 + rcx * 8]

    test al, 1
    jz .skip_copy_odd

    mov [rbp + rbx], rax
    add rbx, 8

.skip_copy_odd:
    inc rcx
    jmp .loop_start_odd

.loop_end_odd:
    mov rax, rbp
    mov rdx, rbx
    shr rdx, 3

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

.error_exit:
    mov rax, 0
    mov rdx, 0

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


get_odd_numbers_addr:
    call get_odd_numbers

    mov [ odd_array_count], rdx
    ret

get_odd_numbers_count:
    mov rax, [ odd_array_count]
    ret
