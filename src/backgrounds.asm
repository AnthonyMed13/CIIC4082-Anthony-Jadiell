.INClude "conSTAnts.INC"
.INClude "header.INC"


.segment "ZEROPAGE"
	zptemp: .res 2
	player1_x: .res 1
  player1_cs: .res 1
	player1_y: .res 1
	player1_dir: .res 1
	player1_ws: .res 1
	player1_ult : .res 1
	player1_urt : .res 1
	player1_llt : .res 1
	player1_lrt : .res 1
	frame_counter1 : .res 1
  pad1: .res 1
	.exportzp player1_x, player1_y, player1_dir, player1_ws, player1_cs, player1_ult, player1_urt, player1_llt, player1_lrt
	.exportzp frame_counter1, pad1
.segment "CODE"

.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

; read controller
  JSR read_controller1

  JSR update_player1
  JSR draw_players
	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  ; write sprite data
;   LDX #$00
; load_sprites:
;   LDA sprites,X
;   STA $0200,X
;   INX
;   CPX #$ff			
;   BNE load_sprites

; write background data
LDA PPUSTATUS
LDA #$20
STA PPUADDR
LDA #$00
STA PPUADDR

; low byte of bg address
LDA #<bg
STA zptemp            
LDA #>bg
; high byte of bg address
STA zptemp+1
; initialize X and Y to 0
LDY #0
LDX #0

@loop:
    LDA (zptemp), y
    STA PPUDATA
    INY
    BNE @loop_skip_INX ; skip the next instruction if we dont want to increment high byte
    INX
    INC zptemp+1 ; increment high byte of pointer
@loop_skip_INX:
    CPX #>1024 ; comparing high byte       
    BNE @loop  ; continue loop if high byte of X is not beyond 1024
    CPY #<1024 ; comparing low byte
    BNE @loop  ; continue loop if low byte of Y is less than 1024


vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever

;Background data
bg:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$70,$00,$00,$00,$a2,$00,$a4,$a5,$a6,$a7
	.byte $a8,$a9,$aa,$ab,$ac,$7a,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04
	.byte $05,$06,$07,$08,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$11,$12,$00,$00
	.byte $00,$16,$17,$18,$19,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$14,$00,$00
	.byte $00,$00,$ba,$bb,$bc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$20,$21
	.byte $22,$23,$24,$08,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$11,$12,$30,$31
	.byte $32,$33,$34,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$14,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$5f,$5f,$5f,$df,$ff,$ff
	.byte $ff,$ff,$f7,$55,$50,$df,$ff,$ff,$ff,$ff,$f7,$f4,$f5,$fd,$ff,$ff
	.byte $ff,$ff,$ff,$fc,$ff,$ff,$ff,$ff,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f

.endproc

.proc draw_players
;Save values on stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;Tiles of player1
  LDA player1_ult
  STA $0201
  LDA player1_urt
  STA $0205
  LDA player1_llt
  STA $0209
  LDA player1_lrt
  STA $020d

 
  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  STA $0222
  STA $0226
  STA $022a
  STA $022e
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  ; top left tile:
  LDA player1_y
  STA $0200
  LDA player1_x
  STA $0203

  ; top right tile (x + 8):
  LDA player1_y
  STA $0204
  LDA player1_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player1_y
  CLC
  ADC #$08
  STA $0208
  LDA player1_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player1_y
  CLC
  ADC #$08
  STA $020c
  LDA player1_x
  CLC
  ADC #$08
  STA $020f


  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player1
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA frame_counter1
  CMP #$0f
  BNE skip
    Jmp continue
  skip:
    JMP increase_counter
  continue:

  LDA #$00
  STA frame_counter1

  LDA pad1          ; Load button presses into A
  EOR #$FF          ; XOR with $FF to invert the bits.
  BEQ no_buttons
  JMP player1_moving

  no_buttons:
    JMP exit_subroutine
  ; if player1_ws = 01, player1 is moving
  ;since we are making him move, it will always branch to player1_moving
  ;here goes else statement later

player1_moving:
  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  DEC player1_x  ; If the branch is not taken, move player left
  JMP player1_moveleft
  check_right:
    LDA pad1
    AND #BTN_RIGHT
    BEQ check_up
    INC player1_x
    JMP player1_moveright
  check_up:
    LDA pad1
    AND #BTN_UP
    BEQ check_down
    DEC player1_y
    JMP player1_moveup
  check_down:
    LDA pad1
    AND #BTN_DOWN
    BEQ next
    INC player1_y
    JMP player1_movedown
    next:
      JMP exit_subroutine
  ; if player1_dir = 00, player is moving down

player1_moveleft:
  ; now, actually update player1 sprites
  LDA player1_cs
  CMP #$00
  BEQ player1_lefttostage1
  CMP #$01
  BEQ player1_lefttostage2
  CMP #$02
  BEQ player1_lefttostage3

  LDA #$21
  STA player1_ult
  LDA #$22
  STA player1_urt
  LDA #$31
  STA player1_llt
  LDA #$32
  STA player1_lrt
  LDA #$00
  STA player1_cs
  JMP exit_subroutine

player1_lefttostage1:
  LDA #$23
  STA player1_ult
  LDA #$24
  STA player1_urt
  LDA #$33
  STA player1_llt
  LDA #$34
  STA player1_lrt
  LDA #$01
  STA player1_cs
  JMP exit_subroutine
player1_lefttostage2:
  LDA #$21
  STA player1_ult
  LDA #$22
  STA player1_urt
  LDA #$31
  STA player1_llt
  LDA #$32
  STA player1_lrt
  LDA #$02
  STA player1_cs
	JMP exit_subroutine
player1_lefttostage3:
  LDA #$25
  STA player1_ult
  LDA #$26
  STA player1_urt
  LDA #$35
  STA player1_llt
  LDA #$36
  STA player1_lrt
  LDA #$03
  STA player1_cs
  JMP exit_subroutine

player1_moveright:
  ; now, actually update player1 sprites
  LDA player1_cs
  CMP #$00
  BEQ player1_righttostage1
  CMP #$01
  BEQ player1_righttostage2
  CMP #$02
  BEQ player1_righttostage3

  LDA #$27
  STA player1_ult
  LDA #$28
  STA player1_urt
  LDA #$37
  STA player1_llt
  LDA #$38
  STA player1_lrt
  LDA #$00
  STA player1_cs
  JMP exit_subroutine
player1_righttostage1:
  LDA #$29
  STA player1_ult
  LDA #$2A
  STA player1_urt
  LDA #$39
  STA player1_llt
  LDA #$3A
  STA player1_lrt
  LDA #$01
  STA player1_cs
  JMP exit_subroutine
player1_righttostage2:
  LDA #$27
  STA player1_ult
  LDA #$28
  STA player1_urt
  LDA #$37
  STA player1_llt
  LDA #$38
  STA player1_lrt
  LDA #$02
  STA player1_cs
	JMP exit_subroutine
player1_righttostage3:
  LDA #$2B
  STA player1_ult
  LDA #$2C
  STA player1_urt
  LDA #$3B
  STA player1_llt
  LDA #$3C
  STA player1_lrt
  LDA #$03
  STA player1_cs
  JMP exit_subroutine

player1_moveup:
  ; now, actually update player1 sprites
  LDA player1_cs
  CMP #$00
  BEQ player1_uptostage1
  CMP #$01
  BEQ player1_uptostage2
  CMP #$02
  BEQ player1_uptostage3

  LDA #$07
  STA player1_ult
  LDA #$08
  STA player1_urt
  LDA #$17
  STA player1_llt
  LDA #$18
  STA player1_lrt
  LDA #$00
  STA player1_cs
  JMP exit_subroutine
player1_uptostage1:
  LDA #$09
  STA player1_ult
  LDA #$0A
  STA player1_urt
  LDA #$19
  STA player1_llt
  LDA #$1A
  STA player1_lrt
  LDA #$01
  STA player1_cs
  JMP exit_subroutine
player1_uptostage2:
  LDA #$07
  STA player1_ult
  LDA #$08
  STA player1_urt
  LDA #$17
  STA player1_llt
  LDA #$18
  STA player1_lrt
  LDA #$02
  STA player1_cs
	JMP exit_subroutine
player1_uptostage3:
  LDA #$0B
  STA player1_ult
  LDA #$0C
  STA player1_urt
  LDA #$1B
  STA player1_llt
  LDA #$1C
  STA player1_lrt
  LDA #$03
  STA player1_cs
  JMP exit_subroutine

player1_movedown:
  ; now, actually update player1 sprites
  LDA player1_cs
  CMP #$00
  BEQ player1_downtostage1
  CMP #$01
  BEQ player1_downtostage2
  CMP #$02
  BEQ player1_downtostage3

  LDA #$01
  STA player1_ult
  LDA #$02
  STA player1_urt
  LDA #$11
  STA player1_llt
  LDA #$12
  STA player1_lrt
  LDA #$00
  STA player1_cs
  JMP exit_subroutine
player1_downtostage1:
  LDA #$03
  STA player1_ult
  LDA #$04
  STA player1_urt
  LDA #$13
  STA player1_llt
  LDA #$14
  STA player1_lrt
  LDA #$01
  STA player1_cs
  JMP exit_subroutine
player1_downtostage2:
  LDA #$01
  STA player1_ult
  LDA #$02
  STA player1_urt
  LDA #$11
  STA player1_llt
  LDA #$12
  STA player1_lrt
  LDA #$02
  STA player1_cs
	JMP exit_subroutine
player1_downtostage3:
  LDA #$05
  STA player1_ult
  LDA #$06
  STA player1_urt
  LDA #$15
  STA player1_llt
  LDA #$16
  STA player1_lrt
  LDA #$03
  STA player1_cs
  JMP exit_subroutine

increase_counter:
  INC frame_counter1
exit_subroutine:
  ; all done, clean up and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
;Background color
.byte $0f, $00, $10, $30
.byte $0f, $37, $17, $07
.byte $0f, $0A, $06, $05
.byte $0f, $09, $19, $07
;Character color
.byte $0f, $2d, $10, $15
.byte $0f, $30, $26, $17
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29


; sprites:
; ;Looking straight
; ;First
; 	.byte $40, $01, $01, $60
; 	.byte $40, $02, $01, $68
; 	.byte $48, $11, $01, $60
; 	.byte $48, $12, $01, $68
; 	;Second
; 	.byte $40, $03, $01, $70
; 	.byte $40, $04, $01, $78
; 	.byte $48, $13, $01, $70
; 	.byte $48, $14, $01, $78
; 	;Third
; 	.byte $40, $05, $01, $80
; 	.byte $40, $06, $01, $88
; 	.byte $48, $15, $01, $80
; 	.byte $48, $16, $01, $88

; 	;Looking left
; 	;First
; 	.byte $50, $21, $01, $60
; 	.byte $50, $22, $01, $68
; 	.byte $58, $31, $01, $60
; 	.byte $58, $32, $01, $68
; 	;Second
; 	.byte $50, $23, $01, $70
; 	.byte $50, $24, $01, $78
; 	.byte $58, $33, $01, $70
; 	.byte $58, $34, $01, $78
; 	;Third
; 	.byte $50, $25, $01, $80
; 	.byte $50, $26, $01, $88
; 	.byte $58, $35, $01, $80
; 	.byte $58, $36, $01, $88

; 	;Looking right
; 	;First
; 	.byte $60, $27, $01, $60
; 	.byte $60, $28, $01, $68
; 	.byte $68, $37, $01, $60
; 	.byte $68, $38, $01, $68
; 	;Second
; 	.byte $60, $29, $01, $70
; 	.byte $60, $2A, $01, $78
; 	.byte $68, $39, $01, $70
; 	.byte $68, $3A, $01, $78
; 	;Third
; 	.byte $60, $2B, $01, $80
; 	.byte $60, $2C, $01, $88
; 	.byte $68, $3B, $01, $80
; 	.byte $68, $3C, $01, $88

; 	;Looking backwards
; 	;First
; 	.byte $70, $07, $01, $60
; 	.byte $70, $08, $01, $68
; 	.byte $78, $17, $01, $60
; 	.byte $78, $18, $01, $68
; 	;Second
; 	.byte $70, $09, $01, $70
; 	.byte $70, $0A, $01, $78
; 	.byte $78, $19, $01, $70
; 	.byte $78, $1A, $01, $78
; 	;Third
; 	.byte $70, $0B, $01, $80
; 	.byte $70, $0C, $01, $88
; 	.byte $78, $1B, $01, $80
; 	.byte $78, $1C, $01, $88

.segment "CHR"
.INCbin "GameSpritesandBackgrounds.chr"
