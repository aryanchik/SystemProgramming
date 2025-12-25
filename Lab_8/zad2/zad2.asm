format ELF64

public _start

extrn printf

section '.data' writable
    ; Заголовки и формат
    header_msg     db "Исследование сходимости бесконечного произведения для cos(x)", 10
                   db "Формула: cos(x) = П (1 - 4x^2 / ((2n-1)^2 * pi^2))", 10, 0

    table_header   db "-------------------------------------------------------------", 10
                   db " %-10s | %-15s | %-20s", 10
                   db "-------------------------------------------------------------", 10, 0
    col_x          db "x", 0
    col_eps        db "Epsilon", 0
    col_n          db "Множителей (N)", 0

    table_row      db " %-10.4f | %-15.8f | %-20d", 10, 0
    separator      db "-------------------------------------------------------------", 10, 0

    newline        db 10, 0


    x_values       dq 0.0, 0.785398, 1.0, 1.570796, 3.141592
    x_count        dq 5


    epsilons       dq 0.01, 0.0001, 0.000001, 0.00000001
    eps_count      dq 4

    const_1        dq 1.0
    const_2        dq 2.0
    const_4        dq 4.0
    limit_iters    dq 1000000 ; Защита от зависания

section '.bss' writable
    current_x rq 1
    current_eps rq 1
    true_val rq 1
    prod_val rq 1
    diff rq 1

    iter_count rq 1


    temp_k rq 1
    temp_denom rq 1
    temp_term rq 1
    temp_factor rq 1
    c_val rq 1

section '.text' executable


compute_convergence:
    push rbp
    mov rbp, rsp

    finit
    fld qword [current_x]
    fcos                     ; st0 = cos(x)
    fstp qword [true_val]

    fld1
    fstp qword [prod_val]

    mov qword [iter_count], 0


    fld qword [current_x]
    fmul st0, st0
    fld qword [const_4]
    fmulp st1, st0
    fldpi
    fmul st0, st0
    fdivp st1, st0
    fstp qword [c_val]

.product_loop:
    inc qword [iter_count]


    mov rax, [iter_count]
    shl rax, 1
    dec rax
    mov [temp_k], rax


    fild qword [temp_k]
    fmul st0, st0

    fld qword [c_val]
    fdivrp st1, st0



    fld1
    fsubrp st1, st0

    fld qword [prod_val]
    fmulp st1, st0
    fst qword [prod_val]

    fld qword [true_val]
    fsubp st1, st0
    fabs

    fld qword [current_eps]
    fcomip st1
    fstp st0

    ja .converged

    mov rax, [iter_count]
    cmp rax, [limit_iters]
    jge .converged

    jmp .product_loop

.converged:
    leave
    ret

_start:
    and rsp, -16

    mov rdi, header_msg
    xor rax, rax
    call printf

    mov rdi, table_header
    mov rsi, col_x
    mov rdx, col_eps
    mov rcx, col_n
    xor rax, rax
    call printf

    mov r12, 0
.loop_x:
    cmp r12, [x_count]
    jge .done_all

    mov rax, [x_values + r12*8]
    mov [current_x], rax

    mov r13, 0
.loop_eps:
    cmp r13, [eps_count]
    jge .next_x

    mov rax, [epsilons + r13*8]
    mov [current_eps], rax

    call compute_convergence

    mov rdi, table_row
    movq xmm0, [current_x]
    movq xmm1, [current_eps]
    mov rsi, [iter_count]
    mov rax, 2
    call printf

    inc r13
    jmp .loop_eps

.next_x:
    mov rdi, separator
    xor rax, rax
    call printf

    inc r12
    jmp .loop_x

.done_all:
    ; Выход
    mov rax, 60
    xor rdi, rdi
    syscall
