.INClude "conSTAnts.INC"
.INClude "header.INC"


.segment "ZEROPAGE"
	zptemp: .res 2
	player1_x: .res 1
	player1_y: .res 1
	player2_x: .res 1
	player2_y: .res 1
	player3_x: .res 1
	player3_y: .res 1
	player4_x: .res 1
	player4_y: .res 1
	player1_dir: .res 1
	player2_dir: .res 1
	player3_dir: .res 1
	player4_dir: .res 1
	player1_ws: .res 1
	player2_ws: .res 1
	player3_ws: .res 1
	player4_ws: .res 1
	player1_cs: .res 1
	player2_cs: .res 1
	player3_cs: .res 1
	player4_cs: .res 1
	player1_ult : .res 1
	player1_urt : .res 1
	player1_llt : .res 1
	player1_lrt : .res 1
	player2_ult : .res 1
	player2_urt : .res 1
	player2_llt : .res 1
	player2_lrt : .res 1
	player3_ult : .res 1
	player3_urt : .res 1
	player3_llt : .res 1
	player3_lrt : .res 1
	player4_ult : .res 1
	player4_urt : .res 1
	player4_llt : .res 1
	player4_lrt : .res 1
	frame_counter1 : .res 1
	frame_counter2 : .res 1
	frame_counter3 : .res 1
	frame_counter4 : .res 1
	.exportzp player1_x, player1_y, player2_x, player2_y, player3_x, player3_y, player4_x, player4_y, player1_dir, player2_dir, player3_dir, player4_dir, player1_ws, player2_ws, player3_ws, player4_ws, player1_cs, player2_cs, player3_cs, player4_cs, player1_ult, player1_urt, player1_llt, player1_lrt,player2_ult, player2_urt, player2_llt, player2_lrt, player3_ult, player3_urt, player3_llt, player3_lrt
	.exportzp player4_ult, player4_urt, player4_llt, player4_lrt, frame_counter1, frame_counter2, frame_counter3, frame_counter4
.segment "CODE"

.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  JSR update_player1
  JSR update_player2
  JSR update_player3
  JSR update_player4
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

  ;Tiles of player2
  LDA player2_ult
  STA $0211
  LDA player2_urt
  STA $0215
  LDA player2_llt
  STA $0219
  LDA player2_lrt
  STA $021d

  ;Tiles of player3
  LDA player3_ult
  STA $0221
  LDA player3_urt
  STA $0225
  LDA player3_llt
  STA $0229
  LDA player3_lrt
  STA $022d

  ;Tiles of player4
  LDA player4_ult
  STA $0231
  LDA player4_urt
  STA $0235
  LDA player4_llt
  STA $0239
  LDA player4_lrt
  STA $023d

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

  ; top left tile:
  LDA player2_y
  STA $0210
  LDA player2_x
  STA $0213

  ; top right tile (x + 8):
  LDA player2_y
  STA $0214
  LDA player2_x
  CLC
  ADC #$08
  STA $0217

  ; bottom left tile (y + 8):
  LDA player2_y
  CLC
  ADC #$08
  STA $0218
  LDA player2_x
  STA $021b

  ; bottom right tile (x + 8, y + 8)
  LDA player2_y
  CLC
  ADC #$08
  STA $021c
  LDA player2_x
  CLC
  ADC #$08
  STA $021f

  ; top left tile:
  LDA player3_y
  STA $0220
  LDA player3_x
  STA $0223

  ; top right tile (x + 8):
  LDA player3_y
  STA $0224
  LDA player3_x
  CLC
  ADC #$08
  STA $0227

  ; bottom left tile (y + 8):
  LDA player3_y
  CLC
  ADC #$08
  STA $0228
  LDA player3_x
  STA $022b

  ; bottom right tile (x + 8, y + 8)
  LDA player3_y
  CLC
  ADC #$08
  STA $022c
  LDA player3_x
  CLC
  ADC #$08
  STA $022f

  ; top left tile:
  LDA player4_y
  STA $0230
  LDA player4_x
  STA $0233

  ; top right tile (x + 8):
  LDA player4_y
  STA $0234
  LDA player4_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA player4_y
  CLC
  ADC #$08
  STA $0238
  LDA player4_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA player4_y
  CLC
  ADC #$08
  STA $023c
  LDA player4_x
  CLC
  ADC #$08
  STA $023f

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
  BNE increase_counter

  LDA #$00
  STA frame_counter1
  LDA player1_ws
  CMP #$01
  BEQ player1_moving
  ; if player1_ws = 01, player1 is moving
  ;since we are making him move, it will always branch to player1_moving
  ;here goes else statement later

player1_moving:
  LDA player1_dir
  CMP #$00
  BEQ player1_movedown
  ; if player1_dir = 00, player is moving down

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

.proc update_player2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA frame_counter2
  CMP #$0f
  BNE increase_counter

  LDA #$00
  STA frame_counter2
  LDA player2_ws
  CMP #$01
  BEQ player2_moving
  ; if player2_ws = 01, player2 is moving
  ;since we are making him move, it will always branch to player2_moving
  ;here goes else statement later

player2_moving:
  LDA player2_dir
  CMP #$01
  BEQ player2_moveleft
  ; if player2_dir = 01, player is moving left

player2_moveleft:
  ; now, actually update player2 sprites
  LDA player2_cs
  CMP #$00
  BEQ player2_lefttostage1
  CMP #$01
  BEQ player2_lefttostage2
  CMP #$02
  BEQ player2_lefttostage3

  LDA #$21
  STA player2_ult
  LDA #$22
  STA player2_urt
  LDA #$31
  STA player2_llt
  LDA #$32
  STA player2_lrt
  LDA #$00
  STA player2_cs
  JMP exit_subroutine
player2_lefttostage1:
  LDA #$23
  STA player2_ult
  LDA #$24
  STA player2_urt
  LDA #$33
  STA player2_llt
  LDA #$34
  STA player2_lrt
  LDA #$01
  STA player2_cs
  JMP exit_subroutine
player2_lefttostage2:
  LDA #$21
  STA player2_ult
  LDA #$22
  STA player2_urt
  LDA #$31
  STA player2_llt
  LDA #$32
  STA player2_lrt
  LDA #$02
  STA player2_cs
	JMP exit_subroutine
player2_lefttostage3:
  LDA #$25
  STA player2_ult
  LDA #$26
  STA player2_urt
  LDA #$35
  STA player2_llt
  LDA #$36
  STA player2_lrt
  LDA #$03
  STA player2_cs
  JMP exit_subroutine

increase_counter:
  INC frame_counter2
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

.proc update_player3
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA frame_counter3
  CMP #$0f
  BNE increase_counter

  LDA #$00
  STA frame_counter3
  LDA player3_ws
  CMP #$01
  BEQ player3_moving
  ; if player3_ws = 01, player3 is moving
  ;since we are making him move, it will always branch to player1_moving
  ;here goes else statement later

player3_moving:
  LDA player3_dir
  CMP #$03
  BEQ player1_moveright
  ; if player3_dir = 03, player is moving right

player1_moveright:
  ; now, actually update player3 sprites
  LDA player3_cs
  CMP #$00
  BEQ player3_righttostage1
  CMP #$01
  BEQ player3_righttostage2
  CMP #$02
  BEQ player3_righttostage3

  LDA #$27
  STA player3_ult
  LDA #$28
  STA player3_urt
  LDA #$37
  STA player3_llt
  LDA #$38
  STA player3_lrt
  LDA #$00
  STA player3_cs
  JMP exit_subroutine
player3_righttostage1:
  LDA #$29
  STA player3_ult
  LDA #$2A
  STA player3_urt
  LDA #$39
  STA player3_llt
  LDA #$3A
  STA player3_lrt
  LDA #$01
  STA player3_cs
  JMP exit_subroutine
player3_righttostage2:
  LDA #$27
  STA player3_ult
  LDA #$28
  STA player3_urt
  LDA #$37
  STA player3_llt
  LDA #$38
  STA player3_lrt
  LDA #$02
  STA player3_cs
	JMP exit_subroutine
player3_righttostage3:
  LDA #$2B
  STA player3_ult
  LDA #$2C
  STA player3_urt
  LDA #$3B
  STA player3_llt
  LDA #$3C
  STA player3_lrt
  LDA #$03
  STA player3_cs
  JMP exit_subroutine

increase_counter:
  INC frame_counter3
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

.proc update_player4
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA frame_counter4
  CMP #$0f
  BNE increase_counter

  LDA #$00
  STA frame_counter4
  LDA player4_ws
  CMP #$01
  BEQ player4_moving
  ; if player4_ws = 01, player4 is moving
  ;since we are making him move, it will always branch to player1_moving
  ;here goes else statement later

player4_moving:
  LDA player4_dir
  CMP #$02
  BEQ player4_moveup
  ; if player4_dir = 02, player is moving up

player4_moveup:
  ; now, actually update player4 sprites
  LDA player4_cs
  CMP #$00
  BEQ player4_uptostage1
  CMP #$01
  BEQ player4_uptostage2
  CMP #$02
  BEQ player4_uptostage3

  LDA #$07
  STA player4_ult
  LDA #$08
  STA player4_urt
  LDA #$17
  STA player4_llt
  LDA #$18
  STA player4_lrt
  LDA #$00
  STA player4_cs
  JMP exit_subroutine
player4_uptostage1:
  LDA #$09
  STA player4_ult
  LDA #$0A
  STA player4_urt
  LDA #$19
  STA player4_llt
  LDA #$1A
  STA player4_lrt
  LDA #$01
  STA player4_cs
  JMP exit_subroutine
player4_uptostage2:
  LDA #$07
  STA player4_ult
  LDA #$08
  STA player4_urt
  LDA #$17
  STA player4_llt
  LDA #$18
  STA player4_lrt
  LDA #$02
  STA player4_cs
	JMP exit_subroutine
player4_uptostage3:
  LDA #$0B
  STA player4_ult
  LDA #$0C
  STA player4_urt
  LDA #$1B
  STA player4_llt
  LDA #$1C
  STA player4_lrt
  LDA #$03
  STA player4_cs
  JMP exit_subroutine

increase_counter:
  INC frame_counter4
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
