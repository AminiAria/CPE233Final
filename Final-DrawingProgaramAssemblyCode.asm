;---------------------------------------------------------------------
; Drawing Program
; Created by Trevor Jones and Aria Amini
;
; Movement: arrow keys or WASD
; Modes:
;   Draw: enter
;   Erase: backspace
;   Cursor: space
; Color Selection:
;   1: red (default pen color)
;   2: orange
;   3: yellow
;   4: green
;   5: blue (default background color)
;   6: indigo
;   7: violet
;   8: black
;   9: white
;   0: gray
; Other:
;   B colors the whole screen the current pen color
;   L draws a rectangle bounded by the points set using J and K
;---------------------------------------------------------------------

.CSEG
.ORG 0x01

.EQU VGA_HADD       = 0x90
.EQU VGA_LADD       = 0x91
.EQU VGA_COLOR      = 0x92
.EQU VGA_READ_ID    = 0x93
.EQU PS2_KEY_CODE   = 0x44
.EQU SSEG1          = 0x81
.EQU SSEG2          = 0x82
.EQU LEDS           = 0x40

; Registers:
;    R0: mode (0 cursor, 1 erase, 2 draw)
;    R1: keycode
;    R6: current color
;    R7: current Y
;    R8: current X
;   R11: current pen color
;   R12: pen X
;   R13: pen Y
;   R14: background color
;   R15: previous color
;   R16: X1
;   R17: Y1
;   R18: X2
;   R19: Y2
;   R20: temporary

;---------------------------------------------------------------------
init:   MOV     R1, 0                   ; used to hold keycode
        MOV     R0, 0                   ; used to hold mode
        MOV     R11, 0xE0               ; initial pen color is red
        MOV     R14, 0x03               ; initial background is blue
        MOV     R15, R14                ; initialize previous color
        CALL    draw_background         ; draw using default color

        MOV     R6, R11                 ; color red
        MOV     R7, 0x1E                ; center Y coordinate
        MOV     R8, 0x28                ; center X coordinate
        CALL    draw_dot                ; draw red square
        OUT     R8, SSEG1
        OUT     R7, SSEG2
        SEI
        
main:   BRN  main                       ; waiting for interrupts
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Subroutine: draw_horizontal_line
;
; Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;
; Parameters:
;   r8  = starting x-coordinate
;   r7  = y-coordinate
;   r9  = ending x-coordinate
;   r6  = color used for line
; 
; Tweaked registers: r8,r9
;---------------------------------------------------------------------
draw_horizontal_line:
        ADD    r9,0x01          ; go from r8 to r9 inclusive

draw_horiz1:
        CALL   draw_dot
        ADD    r8,0x01
        CMP    r8,r9
        BRNE   draw_horiz1
        RET
;---------------------------------------------------------------------


;---------------------------------------------------------------------
; Subroutine: draw_vertical_line
;
; Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
;
; Parameters:
;   r8  = x-coordinate
;   r7  = starting y-coordinate
;   r9  = ending y-coordinate
;   r6  = color used for line
; 
; Tweaked registers: r7,r9
;---------------------------------------------------------------------
draw_vertical_line:
        ADD    r9,0x01

draw_vert1:          
        CALL   draw_dot
        ADD    r7,0x01
        CMP    r7,R9
        BRNE   draw_vert1
        RET
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Subroutine: draw_background
;
; Fills the 80x60 grid with one color using successive calls to 
; draw_horizontal_line subroutine. 
; 
; Tweaked registers: r10,r7,r8,r9
;----------------------------------------------------------------------
draw_background: 
        MOV   r6,r14                    ; use background color
        MOV   r10,0x00                  ; r10 keeps track of rows
start:  MOV   r7,r10                    ; load current row count 
        MOV   r8,0x00                   ; restart x coordinates
        MOV   r9,0x4F                   ; set to number of columns

        CALL  draw_horizontal_line
        ADD   r10,0x01                  ; increment row count
        CMP   r10,0x3C                  ; see if more rows to draw
        BRNE  start                     ; branch to draw more rows
        MOV   r7, 0x1E                  ; center Y coordinate
        MOV   r8, 0x28                  ; center X coordinate
        RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
; Subroutine: draw_dot
; 
; This subroutine draws a dot on the display the given coordinates: 
; 
; (X,Y) = (r8,r7)  with a color stored in r6  
;---------------------------------------------------------------------
draw_dot: 
        OUT   r8,VGA_LADD      ; write bot 8 address bits to register
        OUT   r7,VGA_HADD      ; write top 5 address bits to register
        OUT   r6,VGA_COLOR     ; write color data to frame buffer
        RET           
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Subroutine: read_color
; 
; This subroutine reads the color at the given coordinates: 
; 
; (X,Y) = (r8,r7)  the color is stored in r15
;---------------------------------------------------------------------
read_color: 
        OUT   r8,VGA_LADD      ; write bot 8 address bits to register
        OUT   r7,VGA_HADD      ; write top 5 address bits to register
        IN    r15,VGA_READ_ID  ; store the color
        RET
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Subroutine: draw_rect
;
; Fills a rectangle bounded by (R16, R17) and (R17,R18) with one
; color using successive calls to draw_horizontal_line subroutine. 
; 
; Parameters: R16 (X1), R17 (Y1), R18 (X2), R19 (Y2), R11 (Color)
; Tweaked registers: R6, R7, R8, R9, R12, R13, R16, R17, R18, R19, R20
;---------------------------------------------------------------------
draw_rect: 
        MOV   r12,r8                    ; save current x coordinate
        MOV   r13,r7                    ; save current y coordinate
        MOV   r6,r11                    ; use pen color
        CMP   r18,r16
        BRCS  swap_x
chk_y:  CMP   r19,r17
        BRCS  swap_y
rect:   MOV   r7,r17                    ; first y coordinate
rloop:  MOV   r8,r16                    ; first x coordinate
        MOV   r9,r18                    ; second x coordinate
        CALL  draw_horizontal_line
        ADD   r7,1                      ; increment row count
        CMP   r19,r7                    ; see if more rows to draw
        BRCC  rloop                     ; branch to draw more rows
        MOV   r8,r12                    ; restore x coordinate
        MOV   r7,r13                    ; restore y coordinate
        RET
        
swap_x: MOV   r20,r16
        MOV   r16,r18
        MOV   r18,r20
        BRN   chk_y

swap_y: MOV   r20,r17
        MOV   r17,r19
        MOV   r19,r20
        BRN   rect
        
;---------------------------------------------------------------------
; Subroutine: Pen
; Uses the pen color to draw a dot a the current location
; Modifies R6 and uses R11 (pen color), R8 (X), and R7 (Y).
;---------------------------------------------------------------------
Pen:    MOV     R6, R11
        CALL    draw_dot
        RET
        
;---------------------------------------------------------------------
; Subroutine: Erase
; Resets the current pixel to its previous color if in cursor mode
; or the background color in eraser mode. Does nothing in draw mode.
; Modifies R6 and uses R15 (color), R8 (X), and R7 (Y).
;---------------------------------------------------------------------
Erase:  CMP     R0, 0
        BRNE    Not0
        MOV     R6, R15
        CALL    draw_dot
Not0:   CMP     R0, 1
        BRNE    Not1
        MOV     R6, R14
        CALL    draw_dot
Not1:   RET

;---------------------------------------------------------------------
; Interrupt service routine
;---------------------------------------------------------------------
My_ISR:     IN      R1, PS2_KEY_CODE

            CMP     R1, 90      ;ENTER
            BREQ    SetDraw
            
            CMP     R1, 102     ;DELETE
            BREQ    SetDel
            
            CMP     R1, 41      ;SPACE
            BREQ    SetCursor
            
            CMP     R1, 50      ;B
            BREQ    Background

            CMP     R1, 29      ;W
            BREQ    Up
            CMP     R1, 28      ;A
            BREQ    Left
            CMP     R1, 27      ;S
            BREQ    Down
            CMP     R1, 35      ;D
            BREQ    Right
            
            CMP     R1, 117     ;Up
            BREQ    Up
            CMP     R1, 107     ;Left
            BREQ    Left
            CMP     R1, 114     ;Down
            BREQ    Down
            CMP     R1, 116     ;Right
            BREQ    Right
            
            CMP     R1, 59      ;J
            BREQ    SetPt1
            CMP     R1, 66      ;K
            BREQ    SetPt2
            CMP     R1, 75      ;L
            BREQ    Rectangle
            
            CMP     R1, 22      ;1
            BREQ    SetRed
            CMP     R1, 30      ;2
            BREQ    SetOrange
            CMP     R1, 38      ;3
            BREQ    SetYellow
            CMP     R1, 37      ;4
            BREQ    SetGreen
            CMP     R1, 46      ;5
            BREQ    SetBlue
            CMP     R1, 54      ;6
            BREQ    SetIndigo
            CMP     R1, 61      ;7
            BREQ    SetViolet
            CMP     R1, 62      ;8
            BREQ    SetBlack
            CMP     R1, 70      ;9
            BREQ    SetWhite
            CMP     R1, 69      ;0
            BREQ    SetGray
            
            BRN     Finish
            
SetDraw:    MOV     R0, 0x02
            OUT     R0, LEDS
            BRN     Finish
            
SetDel:     MOV     R0, 0x01
            OUT     R0, LEDS
            BRN     Finish

SetCursor:  MOV     R0, 0x00
            OUT     R0, LEDS
            BRN     Finish
            
Background: MOV     R14, R11
            MOV     R15, R11
            CALL    draw_background
            BRN     Finish
            
Up:         CALL    Erase
            SUB     R7, 1
            CALL    read_color
            CALL    Pen
            BRN     Finish

Down:       CALL    Erase
            ADD     R7, 1
            CALL    read_color
            CALL    Pen
            BRN     Finish

Left:       CALL    Erase
            SUB     R8, 1
            CALL    read_color
            CALL    Pen
            BRN     Finish

Right:      CALL    Erase
            ADD     R8, 1
            CALL    read_color
            CALL    Pen
            BRN     Finish
            
SetRed:     MOV     R11, 0xE0
            CALL    Pen
            BRN     Finish

SetOrange:  MOV     R11, 0xF0
            CALL    Pen
            BRN     Finish

SetYellow:  MOV     R11, 0xFC
            CALL    Pen
            BRN     Finish

SetGreen:   MOV     R11, 0x1C
            CALL    Pen
            BRN     Finish

SetBlue:    MOV     R11, 0x03
            CALL    Pen
            BRN     Finish

SetIndigo:  MOV     R11, 0xE2
            CALL    Pen
            BRN     Finish

SetViolet:  MOV     R11, 0xC3
            CALL    Pen
            BRN     Finish
            
SetBlack:   MOV     R11, 0x00
            CALL    Pen
            BRN     Finish
            
SetWhite:   MOV     R11, 0xFF
            CALL    Pen
            BRN     Finish
            
SetGray:    MOV     R11, 0x92
            CALL    Pen
            BRN     Finish
            
SetPt1:     MOV     R16, R8
            MOV     R17, R7
            BRN     Finish

SetPt2:     MOV     R18, R8
            MOV     R19, R7
            BRN     Finish
            
Rectangle:  CALL    draw_rect
            BRN     Finish
            
Finish:     OUT     R8, SSEG1
            OUT     R7, SSEG2
            RETIE

;---------------------------------------------------------------------
; Interrupt vector
;---------------------------------------------------------------------
.CSEG
.ORG 0x3FF
BRN My_ISR
