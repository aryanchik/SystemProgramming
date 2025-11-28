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
extrn addch

section '.bss' writable
    ; --- Исправлено: dq ? заменено на resq 1 ---
    min_x rq 1
    min_y rq 1
    max_x rq 1
    max_y rq 1

    current_x rq 1
    current_y rq 1

    color_flag rb 1 ; db ? заменено на resb 1

section '.data' writable
    char db ' ', 0

section '.text' executable
_start:
    call initscr
    call start_color

; --- Настройка пар цветов (Красный/Зеленый) ---
; 1: Белый текст, Зеленый фон
mov rdi, 1
    mov rsi, 7
    mov rdx, 2
    call init_pair

; 2: Белый текст, Красный фон
    mov rdi, 2
    mov rsi, 7
    mov rdx, 1
    call init_pair

    ; --- Границы --\
    ; Исправлено: Явно qword
    mov [qword min_x], 0
    mov [qword min_y], 0

    xor rdi, rdi
    call getmaxx
    dec rax
    mov [qword max_x], rax

    xor rdi, rdi
    call getmaxy
    dec rax
    mov [qword max_y], rax

    mov byte [color_flag], 0

; ==========================================
; ЦИКЛ СПИРАЛИ
; ==========================================
.spiral_loop:
; Проверка условия выхода
    mov rax, [qword min_x] ; Исправлено: Явно qword
    cmp rax, [qword max_x] ; Исправлено: Явно qword
    jg .exit_program
    mov rax, [qword min_y] ; Исправлено: Явно qword
    cmp rax, [qword max_y] ; Исправлено: Явно qword
    jg .exit_program

; --------------------------------------
    mov rax, [qword min_x] ; Исправлено: Явно qword
    mov [qword current_x], rax
.loop_right:
    mov rax, [qword current_x] ; Исправлено: Явно qword
    cmp rax, [qword max_x] ; Исправлено: Явно qword
    jg .done_right

    mov rsi, [qword current_x] ; X (Исправлено: Явно qword)
    mov rdi, [qword min_y]
    call draw_pixel

    inc qword [current_x]
    jmp .loop_right
.done_right:
    inc qword [min_y]

    ; --------------------------------------
    ; 2. ВНИЗ (столбец max_x, y: min_y -> max_y)
    ; --------------------------------------
    mov rax, [qword min_x] ; Исправлено: Явно qword
    cmp rax, [qword max_x] ; Исправлено: Явно qword
    jg .exit_program

    mov rax, [qword min_y] ; Исправлено: Явно qword
    mov [qword current_y], rax
.loop_down:
    mov rax, [qword current_y] ; Исправлено: Явно qword
    cmp rax, [qword max_y] ; Исправлено: Явно qword
    jg .done_down

    mov rsi, [qword max_x]
    mov rdi, [qword current_y]
    call draw_pixel

    inc qword [current_y]
    jmp .loop_down
.done_down:
    dec qword [max_x]

    ; --------------------------------------
    ; 3. ВЛЕВО (строка max_y, x: max_x -> min_x)
    ; --------------------------------------
    mov rax, [qword min_y]
    cmp rax, [qword max_y]
    jg .exit_program

    mov rax, [qword max_x]
    mov [qword current_x], rax
.loop_left:
    mov rax, [qword current_x]
    cmp rax, [qword min_x]
    jl .done_left

    mov rsi, [qword current_x] ; X (Исправлено: Явно qword)
    mov rdi, [qword max_y]
    call draw_pixel

    dec qword [current_x]
    jmp .loop_left
.done_left:
    dec qword [max_y]

    ; --------------------------------------
    ; 4. ВВЕРХ (столбец min_x, y: max_y -> min_y)
    ; --------------------------------------
    mov rax, [qword min_x] ; Исправлено: Явно qword
    cmp rax, [qword max_x] ; Исправлено: Явно qword
    jg .exit_program

    mov rax, [qword max_y] ; Исправлено: Явно qword
    mov [qword current_y], rax
.loop_up:
    mov rax, [qword current_y] ; Исправлено: Явно qword
    cmp rax, [qword min_y] ; Исправлено: Явно qword
    jl .done_up

    mov rsi, [qword min_x]
    mov rdi, [qword current_y] ; Y (Исправлено: Явно qword)
    call draw_pixel

    dec qword [current_y]
    jmp .loop_up
.done_up:
    inc qword [min_x]

    jmp .spiral_loop

.exit_program:
    mov rdi, 2000000
    call usleep

    call endwin
    xor rdi, rdi
    call exit
; ==========================================
; ФУНКЦИЯ ОТРИСОВКИ (С ВЫРАВНИВАНИЕМ СТЕКА)
; ==========================================
draw_pixel:
    push rbp
    mov rbp, rsp

    ; Выравнивание стека на 16 байт
    push rbx
    push rdi
    push rsi
    push r12

    ; 1. Перемещаем курсор (move(Y, X))
    call move

    ; 2. Вычисляем цвет
    mov al, [color_flag]
    cmp al, 0
    je .set_green
.set_red:
    mov rbx, 2
    mov byte [color_flag], 0
    jmp .do_draw
.set_green:
    mov rbx, 1
    mov byte [color_flag], 1

.do_draw:
    ; Формируем атрибут цвета
    shl rbx, 8
    add rbx, 0x10000000

    movzx rax, byte [char]
    or rax, rbx

    mov rdi, rax
    call addch

    ; 3. Обновляем экран и задержка
    call refresh
    mov rdi, 10000
    call usleep

    ; --- ВОССТАНОВЛЕНИЕ ---
    pop r12
    pop rsi
    pop rdi
    pop rbx

    leave
    ret
