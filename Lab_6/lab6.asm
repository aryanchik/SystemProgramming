format ELF64

public _start


extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn noecho
extrn cbreak
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn keypad


extrn mydelay

section '.data' writable
    palette_color dq 0x100
    is_fast dq 0
    current_delay dq 100000

section '.bss' writable
    direction dq 0
    x dq 0
    y dq 0
    max_x_scr dq 0
    max_y_scr dq 0
    curr_min_x dq 0
    curr_min_y dq 0
    curr_max_x dq 0
    curr_max_y dq 0
    total_cells dq 0
    cells_filled dq 0

section '.text' executable

_start:
    call initscr

    xor rdi, rdi
    mov rdi, [stdscr]
    call getmaxx
    mov [max_x_scr], rax
    call getmaxy
    mov [max_y_scr], rax

    mov rax, [max_x_scr]
    imul rax, [max_y_scr]
    mov [total_cells], rax

    call start_color

    ;; Green
    mov rdx, 2
    mov rsi, 0
    mov rdi, 1
    call init_pair

    ;; Red
    mov rdx, 1
    mov rsi, 0
    mov rdi, 2
    call init_pair

    call noecho
    call cbreak

    mov rdi, [stdscr]
    mov rsi, 1
    call keypad

    mov rdi, 0
    call timeout

    call reset_spiral_vars

main_loop:

    mov rdi, [y]
    mov rsi, [x]
    call move

    mov rax, ' '
    or rax, [palette_color]
    mov rdi, rax
    call addch
    call refresh

.read_keys:
    call getch
    cmp eax, -1
    je .keys_done


    cmp al, 'y'
    je do_exit

    cmp al, 'u'
    jne .read_keys


    mov rax, [is_fast]
    xor rax, 1
    mov [is_fast], rax

    cmp rax, 1
    je .set_fast

    mov qword [current_delay], 100000
    jmp .read_keys

.set_fast:
    mov qword [current_delay], 3000
    jmp .read_keys

.keys_done:

    mov rdi, [current_delay]
    call mydelay


    inc qword [cells_filled]
    mov rax, [cells_filled]
    cmp rax, [total_cells]
    jge do_restart

    mov rax, [direction]
    cmp rax, 0
    je go_right
    cmp rax, 1
    je go_down
    cmp rax, 2
    je go_left
    jmp go_up

go_right:
    mov rax, [x]
    cmp rax, [curr_max_x]
    jge turn_down
    inc qword [x]
    jmp main_loop
turn_down:
    mov qword [direction], 1
    inc qword [curr_min_y]
    inc qword [y]
    jmp main_loop

go_down:
    mov rax, [y]
    cmp rax, [curr_max_y]
    jge turn_left
    inc qword [y]
    jmp main_loop
turn_left:
    mov qword [direction], 2
    dec qword [curr_max_x]
    dec qword [x]
    jmp main_loop

go_left:
    mov rax, [x]
    cmp rax, [curr_min_x]
    jle turn_up
    dec qword [x]
    jmp main_loop
turn_up:
    mov qword [direction], 3
    dec qword [curr_max_y]
    dec qword [y]
    jmp main_loop

go_up:
    mov rax, [y]
    cmp rax, [curr_min_y]
    jle turn_right
    dec qword [y]
    jmp main_loop
turn_right:
    mov qword [direction], 0
    inc qword [curr_min_x]
    inc qword [x]
    jmp main_loop

do_restart:
    mov rax, [palette_color]
    xor rax, 0x300
    and rax, 0x300
    cmp rax, 0
    jne .ok_col
    mov rax, 0x100
.ok_col:
    mov [palette_color], rax
    call reset_spiral_vars
    jmp main_loop

do_exit:
    call endwin
    xor rdi, rdi
    call exit

reset_spiral_vars:
    mov qword [x], 0
    mov qword [y], 0
    mov qword [direction], 0
    mov qword [cells_filled], 0
    mov qword [curr_min_x], 0
    mov qword [curr_min_y], 0
    mov rax, [max_x_scr]
    dec rax
    mov [curr_max_x], rax
    mov rax, [max_y_scr]
    dec rax
    mov [curr_max_y], rax
    ret
