format elf64
public _start

include 'func.asm'

section '.bss' writable
  buffer rb 100
  sent_buf rb 100
  buf64 rb 64
  buf2 rb 64


section '.text' executable

_start:

  mov rdi, [rsp+16]
  mov rax, 2
  mov rsi, 0o
  syscall
  cmp rax, 0
  jl l1

  mov r8, rax


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


    xor rcx,rcx


    .iter:
      mov rbx, rdx
      sub rbx, rcx

      mov al, [rsi+rcx]
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


  mov rdi, r8
  mov rax, 3
  syscall
  mov rdi, r10
  syscall


l1:
  call exit

write_sentence:
  push rdi
  push rsi
  push rax
  push rcx
  push rdx


  mov rax, 1
  mov rdi, r10
  syscall
  pop rdx
  pop rcx
  pop rax
  pop rsi
  pop rdi
  ret
