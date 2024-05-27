JUMPS
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

MARIO_w  equ 11
MARIO_h  equ 15
MARIO_bg equ 255 ; 255

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

CHASE_w  equ 5
CHASE_h  equ 5

GAME_t   equ 15
GAME_w   equ 320
GAME_h   equ 200
GAME_mpt equ 30000
MENU_mpt equ 1

DATASEG
    MENU_ticks         dw 0

    GAME_ticks         dw 0
    GAME_palette       db 300h dup(?)
    GAME_state         db 30
    GAME_menu_is_hover db 0
    ; 0 - main menu
    ;   1 - guide
    ;   2 - other stuff
    ; 10 - game
    ; 20 - game over
    ; 30 - starting

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FLAG_should_setup_game db 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ALIEN_is_alive db 1
    ALIEN_death    dw 0
    ROBOT_is_alive db 1
    ROBOT_death    dw 0

    MARIO_i_x   dw FLOOR_x - (MARIO_w / 2)
    MARIO_i_y   dw FLOOR_y - (MARIO_h / 2)
    MARIO_i_dir db 0
    MARIO_x     dw FLOOR_x - (MARIO_w / 2)
    MARIO_y     dw FLOOR_y - (MARIO_h / 2)
    MARIO_dir   db 0
    MARIO_speed dw 5

    ALIEN_i_x   dw FLOOR_x + (ALIEN_w * 2)
    ALIEN_i_y   dw FLOOR_y + (ALIEN_h * 2)
    ALIEN_i_dir db 0
    ALIEN_x     dw FLOOR_x + (ALIEN_w * 2)
    ALIEN_y     dw FLOOR_y + (ALIEN_h * 2)
    ALIEN_dir   db 0
    ALIEN_speed dw 3

    ROBOT_i_x   dw GAME_w - ROBOT_w
    ROBOT_i_y   dw GAME_t + 1
    ROBOT_i_dir db 2
    ROBOT_x     dw GAME_w - ROBOT_w
    ROBOT_y     dw GAME_t + 1
    ROBOT_dir   db 2
    ROBOT_speed dw 10

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    BMP_line        db 320 dup (0)
    BMP_screen_line db 324 dup (0)

    BMP_starting       db 'start.bmp', 0
    BMP_cycles         db 'cycles.bmp' , 0
    BMP_menu           db 'menu.bmp' , 0
    BMP_menu_guide     db 'menug.bmp' , 0
    BMP_menu_play      db 'menup.bmp' , 0
    BMP_guide          db 'guide.bmp' , 0
    BMP_tools_bg       db 'toolsbg.bmp' , 0
    BMP_robot          db 'robot.bmp' , 0
    BMP_mario          db 'mario.bmp' , 0
    BMP_landmine        db 'grnd.bmp' , 0
    BMP_black_hole     db 'bh.bmp' , 0
    BMP_alien          db 'alien.bmp' , 0
    BMP_sky            db 'sky.bmp' , 0

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

    BMP_dragging       db 0
    BMP_dragging_x     dw 0
    BMP_dragging_y     dw 0
    BMP_dragging_ptr   dw 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    LANDMINE_is_placed    db 0
    LANDMINE_did_explode  db 0
    LANDMINE_is_counting  db 0
    LANDMINE_x            dw 0
    LANDMINE_y            dw 0

    BLACK_HOLE_is_placed db 0
    BLACK_HOLE_is_alive  db 0
    BLACK_HOLE_x         dw 0
    BLACK_HOLE_y         dw 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ERROR_opening_bmp_file   db 'Error when opening BMP file.', 0dh, 0ah, '$'
    ERROR_too_many_instances db 'Too many instances.', 0dh, 0ah, '$'

    ERROR_exit               db 'Press any key to exit.', 0dh, 0ah, '$'

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; INFO_alien_struct_size equ 5
    ; INFO_max_aliens        equ 5

    ; OBJECT_alien equ is_alive
    ;     is_alive db 1
    ;     alien_x  dw 0
    ;     alien_y  dw 0

    ; TMP_current_alien equ tmp_is_alive
    ;     tmp_is_alive  db 1
    ;     tmp_alien_x   dw 0
    ;     tmp_alien_y   dw 0

    ; PROP_alien_is_alive equ 0
    ; PROP_alien_x        equ 1
    ; PROP_alien_y        equ 3

    ; DATA_alien_list       db INFO_alien_struct_size * INFO_max_aliens dup(?)
    ; POINTER_current_alien db 0

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
    call HideCursor

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

    mov [GAME_state], 0
    call ShowCursor

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
;  listener to all mouse events, does hover effects
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
    cmp bl, 0 ; main menu
    jne @@check_game
    jmp @@main_menu

@@check_game:
    cmp bl, 10 ; game
    jne @@check_starting
    jmp @@game

@@check_starting:
    cmp bl, 30 ; starting
    jne @@check_next
    jmp @@starting

@@check_next:
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
    call ViewGuide
    jmp @@cont

@@not_guide:
    push offset BMP_menu

    @@cont:
        push 0
        push 0
        push 320
        push 200
        call RenderBmp

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

            mov [BMP_dragging], 1
            mov [BMP_dragging_x], cx
            mov [BMP_dragging_y], dx
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

            mov [BMP_dragging], 1
            mov [BMP_dragging_x], cx
            mov [BMP_dragging_y], dx
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
            mov [LANDMINE_x], cx
            mov [LANDMINE_y], dx

            @@check_black_hole_release:
            cmp [BMP_dragging_ptr], offset BMP_black_hole
            jne @@ret
            mov [BLACK_HOLE_is_placed], 1
            mov [BLACK_HOLE_x], cx
            mov [BLACK_HOLE_y], dx

            call DrawTools

        jmp @@ret

        @@not_left_release:
        cmp ax, 1b ; pos change
        jne @@not_pos_change
            cmp [BMP_dragging], 0
            je @@ret
                call DrawTools
                call DrawBackground
                call DrawAllSprites
                call DrawDraggedBmp

                mov [BMP_dragging_x], cx
                mov [BMP_dragging_y], dx

        jmp @@ret

        @@not_pos_change:
        jmp @@ret

    @@starting:
    jmp @@ret

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

    ; push 0
    ; push GAME_t + 1
    ; push GAME_w * (GAME_h - GAME_t - 1)
    ; push BG
    ; call DrawHorizontalLine
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
; Procedure: DrawDraggedBmp
;
; Arguments:
;  none
;
; Returns:
;  none
;
; Description:
;  draws dragged bmp on screen
;
; Register usage:
;  none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc DrawDraggedBmp
    mov [BMP_should_skip], 1
    mov [BMP_skip_color], OBJ_bg

    call HideCursor

    push [BMP_dragging_ptr]
    push [BMP_dragging_x]
    push [BMP_dragging_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    call ShowCursor

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
    call RestorePalette

    mov ax, [MARIO_i_x]
    mov [MARIO_x], ax
    mov ax, [MARIO_i_y]
    mov [MARIO_y], ax
    mov al, [MARIO_i_dir]
    mov [MARIO_dir], al

    mov ax, [ALIEN_i_x]
    mov [ALIEN_x], ax
    mov ax, [ALIEN_i_y]
    mov [ALIEN_y], ax
    mov al, [ALIEN_i_dir]
    mov [ALIEN_dir], al

    mov ax, [ROBOT_i_x]
    mov [ROBOT_x], ax
    mov ax, [ROBOT_i_y]
    mov [ROBOT_y], ax
    mov al, [ROBOT_i_dir]
    mov [ROBOT_dir], al

    mov [BMP_skip_color], 0
    mov [BMP_should_skip], 0

    mov [BMP_dragging], 0
    mov [BMP_dragging_x], 0
    mov [BMP_dragging_y], 0
    mov [BMP_dragging_ptr], 0

    mov [LANDMINE_is_placed], 0
    mov [LANDMINE_did_explode], 0
    mov [LANDMINE_is_counting], 0
    mov [LANDMINE_x], 0
    mov [LANDMINE_y], 0

    mov [BLACK_HOLE_is_placed], 0
    mov [BLACK_HOLE_is_alive], 0
    mov [BLACK_HOLE_x], 0
    mov [BLACK_HOLE_y], 0

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
    jmp @@skip_move

@@game_tick:
    inc [GAME_ticks]
    xor ah, ah
    mov ax, GAME_mpt
    cmp [GAME_ticks], ax
    jnae @@jmp_to_skip_move

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

    @@jmp_to_skip_move:
        jmp @@skip_move

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
    jne @@jmp_to_cont

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

    @@jmp_to_cont:
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

    cmp [LANDMINE_is_placed], 0
    je @@skip_mario_landmine_collision

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
    je @@game_over

    @@skip_mario_landmine_collision:

    cmp [BLACK_HOLE_is_placed], 0
    je @@skip_mario_black_hole_collision

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
    je @@game_over

    @@skip_mario_black_hole_collision:

    cmp [ALIEN_is_alive], 0
    je @@skip_alien_collision

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
    je @@game_over

    cmp [LANDMINE_is_placed], 0
    je @@skip_alien_landmine_collision

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
    je @@kill_alien

    @@skip_alien_landmine_collision:

    cmp [BLACK_HOLE_is_placed], 0
    je @@skip_alien_black_hole_collision

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
    je @@kill_alien

    @@skip_alien_black_hole_collision:

    @@skip_alien_collision:

    jmp @@ret

    @@game_over:
        mov [BMP_should_skip], 0
        mov [GAME_state], 0
        jmp @@ret

    @@kill_alien:
        mov [ALIEN_is_alive], 0
        mov ax, 40h
        mov es, ax

        mov ax, [es:6Ch]
        mov [ALIEN_death], ax

    ; @@col_mario_robot:
    ;     mov [BMP_should_skip], 0
    ;     mov [GAME_state], 0
    ;     jmp @@ret

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

    push [ALIEN_x]
    push [ALIEN_y]
    call DrawAlienAt

    push [ROBOT_x]
    push [ROBOT_y]
    call DrawRobotAt

    cmp [LANDMINE_is_placed], 1
    jne @@skip_landmine
    cmp [LANDMINE_did_explode], 1
    je @@skip_landmine
    push offset BMP_landmine
    push [LANDMINE_x]
    push [LANDMINE_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    @@skip_landmine:

    cmp [BLACK_HOLE_is_placed], 1
    jne @@skip_black_hole
    cmp [BLACK_HOLE_is_alive], 1
    je @@skip_black_hole
    push offset BMP_black_hole
    push [BLACK_HOLE_x]
    push [BLACK_HOLE_y]
    push OBJ_w
    push OBJ_h
    call RenderBmp

    @@skip_black_hole:

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

    xor di, di
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
    push offset BMP_mario
    push x
    push y
    push MARIO_w
    push MARIO_h
    ; push offset mario
    ; call DrawMatrixAt
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

