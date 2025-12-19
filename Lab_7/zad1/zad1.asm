format elf64

public _start
include 'func.asm'

section '.data' writable
    msg db "Enter the name of program", 0xa, 0
    ; Аргументы для zad10, которые мы передадим насильно
    arg1 db "text1.txt", 0
    arg2 db "text2.txt", 0

section '.bss' writable
    buffer rb 200
    env_ptr rq 1
    argv_ptrs rq 4     ; Массив указателей на аргументы: [prog_name, arg1, arg2, NULL]

section '.text' executable

_start:
    ; --- Сохраняем указатель на окружение (нужно для ncurses/терминала) ---
    mov rcx, [rsp]
    lea rax, [rsp + 16 + rcx*8]
    mov [env_ptr], rax

main_loop:
    mov rsi, msg
    call print_str

    mov rsi, buffer
    call input_keyboard

    ; --- Удаляем \n (Enter) из буфера ---
    mov rdi, buffer
    mov al, 0xA
    mov rcx, 200
    repne scasb
    jne fork_start
    mov byte [rdi-1], 0

fork_start:
    mov rax, 57             ; fork
    syscall

    cmp rax, 0
    je child_process        ; Дочерний процесс
    jl main_loop            ; Ошибка fork

    ; --- Родитель ждет ---
    mov rdi, -1
    mov rsi, 0
    mov rdx, 0
    mov r10, 0
    mov rax, 61             ; wait4
    syscall

    jmp main_loop

child_process:
    ; --- Подготовка аргументов для zad10 ---
    ; Мы создаем массив argv, как если бы вы ввели: "./zad10 text1.txt text2.txt"

    ; argv[0] = Имя программы (то, что вы ввели, например "./lab5/zad10")
    mov rax, buffer
    mov [argv_ptrs], rax

    ; argv[1] = "text1.txt"
    mov rax, arg1
    mov [argv_ptrs + 8], rax

    ; argv[2] = "text2.txt"
    mov rax, arg2
    mov [argv_ptrs + 16], rax

    ; argv[3] = NULL (конец массива)
    mov qword [argv_ptrs + 24], 0

    ; --- ЗАПУСК ---
    mov rdi, buffer           ; Путь к файлу (то, что вы ввели)
    mov rsi, argv_ptrs        ; Аргументы: [prog, text1, text2]
    mov rdx, [env_ptr]        ; Окружение
    mov rax, 59               ; sys_execve
    syscall

    ; Если не запустилось
    neg rax
    mov rdi, rax
    mov rax, 60               ; sys_exit
    syscall
