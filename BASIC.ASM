.MODEL Small
.STACK 64
.DATA

chickenWidth EQU 320
chickenHeight EQU 200
chickenFilename DB 'bg.bin', 0
chickenFilehandle DW ?
chickenData DB chickenWidth*chickenHeight DUP(0)
message1 DB 'Welcome! Input your name: $ ', 0 
message2 DB 'There are 2 modes in this game. Enter 1 for mode 1 and 2 for mode 2:  $ ', 0 
enteredNumber DW 0 ; To hold all entered numbers
temp DW 0
filename db "data.txt",0
fhandle dw ?
buffer db 100 dup('$')
NUM_CH DW 0 
choice DW ?

;for mode 1
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




;for mode 2
;ducks dw 5                ; Number of ducks
;duck_x dw 10, 30, 50, 70, 90    ; Initial x-coordinates of the ducks
;duck_y dw 50, 60, 70, 80, 90    ; y-coordinates of the ducks
;;duck_size dw 10                ; Size of the ducks (10x10 pixels)
;duck_color db 0Fh              ; Color of the ducks (white)
;round_count dw 3               ; Number of rounds
;current_round dw 1             ; Current round number
;bullets dw 10                  ; Number of bullets
;round_msg db 'Round: $', 0
;game_over_msg db 'Game Over!$'
;bullets_msg db 'Bullets: $', 0
;mouse_button db 0      ; Mouse button status
;mouse_x dw 0           ; Mouse x-coordinate
;mouse_y dw 0           ; Mouse y-coordinate
;score dw 0             ; Score
;score_msg db 'Score: $', 0




.CODE
MAIN PROC FAR
    ; Display title image
    MOV AX, @DATA
    MOV DS, AX
    
    ; Set video mode to graphics mode
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    ; Display image
    CALL OpenFile
    CALL ReadData
	
    LEA BX, chickenData ; BL contains index at the current drawn pixel
    MOV CX, 0
    MOV DX, 0
    MOV AH, 0ch
	
    ; Drawing loop
drawLoop:
    MOV AL, [BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX, chickenWidth
    JNE drawLoop 
	
    MOV CX, 0
    INC DX
    CMP DX, chickenHeight
    JNE drawLoop

page2:
    MOV AH, 08h ; Input a character from keyboard without displaying on the screen
    INT 21h
	
    CMP AL, 13
    JNE page2
    
    ; Scroll up window (clear screen)
    mov ah, 6
    mov al, 0
    mov bh, 16h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    
    ; Set cursor position for page 2
    mov ah, 02h
    mov bh, 0
    mov dl,0
    mov dh, 0
    int 10h
    
    MOV AH, 09h         ; Print message prompting user for their name
    LEA DX, message1    
    INT 21h  
    

input: ; label 1
    mov ah, 01h          ; Input a character from keyboard without echo
    int 21h
    
    cmp al, 13           ; Stop taking input if user presses Enter key
    je page3
    
    sub al, 48           ; Convert ASCII character to numerical value
    mov [buffer], al     ; Store the numerical value in the buffer
    inc buffer           ; Move to the next position in the buffer
    
    inc NUM_CH

    jmp continue_input   ; Jump to continue_input to handle the rest of the string
    
continue_input:
    cmp al, '$'          ; Check if the input character is end of string
    je page3              ; If end of string, jump to exit
    
    jmp input            ; If not end of string, continue inputting characters

file_handling: 
;;for creating a new file
;mov ah,3ch
;lea dx,filename
;mov cl,0
;int 21h
;mov fhandle,ax   

;;for opening an existing file
mov ah,3dh
mov al,2
lea dx,filename
int 21h
mov fhandle,ax

;;for writing in text file
mov ah,40h
mov bx,fhandle
lea dx,buffer
mov cx,num_ch
int 21h




;;for closing a file
mov ah,3eh
mov bx,fhandle
int 21h

;exitting process
;jmp exit


page3:
    MOV AH, 08h ; Input a character from keyboard without displaying on the screen
    INT 21h
	
    CMP AL, 13
    JNE page2
   
    
    ; Scroll up window (clear screen)
    mov ah, 6
    mov al, 0
    mov bh, 16h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    
    ; Set cursor position for page 2
    mov ah, 02h
    mov bh, 0
    mov dl,0
    mov dh, 0
    int 10h
    
    MOV AH, 09h         ; Print message prompting user for their input 
    LEA DX, message2    
    INT 21h 
    
    mov ah, 1
    int 21h
    mov choice,al
   ; Convert ASCII to number
   sub al, 30h

     cmp choice,1
     je page4
     cmp choice,2
     je int1
     ;jne error_msg
     

int1 :
jmp page5

page4: ;mode 1 of the game
MOV AH, 08h ; Input a character from keyboard without displaying on the screen
    INT 21h
	
    CMP AL, 13
    JNE page4
    JE int2
    


    ; Scroll up window (clear screen)
    mov ah, 6
    mov al, 0
    mov bh, 16h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    
    ; Set cursor position for page 2
    mov ah, 02h
    mov bh, 0
    mov dl,0
    mov dh, 0
    int 10h


int2 :
 jmp exit


;for mode 1
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

    ;;for opening an existing file
    mov ah,3dh
    mov al,2
    lea dx,filename
    int 21h
    mov fhandle,ax

;;for writing in text file
    mov ah,40h
    mov bx,fhandle
    lea dx,score
    mov cx,1
    int 21h




;;for closing a file
    mov ah,3eh
    mov bx,fhandle
    int 21h
    
   

















page5 : ;for mode2
MOV AH, 08h ; Input a character from keyboard without displaying on the screen
    INT 21h
	
    CMP AL, 13
    JNE page5
    JE exit
    
    ; Scroll up window (clear screen)
    mov ah, 6
    mov al, 0
    mov bh, 16h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    
    ; Set cursor position for page 2
    mov ah, 02h
    mov bh, 0
    mov dl,0
    mov dh, 0
    int 10h































exit:
    ; Press any key to exit
    MOV AH, 0
    INT 16h
    
    ; Close file
    call CloseFile
    
    ; Change to text mode
    MOV AH, 0          
    MOV AL, 03h
    INT 10h 
    
    ; Return control to operating system
    MOV AH, 4ch
    INT 21H  
    
    ; Going to next page
    MOV AH, 0       ; Read key
    INT 16h         ; Read the key
    
    ; Set video mode back to text mode
    MOV AH, 00h
    MOV AL, 03h
    INT 10h






MAIN ENDP



OpenFile PROC 
    ; Open file
    MOV AH, 3Dh
    MOV AL, 0 ; Read only
    LEA DX, chickenFilename
    INT 21h
    
    ; Check carry flag to make sure it worked correctly
    ; Carry = 0 -> successful, file handle -> AX
    ; Carry = 1 -> failed, AX -> error code
    MOV [chickenFilehandle], AX
    
    RET

OpenFile ENDP

ReadData PROC
    ; Read data from file
    MOV AH, 3Fh
    MOV BX, [chickenFilehandle]
    MOV CX, chickenWidth*chickenHeight ; Number of bytes to read
    LEA DX, chickenData
    INT 21h
    RET

ReadData ENDP 

CloseFile PROC
    MOV AH, 3Eh
    MOV BX, [chickenFilehandle]
    INT 21h
    RET

CloseFile ENDP


;procedure for adding delays
delay proc
push ax
push bx
push cx
push dx

mov cx,1000
D1:
mov bx,10
D2:
dec bx
jnz D2
loop D1

pop dx
pop cx
pop bx
pop ax
 
delay ENDP

;procs for mode 1

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
;delay proc
    ; Simple delay loop
   ; mov cx, 0FFFFh
;delay_loop:
 ;   loop delay_loop
  ;  ret
;delay endp

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

END MAIN
