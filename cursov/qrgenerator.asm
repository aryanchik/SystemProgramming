format elf64
public _start

section '.data' writable
    msg_in db "Введите текст (до 15 символов): ", 0
    msg_theme db "Выберите тему (1-Классика 2-Розовая 3-Синяя 4-Зеленая): ", 0
    msg_out db 0xA, "Ваш QR-код (Version 1-L):", 0xA, 0

    black1 db 0xE2, 0x96, 0x88, 0xE2, 0x96, 0x88, 0
    white1 db "  ", 0

    black2 db 0xF0, 0x9F, 0x9F, 0xAA, 0xF0, 0x9F, 0x9F, 0xAA, 0
    white2 db 0xE2, 0xAC, 0x9C, 0xE2, 0xAC, 0x9C, 0

    black3 db 0xF0, 0x9F, 0x9F, 0xA6, 0xF0, 0x9F, 0x9F, 0xA6, 0
    white3 db 0xE2, 0xAC, 0x9C, 0xE2, 0xAC, 0x9C, 0

    black4 db 0xF0, 0x9F, 0x9F, 0xA9, 0xF0, 0x9F, 0x9F, 0xA9, 0
    white4 db 0xE2, 0xAC, 0x9B, 0xE2, 0xAC, 0x9B, 0

    newline db 0xA, 0
    pad_byte1 db 0xEC
    pad_byte2 db 0x11

section '.bss' writable
    input_buf rb 256
    theme_buf rb 10
    theme_sel rq 1
    msg_len rq 1
    qr_data rb 19
    grid rb 441
    black_ptr rq 1
    white_ptr rq 1

section '.text' executable

print_str:
    push rax
    push rdi
    push rdx
    xor rdx, rdx
.len:
    cmp byte [rsi + rdx], 0
    je .out
    inc rdx
    jmp .len
.out:
    mov rax, 1
    mov rdi, 1
    syscall
    pop rdx
    pop rdi
    pop rax
    ret

draw_finder:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    xor rbx, rbx
.y_loop:
    xor rcx, rcx
.x_loop:
    mov rax, rdi
    add rax, rbx
    imul rax, 21
    mov rdx, rsi
    add rdx, rcx
    add rax, rdx

    mov byte [grid + rax], 1

    cmp rbx, 1
    jl .next_pixel
    cmp rbx, 5
    jg .next_pixel
    cmp rcx, 1
    jl .next_pixel
    cmp rcx, 5
    jg .next_pixel

    mov byte [grid + rax], 0

    cmp rbx, 2
    jl .next_pixel
    cmp rbx, 4
    jg .next_pixel
    cmp rcx, 2
    jl .next_pixel
    cmp rcx, 4
    jg .next_pixel

    mov byte [grid + rax], 1

.next_pixel:
    inc rcx
    cmp rcx, 7
    jl .x_loop
    inc rbx
    cmp rbx, 7
    jl .y_loop

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

draw_timing:
    push rax
    push rcx

    mov rcx, 8
.h_loop:
    mov rax, 6
    imul rax, 21
    add rax, rcx

    mov byte [grid + rax], 1
    test rcx, 1
    jz .h_next
    mov byte [grid + rax], 0
.h_next:
    inc rcx
    cmp rcx, 13
    jl .h_loop

    mov rcx, 8
.v_loop:
    mov rax, rcx
    imul rax, 21
    add rax, 6

    mov byte [grid + rax], 1
    test rcx, 1
    jz .v_next
    mov byte [grid + rax], 0
.v_next:
    inc rcx
    cmp rcx, 13
    jl .v_loop

    pop rcx
    pop rax
    ret

draw_dark_module:
    push rax
    mov rax, 13
    imul rax, 21
    add rax, 8
    mov byte [grid + rax], 1
    pop rax
    ret


_start:
    mov rsi, msg_theme
    call print_str

    xor rax, rax
    xor rdi, rdi
    mov rsi, theme_buf
    mov rdx, 10
    syscall

    movzx rax, byte [theme_buf]
    sub rax, '0'
    cmp rax, 1
    jl .theme_default
    cmp rax, 4
    jg .theme_default
    mov [theme_sel], rax
    jmp .theme_ok

.theme_default:
    mov qword [theme_sel], 1

.theme_ok:
    mov rax, [theme_sel]
    cmp rax, 1
    jne .t2
    mov qword [black_ptr], black1
    mov qword [white_ptr], white1
    jmp .theme_set
.t2:
    cmp rax, 2
    jne .t3
    mov qword [black_ptr], black2
    mov qword [white_ptr], white2
    jmp .theme_set
.t3:
    cmp rax, 3
    jne .t4
    mov qword [black_ptr], black3
    mov qword [white_ptr], white3
    jmp .theme_set
.t4:
    mov qword [black_ptr], black4
    mov qword [white_ptr], white4

.theme_set:
    mov rsi, msg_in
    call print_str

    xor rax, rax
    xor rdi, rdi
    mov rsi, input_buf
    mov rdx, 255
    syscall

    dec rax
    cmp rax, 0
    jl .exit_prog
    mov [msg_len], rax

    mov rcx, 441
.clear_grid:
    mov byte [grid + rcx - 1], 2
    loop .clear_grid

    mov rsi, 0
    mov rdi, 0
    call draw_finder

    mov rsi, 14
    mov rdi, 0
    call draw_finder

    mov rsi, 0
    mov rdi, 14
    call draw_finder

    call draw_timing

    call draw_dark_module

    xor rcx, rcx
    mov r8, [msg_len]

    cmp r8, 0
    je .exit_prog

    mov al, 0100b
    shl al, 4
    mov r9, r8
    shr r9, 4
    or al, r9b
    mov [qr_data], al
    inc rcx

    mov al, r8b
    and al, 0x0F
    shl al, 4

    movzx rbx, byte [input_buf]
    shr rbx, 4
    or al, bl
    mov [qr_data + rcx], al
    inc rcx

    mov rdx, 1

.pack_loop:
    cmp rdx, r8
    jge .add_terminator
    cmp rcx, 19
    jge .padding

    movzx rax, byte [input_buf + rdx - 1]
    and rax, 0x0F
    shl rax, 4

    movzx rbx, byte [input_buf + rdx]
    shr rbx, 4
    or rax, rbx

    mov [qr_data + rcx], al
    inc rcx
    inc rdx
    jmp .pack_loop

.add_terminator:
    cmp rcx, 19
    jge .padding

    movzx rax, byte [input_buf + r8 - 1]
    and rax, 0x0F
    shl rax, 4
    mov [qr_data + rcx], al
    inc rcx

.padding:
    cmp rcx, 19
    jge .encode_done

    test rcx, 1
    jz .pad_ec
    mov byte [qr_data + rcx], 0x11
    jmp .pad_next
.pad_ec:
    mov byte [qr_data + rcx], 0xEC
.pad_next:
    inc rcx
    jmp .padding

.encode_done:

    mov r12, 20
    mov r13, 20
    mov r14, 0
    mov r15, 1

.snake_loop:
    cmp r12, 0
    jl .place_done

    mov rax, r13
    imul rax, 21
    add rax, r12

    cmp byte [grid + rax], 2
    jne .skip_cell

    mov rbx, r14
    shr rbx, 3

    cmp rbx, 19
    jge .set_white

    mov rsi, r14
    and rsi, 7
    mov cl, 7
    sub cl, sil

    movzx rax, byte [qr_data + rbx]
    shr rax, cl
    and rax, 1

    push rax
    mov rax, r13
    imul rax, 21
    add rax, r12
    pop rbx
    mov [grid + rax], bl

    inc r14
    jmp .skip_cell

.set_white:
    push rax
    mov rax, r13
    imul rax, 21
    add rax, r12
    mov byte [grid + rax], 0
    pop rax
    inc r14

.skip_cell:
    test r12, 1
    jnz .move_left

    dec r12
    jmp .snake_loop

.move_left:
    inc r12

    cmp r15, 1
    je .move_up

.move_down:
    inc r13
    cmp r13, 21
    jl .snake_loop

    sub r12, 2
    cmp r12, 6
    jne .change_to_up
    dec r12
.change_to_up:
    mov r15, 1
    mov r13, 20
    jmp .snake_loop

.move_up:
    dec r13
    cmp r13, 0
    jge .snake_loop

    sub r12, 2
    cmp r12, 6
    jne .change_to_down
    dec r12
.change_to_down:
    mov r15, 0
    mov r13, 0
    jmp .snake_loop

.place_done:

    mov rsi, msg_out
    call print_str

    xor r12, r12
.print_y:
    xor r13, r13
.print_x:
    mov rax, r12
    imul rax, 21
    add rax, r13

    mov rsi, [white_ptr]
    cmp byte [grid + rax], 1
    jne .print_pixel
    mov rsi, [black_ptr]

.print_pixel:
    call print_str

    inc r13
    cmp r13, 21
    jl .print_x

    mov rsi, newline
    call print_str

    inc r12
    cmp r12, 21
    jl .print_y

.exit_prog:
    mov rax, 60
    xor rdi, rdi
    syscall
