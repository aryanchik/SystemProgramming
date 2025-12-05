format ELF64

public _start


extrn initscr
extrn endwin
extrn exit
extrn refresh
extrn move
extrn addch
extrn getch
extrn getmaxx
extrn getmaxy
extrn curs_set
extrn noecho
extrn nodelay
extrn usleep

section '.bss' writable
    max_x rq 1
    max_y rq 1
    current_x rq 1
    current_y rq 1
    delay_time rq 1
    win_ptr rq 1

section '.data' writable
    char db '*', 0

section '.text' executable
_start:
    call initscr

    mov [win_ptr], rax

    mov rdi, 0
    call curs_set

    call noecho

    mov rdi, [win_ptr]
    mov rsi, 1
    call nodelay


    mov rdi, [win_ptr]
    call getmaxx
    dec rax
    mov [max_x], rax

    mov rdi, [win_ptr]
    call getmaxy
    dec rax
    mov [max_y], rax

    mov qword [delay_time], 300000


.loop_diag_1:
    mov rax, [current_x]
    cmp rax, [max_x]
    jge .start_diag_2

    mov rax, [current_y]
    cmp rax, [max_y]
    jge .start_diag_2

    call draw_step

    inc qword [current_x]
    inc qword [current_y]
    jmp .loop_diag_1


.start_diag_2:
    mov qword [current_x], 0
    mov rax, [max_y]
    mov [current_y], rax

.loop_diag_2:
    mov rax, [current_x]
    cmp rax, [max_x]
    jge .exit_program

    mov rax, [current_y]
    cmp rax, 0
    jl .exit_program

    call draw_step

    inc qword [current_x]
    dec qword [current_y]
    jmp .loop_diag_2

.exit_program:
    mov rdi, 1000000
    call usleep

    call endwin
    xor rdi, rdi
    call exit

draw_step:
    push rbp
    mov rbp, rsp

    mov rdi, [current_y]
    mov rsi, [current_x]
    call move

    mov rdi, '*'
    call addch


    call refresh


    mov rdi, [delay_time]
    call usleep

    call getch

    cmp rax, -1
    je .done

    cmp al, '+'
    je .faster
    cmp al, '='
    je .faster
    cmp al, '-'
    je .slower
    cmp al, 'q'
    je .exit_func

    jmp .done

.faster:
    mov rax, [delay_time]
    sub rax, 50000
    cmp rax, 5000
    jle .limit_min
    mov [delay_time], rax
    jmp .done
.limit_min:
    mov qword [delay_time], 1000
    jmp .done

.slower:
    mov rax, [delay_time]
    add rax, 5000
    cmp rax, 500000
    jge .done
    mov [delay_time], rax
    jmp .done

.exit_func:
    call endwin
    xor rdi, rdi
    call exit

.done:

    leave
    ret
