format elf64
public _start
include 'func.asm'

section '.data' writable
    buffer rb 100   ; Читаем по 100 байт

section '.text' executable
_start:
    pop rcx ; rcx = argc (количество аргументов)
    cmp rcx, 4 ; Нам нужно 4: ./program <infile> <outfile> <shift>
    jne .l1    ; Если не 4, выходим

    ; 1. Открываем входной файл (argv[1])
    mov rdi, [rsp+8] ; argv[1]
    mov rax, 2       ; sys_open
    mov rsi, 0o      ; O_RDONLY (только чтение)
    syscall
    cmp rax, 0
    jl .l1           ; Ошибка, если rax < 0
    mov r8, rax      ; Сохраняем дескриптор входного файла в r8

    ; 2. Открываем/создаем выходной файл (argv[2])
    mov rdi, [rsp+16] ; argv[2]
    mov rax, 2        ; sys_open
    mov rsi, 1101o    ; O_WRONLY | O_CREAT | O_TRUNC (запись, создать, обрезать)
    mov rdx, 0644o    ; Права доступа r-w-r--r--
    syscall
    cmp rax, 0
    jl .l1            ; Ошибка, если rax < 0
    mov r9, rax       ; Сохраняем дескриптор выходного файла в r9

    ; 3. Получаем значение сдвига (argv[3])
    mov rdi, [rsp+24] ; argv[3] (строка)
    call str_to_int   ; Преобразуем в число
    mov r10, rax      ; Сохраняем число N (сдвиг) в r10

.loop_read:
    ; 4. Читаем из входного файла
    mov rax, 0       ; sys_read
    mov rdi, r8      ; дескриптор r8 (входной файл)
    mov rsi, buffer  ; куда читать
    mov rdx, 100     ; сколько читать
    syscall
    cmp rax, 0       ; Если прочитано 0 байт - конец файла
    jle .next        ; (<= 0, также ловим ошибки)
    mov r11, rax     ; Сохраняем кол-во прочитанных байт в r11

    ; 5. Обрабатываем буфер
    mov rcx, r11     ; rcx = счетчик (сколько байт обработать)
    mov rdi, buffer  ; rdi = указатель на начало буфера
.process_loop:
    mov al, [rdi]    ; Загружаем 1 байт
    add al, r10b     ; Применяем сдвиг (r10b - 8-битная часть r10)
    mov [rdi], al    ; Сохраняем измененный байт обратно
    inc rdi          ; Двигаем указатель
    dec rcx          ; Уменьшаем счетчик
    jnz .process_loop ; Повторяем, пока rcx != 0

    ; 6. Пишем в выходной файл
    mov rax, 1       ; sys_write
    mov rdi, r9      ; дескриптор r9 (выходной файл)
    mov rsi, buffer  ; откуда писать
    mov rdx, r11     ; сколько писать (столько же, сколько прочли)
    syscall
    jmp .loop_read   ; Повторяем цикл чтения

.next:
    ; 7. Закрываем выходной файл
    mov rdi, r9
    mov rax, 3       ; sys_close
    syscall

    ; 8. Закрываем входной файл
    mov rdi, r8
    mov rax, 3       ; sys_close
    syscall

.l1:
    call exit ; Выход из 'func.asm'

; ============================================
; Функция преобразования строки в число
; Принимает: rdi - указатель на C-строку (0-terminated)
; Возвращает: rax - число
; ============================================
str_to_int:
    push rbx
    push rcx
    push rdx

    xor rax, rax     ; rax = 0 (результат)
    xor rcx, rcx     ; rcx = 0 (индекс)
.s2i_loop:
    xor rbx, rbx     ; Обнуляем rbx для чистого сложения
    mov bl, [rdi+rcx] ; Читаем 1 байт (символ)

    ; Проверяем, что это цифра от '0' до '9'
    cmp bl, '0'
    jl .s2i_done
    cmp bl, '9'
    jg .s2i_done

    sub bl, '0'      ; Превращаем '5' (символ) в 5 (число)
    imul rax, rax, 10 ; результат = результат * 10
    add rax, rbx     ; результат = результат + (новая цифра)
    inc rcx
    jmp .s2i_loop

.s2i_done:
    pop rdx
    pop rcx
    pop rbx
    ret
