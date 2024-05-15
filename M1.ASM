.model small
.stack 100h
.data
duck_x dw 10           ; Initial x-coordinate of the duck
duck_y dw 50           ; y-coordinate of the duck
duck_size dw 10        ; Size of the duck (10x10 pixels)
duck_color db 0Fh      ; Color of the duck (white)
round_count dw 3       ; Number of rounds
current_round dw 1     ; Current round number
score dw 0             ; Score
round_msg db 'Round: $', 0
game_over_msg db 'Game Over!$'
score_msg db 'Score: $', 0
mouse_button db 0      ; Mouse button status
mouse_x dw 0           ; Mouse x-coordinate
mouse_y dw 0           ; Mouse y-coordinate

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Set video mode to 13h (320x200, 256 colors)
    mov ah, 0
    mov al, 13h
    int 10h
    
    ; Initialize mouse
    mov ax, 0
    int 33h
    
    ; Show the mouse cursor
    mov ax, 1
    int 33h
    
    ; Display initial round message
    call display_round_msg
    
    ; Main game loop
game_loop:
    call clear_screen
    call display_duck
    
    ; Duck movement loop
duck_movement_loop:
    call clear_screen
    call display_duck
    call move_duck
    call delay
    call get_mouse_status
    call check_shoot
    call check_round_end
    jmp duck_movement_loop
    
end_game:
    ; Display game over message
    call clear_screen
    mov dx, offset game_over_msg
    mov ah, 09h
    int 21h
    
    ; Move cursor to next line
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    mov dl, 0Dh
    int 21h
    
    ; Calculate and display score
    call calculate_score
    
    ; Display "Score: " message
    mov dx, offset score_msg
    mov ah, 09h
    int 21h
    
    ; Display the actual score value
    mov ax, [score]
    sub ax,1
    add ax, 30h           ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Exit to DOS
    mov ah, 4Ch
    int 21h
    
main endp

; Procedure to display round message
display_round_msg proc
    ; Clear the screen
    call clear_screen
    
    ; Display "Round: X" message
    mov dx, offset round_msg
    mov ah, 09h
    int 21h
    
    ; Display the current round number
    mov ax, [current_round]
    add ax, 30h           ; Convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Wait for a key press
    mov ah, 00h
    int 16h
    
    ; Reset duck position for the next round
    mov [duck_x], 10
    mov [duck_y], 50
    
    ret
display_round_msg endp

; Procedure to clear the screen
clear_screen proc
    mov ax, 0A000h
    mov es, ax
    xor di, di
    mov cx, 32000         ; 320 * 200 / 2
    xor ax, ax
    rep stosw
    ret
clear_screen endp

; Procedure to display the duck
display_duck proc
    mov cx, [duck_x]     ; X-coordinate of the top-left corner
    mov dx, [duck_y]     ; Y-coordinate of the top-left corner
    mov ah, 0Ch          ; Function to write pixel
    mov al, duck_color   ; Color of the duck
    mov bh, 0            ; Page number
    
    mov di, 0            ; Row counter
duck_row_loop:
    mov si, 0            ; Column counter
duck_col_loop:
    push cx
    push dx
    int 10h
    pop dx
    pop cx
    inc cx
    inc si
    cmp si, [duck_size]
    jne duck_col_loop
    inc dx
    sub cx, [duck_size]
    inc di
    cmp di, [duck_size]
    jne duck_row_loop
    ret
display_duck endp

; Procedure to move the duck from left to right
move_duck proc
    add [duck_x], 1       ; Move the duck slower by incrementing less
    cmp [duck_x], 310
    jb no_reset
    mov [duck_x], 10
no_reset:
    ret
move_duck endp

check_round_end proc
    ; Check if Enter key is pressed
    mov ah, 01h
    int 16h
    jz skip_round_end     ; No key pressed, continue duck movement
    
    ; Enter key pressed, move to next round
    mov ah, 00h
    int 16h
    
    ; Check if the current round is less than or equal to the total round count
    mov ax, [current_round]
    inc ax
    cmp ax, [round_count]
    jg finish_game        ; If current round exceeds total rounds, end the game
    
    mov [current_round], ax
    call display_round_msg
    
    ret
skip_round_end:
    ret
check_round_end endp


; Procedure to create a delay
delay proc
    ; Simple delay loop
    mov cx, 0FFFFh
delay_loop:
    loop delay_loop
    ret
delay endp

; Procedure to get mouse button and position status
get_mouse_status proc
    mov ax, 3
    int 33h
    mov [mouse_button], bl
    mov [mouse_x], cx
    mov [mouse_y], dx
    ret
get_mouse_status endp

; Procedure to check if the duck is shot
check_shoot proc
    cmp [mouse_button], 1  ; Check if left mouse button is pressed
    jne no_shoot
    
    ; Check if the click is within the duck's boundaries
    mov ax, [mouse_x]
    cmp ax, [duck_x]       ; Check if click is to the right of the left edge of the duck
    jl no_shoot            ; If so, it's not a hit
    cmp ax, [duck_x]       ; Check if click is to the left of the right edge of the duck
    jge check_y            ; If not, go to y-coordinate check
    jmp no_shoot           ; If so, it's not a hit
    
check_y:
    mov ax, [mouse_y]
    cmp ax, [duck_y]       ; Check if click is below the top edge of the duck
    jl no_shoot            ; If so, it's not a hit
    cmp ax, [duck_y]       ; Check if click is above the bottom edge of the duck
    jge shoot_duck         ; If not, it's a hit
    jmp no_shoot           ; If so, it's not a hit
    
shoot_duck:
    ; Duck is shot, move to next round
    inc [current_round]
    call display_round_msg
    mov [duck_x], 10       ; Reset duck position for the next round
    mov [duck_y], 50
    ret
    
no_shoot:
    ret
check_shoot endp

calculate_score proc
    ; Calculate score
    mov ax, [current_round]
    sub ax, 1               ; Subtract 1 to exclude initial round
    imul ax, 10             ; Multiply by 10
    mov [score], ax         ; Update score

    ret
calculate_score endp

finish_game:
    jmp end_game
end main
