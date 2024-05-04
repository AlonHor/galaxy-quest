IDEAL
MODEL small
STACK 100h

RED      equ 28h
WHITE    equ 0Fh
BLACK    equ 00h
BROWN    equ 06h
BEIGE    equ 41h
BLUE     equ 21h
SKY      equ 36h
YELLOW   equ 0Eh
GREEN    equ 02h
L_GREEN  equ 31h
UP_SKY   equ 0C7h

BG       equ BLACK

FLOOR_y  equ 200 / 2
FLOOR_x  equ 320 / 2

MARIO_w  equ 14
MARIO_h  equ 18
MARIO_bg equ 255

ALIEN_h  equ 26
ALIEN_w  equ 21
ALIEN_bg equ 255

CYCLES   equ 50000

CHASE_w  equ 5
CHASE_h  equ 5

GAME_t   equ 50
GAME_w   equ 320
GAME_h   equ 200
GAME_tps equ 40
GAME_mpt equ GAME_tps * 60
MENU_mpt equ 1

DATASEG
    MENU_ticks         dw 0

    GAME_ticks         dw 0
    GAME_palette       db 300h dup(?)
    GAME_state         db 0
    GAME_menu_is_hover db 0
    ; 0 - main menu
    ;   1 - guide
    ;   2 - other stuff
    ; 10 - game
    ; 20 - game over

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FLAG_should_setup_game db 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MARIO_x     dw FLOOR_x - (MARIO_w / 2)
    MARIO_y     dw FLOOR_y - (MARIO_h / 2)
    MARIO_dir   db 0
    MARIO_speed db 1

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    CHASE_random_x     dw ?
    CHASE_random_y     dw ?
    CHASE_random_color db ?
    CHASE_points       db ?
    CHASE_seconds      db ?
    CHASE_ticks        dw 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    BMP_line        db 320 dup (0)
    BMP_screen_line db 324 dup (0)

    BMP_starting       db 'start.bmp', 0
    BMP_cycles         db 'cycles.bmp' , 0
    BMP_menu           db 'menu.bmp' , 0
    BMP_menu_guide     db 'menug.bmp' , 0
    BMP_menu_play      db 'menup.bmp' , 0
    BMP_tools_bg       db 'toolsbg.bmp' , 0
    BMP_robot          db 'robot.bmp' , 0
    BMP_mario          db 'mario.bmp' , 0
    BMP_grenade        db 'grnd.bmp' , 0
    BMP_black_hole     db 'bh.bmp' , 0
    BMP_alien          db 'alien.bmp' , 0

    BMP_handle     dw ?
    BMP_header     db 54 dup(0)
    BMP_palette    db 400h dup(0)

    BMP_error_file         db 0

    BMP_x dw ?
    BMP_y dw ?
    BMP_w dw ?
    BMP_h dw ?

    BMP_skip_color     db 0
    BMP_should_skip    db 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ERROR_opening_bmp_file   db 'Error when opening BMP file.', 0dh, 0ah, '$'
    ERROR_too_many_instances db 'Too many instances.', 0dh, 0ah, '$'

    ERROR_exit               db 'Press any key to exit.', 0dh, 0ah, '$'

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    INFO_alien_struct_size equ 5
    INFO_max_aliens        equ 5

    OBJECT_alien equ is_alive
        is_alive db 1
        alien_x  dw 0
        alien_y  dw 0

    TMP_current_alien equ tmp_is_alive
        tmp_is_alive  db 1
        tmp_alien_x   dw 0
        tmp_alien_y   dw 0

    PROP_alien_is_alive equ 0
    PROP_alien_x        equ 1
    PROP_alien_y        equ 3

    DATA_alien_list       db INFO_alien_struct_size * INFO_max_aliens dup(?)
    POINTER_current_alien db 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    alien db 21 dup(BG) ; 21x26
          db 9  dup(BG), 3 dup(BLACK), 9  dup(BG)
          db 7  dup(BG), 2 dup(BLACK), 2  dup(L_GREEN), 1 dup(GREEN)  , 2 dup(BLACK)  , 7 dup(BG)
          db 6  dup(BG), 1 dup(BLACK), 5  dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 6 dup(BG)
          db 5  dup(BG), 1 dup(BLACK), 7  dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 5 dup(BG)
          db 4  dup(BG), 1 dup(BLACK), 9  dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 4 dup(BG)
          db 3  dup(BG), 1 dup(BLACK), 11 dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 3 dup(BG)
          db 3  dup(BG), 1 dup(BLACK), 12 dup(L_GREEN), 1 dup(GREEN)  , 1 dup(BLACK)  , 3 dup(BG)
          db 2  dup(BG), 1 dup(BLACK), 1  dup(L_GREEN), 4 dup(BLACK)  , 5 dup(L_GREEN), 4 dup(BLACK)  , 1 dup(GREEN)  , 1 dup(BLACK)  , 2 dup(BG)
          db 2  dup(BG), 1 dup(BLACK), 1  dup(L_GREEN), 1 dup(BLACK)  , 3 dup(WHITE)  , 1 dup(BLACK)  , 3 dup(L_GREEN), 1 dup(BLACK)  , 3 dup(WHITE), 1 dup(BLACK), 1 dup(GREEN), 1 dup(BLACK), 2 dup(BG)
          db 2  dup(BG), 1 dup(BLACK), 1  dup(L_GREEN), 2 dup(BLACK)  , 2 dup(WHITE)  , 2 dup(BLACK)  , 1 dup(L_GREEN), 2 dup(BLACK)  , 2 dup(WHITE), 2 dup(BLACK), 1 dup(GREEN), 1 dup(BLACK), 2 dup(BG)
          db 2  dup(BG), 1 dup(BLACK), 1  dup(L_GREEN), 3 dup(BLACK)  , 1 dup(WHITE)  , 2 dup(BLACK)  , 1 dup(L_GREEN), 2 dup(BLACK)  , 1 dup(WHITE), 3 dup(BLACK), 1 dup(GREEN), 1 dup(BLACK), 2 dup(BG)
          db 3  dup(BG), 1 dup(BLACK), 1  dup(L_GREEN), 5 dup(BLACK)  , 1 dup(L_GREEN), 5 dup(BLACK)  , 1 dup(GREEN)  , 1 dup(BLACK)  , 3 dup(BG)
          db 3  dup(BG), 1 dup(BLACK), 2  dup(L_GREEN), 4 dup(BLACK)  , 1 dup(L_GREEN), 4 dup(BLACK)  , 2 dup(GREEN)  , 1 dup(BLACK)  , 3 dup(BG)
          db 4  dup(BG), 1 dup(BLACK), 10 dup(L_GREEN), 1 dup(GREEN)  , 1 dup(BLACK)  , 4 dup(BG)
          db 4  dup(BG), 1 dup(BLACK), 3  dup(L_GREEN), 1 dup(BLACK)  , 5 dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 4 dup(BG)
          db 5  dup(BG), 1 dup(BLACK), 2  dup(L_GREEN), 4 dup(BLACK)  , 1 dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 5 dup(BG)
          db 6  dup(BG), 1 dup(BLACK), 5  dup(L_GREEN), 2 dup(L_GREEN), 1 dup(BLACK)  , 6 dup(BG)
          db 4  dup(BG), 2 dup(BLACK), 1  dup(L_GREEN), 2 dup(BLACK)  , 2 dup(L_GREEN), 1 dup(GREEN)  , 2 dup(BLACK)  , 1 dup(GREEN)  , 2 dup(BLACK), 4 dup(BG)
          db 2  dup(BG), 2 dup(BLACK), 3  dup(L_GREEN), 2 dup(GREEN)  , 3 dup(BLACK)  , 5 dup(GREEN)  , 2 dup(BLACK)  , 2 dup(BG)
          db 1  dup(BG), 1 dup(BLACK), 8  dup(L_GREEN), 3 dup(GREEN)  , 4 dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 1 dup(BG)
          db 1  dup(BG), 1 dup(BLACK), 1  dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK)  , 9 dup(L_GREEN), 1 dup(BLACK)  , 2 dup(L_GREEN), 1 dup(GREEN), 1 dup(BLACK), 1 dup(BG)
          db 1  dup(BG), 4 dup(BLACK), 1  dup(BG)     , 1 dup(BLACK)  , 1 dup(GREEN)  , 6 dup(L_GREEN), 1 dup(BLACK)  , 1 dup(BG)     , 4 dup(BLACK), 1 dup(BG)
          db 6  dup(BG), 1 dup(BLACK), 1  dup(GREEN)  , 5 dup(L_GREEN), 1 dup(GREEN)  , 1 dup(BLACK), 6 dup(BG)
          db 5  dup(BG), 1 dup(BLACK), 7  dup(L_GREEN), 2 dup(GREEN)  , 1 dup(BLACK), 5 dup(BG)
          db 21 dup(BG)

    mario db 14 dup(BG) ; 14x18
          db 4  dup(BG), 5 dup(RED)  , 5 dup(BG)
          db 3  dup(BG), 9 dup(RED)  , 2 dup(BG)
          db 3  dup(BG), 3 dup(BROWN), 2 dup(BEIGE), 1 dup(BLACK), 1 dup(BEIGE) , 4 dup(BG)
          db 2  dup(BG), 1 dup(BROWN), 1 dup(BEIGE), 1 dup(BROWN), 3 dup(BEIGE) , 1 dup(BLACK), 3 dup(BEIGE) , 2 dup(BG)
          db 2  dup(BG), 1 dup(BROWN), 1 dup(BEIGE), 2 dup(BROWN), 3 dup(BEIGE) , 1 dup(BLACK), 3 dup(BEIGE) , 1 dup(BG)
          db 3  dup(BG), 1 dup(BROWN), 4 dup(BEIGE), 4 dup(BLACK), 2 dup(BG)
          db 4  dup(BG), 6 dup(BEIGE), 4 dup(BG)
          db 3  dup(BG), 2 dup(RED)  , 1 dup(BLUE) , 2 dup(RED)  , 1 dup(BLUE)  , 2 dup(RED)  , 3 dup(BG)
          db 2  dup(BG), 3 dup(RED)  , 1 dup(BLUE) , 2 dup(RED)  , 1 dup(BLUE)  , 3 dup(RED)  , 2 dup(BG)
          db 1  dup(BG), 4 dup(RED)  , 4 dup(BLUE) , 4 dup(RED)  , 1 dup(BG)
          db 1  dup(BG), 2 dup(BEIGE), 1 dup(RED)  , 1 dup(BLUE) , 1 dup(YELLOW), 2 dup(BLUE) , 1 dup(YELLOW), 1 dup(BLUE), 1 dup(RED), 2 dup(BEIGE), 1 dup(BG)
          db 1  dup(BG), 3 dup(BEIGE), 6 dup(BLUE) , 3 dup(BEIGE), 1 dup(BG)
          db 1  dup(BG), 2 dup(BEIGE), 8 dup(BLUE) , 2 dup(BEIGE), 1 dup(BG)
          db 3  dup(BG), 3 dup(BLUE) , 2 dup(BG)   , 3 dup(BLUE) , 3 dup(BG)
          db 2  dup(BG), 3 dup(BROWN), 4 dup(BG)   , 3 dup(BROWN), 2 dup(BG)
          db 1  dup(BG), 4 dup(BROWN), 4 dup(BG)   , 4 dup(BROWN), 1 dup(BG)
          db 14 dup(BG)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    rnd_pos dw start

CODESEG

start:
    mov ax, @data
    mov ds, ax

    mov ax, 0
    int 33h

    mov ax, 13h
    int 10h

    call SavePalette

    call ShowCursor

    push offset BMP_starting
    push 0
    push 0
    push 320
    push 200
    call RenderBmp

    mov ax, 40h
    mov es, ax

    mov cx, [es:6Ch]

    push 300
    call Sleep
    
    mov ax, [es:6Ch]
    sub ax, cx

    cmp ax, 4
    je skip_err
    cmp ax, 5
    je skip_err
    cmp ax, 6
    jne cpu_cycles_error

skip_err:
    mov ax, seg OnCursorEvent
    mov es, ax
    mov ax, 0Ch
    mov dx, offset OnCursorEvent
    mov cx, 1111b
    int 33h

    l:
        call OnGameTick
    jmp l

cpu_cycles_error:
    push offset BMP_cycles
    push 0
    push 0
    push 320
    push 200
    call RenderBmp
    call AwaitKeypress

    call ExitGame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: RenderBmp
;
; Arguments:
;  stack - (filename asciiz offset, x, y, w, h)
;
; Returns:
;  none
;
; Description:
;  renders bmp on screen at given coordinates
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
filename equ [word bp + 12]
x        equ [word bp + 10]
y        equ [word bp + 8 ]
w        equ [word bp + 6 ]
h        equ [word bp + 4 ]
proc RenderBmp
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov bx, x
    mov [BMP_x], bx
    mov bx, y
    mov [BMP_y], bx
    mov bx, w
    mov [BMP_w], bx
    mov bx, h
    mov [BMP_h], bx

    mov dx, filename
    call OpenShowBmp
    cmp [BMP_error_file], 1
    jne @@ret 
    jmp @@exit_error

    @@exit_error:
        push offset ERROR_opening_bmp_file
        call HandleError

    @@exit:
        call ExitGame

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        pop bp
        ret 10

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ClearScreen
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  clears B800 screen
;
; Register usage:
;  ax - 0 to place in memory (nothing, clear)
;  cx - loop index
;  di - offset to render
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc ClearScreen
    push ax
    push bx
    push cx
    push di

    mov cx, 5000
    mov di, 0

    mov ax, 0B800h
    mov es, ax

    @@loop:
        push ax

        xor ax, ax
        mov [es:di], al
        inc di
        inc di

        pop ax
    loop @@loop

    @@ret:
        pop di
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: Instantiate
;
; Arguments:
;  stack - (INFO_max_?s, INFO_?_struct_size, offset DATA_?_list, offset TMP_current_?)
;
; Returns:
;  none
;
; Description:
;  creates an instance of an object
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
max         equ [word bp + 10]
struct_size equ [word bp + 8 ]
list        equ [word bp + 6 ]
current     equ [word bp + 4 ]
proc Instantiate
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    @@create_instace:
        mov cx, max
        mov si, list
        @@find_empty_slot:
            mov bl, [si]
            cmp bl, 0
            je @@slot_found
            add si, struct_size
        loop @@find_empty_slot

    push offset ERROR_too_many_instances
    call HandleError

    @@slot_found:
        mov cx, struct_size
        mov bx, current
        @@copy:
            mov ax, [bx]
            mov [si], ax
            inc bx
            inc si
        loop @@copy

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 8

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ShowCursor
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  shows the cursor
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc ShowCursor
    push ax
    push bx
    push cx
    push dx

    mov ax, 1
    int 33h

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: HideCursor
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  hides the cursor
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc HideCursor
    push ax
    push bx
    push cx
    push dx

    mov ax, 2
    int 33h

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: OnCursorEvent
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  listener to mouse events, does hover effects
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc OnCursorEvent far
    push ax
    push bx
    push cx
    push dx

    shr cx, 1

    mov bl, [GAME_state]
    cmp bl, 0
    je @@main_menu
    jmp @@ret

@@main_menu:
    inc [MENU_ticks]
    cmp [MENU_ticks], MENU_mpt
    je @@s_skip_main_menu
    jmp @@skip_main_menu

@@s_skip_main_menu:
    mov [MENU_ticks], 0

    cmp cx, 105
    jna @@not_play

    cmp cx, 212
    jnb @@not_play

    cmp dx, 95
    jna @@not_play

    cmp dx, 121
    jnb @@not_play

    push offset BMP_menu_play
    cmp ax, 10b
    jne @@cont
    mov [FLAG_should_setup_game], 1
    jmp @@cont

@@not_play:
    cmp cx, 105
    jna @@not_guide

    cmp cx, 212
    jnb @@not_guide

    cmp dx, 141
    jna @@not_guide

    cmp dx, 167
    jnb @@not_guide

    push offset BMP_menu_guide
    cmp ax, 10b
    jne @@cont
    ;call ViewGuide
    jmp @@cont ; remove when ViewGuide is implemented

@@not_guide:
    push offset BMP_menu

    @@cont:
        push 0
        push 0
        push 320
        push 200
        call RenderBmp

@@skip_main_menu:

    @@ret:
        call ShowCursor

        pop dx
        pop cx
        pop bx
        pop ax

        retf

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ResetCursorPos
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  resets cursor position to 0, 0
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc ResetCursorPos
    push ax
    push bx
    push cx
    push dx

    mov bh, 0
    mov ah, 2
    mov dh, 0
    mov dl, 0
    int 10h

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: HandleError
;
; Arguments:
;  stack - ($ error message offset)
;
; Returns:
;  none
;
; Description:
;  logs error message and exits game
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
error_message equ [word bp + 4]
proc HandleError
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov ax, 2
    int 10h

    mov dx, error_message
    mov ah, 9
    int 21h

    lea dx, [ERROR_exit]
    mov ah, 9
    int 21h

    call AwaitKeypress
    call ExitGame

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 2

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawBackground
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  draws white background
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawBackground
    push ax
    push bx
    push cx
    push dx

    push 0
    push 0
    push GAME_w * (GAME_h + 1)
    push BG
    call DrawHorizontalLine

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: SavePalette
;
; Arguments:
; none
;
; Returns:
; none
;
; Description:
; saves dos 256 color pallete
;
; Register usage:
; none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc SavePalette
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si

    lea bx, [GAME_palette]
    xor al, al
    xor si, si
    mov dx, 3C8h
    out dx, al
    mov dx, 3C9h
    mov cx, 300h
    @@save_loop:
        in al, dx
        mov [bx + si], al
        inc si
    loop @@save_loop

    @@ret:
        pop si
        pop di
        pop es
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: RestorePalette
;
; Arguments:
; none
;
; Returns:
; none
;
; Description:
; restores dos 256 color pallete
;
; Register usage:
; none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc RestorePalette
    push ax
    push bx
    push cx
    push dx
    push es
    push di
    push si

    lea bx, [GAME_palette]
    xor si, si
    mov dx, 3C8h
    mov al, 0
    out dx, al

    mov dx, 3C9h
    mov cx, 300h
    @@restore_loop:
        mov al, [bx + si]
        out dx, al
        inc si
    loop @@restore_loop

    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop ax

    @@ret:
        ret
endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: AwaitKeypress
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  waits for any key to be pressed
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc AwaitKeypress
    push ax
    push bx
    push cx
    push dx

    mov ah, 1
    int 21h

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ExitGame
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  exit game
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc ExitGame
    mov ax, 2
    int 10h

    xor ax, ax
    int 33h

    mov ax, 4C00h
    int 21h

    @@ret:

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: SetupGame
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  setups game
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc SetupGame
    mov [GAME_state], 10
    call RestorePalette
    call DrawBackground

    ; push offset BMP_tools_bg
    ; push 0
    ; push 0
    ; push 320
    ; push 50
    ; call RenderBmp

    @@ret:

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: OnGameTick
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  run every game tick, call procedures
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc OnGameTick
    push ax
    push bx
    push cx
    push dx

    mov al, [GAME_state]
    mov bl, 0
    cmp al, bl
    je @@main_menu

    mov bl, 10
    cmp al, bl
    je @@game_tick

    jmp @@game_tick

@@main_menu:
    cmp [FLAG_should_setup_game], 1
    jne @@s_skip_setup_game

    mov [FLAG_should_setup_game], 0
    call SetupGame

@@s_skip_setup_game:
    jmp @@skip_move

@@game_tick:
    inc [GAME_ticks]
    xor ah, ah
    mov ax, GAME_mpt
    cmp [GAME_ticks], ax
    jnae @@jmp_to_skip_move

    mov [GAME_ticks], 0

    cmp [MARIO_dir], 1
    je @@up

    cmp [MARIO_dir], 2
    je @@left

    cmp [MARIO_dir], 3
    je @@down

    cmp [MARIO_dir], 4
    je @@right

    jmp @@cont

    @@up:
        mov ax, [MARIO_y]
        cmp ax, GAME_t
        jng @@cont

        dec [MARIO_y]
        jmp @@cont

    @@left:
        mov ax, [MARIO_x]
        cmp ax, 0
        jng @@cont

        dec [MARIO_x]
        jmp @@cont

    @@jmp_to_skip_move:
        jmp @@skip_move

    @@down:
        mov ax, [MARIO_y]
        add ax, MARIO_h
        cmp ax, GAME_h
        jnl @@cont

        inc [MARIO_y]
        jmp @@cont

    @@right:
        mov ax, [MARIO_x]
        add ax, MARIO_w
        cmp ax, GAME_w
        jnl @@cont

        inc [MARIO_x]
        jmp @@cont

@@cont:
    push [MARIO_x]
    push [MARIO_y]
    call DrawMarioAt

@@skip_move:
    call HandlePlayerInput
    cmp dl, 1
    jne @@skip_exit_game
    call ExitGame

    @@skip_exit_game:
    ; check for collision of mario and rect
    ; conditions for collision are:
    ;  rect x is less than or equal to mario x + mario w AND
    ;  rect x is higher than or equal to mario x AND
    ;  rect y is less than or equal to mario y + mario h AND
    ;  rect y is higher than or equal to mario y
    ; OR: SAME CHECKS FOR SWAPPED OBJECTS
    @@check_mario_pov:
        ; 1
        mov ax, [MARIO_x]
        add ax, MARIO_w
        cmp [CHASE_random_x], ax
        jnle @@check_rect_pov

        ; 2
        mov ax, [MARIO_x]
        cmp [CHASE_random_x], ax
        jnae @@check_rect_pov

        ; 3
        mov ax, [MARIO_y]
        add ax, MARIO_h
        cmp [CHASE_random_y], ax
        jnle @@check_rect_pov

        ; 4
        mov ax, [MARIO_y]
        cmp [CHASE_random_y], ax
        jnae @@check_rect_pov

        ; COLLISION
        inc [CHASE_points]

    @@check_rect_pov:
        ; 1
        mov ax, [CHASE_random_x]
        add ax, CHASE_w
        cmp [MARIO_x], ax
        jnle @@no_collision

        ; 2
        mov ax, [CHASE_random_x]
        cmp [MARIO_x], ax
        jnae @@no_collision

        ; 3
        mov ax, [CHASE_random_y]
        add ax, CHASE_h
        cmp [MARIO_y], ax
        jnle @@no_collision

        ; 4
        mov ax, [CHASE_random_y]
        cmp [MARIO_y], ax
        jnae @@no_collision

        ; COLLISION
        inc [CHASE_points]

    @@no_collision:

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: HandlePlayerInput
;
; Arguments:
;  none
;
; Returns:
;  dl - 1 if exit, 0 if continue
;
; Description:
;  handles player input
;
; External links:
;  https://stanislavs.org/helppc/scan_codes.html
;
; Register usage:
;  ax - keybind interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc HandlePlayerInput
    push ax

    ; check if key in buffer
    mov ah, 1
    int 16h
    jnz @@key_pressed
    jmp @@ret ; continue

    @@key_pressed:
        ; read key from buffer
        mov ah, 0
        int 16h

        ; esc key
        cmp ax, 011Bh
        je @@exit_game

        ; avoid changing  anything when game is not running
        cmp [GAME_state], 10
        jne @@cont

        ; up arrow
        cmp ah, 48h
        je @@up

        ; left arrow
        cmp ah, 4Bh
        je @@left

        ; down arrow
        cmp ah, 50h
        je @@down

        ; right arrow
        cmp ah, 4Dh
        je @@right

        jmp @@cont

    @@up:
        mov [MARIO_dir], 1
        jmp @@cont

    @@left:
        mov [MARIO_dir], 2
        jmp @@cont

    @@down:
        mov [MARIO_dir], 3
        jmp @@cont

    @@right:
        mov [MARIO_dir], 4
        jmp @@cont

    @@cont:
        xor dl, dl
        jmp @@ret

    @@exit_game:
        mov dl, 1

    @@ret:
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: Sleep
;
; Arguments:
;  stack - (ms)
;
; Returns:
;  none
;
; Description:
;  puts thread to sleep for provided ms
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ms equ [word bp + 4]
proc Sleep
    push bp
    mov bp, sp

    push ax
    push cx

    mov cx, ms
    @@out_l:
        push cx
        mov cx, CYCLES
        @@l:
            loop @@l
        pop cx
    loop @@out_l

@@ret:
    pop cx
    pop ax

    pop bp
    ret 2

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawAlienAt
;
; Arguments:
;  stack - (x, y)
;
; Returns:
;  none
;
; Description:
;  draws an alien at given position
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x equ [word bp + 6]
y equ [word bp + 4]
proc DrawAlienAt
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    ; mov [BMP_skip_color], ALIEN_bg
    ; mov [BMP_should_skip], 1
    ; push offset BMP_alien
    push x
    push y
    push ALIEN_w
    push ALIEN_h
    push offset alien
    call DrawMatrixAt
    ; call RenderBmp

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 4

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawMarioAt
;
; Arguments:
;  stack - (x, y)
;
; Returns:
;  none
;
; Description:
;  draws mario at given position
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x equ [word bp + 6]
y equ [word bp + 4]
proc DrawMarioAt
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    ; mov [BMP_skip_color], MARIO_bg
    ; mov [BMP_should_skip], 1
    ; push offset BMP_mario
    push x
    push y
    push MARIO_w
    push MARIO_h
    push offset mario
    call DrawMatrixAt
    ; call RenderBmp

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 4

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawPixelLineAt
;
; Arguments:
;  stack - (x, y, offset, length, color)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 12]
y     equ [word bp + 10]
off   equ [word bp + 8 ]
len   equ [word bp + 6 ]
color equ [word bp + 4 ]
proc DrawPixelLineAt
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov cx, len
    mov ax, off
    add x, ax

    @@l:
        push x
        push y
        push color
        call DrawPixelAt
        inc x
    loop @@l

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 10

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: PosToOffset
;
; Arguments:
;  stack - (x, y)
;
; Returns:
;  di - offset
;
; Description:
;  returns offset of given X and Y values
;  GAME_w * (y - 1) + x
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x      equ [word bp + 6]
y      equ [word bp + 4]
proc PosToOffset
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov cx, y
    dec cx
    mov ax, GAME_w
    mul cx
    add ax, x

    mov di, ax

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 4

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawMatrixAt
;
; Arguments:
;  stack - (x, y, width, height, offset of matrix)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x      equ [word bp + 12]
y      equ [word bp + 10]
w      equ [word bp + 8 ]
h      equ [word bp + 6 ]
matrix equ [word bp + 4 ]
proc DrawMatrixAt
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    push x
    push y
    call PosToOffset
    ; offset now in di

    mov ax, 0A000h
    mov es, ax
    cld

    mov si, matrix
    
    mov cx, h
    mov dx, w
    @@l:
        push cx
        mov cx, dx

        @@l2:
            mov al, [si]
            cmp al, BG
            ;je @@cont
            mov [es:di], al

            @@cont:
                inc si
                inc di
        loop @@l2

        sub di, dx
        add di, GAME_w
        pop cx
    loop @@l

@@ret:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 10

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawPixelAt
;
; Arguments:
;  stack - (x, y, color)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  cx - loop
;  si - draw index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 8]
y     equ [word bp + 6]
color equ [word bp + 4]
proc DrawPixelAt
    push bp
    mov bp, sp

    push ax
    push bx

    push x
    push y
    call PosToOffset
    ; offset now in di

    mov ax, 0A000h
    mov es, ax
    mov bx, color
    mov [es:di], bx

@@ret:
    pop bx
    pop ax

    pop bp
    ret 6

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawFilledRect
;
; Arguments:
;  stack - (x, y, width, height, color)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  cx - loop
;  si - draw index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 12]
y     equ [word bp + 10]
w     equ [word bp + 8 ]
h     equ [word bp + 6 ]
color equ [word bp + 4 ]
proc DrawFilledRect
    push bp
    mov bp, sp

    push si
    push cx

    mov cx, w
    mov si, x

    @@draw_loop:
        push si
        push y
        push h
        push color
        call DrawVerticalLine
        inc si
    loop @@draw_loop

@@ret:
    pop cx
    pop si

    pop bp
    ret 10

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: UndrawRect
;
; Arguments:
;  stack - (x, y, width, height)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  ax - width
;  bx - height
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 10]
y     equ [word bp + 8 ]
w     equ [word bp + 6 ]
h     equ [word bp + 4 ]
proc UndrawRect
    push bp
    mov bp, sp

    push ax
    push si
    push cx

    mov cx, w
    mov si, x

    @@draw_loop:
        push si
        push y
        mov ax, h
        inc ax
        push ax
        push BG
        call DrawVerticalLine
        inc si
    loop @@draw_loop

@@ret:
    pop cx
    pop si
    pop ax

    pop bp
    ret 8

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawRect
;
; Arguments:
;  stack - (x, y, width, height, color)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  ax - width
;  bx - height
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 12]
y     equ [word bp + 10]
w     equ [word bp + 8 ]
h     equ [word bp + 6 ]
color equ [word bp + 4 ]
proc DrawRect
    push bp
    mov bp, sp

    push ax
    push bx

    mov ax, w
    mov bx, h

    push x
    push y
    push w
    push color
    call DrawHorizontalLine

    add y, bx

    push x
    push y
    push w
    push color
    call DrawHorizontalLine

    sub y, bx

    push x
    push y
    push h
    push color
    call DrawVerticalLine

    add x, ax
    inc h
    dec y

    push x
    push y
    push h
    push color
    call DrawVerticalLine

@@ret:
    pop bx
    pop ax

    pop bp
    ret 10

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawVerticalLine
;
; Arguments:
;  stack - (x, y, length, color)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  cx - loop
;  si - draw index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 10]
y     equ [word bp + 8 ]
len   equ [word bp + 6 ]
color equ [word bp + 4 ]
proc DrawVerticalLine
    push bp
    mov bp, sp

    push si
    push ax
    push bx
    push cx
    push dx

    push x
    push y
    call PosToOffset
    ; offset now in di
    mov ax, 0A000h
    mov es, ax

    mov cx, len
    @@draw_loop:
        mov ax, color
        mov [es:di], ax
        add di, 320
        loop @@draw_loop

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax
    pop si

    pop bp
    ret 8

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawHorizontalLine
;
; Arguments:
;  stack - (x, y, length, color)
;
; Returns:
;  none
;
; Description:
;  none
;
; Registers:
;  cx - loop
;  si - draw index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x     equ [word bp + 10]
y     equ [word bp + 8 ]
len   equ [word bp + 6 ]
color equ [word bp + 4 ]
proc DrawHorizontalLine
    push bp
    mov bp, sp

    push si
    push ax
    push bx
    push cx
    push dx

    push x
    push y
    call PosToOffset
    ; offset now in di
    mov ax, 0A000h
    mov es, ax

    mov cx, len
    @@draw_loop:
        mov ax, color
        mov [es:di], ax
        inc di
        loop @@draw_loop

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax
    pop si

    pop bp
    ret 8

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: RandomByte
;
; Arguments:
;  bl - lowest
;  bh - highest
;
; Returns:
;  al - random number in that range
;
; Description:
;  generate a random byte using cs and timer
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc RandomByte
    push es
    push si
    push di

    mov ax, 40h
    mov es, ax

    sub bh, bl
    cmp bh, 0
    jz @@ret

    mov di, [word rnd_pos]
    call MakeMask

@@rand_loop:
    mov ax, [es:06ch]
    mov ah, [byte cs:di]
    xor al, ah

    inc di
    cmp di, (end_of_cs - start - 1)
    jb @@cont
    lea di, [start]

@@cont:
    mov [word rnd_pos], di

    and ax, si
    cmp al, bh
    ja @@rand_loop

    add al, bl

@@ret:
    pop di
    pop si
    pop es
    ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: RandomWord
;
; Arguments:
;  bx - lowest
;  dx - highest
;
; Returns:
;  ax - random number in that range
;
; Description:
;  generate a random word using cs and timer
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc RandomWord
    push es
    push si
    push di

    mov ax, 40h
    mov es, ax

    sub dx, bx

    cmp dx,0
    jz @@ret

    push bx

    mov di, [word rnd_pos]
    call MakeMaskWord

@@rand_loop:
    mov bx, [es:06ch]
    
    mov ax, [word cs:di]
    xor ax, bx
    
    inc di
    inc di
    cmp di, (end_of_cs - start - 2)
    jb @@cont
    lea di, [start]

@@cont:
    mov [word rnd_pos], di

    and ax, si

    cmp ax, dx
    ja @@rand_loop
    pop bx
    add ax, bx
@@ret:
    pop di
    pop si
    pop es
    ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MakeMask
;
; Arguments:
;  bh - seed
;
; Returns:
;  si - mask
;
; Description:
;  generates a mask from bh
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc MakeMask    
    push bx
    mov si, 1

@@l1:
    shr bh, 1
    cmp bh, 0
    jz @@ret

    shl si, 1
    inc si

    jmp @@l1

@@ret:
    pop bx
    ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MakeMaskWord
;
; Arguments:
;  dx - seed
;
; Returns:
;  si - mask
;
; Description:
;  generates a mask from dx
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc MakeMaskWord    
    push dx
    mov si, 1

@@l1:
    shr dx, 1
    cmp dx, 0
    jz @@ret

    shl si, 1
    inc si

    jmp @@l1

@@ret:
    pop dx
    ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ShowAxDecimal
;
; Arguments:
;  ax - number to print
;
; Returns:
;  none
;
; Description:
;  print value in ax as decimal
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc ShowAxDecimal
    push ax
    push bx
    push cx
    push dx

    test ax, 08000h
    jz @@positive_ax

    push ax

    mov dl, '-'
    mov ah, 2
    int 21h

    pop ax

    neg ax

    @@positive_ax:
        mov cx, 0
        mov bx, 10

    @@put_mode_to_stack:
        xor dx, dx
        div bx
        add dl, 30h
        push dx
        inc cx
        cmp ax, 9
        jg @@put_mode_to_stack

        cmp ax, 0
        jz @@pop_next
        add al, 30h
        mov dl, al
        mov ah, 2h
        int 21h

    @@pop_next: 
        pop ax
        mov dl, al
        mov ah, 2h
        int 21h
    loop @@pop_next

    mov dl, ','
    mov ah, 2h
    int 21h

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    ret

endp

; BMP STUFF
proc OpenShowBmp near
    call OpenBmpFile
    cmp [BMP_error_file], 1
    je @@ret

    call ReadBmpHeader
    call ReadBmpPalette
    call CopyBmpPalette
    call ShowBmp
    call CloseBmpFile

    @@ret:
	ret

endp OpenShowBmp

proc OpenBmpFile near
    mov ah, 3Dh
    xor al, al
    int 21h
    jc @@error
    mov [BMP_handle], ax
    jmp @@ret

    @@error:
	mov [BMP_error_file], 1

    @@ret:
	ret

endp OpenBmpFile

proc CloseBmpFile near
    mov ah, 3Eh
    mov bx, [BMP_handle]
    int 21h

    @@ret:
	ret

endp CloseBmpFile

proc ReadBmpHeader near
    push cx
    push dx

    mov ah, 3fh
    mov bx, [BMP_handle]
    mov cx, 54
    lea dx, [BMP_header]
    int 21h

    @@ret:
        pop dx
        pop cx
        ret

endp ReadBmpHeader

proc ReadBmpPalette near
    push cx
    push dx

    mov ah, 3fh
    mov cx, 400h
    lea dx, [BMP_palette]
    int 21h

    @@ret:
        pop dx
        pop cx
	ret

endp ReadBmpPalette

proc CopyBmpPalette near
    push cx
    push dx

    lea si, [BMP_palette]
    mov cx, 256
    mov dx, 3C8h
    mov al, 0
    out dx, al
    inc dx

    @@next_color:
        mov al, [si+2]
        shr al, 2
        out dx, al
        mov al, [si+1]
        shr al, 2
        out dx, al
        mov al, [si]
        shr al, 2
        out dx, al
        add si, 4
    loop @@next_color

    @@ret:
        pop dx
        pop cx
        ret

endp CopyBmpPalette

proc ShowBmp
    push cx

    mov ax, 0A000h
    mov es, ax

    mov cx, [BMP_h]

    mov ax, [BMP_w]
    xor dx, dx
    mov si, 4
    div si
    cmp dx, 0
    mov bp, 0
    jz @@row_ok
    mov bp, 4
    sub bp, dx

@@row_ok:
    mov dx, [BMP_x]

@@next_line:
    push cx
    push dx

    mov di, cx
    add di, [BMP_y]
    dec di

    mov cx, di
    shl cx, 6
    shl di, 8
    add di, cx
    add di, dx

    mov ah, 3fh
    mov cx, [BMP_w]
    add cx, bp
    lea dx, [BMP_screen_line]
    int 21h

    cld
    mov cx, [BMP_w]
    lea si, [BMP_screen_line]

    @@l:
        mov al, [si]
        cmp [BMP_should_skip], 1
        jne @@skip_check
        cmp al, [BMP_skip_color]
        je @@cont
        @@skip_check:
            mov [es:di], al

        @@cont:
            inc si
            inc di
    loop @@l

    pop dx
    pop cx

    loop @@next_line

@@ret:
    pop cx
    ret

endp

proc PutBmpHeader near
    mov ah, 40h
    mov bx, [BMP_handle]
    mov cx, 54
    lea dx, [BMP_header]
    int 21h

    @@ret:
	ret

endp PutBmpHeader

proc PutBmpPalette near
    mov ah, 40h
    mov cx, 400h
    lea dx, [BMP_palette]
    int 21h

    @@ret:
        ret

endp

proc PutBmpDataIntoFile near
    lea dx, [BMP_line]
    mov ax, 0A000h
    mov es, ax

    mov cx, [BMP_h]
    cld

@@next_line:
    push cx
    dec cx

    mov si, cx
    shl cx, 6
    shl si, 8
    add si, cx

    mov cx, [BMP_w]
    mov di, dx
    push ds
    push es
    pop ds
    pop es
    rep movsb
    push ds
    push es
    pop ds
    pop es

    mov ah, 40h
    mov cx, [BMP_w]
    int 21h

    pop cx
    loop @@next_line

    @@ret:
         ret

endp

end_of_cs:
END start

