;Function exit
exit:
     mov rax, 60
     mov rdi, 0
     syscall

;Function printing of string
;input rsi - place of memory of begin string
print_str:
    push rax
    push rdi
    push rdx
    push rcx
    mov rax, rsi
    call len_str
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

;The function makes new line
new_line:
   push rax
   push rdi
   push rsi
   push rdx
   push rcx
   mov rax, 0xA
   push rax
   mov rdi, 1
   mov rsi, rsp
   mov rdx, 1
   mov rax, 1
   syscall
   pop rax
   pop rcx
   pop rdx
   pop rsi
   pop rdi
   pop rax
   ret


;The function finds the length of a string
;input rax - place of memory of begin string
;output rax - length of the string
len_str:
  push rdx
  mov rdx, rax
  .iter:
      cmp byte [rax], 0
      je .next
      inc rax
      jmp .iter
  .next:
     sub rax, rdx
     pop rdx
     ret


;Function converting the string to the number
;input rsi - place of memory of begin string
;output rax - the number from the string
str_number:
    push rcx
    push rbx

    xor rax,rax
    xor rcx,rcx
.loop:
    xor     rbx, rbx
    mov     bl, byte [rsi+rcx]
    cmp     bl, 48
    jl      .finished
    cmp     bl, 57
    jg      .finished

    sub     bl, 48
    add     rax, rbx
    mov     rbx, 10
    mul     rbx
    inc     rcx
    jmp     .loop

.finished:
    cmp     rcx, 0
    je      .restore
    mov     rbx, 10
    div     rbx

.restore:
    pop rbx
    pop rcx
    ret

;The function converts the nubmer to string
;input rax - number
;rsi -address of begin of string
number_str:
  push rax
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rbx, 10
  .loop_1:
    xor rdx, rdx
    div rbx
    add rdx, 48
    push rdx
    inc rcx
    cmp rax, 0
    jne .loop_1
  xor rdx, rdx
  .loop_2:
    pop rax
    mov byte [rsi+rdx], al
    inc rdx
    dec rcx
    cmp rcx, 0
  jne .loop_2
  mov byte [rsi+rdx], 0
  pop rdx
  pop rcx
  pop rbx
  pop rax
  ret


;The function realizates user input from the keyboard
;input: rsi - place of memory saved input string lovu me2
input_keyboard:
    push rax
    push rdi
    push rdx
    push rcx
    push rsi

    ; 1. Указываем ПРАВИЛЬНЫЙ буфер для записи
    mov rsi, input_buf    ; Убедись, что input_buf объявлен в section .bss
    mov rax, 0            ; sys_read
    mov rdi, 0            ; stdin
    mov rdx, 255          ; макс длина
    syscall

    ; 2. rax теперь содержит количество прочитанных байт (включая \n)
    ; Если ввели 0 байт (EOF), выходим
    test rax, rax
    jz .end_input

    ; 3. Убираем символ переноса строки (0x0A)
    mov rcx, rax          ; копируем длину в rcx
    dec rcx               ; встаем на индекс последнего символа
    mov al, [rsi + rcx]   ; берем этот символ
    cmp al, 0x0A          ; это перенос строки?
    jne .save_len         ; если нет (вдруг буфер забит до краев), идем сохранять

    mov byte [rsi + rcx], 0 ; заменяем \n на нуль-терминатор
    ; (Длина в rcx как раз стала правильной без \n)

.save_len:
    ; 4. КРИТИЧЕСКИЙ МОМЕНТ: сохраняем длину в переменную
    ; Если ты использовал dec rcx, то в rcx сейчас чистая длина текста
    mov [msg_len], rcx

.end_input:
    pop rsi
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret
