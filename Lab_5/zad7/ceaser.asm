format elf64
public _start
include 'func.asm' ; Предполагается, что 'exit' находится здесь

section '.data' writable
    buffer rb 100   ; Буфер для чтения/записи

section '.text' executable
_start:
    pop rcx ; rcx = argc (количество аргументов)
    cmp rcx, 4 ; ./decrypt <infile> <outfile> <shift>
    jne .l1    ; Если аргументов не 4, выходим

    ; 1. Открываем входной (зашифрованный) файл (argv[1])
    mov rdi, [rsp+8] ; argv[1]
    mov rax, 2       ; sys_open
    mov rsi, 0o      ; O_RDONLY (только чтение)
    syscall
    cmp rax, 0
    jl .l1           ; Ошибка
    mov r8, rax      ; Сохраняем дескриптор в r8

    ; 2. Открываем/создаем выходной (расшифрованный) файл (argv[2])
    mov rdi, [rsp+16] ; argv[2]
    mov rax, 2        ; sys_open
    mov rsi, 1101o    ; O_WRONLY | O_CREAT | O_TRUNC (запись, создать, обрезать)
    mov rdx, 0644o    ; Права доступа r-w-r--r--
    syscall
    cmp rax, 0
    jl .l1            ; Ошибка
    mov r9, rax       ; Сохраняем дескриптор в r9

    ; 3. Получаем значение сдвига (argv[3])
    mov rdi, [rsp+24] ; argv[3] (строка)
    call str_to_int   ; Преобразуем в число
    mov r10, rax      ; Сохраняем число N (сдвиг) в r10

.loop_read:
    ; 4. Читаем из входного файла
    mov rax, 0       ; sys_read
    mov rdi, r8      ; дескриптор r8
    mov rsi, buffer
    mov rdx, 100
    syscall
    cmp rax, 0       ; Если прочитано 0 байт - конец файла
    jle .next
    mov r11, rax     ; Сохраняем кол-во прочитанных байт в r11

    ; 5. Обрабатываем буфер (ДЕШИФРОВКА)
    mov rcx, r11     ; rcx = счетчик
    mov rdi, buffer  ; rdi = указатель
.process_loop:
    mov al, [rdi]    ; Загружаем 1 байт

    ; *** ВОТ ЕДИНСТВЕННОЕ ИЗМЕНЕНИЕ ***
    sub al, r10b     ; Применяем ОБРАТНЫЙ сдвиг (вычитаем)

    mov [rdi], al    ; Сохраняем измененный байт
    inc rdi          ; Двигаем указатель
    dec rcx          ; Уменьшаем счетчик
    jnz .process_loop ; Повторяем, пока rcx != 0

    ; 6. Пишем в выходной файл
    mov rax, 1       ; sys_write
    mov rdi, r9      ; дескриптор r9
    mov rsi, buffer
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
; (остается без изменений)
; ============================================
str_to_int:
    push rbx
    push rcx
    push rdx

    xor rax, rax     ; rax = 0 (результат)
    xor rcx, rcx     ; rcx = 0 (индекс)
.s2i_loop:
    xor rbx, rbx     ; Обнуляем rbx
    mov bl, [rdi+rcx] ; Читаем 1 байт

    cmp bl, '0'
    jl .s2i_done
    cmp bl, '9'
    jg .s2i_done

    sub bl, '0'      ; '5' -> 5
    imul rax, rax, 10 ; результат = результат * 10
    add rax, rbx     ; результат = результат + (новая цифра)
    inc rcx
    jmp .s2i_loop

.s2i_done:
    pop rdx
    pop rcx
    pop rbx
    ret
