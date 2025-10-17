format elf64
public _start

include 'func.asm'

section '.bss' writable
  buffer rb 100
  sent_buf rb 100
  buf64 rb 64
  buf2 rb 64
  stro dq 0
  rev_buf rb 100

section '.data' writable
  endfile db '10e', 0

section '.text' executable

_start:
  ;; Открываем первый файл для чтения
  mov rdi, [rsp+16]
  mov rax, 2
  mov rsi, 0o
  syscall
  cmp rax, 0
  jl l1

  mov r8, rax

  ;; Открываем второй файл для записи
  mov rdi, [rsp + 24]
  mov rax, 2
  mov rsi, 577
  mov rdx, 777o
  syscall
  cmp rax, 0
  jl l1

  mov r10, rax


  mov rax, 0
  mov rdi, r8
  mov rsi, buffer
  mov rdx, 100
  syscall
  mov r9, rax
  mov rdi, sent_buf
  mov rcx, 0

  mov rsi, buffer

xor rcx,rcx
next_char:

  cmp rcx, r9
  je end_of_text

  mov al, [buffer + rcx]
  inc rcx

  mov [rdi], al
  inc rdi
  cmp al, '.'
  je .end_sentence
  cmp al, '!'
  je .end_sentence
  cmp al, '?'
  je .end_sentence





  jmp next_char

.end_sentence:
  mov byte [rdi], 0
  mov rsi, sent_buf
  sub rdi, sent_buf
  mov rdx, rdi
  push rdx
;rdx len, rsi start
 call revert_rsi
     ;call print_str
 pop rdx
 inc rdx
  call write_sentence



  mov rdi, sent_buf
  jmp next_char
revert_rsi:
    push rax
    push rbx
    push rcx
    push rdx

    ;rdx = len
    xor rcx,rcx
    ;call new_line

    .iter:
      mov rbx, rdx
      sub rbx, rcx

      mov al, [rsi+rcx] ; start s
      mov byte [buf2+rbx], al
      inc rcx
      cmp rcx, rdx
      jl .iter

    mov [buf2], ' '
    mov rsi, buf2



    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

end_of_text:
  ;; Закрываем оба файла

  mov rdi, r8
  mov rax, 3
  syscall
  mov rdi, r10
  syscall

  ;; Завершение программы
l1:
  call exit

write_sentence:
  push rdi
  push rsi
  push rax
  push rcx
  push rdx
 ;call print_str

  mov rax, 1
  mov rdi, r10
  syscall
  pop rdx
  pop rcx
  pop rax
  pop rsi
  pop rdi
  ret
