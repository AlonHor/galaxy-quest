JUMPS
IDEAL
MODEL small
STACK 100h

FLOOR_y  equ 200 / 2
FLOOR_x  equ 320 / 2

MARIO_w  equ 11
MARIO_h  equ 15
MARIO_bg equ 255

ALIEN_h  equ 15
ALIEN_w  equ 15
ALIEN_bg equ 255

ROBOT_h  equ 15
ROBOT_w  equ 15
ROBOT_bg equ 255

OBJ_bg   equ 255
OBJ_w    equ 11
OBJ_h    equ 11

CYCLES   equ 50000

GAME_t   equ 15
GAME_w   equ 320
GAME_h   equ 200
GAME_mpt equ 1000
MENU_mpt equ 1

DATASEG
    MENU_ticks         dw 0

    GAME_ticks         dw 0
    GAME_state         db 30
    GAME_menu_is_hover db 0
    GAME_score         dw 0
    GAME_is_over       db 0

    CURSOR_x         dw 0
    CURSOR_y         dw 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FLAG_should_setup_game db 0
    FLAG_should_exit_game  db 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ALIEN_is_alive   db 1
    ALIEN_death_time dw 0
    ROBOT_is_alive   db 1
    ROBOT_death_time dw 0

    BLACK_HOLE_death_time dw 0
    LANDMINE_death_time   dw 0

    MARIO_i_x   dw FLOOR_x - (MARIO_w / 2)
    MARIO_i_y   dw FLOOR_y - (MARIO_h / 2)
    MARIO_i_dir db 0
    MARIO_x     dw FLOOR_x - (MARIO_w / 2)
    MARIO_y     dw FLOOR_y - (MARIO_h / 2)
    MARIO_dir   db 4
    MARIO_r_dir db 0
    MARIO_speed dw 3

    ALIEN_i_x   dw FLOOR_x - (ALIEN_w * 3)
    ALIEN_i_y   dw FLOOR_y + (ALIEN_h * 3)
    ALIEN_i_dir db 0
    ALIEN_x     dw FLOOR_x + (ALIEN_w * 2)
    ALIEN_y     dw FLOOR_y + (ALIEN_h * 2)
    ALIEN_dir   db 0
    ALIEN_speed dw 2

    ROBOT_i_x   dw GAME_w - ROBOT_w
    ROBOT_i_y   dw GAME_t + 1
    ROBOT_i_dir db 2
    ROBOT_x     dw GAME_w - ROBOT_w
    ROBOT_y     dw GAME_t + 1
    ROBOT_dir   db 2
    ROBOT_speed dw 5

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    BMP_line         db 320 dup (0)
    BMP_screen_line  db 324 dup (0)

    BMP_starting     db 'start.bmp', 0
    BMP_cycles       db 'cycles.bmp' , 0
    BMP_menu         db 'menu.bmp' , 0
    BMP_menu_guide   db 'menug.bmp' , 0
    BMP_menu_play    db 'menup.bmp' , 0
    BMP_go           db 'go.bmp' , 0
    BMP_go_exit      db 'goe.bmp' , 0
    BMP_go_play      db 'gop.bmp' , 0
    BMP_guide        db 'guide.bmp' , 0
    BMP_robot        db 'robot.bmp' , 0
    BMP_robot_d      db 'robotd.bmp' , 0
    BMP_mario_r      db 'marior.bmp' , 0
    BMP_mario_l      db 'mariol.bmp' , 0
    BMP_landmine     db 'grnd.bmp' , 0
    BMP_landmine_d   db 'grndd.bmp' , 0
    BMP_black_hole   db 'bh.bmp' , 0
    BMP_black_hole_d db 'bhd.bmp' , 0
    BMP_alien        db 'alien.bmp' , 0
    BMP_alien_d      db 'aliend.bmp' , 0
    BMP_star         db 'star.bmp', 0
    BMP_sky          db 'sky.bmp' , 0

    BMP_handle       dw ?
    BMP_header       db 54 dup(0)
    BMP_palette      db 400h dup(0)
    BMP_error_file   db 0

    BMP_x dw ?
    BMP_y dw ?
    BMP_w dw ?
    BMP_h dw ?

    BMP_skip_color   db 0
    BMP_should_skip  db 0

    BMP_dragging     db 0
    BMP_dragging_ptr dw 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    LANDMINE_is_placed   db 0
    LANDMINE_did_explode db 0
    LANDMINE_x           dw 0
    LANDMINE_y           dw 0

    BLACK_HOLE_is_placed   db 0
    BLACK_HOLE_is_inactive db 0
    BLACK_HOLE_x           dw 0
    BLACK_HOLE_y           dw 0

    STAR_x         dw 0
    STAR_y         dw 0
    STAR_last_time dw 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ERROR_opening_bmp_file   db 'Error when opening BMP file.', 0dh, 0ah, '$'
    ERROR_too_many_instances db 'Too many instances.', 0dh, 0ah, '$'

    ERROR_exit               db 'Press any key to exit.', 0dh, 0ah, '$'

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    rnd_pos dw start

SEGMENT SCREEN
    s db 320 * 200 dup(0)
ENDS

CODESEG

start:
    mov ax, @data
    mov ds, ax

    xor ax, ax
    int 33h

    mov ax, 13h
    int 10h

    call HideCursor

    push offset BMP_starting
    push 0
    push 0
    push 320
    push 200
    call RenderBmp

    call UpdateScreen

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

    mov [GAME_state], 0
    call ShowCursor

    call UpdateScreen

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
    call UpdateScreen
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
        jmp @@ret
        ; push offset ERROR_opening_bmp_file
        ; call HandleError

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
;  listener to all mouse events, does hover effects for menu
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc OnCursorEvent far
    push ax
    push bx
    push cx
    push dx
    push ds
    push di

    mov di, @data
    mov ds, di

    shr cx, 1

    mov bl, [GAME_state]
    cmp bl, 0 ; main menu
    jne @@check_game
    jmp @@main_menu

@@check_game:
    cmp bl, 10 ; game
    jne @@check_starting
    jmp @@game

@@check_starting:
    cmp bl, 30 ; starting
    jne @@check_guide
    jmp @@starting

@@check_guide:
    cmp bl, 1 ; guide
    jne @@ret
    jmp @@check_next

@@check_next:
    jmp @@ret

@@main_menu:
    inc [MENU_ticks]
    cmp [MENU_ticks], MENU_mpt
    jne @@skip_main_menu

    mov [MENU_ticks], 0

    cmp cx, 105
    jna @@not_play

    cmp cx, 212
    jnb @@not_play

    cmp dx, 95
    jna @@not_play

    cmp dx, 121
    jnb @@not_play

    cmp [GAME_is_over], 1
    je @@game_over_play
    push offset BMP_menu_play
    jmp @@cont_play
    @@game_over_play:
    push offset BMP_go_play
    @@cont_play:

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

    cmp [GAME_is_over], 1
    je @@game_over_exit
    push offset BMP_menu_guide
    jmp @@cont_guide
    @@game_over_exit:
    push offset BMP_go_exit
    @@cont_guide:

    cmp ax, 10b
    jne @@cont
    cmp [GAME_is_over], 1
    je @@menu_exit
    call ViewGuide
    jmp @@cont_menu_exit
    @@menu_exit:
    mov [FLAG_should_exit_game], 1
    @@cont_menu_exit:
    jmp @@cont

@@not_guide:
    cmp [GAME_is_over], 1
    je @@game_over_primary
    push offset BMP_menu
    jmp @@cont_primary
    @@game_over_primary:
    push offset BMP_go
    @@cont_primary:

    @@cont:
        push 0
        push 0
        push 320
        push 200
        call RenderBmp
        call UpdateScreen

        cmp [GAME_is_over], 1
        jne @@ret

        mov bh, 0
        mov ah, 2

        ; set cursor position to 10, 7
        mov dl, 10
        mov dh, 7
        int 10h

        mov ax, [GAME_score]
        call ShowAxDecimal

        jmp @@ret

@@skip_main_menu:

    @@game:
        cmp ax, 10b ; left press
        jne @@not_left_press
            ; check if hovering on any tool

            ; landmine
            cmp cx, 2
            jna @@not_landmine

            cmp cx, 2 + OBJ_w
            jnb @@not_landmine

            cmp dx, 2
            jna @@not_landmine

            cmp dx, 2 + OBJ_h
            jnb @@not_landmine

            ; yes
            cmp [LANDMINE_is_placed], 1
            je @@not_landmine

            mov [CURSOR_x], cx
            mov [CURSOR_y], dx
            mov [BMP_dragging], 1
            mov [BMP_dragging_ptr], offset BMP_landmine

            @@not_landmine:
            ; black hole
            cmp cx, 2 + OBJ_w + 2
            jna @@not_black_hole

            cmp cx, 2 + OBJ_w + 2 + OBJ_w
            jnb @@not_black_hole

            cmp dx, 2
            jna @@not_black_hole

            cmp dx, 2 + OBJ_h
            jnb @@not_black_hole

            ; yes
            cmp [BLACK_HOLE_is_placed], 1
            je @@not_black_hole

            mov [CURSOR_x], cx
            mov [CURSOR_y], dx
            mov [BMP_dragging], 1
            mov [BMP_dragging_ptr], offset BMP_black_hole

            @@not_black_hole:

        jmp @@ret

        @@not_left_press:
        cmp ax, 100b ; left release
        jne @@not_left_release
        cmp [BMP_dragging], 1
        jne @@not_left_release
            mov [BMP_dragging], 0
            
            cmp [BMP_dragging_ptr], offset BMP_landmine
            jne @@check_black_hole_release
            mov [LANDMINE_is_placed], 1
            sub cx, OBJ_W / 2
            sub dx, OBJ_H / 2
            mov [LANDMINE_x], cx
            mov [LANDMINE_y], dx

            @@check_black_hole_release:
            cmp [BMP_dragging_ptr], offset BMP_black_hole
            jne @@ret
            mov [BLACK_HOLE_is_placed], 1
            sub cx, OBJ_W / 2
            sub dx, OBJ_H / 2
            mov [BLACK_HOLE_x], cx
            mov [BLACK_HOLE_y], dx

        jmp @@ret

        @@not_left_release:
        cmp ax, 1b ; pos change
        jne @@not_pos_change
            sub cx, OBJ_W / 2
            sub dx, OBJ_H / 2
            mov [CURSOR_x], cx
            mov [CURSOR_y], dx

        jmp @@ret

        @@not_pos_change:
        jmp @@ret

    @@starting:
    jmp @@ret

    @@ret:
        call ShowCursor

        pop di
        pop ds
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
;  draws black background
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawBackground
    push ax
    push bx
    push cx
    push dx

    push offset BMP_sky
    push 0
    push GAME_t
    push GAME_w
    push GAME_h - GAME_t
    call RenderBmp

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

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

    mov ah, 1
    int 21h

    @@ret:
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: GameOver
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  shows game over screen
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc GameOver
    mov [BMP_should_skip], 0
    mov [GAME_is_over], 1
    mov [GAME_state], 0

    @@ret:

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
; Procedure: DrawLandmineInTools
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  draws the landmine in the tools section
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawLandmineInTools
    mov [BMP_should_skip], 1
    mov [BMP_skip_color], OBJ_bg

    push offset BMP_landmine
    push 2
    push 2
    push OBJ_w
    push OBJ_h
    call RenderBmp

    @@ret:

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawBlackHoleInTools
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  draws the black hole in the tools section
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawBlackHoleInTools
    mov [BMP_should_skip], 1
    mov [BMP_skip_color], OBJ_bg

    push offset BMP_black_hole
    push 2 + OBJ_w + 2
    push 2
    push OBJ_w
    push OBJ_h
    call RenderBmp

    @@ret:

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawTools
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  draws tools on screen
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawTools
    mov [BMP_should_skip], 0

    push 0
    push 0
    push 320 * 16
    push 0
    call DrawHorizontalLine

    mov [BMP_should_skip], 1
    mov [BMP_skip_color], OBJ_bg

    cmp [BMP_dragging], 1
    jne @@not_dragging

    cmp [BMP_dragging_ptr], offset BMP_landmine
    je @@skip_landmine_drag
    cmp [LANDMINE_is_placed], 1
    je @@skip_landmine_drag
    call DrawLandmineInTools
    @@skip_landmine_drag:
    cmp [BMP_dragging_ptr], offset BMP_black_hole
    je @@skip_black_hole_drag
    cmp [BLACK_HOLE_is_placed], 1
    je @@skip_black_hole_drag
    call DrawBlackHoleInTools
    @@skip_black_hole_drag:
    jmp @@ret

    @@not_dragging:
        cmp [LANDMINE_is_placed], 1
        je @@skip_landmine_placed
        call DrawLandmineInTools

    @@skip_landmine_placed:
        cmp [BLACK_HOLE_is_placed], 1
        je @@skip_black_hole_placed
        call DrawBlackHoleInTools

    @@skip_black_hole_placed:
        jmp @@ret

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
    call DrawBackground

    mov ax, [MARIO_i_x]
    mov [MARIO_x], ax
    mov ax, [MARIO_i_y]
    mov [MARIO_y], ax
    mov al, [MARIO_i_dir]
    mov [MARIO_dir], al
    mov [MARIO_r_dir], 0
    mov [MARIO_speed], 3

    mov ax, [ALIEN_i_x]
    mov [ALIEN_x], ax
    mov ax, [ALIEN_i_y]
    mov [ALIEN_y], ax
    mov al, [ALIEN_i_dir]
    mov [ALIEN_dir], al
    mov [ALIEN_speed], 2

    mov ax, [ROBOT_i_x]
    mov [ROBOT_x], ax
    mov ax, [ROBOT_i_y]
    mov [ROBOT_y], ax
    mov al, [ROBOT_i_dir]
    mov [ROBOT_dir], al
    mov [ROBOT_speed], 5

    mov [ALIEN_is_alive], 1
    mov [ALIEN_death_time], 0
    mov [ROBOT_is_alive], 1
    mov [ROBOT_death_time], 0
    mov [LANDMINE_death_time], 0
    mov [BLACK_HOLE_death_time], 0

    mov [BMP_skip_color], 0
    mov [BMP_should_skip], 0

    mov [BMP_dragging], 0
    mov [CURSOR_x], 0
    mov [CURSOR_y], 0
    mov [BMP_dragging_ptr], 0

    mov [LANDMINE_is_placed], 0
    mov [LANDMINE_did_explode], 0
    mov [LANDMINE_x], 0
    mov [LANDMINE_y], 0

    mov [BLACK_HOLE_is_placed], 0
    mov [BLACK_HOLE_is_inactive], 0
    mov [BLACK_HOLE_x], 0
    mov [BLACK_HOLE_y], 0

    mov [STAR_x], 0
    mov [STAR_y], 0
    mov [STAR_last_time], 0

    mov [GAME_is_over], 0

    call OnStarCollision
    mov [GAME_score], 0
    mov [MARIO_speed], 3

    call DrawTools

    @@ret:

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ViewGuide
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  views the guide image
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc ViewGuide
    mov [GAME_state], 1

    push offset BMP_guide
    push 0
    push 0
    push 320
    push 200
    call RenderBmp
    call UpdateScreen

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

    mov bl, 1
    cmp al, bl
    je @@guide

    mov bl, 10
    cmp al, bl
    je @@game_tick

    jmp @@game_tick

@@main_menu:
    cmp [FLAG_should_setup_game], 1
    jne @@s_skip_setup_game

    mov [FLAG_should_setup_game], 0
    call SetupGame
    jmp @@s_skip_setup_game

@@guide:
    call ViewGuide
    jmp @@s_skip_setup_game

@@s_skip_setup_game:
    cmp [FLAG_should_exit_game], 1
    jne @@skip_move

    mov [FLAG_should_exit_game], 0
    call ExitGame
    jmp @@skip_move

@@game_tick:
    inc [GAME_ticks]
    xor ah, ah
    mov ax, GAME_mpt
    cmp [GAME_ticks], ax
    jnae @@skip_move

    ; move alien towards mario by:
    ; 1. comparing distance of X to the distance in Y
    ; 2. moving in the direction of the greater distance
    ; 3. if the distance is equal, move in the direction of the last move

    mov ax, [ALIEN_x]
    sub ax, [MARIO_x]
    mov cx, ax
    mov bx, [ALIEN_y]
    sub bx, [MARIO_y]
    mov dx, bx

    cmp ax, 0
    jg @@skip_neg_x
    neg ax
    @@skip_neg_x:
    cmp bx, 0
    jg @@skip_neg_y
    neg bx
    jmp @@skip_neg_y

    @@skip_neg_y:

    cmp ax, bx
    jg @@move_alien_x
    ; move alien y
    ; check which direction to move
    cmp dx, 0
    jl @@move_alien_y_down
    ; move up
    mov [ALIEN_dir], 1  ; up
    jmp @@skip_alien_move

    @@move_alien_y_down:
    mov [ALIEN_dir], 3  ; down
    jmp @@skip_alien_move

    @@move_alien_x:
    ; move alien x
    ; check which direction to move
    cmp cx, 0
    jg @@move_alien_x_left
    ; move right
    mov [ALIEN_dir], 4  ; right
    jmp @@skip_alien_move

    @@move_alien_x_left:
    mov [ALIEN_dir], 2  ; left
    jmp @@skip_alien_move

    @@skip_alien_move:

    mov [GAME_ticks], 0

    cmp [MARIO_dir], 1
    je @@up

    cmp [MARIO_dir], 2
    je @@left

    cmp [MARIO_dir], 3
    je @@down

    cmp [MARIO_dir], 4
    jne @@cont

    jmp @@right

    @@up:
        mov ax, [MARIO_y]
        sub ax, [MARIO_speed]
        cmp ax, GAME_t
        jng @@cont

        mov ax, [MARIO_speed]
        sub [MARIO_y], ax
        jmp @@cont

    @@left:
        mov ax, [MARIO_x]
        sub ax, [MARIO_speed]
        cmp ax, 0
        jng @@cont

        mov ax, [MARIO_speed]
        sub [MARIO_x], ax
        jmp @@cont

    @@down:
        mov ax, [MARIO_y]
        add ax, MARIO_h
        add ax, [MARIO_speed]
        cmp ax, GAME_h
        jnl @@cont

        mov ax, [MARIO_speed]
        add [MARIO_y], ax
        jmp @@cont

    @@right:
        mov ax, [MARIO_x]
        add ax, MARIO_w
        add ax, [MARIO_speed]
        cmp ax, GAME_w
        jnl @@cont

        mov ax, [MARIO_speed]
        add [MARIO_x], ax
        jmp @@cont

@@cont:
    cmp [ALIEN_is_alive], 0
    je @@cont_2

    cmp [ALIEN_dir], 1
    je @@up_alien

    cmp [ALIEN_dir], 2
    je @@left_alien

    cmp [ALIEN_dir], 3
    je @@down_alien

    cmp [ALIEN_dir], 4
    jne @@jmp_to_cont_2

    jmp @@right_alien

    @@up_alien:
        mov ax, [ALIEN_y]
        sub ax, [ALIEN_speed]
        cmp ax, GAME_t
        jng @@cont_2

        mov ax, [ALIEN_speed]
        sub [ALIEN_y], ax
        jmp @@cont_2

    @@left_alien:
        mov ax, [ALIEN_x]
        sub ax, [ALIEN_speed]
        cmp ax, 0
        jng @@cont_2

        mov ax, [ALIEN_speed]
        sub [ALIEN_x], ax
        jmp @@cont_2

    @@jmp_to_cont_2:
        jmp @@cont_2

    @@down_alien:
        mov ax, [ALIEN_y]
        add ax, ALIEN_h
        add ax, [ALIEN_speed]
        cmp ax, GAME_h
        jnl @@cont_2

        mov ax, [ALIEN_speed]
        add [ALIEN_y], ax
        jmp @@cont_2

    @@right_alien:
        mov ax, [ALIEN_x]
        add ax, ALIEN_w
        add ax, [ALIEN_speed]
        cmp ax, GAME_w
        jnl @@cont_2

        mov ax, [ALIEN_speed]
        add [ALIEN_x], ax
        jmp @@cont_2

@@cont_2:
    cmp [ROBOT_is_alive], 0
    je @@cont_3

    cmp [ROBOT_dir], 2
    je @@left_robot

    cmp [ROBOT_dir], 4
    jne @@jmp_to_cont_3

    jmp @@right_robot

    @@left_robot:
        mov ax, [ROBOT_x]
        sub ax, [ROBOT_speed]
        cmp ax, 0
        jng @@swap_dir_left

        mov ax, [ROBOT_speed]
        sub [ROBOT_x], ax
        jmp @@cont_3

    @@swap_dir_left:
        mov ax, [ROBOT_y]
        add ax, [ROBOT_speed]
        add ax, ROBOT_h
        cmp ax, GAME_h
        jnl @@reset_robot_pos

        mov [ROBOT_dir], 4
        mov ax, [ROBOT_speed]
        add [ROBOT_y], ax
        jmp @@cont_3

    @@jmp_to_cont_3:
        jmp @@cont_3

    @@right_robot:
        mov ax, [ROBOT_x]
        add ax, ROBOT_w
        add ax, [ROBOT_speed]
        cmp ax, GAME_w
        jnl @@swap_dir_right

        mov ax, [ROBOT_speed]
        add [ROBOT_x], ax
        jmp @@cont_3

    @@swap_dir_right:
        mov ax, [ROBOT_y]
        add ax, [ROBOT_speed]
        add ax, ROBOT_h
        cmp ax, GAME_h
        jnl @@reset_robot_pos

        mov [ROBOT_dir], 2
        mov ax, [ROBOT_speed]
        add [ROBOT_y], ax
        jmp @@cont_3

    @@reset_robot_pos:
        mov ax, [ROBOT_i_x]
        mov [ROBOT_x], ax
        mov ax, [ROBOT_i_y]
        mov [ROBOT_y], ax
        mov [ROBOT_dir], 2

@@cont_3:
    call DrawBackground
    call DrawTools
    call DrawAllSprites
    call UpdateScreen

@@skip_move:
    call HandlePlayerInput
    cmp di, 1
    jne @@skip_exit_game
    cmp [GAME_state], 0
    je @@exit_game
    mov [BMP_should_skip], 0
    mov [GAME_state], 0
    jmp @@ret

    @@exit_game:
        call ExitGame

    @@skip_exit_game:

    push [MARIO_x]
    push [MARIO_y]
    push MARIO_w
    push MARIO_h
    push [STAR_x]
    push [STAR_y]
    push OBJ_w
    push OBJ_h
    call IsCollision
    cmp di, 1
    je @@star_found

    @@no_star_found:

    push [MARIO_x]
    push [MARIO_y]
    push MARIO_w
    push MARIO_h
    push [LANDMINE_x]
    push [LANDMINE_y]
    push OBJ_w
    push OBJ_h
    call IsCollision
    cmp di, 1
    je @@game_over_landmine

    @@no_game_over_landmine:

    push [MARIO_x]
    push [MARIO_y]
    push MARIO_w
    push MARIO_h
    mov ax, [BLACK_HOLE_x]
    sub ax, 10
    push ax
    mov ax, [BLACK_HOLE_y]
    sub ax, 10
    push ax
    push OBJ_w + 20
    push OBJ_h + 20
    call IsCollision
    cmp di, 1
    je @@game_over_black_hole

    @@no_game_over_black_hole:

    push [ALIEN_x]
    push [ALIEN_y]
    push ALIEN_w
    push ALIEN_h
    push [MARIO_x]
    push [MARIO_y]
    push MARIO_w
    push MARIO_h
    call IsCollision
    cmp di, 1
    je @@game_over_alien

    @@no_game_over_alien:

    push [ALIEN_x]
    push [ALIEN_y]
    push ALIEN_w
    push ALIEN_h
    push [LANDMINE_x]
    push [LANDMINE_y]
    push OBJ_w
    push OBJ_h
    call IsCollision
    cmp di, 1
    je @@kill_alien_landmine

    @@no_kill_alien_landmine:

    push [ALIEN_x]
    push [ALIEN_y]
    push ALIEN_w
    push ALIEN_h
    mov ax, [BLACK_HOLE_x]
    sub ax, 10
    push ax
    mov ax, [BLACK_HOLE_y]
    sub ax, 10
    push ax
    push OBJ_w + 20
    push OBJ_h + 20
    call IsCollision
    cmp di, 1
    je @@kill_alien_black_hole

    @@no_kill_alien_black_hole:

    push [ROBOT_x]
    push [ROBOT_y]
    push ROBOT_w
    push ROBOT_h
    push [MARIO_x]
    push [MARIO_y]
    push MARIO_w
    push MARIO_h
    call IsCollision
    cmp di, 1
    je @@game_over_robot

    @@no_game_over_robot:

    push [ROBOT_x]
    push [ROBOT_y]
    push ROBOT_w
    push ROBOT_h
    push [LANDMINE_x]
    push [LANDMINE_y]
    push OBJ_w
    push OBJ_h
    call IsCollision
    cmp di, 1
    je @@kill_robot_landmine

    @@no_kill_robot_landmine:

    push [ROBOT_x]
    push [ROBOT_y]
    push ROBOT_w
    push ROBOT_h
    mov ax, [BLACK_HOLE_x]
    sub ax, 10
    push ax
    mov ax, [BLACK_HOLE_y]
    sub ax, 10
    push ax
    push OBJ_w + 20
    push OBJ_h + 20
    call IsCollision
    cmp di, 1
    je @@kill_robot_black_hole

    @@no_kill_robot_black_hole:

    jmp @@ret

    @@star_found:
        call OnStarCollision
        jmp @@no_star_found

    @@game_over_black_hole:
        cmp [BLACK_HOLE_is_placed], 0
        je @@no_game_over_black_hole

        cmp [BLACK_HOLE_is_inactive], 1
        je @@no_game_over_black_hole

        call GameOver
        jmp @@no_game_over_black_hole

    @@game_over_robot:
        cmp [ROBOT_is_alive], 0
        je @@no_game_over_robot

        call GameOver
        jmp @@no_game_over_robot

    @@game_over_alien:
        cmp [ALIEN_is_alive], 0
        je @@no_game_over_alien

        call GameOver
        jmp @@no_game_over_alien

    @@game_over_landmine:
        cmp [LANDMINE_is_placed], 0
        je @@no_game_over_landmine

        cmp [LANDMINE_did_explode], 1
        je @@no_game_over_landmine

        call GameOver
        jmp @@no_game_over_landmine

    @@kill_alien_landmine:
        cmp [LANDMINE_is_placed], 0
        je @@no_kill_alien_landmine

        cmp [LANDMINE_did_explode], 1
        je @@no_kill_alien_landmine

        cmp [ALIEN_is_alive], 0
        je @@no_kill_alien_landmine

        mov [LANDMINE_did_explode], 1

        mov ax, 40h
        mov es, ax
        mov ax, [es:6Ch]
        mov [LANDMINE_death_time], ax
        jmp @@kill_alien

    @@kill_alien_black_hole:
        cmp [BLACK_HOLE_is_placed], 0
        je @@no_kill_alien_black_hole

        cmp [BLACK_HOLE_is_inactive], 1
        je @@no_kill_alien_black_hole

        cmp [ALIEN_is_alive], 0
        je @@no_kill_alien_black_hole

        mov [BLACK_HOLE_is_inactive], 1

        mov ax, 40h
        mov es, ax
        mov ax, [es:6Ch]
        mov [BLACK_HOLE_death_time], ax
        jmp @@kill_alien

    @@kill_robot_landmine:
        cmp [LANDMINE_is_placed], 0
        je @@no_kill_robot_landmine

        cmp [LANDMINE_did_explode], 1
        je @@no_kill_robot_landmine

        cmp [ROBOT_is_alive], 0
        je @@no_kill_robot_landmine

        mov [LANDMINE_did_explode], 1

        mov ax, 40h
        mov es, ax
        mov ax, [es:6Ch]
        mov [LANDMINE_death_time], ax
        jmp @@kill_robot

    @@kill_robot_black_hole:
        cmp [BLACK_HOLE_is_placed], 0
        je @@no_kill_robot_black_hole

        cmp [BLACK_HOLE_is_inactive], 1
        je @@no_kill_robot_black_hole

        cmp [ROBOT_is_alive], 0
        je @@no_kill_robot_black_hole

        mov [BLACK_HOLE_is_inactive], 1

        mov ax, 40h
        mov es, ax
        mov ax, [es:6Ch]
        mov [BLACK_HOLE_death_time], ax
        jmp @@kill_robot

    @@kill_alien:
        mov [ALIEN_is_alive], 0

        mov ax, 40h
        mov es, ax
        mov ax, [es:6Ch]
        mov [ALIEN_death_time], ax

        jmp @@ret

    @@kill_robot:
        mov [ROBOT_is_alive], 0

        mov ax, 40h
        mov es, ax
        mov ax, [es:6Ch]
        mov [ROBOT_death_time], ax
        jmp @@ret

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        ret

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawAllSprites
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  draws all sprites
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawAllSprites
    push [MARIO_x]
    push [MARIO_y]
    call DrawMarioAt

    cmp [ALIEN_is_alive], 0
    je @@alien_dead

    push [ALIEN_x]
    push [ALIEN_y]
    call DrawAlienAt
    jmp @@skip_alien_dead

    @@alien_dead:

    push offset BMP_alien_d
    push [ALIEN_x]
    push [ALIEN_y]
    push ALIEN_w
    push ALIEN_h
    call RenderBmp

    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    sub ax, [ALIEN_death_time]
    cmp ax, 100
    jl @@skip_alien_dead
    mov [ALIEN_is_alive], 1

    @@skip_alien_dead:

    cmp [ROBOT_is_alive], 0
    je @@robot_dead

    push [ROBOT_x]
    push [ROBOT_y]
    call DrawRobotAt
    jmp @@skip_robot_dead

    @@robot_dead:

    push offset BMP_robot_d
    push [ROBOT_x]
    push [ROBOT_y]
    push ROBOT_w
    push ROBOT_h
    call RenderBmp

    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    sub ax, [ROBOT_death_time]
    cmp ax, 100
    jl @@skip_robot_dead
    mov [ROBOT_is_alive], 1

    @@skip_robot_dead:

    cmp [LANDMINE_is_placed], 1
    jne @@skip_landmine
    cmp [LANDMINE_did_explode], 1
    jne @@landmine_active
        @@landmine_exploded:
        push offset BMP_landmine_d
        jmp @@cont_landmine
    @@landmine_active:
        push offset BMP_landmine
    @@cont_landmine:
    push [LANDMINE_x]
    push [LANDMINE_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    cmp [LANDMINE_did_explode], 1
    jne @@skip_landmine

    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    sub ax, [LANDMINE_death_time]
    cmp ax, 200
    jl @@skip_landmine
    mov [LANDMINE_is_placed], 0
    mov [LANDMINE_did_explode], 0

    @@skip_landmine:

    cmp [BLACK_HOLE_is_placed], 1
    jne @@skip_black_hole
    cmp [BLACK_HOLE_is_inactive], 1
    jne @@black_hole_active
        @@black_hole_inactive:
        push offset BMP_black_hole_d
        jmp @@cont_black_hole
    @@black_hole_active:
        push offset BMP_black_hole
    @@cont_black_hole:
    push [BLACK_HOLE_x]
    push [BLACK_HOLE_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    cmp [BLACK_HOLE_is_inactive], 1
    jne @@skip_black_hole

    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    sub ax, [BLACK_HOLE_death_time]
    cmp ax, 200
    jl @@skip_black_hole
    mov [BLACK_HOLE_is_inactive], 0

    @@skip_black_hole:

    push offset BMP_star
    push [STAR_x]
    push [STAR_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    sub ax, [STAR_last_time]
    cmp ax, 20
    jl @@skip_speed_decrease
    cmp [MARIO_speed], 3
    jle @@skip_speed_decrease
    mov [MARIO_speed], 3

    @@skip_speed_decrease:

    cmp [BMP_dragging], 1
    jne @@skip_drag

    mov [BMP_should_skip], 1
    mov [BMP_skip_color], OBJ_bg

    call HideCursor

    push [BMP_dragging_ptr]
    push [CURSOR_x]
    push [CURSOR_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    jmp @@skip_drag

    @@skip_drag:

    @@ret:

        ret
endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: HandlePlayerInput
;
; Arguments:
;  none
;
; Returns:
;  di - 1 if exit, 0 if continue
;
; Description:
;  handles player input, arrow keys, esc, wasd...
;
; External links:
;  https://stanislavs.org/helppc/scan_codes.html
;
; Register usage:
;  ax - keybind interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc HandlePlayerInput
    push ax

    xor di, di
    ; check if key in buffer
    mov ah, 1
    int 16h
    jz @@ret ; continue

    @@key_pressed:
        ; read key from buffer
        mov ah, 0
        int 16h

        ; esc key
        cmp ax, 011Bh
        je @@exit_game

        ; avoid changing anything when game is not running
        cmp [GAME_state], 10
        jne @@cont

        ; up arrow
        cmp ah, 48h
        je @@up

        ; w
        cmp ah, 11h
        je @@up

        ; left arrow
        cmp ah, 4Bh
        je @@left

        ; a
        cmp ah, 1Eh
        je @@left

        ; down arrow
        cmp ah, 50h
        je @@down

        ; s
        cmp ah, 1Fh
        je @@down

        ; right arrow
        cmp ah, 4Dh
        je @@right

        ; d
        cmp ah, 20h
        je @@right

        jmp @@cont

    @@up:
        mov [MARIO_dir], 1
        jmp @@cont

    @@left:
        mov [MARIO_dir], 2
        mov [MARIO_r_dir], 1
        jmp @@cont

    @@down:
        mov [MARIO_dir], 3
        jmp @@cont

    @@right:
        mov [MARIO_dir], 4
        mov [MARIO_r_dir], 0
        jmp @@cont

    @@cont:
        xor di, di
        jmp @@ret

    @@exit_game:
        mov di, 1

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
; Procedure: IsCollision
;
; Arguments:
;  stack - (x1, y1, w1, h1, x2, y2, w2, h2)
;
; Returns:
;  di - 1 if collision, 0 if no collision
;
; Description:
;  draws mario at given position
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x1 equ [word bp + 18]
y1 equ [word bp + 16]
w1 equ [word bp + 14]
h1 equ [word bp + 12]
x2 equ [word bp + 10]
y2 equ [word bp + 8]
w2 equ [word bp + 6]
h2 equ [word bp + 4]
proc IsCollision
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    ; check for collision on X axis
    mov ax, x2
    add ax, w2
    cmp x1, ax ; is x1 to the right of 2's right edge?
    ja @@no_collision  ; if yes, then no collision

    mov ax, x1
    add ax, w1
    cmp x2, ax ; is x2 to the right of 1's right edge?
    ja @@no_collision  ; if yes, then no collision

    ; check for collision on Y axis
    mov ax, y2
    add ax, h2
    cmp y1, ax ; is y1 below 2's bottom edge?
    ja @@no_collision  ; if yes, then no collision

    mov ax, y1
    add ax, h1
    cmp y2, ax ; is y2 above 1's top edge?
    ja @@no_collision  ; if yes, then no collision

    ; if none of the above conditions are true, then there's a collision
    jmp @@collision

    @@collision:
        mov di, 1
        jmp @@ret

    @@no_collision:
        xor di, di

    @@ret:
        pop dx
        pop cx
        pop bx
        pop ax

        pop bp
        ret 16

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

;  stack - (filename asciiz offset, x, y, w, h)
    mov [BMP_skip_color], MARIO_bg
    mov [BMP_should_skip], 1

    cmp [MARIO_r_dir], 1
    je @@mario_l

    push offset BMP_mario_r
    jmp @@mario_cont

    @@mario_l:
    push offset BMP_mario_l

    @@mario_cont:

    push x
    push y
    push MARIO_w
    push MARIO_h
    call RenderBmp

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 4

endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: DrawRobotAt
;
; Arguments:
;  stack - (x, y)
;
; Returns:
;  none
;
; Description:
;  draws the robot at given position
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x equ [word bp + 6]
y equ [word bp + 4]
proc DrawRobotAt
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

;  stack - (filename asciiz offset, x, y, w, h)
    mov [BMP_skip_color], ROBOT_bg
    mov [BMP_should_skip], 1
    push offset BMP_robot
    push x
    push y
    push ROBOT_w
    push ROBOT_h
    call RenderBmp

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 4

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
;  draws the alien at given position
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

;  stack - (filename asciiz offset, x, y, w, h)
    mov [BMP_skip_color], ALIEN_bg
    mov [BMP_should_skip], 1
    push offset BMP_alien
    push x
    push y
    push ALIEN_w
    push ALIEN_h
    call RenderBmp

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 4

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
    mov ax, SCREEN
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
; Procedure: OnStarCollision
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  randomizes star position and adds 1 to the total score
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc OnStarCollision
    push ax
    push bx
    push cx
    push dx

    mov bx, 0
    mov dx, GAME_w - OBJ_w
    call RandomWord
    mov [STAR_x], ax

    mov bx, GAME_t
    mov dx, GAME_h - OBJ_h
    call RandomWord
    mov [STAR_y], ax

    inc [GAME_score]
    add [MARIO_speed], 2

    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    mov [STAR_last_time], ax

@@ret:
    pop dx
    pop cx
    pop bx
    pop ax

    ret

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
; Procedure: UpdateScreen
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  updates screen data in SCREEN SEGMENT into 0A000h
;
; Registers:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc UpdateScreen
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds

    call HideCursor

    mov ax, 0A000h
    mov es, ax

    mov ax, SCREEN
    mov ds, ax
    xor si, si
    xor di, di

    mov cx, 320 * 200
    rep movsb

    call ShowCursor

@@ret:
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

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

    ; mov dl, ','
    ; mov ah, 2h
    ; int 21h

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
        mov al, [si + 2]
        shr al, 2
        out dx, al
        mov al, [si + 1]
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

    mov ax, SCREEN
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
    mov ax, SCREEN
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

