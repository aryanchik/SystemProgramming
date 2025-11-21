format ELF64

public _start

extrn initscr
extrn start_color
extrn getmaxx
extrn getmaxy
extrn init_pair
extrn move
extrn refresh
extrn endwin
extrn exit
extrn usleep

section '.bss' writeable
    xmax dq 1
    ymax dq 1

section '.text' executable
_start:
    call initscr

    xor rdi, rdi
    call getmaxx
    mov [xmax], rax

    xor rdi, rdi
    call getmaxy
    mov [ymax], rax

    call start_color


    mov rdi, 1
    mov rsi, 2
    mov rdx, 0
    call init_pair

    ; Начальная позиция
    mov rsi, 0      ; X координата
    mov rdi, 0      ; Y координата

.iter1:
    ; rdi = Y, rsi = X
    push rdi
    push rsi
    call move
    call refresh
    pop rsi
    pop rdi


    push rdi
    push rsi
    mov rdi, 100000
    call usleep
    pop rsi
    pop rdi

    inc rsi

    cmp rsi, [xmax]
    jl .iter1

    call endwin
    mov rdi, 0
    call exit
