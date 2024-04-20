.INClude "conSTAnts.INC"
.INClude "header.INC"


.segment "ZEROPAGE"
  slowness: .res 1
  TempX: .res 1
  TempY: .res 1
  counter: .res 1
  TempTileX: .res 1
  TempTileY: .res 1
  collision: .res 1
  zptemp: .res 1
  zpIndexX: .res 1
  zptemp2: .res 1
  zptemp3: .res 2
  zptemp4: .res 1
  zptemp5: .res 1
  world_selector: .res 1
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
  frame_counter2 : .res 1
  scroll: .res 1
  ppuctrl_settings: .res 1
  pad1: .res 1
  nametable: .res 1
	.exportzp player1_x, player1_y, player1_dir, player1_ws, player1_cs, player1_ult, player1_urt, player1_llt, player1_lrt
	.exportzp frame_counter1, pad1, world_selector, zptemp, zptemp2,zptemp3, scroll
  .export tile_map, tile_map1, tile_map2, tile_map3, attribute, attribute1, attribute2, attribute3
.segment "CODE"

.proc irq_handler
  RTI
.endproc

.import read_controller1
.import draw_background
.import draw_background2
.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

; read controller
  LDA world_selector
  CMP #$01
  BNE ness
  continues:
    lda #$00
    sta $2000
    sta $2001
    JSR draw_background2
    LDA #%10010000  ; turn on NMIs, sprites use first pattern table
      STA ppuctrl_settings
      STA PPUCTRL
      LDA #%00011110  ; turn on screen
      STA PPUMASK
      LDA #$00
      STA scroll
      STA PPUSCROLL
      STA PPUSCROLL
      STA nametable
      LDA #$00
      STA player1_x
      STA collision
      STA counter
      LDA #$20
      STA player1_y
      INC world_selector
  ness:

LDA player1_x
JSR read_controller1
JSR update_player1
JSR draw_players


ski:
  RTI

.endproc





.import reset_handler

.export main
.proc main
  LDA #$00
  STA scroll
  STA counter
  LDA player1_x

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

JSR draw_background

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

forever:
  JMP forever


.endproc

.proc checkCollision
  LDA #$00
  STA collision
 
  LDA TempX
  LSR           ; A = A / 2
  LSR           ; Divide X by 16 (shift right 4 times)
  LSR
  LSR
  STA TempTileX    ; Store tile X coordinate
  
  LDA TempY      ; Load the player's Y coordinate
  LSR         ; A = A / 2
  LSR         ; Divide Y by 16 (shift right 4 times)
  LSR
  LSR
  STA TempTileY    ; Store tile Y coordinate

  ; Calculate the map index assuming row-major order
  LDA TempTileY
  ASL        ; Multiply Y by MapWidth (assuming MapWidth = 16, shift left 4 times)
  ASL
  ASL
  ASL
  TAX   
  STX zptemp5          ; Transfer to X
  LDA TempTileX
  CLC
  ADC zptemp5        ; Add X to get the map index
  TAY              ; Transfer to Y

  LDA world_selector
  CMP #$02
  BEQ other_world

  LDA nametable
  CMP #$01
  BEQ other

  LDA tile_map,Y    ; Load the map data at the calculated index
  CMP #$03          ; Assume wall tiles are flagged by the least significant bit
  BEQ Collision  ; Branch if no collision (bit is 0)
  CMP #$16
  BNE NoCollision
  JMP noslow

  other:
  LDA tile_map1,Y    ; Load the map data at the calculated index
  CMP #$03          ; Assume wall tiles are flagged by the least significant bit
  BEQ Collision  ; Branch if no collision (bit is 0)
  CMP #$16
  BNE NoCollision
  JMP noslow

Collision:

  LDA #$01
  STA collision
  RTS
  ; Code to handle collision here

NoCollision:
  CMP #$14
  BNE noslow
  LDA #$02
  STA slowness

  noslow:
  LDA #$00
  STA collision
  RTS
other_world:

  LDA nametable
  CMP #$01
  BEQ other1

  LDA tile_map2,Y    ; Load the map data at the calculated index
  CMP #$20         ; Assume wall tiles are flagged by the least significant bit
  BEQ Collision1  ; Branch if no collision (bit is 0)
  CMP #$21
  BNE NoCollision1
  JMP noslow1

  other1:
  LDA tile_map3,Y    ; Load the map data at the calculated index
  CMP #$20        ; Assume wall tiles are flagged by the least significant bit
  BEQ Collision1  ; Branch if no collision (bit is 0)
  CMP #$21
  BNE NoCollision1
  JMP noslow1

Collision1:

  LDA #$01
  STA collision
  RTS
  ; Code to handle collision here

NoCollision1:
  CMP #$14
  BNE noslow1
  LDA #$02
  STA slowness

  noslow1:
  LDA #$00
  STA collision
  RTS
  ; Code to continue game logic here


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
  LDA #$21
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
  SEC 
  SBC scroll
  STA $0203
  
  ; bottom left tile (y + 8):
  LDA player1_y
  CLC
  ADC #$08
  STA $0208
  LDA player1_x
  SEC 
  SBC scroll
  STA $020b

  
  ; top right tile (x + 8):
  LDA player1_y
  STA $0204
  LDA player1_x
  CLC
  ADC #$08
  SEC 
  SBC scroll
  STA $0207




  ; bottom right tile (x + 8, y + 8)
  LDA player1_y
  CLC
  ADC #$08
  STA $020c

  LDA player1_x
  CLC
  ADC #$08
  SEC 
  SBC scroll
  STA $020f

  no_draw:
  
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
  
player1_moving:

    

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed

  LDA player1_x
  CLC
  SBC #$01      ; Load the player's X coordinate
  STA TempX
  BCC change_nametable1
  JMP dont_change1
  change_nametable1:
  LDA #$00
  STA nametable
  dont_change1:         ; Store in TempX

  LDA player1_y      ; Load the player's X coordinate    
  STA TempY 

  JSR checkCollision
  LDA collision
  CMP #$01
  BEQ nomove2

  LDA player1_x  
  CLC
  SBC #$01    ; Load the player's X coordinate
  STA TempX        ; Store in TempX

  LDA player1_y
  CLC              ; Clear the carry for the addition
  ADC #$0E       ; Load the player's X coordinate    
  STA TempY

  JSR checkCollision
  LDA collision
  CMP #$01
  BEQ nomove2

  noslow:
  LDA scroll
  CMP #$FF
  BEQ no_scroll
  DEC scroll
  DEC scroll
  DEC scroll
  DEC scroll
  DEC scroll
  LDA scroll
  STA PPUSCROLL
  LDA #$00
  STA PPUSCROLL
  no_scroll:
  DEC player1_x  ; If the branch is not taken, move player left
  DEC player1_x
  DEC player1_x
  DEC player1_x
  DEC player1_x  ; If the branch is not taken, move player left
  DEC player1_x
  DEC player1_x
  DEC player1_x
  LDA player1_x
  CMP #248
  BNE nomove2


  nomove2:
  JMP player1_moveleft
  check_right:
    LDA pad1
    AND #BTN_RIGHT
    BEQ check_up


    LDA player1_x      ; Load the player's X coordinate
    CLC              ; Clear the carry for the addition
    ADC #$10       ; Add 15 to get the right edge of the player
    STA TempX
    BCS change_nametable
    JMP dont_change
    change_nametable:
    LDA #$01
    STA nametable
    dont_change:        ; Store in TempX

    LDA player1_y      ; Load the player's X coordinate    
    STA TempY       ; Store in TempX

    JSR checkCollision
    LDA collision
    CMP #$01
    BEQ nomove

    LDA player1_x      ; Load the player's X coordinate
    CLC              ; Clear the carry for the addition
    ADC #$10      ; Add 15 to get the right edge of the player
    STA TempX        ; Store in TempX
  
    LDA player1_y
    CLC
    ADC #$0D
    STA TempY
    
    JSR checkCollision
    LDA collision
    CMP #$01
    BEQ nomove
    noslow2:
    LDA scroll
    CMP #$FF
    BEQ no_scroll1
    INC scroll
    INC scroll
    INC scroll
    INC scroll
    INC scroll
    LDA scroll
    STA PPUSCROLL
    LDA #$00
    STA PPUSCROLL
    no_scroll1:
    INC player1_x
    INC player1_x
    INC player1_x
    INC player1_x
    INC player1_x
    INC player1_x
    INC player1_x
    INC player1_x
    
    nomove:
    JMP player1_moveright
  check_up:
    LDA pad1
    AND #BTN_UP
    BEQ check_down

    LDA player1_x      ; Load the player's X coordinate      ; Add 15 to get the right edge of the player
    STA TempX        ; Store in TempX
  
    LDA player1_y
    CLC
    SBC #$02
    STA TempY

    JSR checkCollision
    LDA collision
    CMP #$01
    BEQ nomove3

    LDA player1_x
    CLC
    ADC #$0E      ; Load the player's X coordinate      ; Add 15 to get the right edge of the player
    STA TempX        ; Store in TempX
  
    LDA player1_y
    CLC
    SBC #$02
    STA TempY

    JSR checkCollision
    LDA collision
    CMP #$01
    BEQ nomove3

    LDA slowness
    CMP #$02
    BNE noslow3
    DEC player1_y  ; If the branch is not taken, move player left
    DEC player1_y
    DEC player1_y  ; If the branch is not taken, move player left
    DEC player1_y
    DEC player1_y  ; If the branch is not taken, move player left
    DEC player1_y
    DEC player1_y  ; If the branch is not taken, move player left
    DEC player1_y
    LDA#$00
    STA slowness
    JMP nomove3
    noslow3:

    DEC player1_y
    DEC player1_y
    DEC player1_y
    DEC player1_y
    DEC player1_y  ; If the branch is not taken, move player left
    DEC player1_y
    DEC player1_y  ; If the branch is not taken, move player left
    DEC player1_y

    nomove3:

    JMP player1_moveup
  check_down:
    LDA pad1
    AND #BTN_DOWN
    BEQ check_A

    LDA player1_x      ; Load the player's X coordinate      ; Add 15 to get the right edge of the player
    STA TempX        ; Store in TempX
  
    LDA player1_y
    ADC #$10
    STA TempY

    JSR checkCollision
    LDA collision
    CMP #$01
    BEQ nomove4

    LDA player1_x
    CLC
    ADC #$0E      ; Load the player's X coordinate      ; Add 15 to get the right edge of the player
    STA TempX        ; Store in TempX
  
    LDA player1_y
    ADC #$10
    STA TempY

    JSR checkCollision
    LDA collision
    CMP #$01
    BEQ nomove4

    LDA slowness
    CMP #$02
    BNE noslow4
    INC player1_y  ; If the branch is not taken, move player left
    INC player1_y
    INC player1_y  ; If the branch is not taken, move player left
    INC player1_y
    INC player1_y  ; If the branch is not taken, move player left
    INC player1_y
    INC player1_y  ; If the branch is not taken, move player left
    INC player1_y
    LDA#$00
    STA slowness
    JMP nomove4
    noslow4:

    INC player1_y
    INC player1_y
    INC player1_y
    INC player1_y
    INC player1_y
    INC player1_y
    INC player1_y
    INC player1_y  
    nomove4:
    JMP player1_movedown
  check_A:
    LDA pad1
    AND #BTN_A
    BEQ next
    INC world_selector
    LDA world_selector
    CMP #$01
    BNE nobg
      JSR draw_background2
    nobg:
    JMP player1_movedown
    

      ; Add button A
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
.byte $0f, $00, $10, $30
.byte $0f, $05, $16, $17
.byte $0f, $37, $17, $07
.byte $0f, $0B, $1A, $06

;Character color
.byte $0f, $2d, $10, $15
.byte $0f, $30, $26, $17
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

;First World - First Nametable
tile_map:     
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $16,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$16
  .byte $03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
  .byte $03,$00,$03,$03,$00,$03,$03,$03,$03,$03,$03,$03,$03,$16,$00,$03
  .byte $03,$00,$03,$16,$00,$14,$00,$00,$00,$00,$00,$00,$00,$16,$00,$03
  .byte $03,$00,$03,$16,$00,$03,$03,$03,$03,$03,$03,$03,$00,$16,$00,$03
  .byte $03,$00,$03,$16,$00,$03,$00,$14,$00,$00,$00,$00,$00,$00,$00,$03
  .byte $03,$00,$03,$16,$00,$03,$03,$03,$03,$03,$03,$03,$03,$03,$00,$03
  .byte $03,$00,$03,$16,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$03
  .byte $03,$00,$03,$03,$03,$03,$03,$03,$03,$03,$16,$03,$03,$03,$00,$03
  .byte $03,$00,$03,$16,$00,$00,$14,$00,$00,$00,$14,$00,$00,$00,$00,$03
  .byte $03,$00,$03,$16,$00,$03,$03,$03,$03,$03,$16,$03,$03,$03,$03,$03
  .byte $03,$00,$03,$16,$00,$00,$00,$00,$00,$00,$00,$00,$00,$14,$00,$00
  .byte $16,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$16
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;First World - Second Nametable
tile_map1:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
  .byte $03,$00,$00,$00,$00,$03,$03,$03,$00,$16,$00,$03,$03,$00,$00,$00
  .byte $03,$00,$03,$03,$03,$03,$16,$16,$00,$14,$00,$03,$03,$03,$00,$03
  .byte $03,$00,$00,$03,$03,$03,$16,$00,$00,$16,$00,$03,$03,$14,$00,$03
  .byte $03,$00,$00,$03,$00,$00,$00,$00,$03,$16,$00,$03,$14,$00,$00,$03
  .byte $03,$00,$00,$03,$00,$00,$00,$16,$03,$16,$00,$03,$00,$00,$00,$03
  .byte $03,$00,$00,$03,$00,$03,$03,$03,$03,$16,$00,$03,$00,$03,$16,$03
  .byte $03,$00,$00,$03,$00,$03,$00,$00,$00,$16,$03,$03,$00,$00,$14,$03
  .byte $03,$00,$00,$03,$00,$03,$00,$00,$00,$16,$00,$03,$00,$03,$00,$03
  .byte $03,$00,$00,$00,$00,$03,$00,$00,$00,$14,$00,$03,$14,$00,$00,$03
  .byte $03,$00,$00,$03,$03,$03,$03,$00,$00,$16,$00,$03,$16,$03,$00,$03
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$16,$00,$00,$00,$00,$00,$03
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;First World - First Attribute Table
attribute:
	.byte $80,$a0,$a0,$a0,$a0,$a0,$a0,$20,$22,$a0,$a2,$a0,$a0,$a0,$2a,$aa
	.byte $22,$22,$82,$a0,$a0,$a0,$00,$8a,$22,$22,$88,$a0,$a0,$a0,$a0,$88
	.byte $22,$a2,$a0,$a0,$a8,$80,$a0,$88,$22,$22,$88,$a0,$a0,$88,$a0,$a8
	.byte $82,$a2,$a0,$a0,$a0,$a0,$a0,$22,$00,$00,$00,$00,$00,$00,$00,$00

;First World - Second Attribute Table
attribute1:
	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$22,$a0,$a8,$0a,$00,$88,$a2,$88
	.byte $22,$88,$0a,$00,$20,$88,$82,$88,$22,$88,$80,$a0,$22,$a8,$80,$88
	.byte $22,$88,$88,$08,$02,$aa,$80,$88,$22,$80,$a8,$20,$00,$88,$80,$88
	.byte $aa,$a0,$a0,$a0,$a0,$a0,$a0,$a8,$00,$00,$00,$00,$00,$00,$00,$00

tile_map2:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$20
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$22,$20,$00,$20
  .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$20
  .byte $20,$22,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$20
  .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20
  .byte $20,$00,$20,$00,$20,$21,$20,$00,$20,$22,$20,$20,$22,$20,$00,$20
  .byte $20,$00,$20,$00,$20,$00,$00,$00,$20,$00,$21,$21,$00,$20,$00,$20
  .byte $20,$00,$20,$00,$20,$00,$00,$00,$20,$00,$21,$21,$00,$20,$00,$20
  .byte $20,$00,$20,$00,$20,$00,$00,$00,$20,$20,$20,$20,$20,$20,$22,$20
  .byte $20,$00,$20,$21,$20,$22,$20,$20,$20,$00,$00,$00,$00,$21,$00,$20
  .byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$21,$00,$00
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tile_map3:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20
	.byte $20,$21,$00,$21,$22,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$20
	.byte $20,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$21,$22,$21,$20,$20
	.byte $20,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$00,$00,$00
	.byte $20,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$21,$22,$21,$20,$20
	.byte $20,$21,$00,$21,$00,$21,$22,$21,$00,$21,$00,$21,$00,$21,$00,$20
	.byte $20,$21,$22,$21,$00,$21,$22,$21,$00,$21,$00,$21,$00,$21,$00,$20
	.byte $20,$21,$22,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$21,$00,$20
	.byte $20,$21,$00,$21,$00,$21,$00,$21,$22,$21,$00,$21,$00,$21,$00,$20
	.byte $20,$21,$00,$21,$00,$21,$00,$21,$00,$21,$22,$21,$00,$21,$00,$20
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

attribute2:
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ef,$ff
	.byte $bf,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$bf,$bb,$bf,$ff,$ef,$ff
	.byte $ff,$ff,$ff,$ff,$ff,$aa,$ff,$ff,$ff,$bf,$bf,$ff,$ff,$ff,$bf,$fe
	.byte $ff,$ff,$ff,$ff,$ff,$ff,$fb,$ff,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
attribute3:
	.byte $ff,$f3,$f0,$f0,$f0,$f0,$f0,$f0,$bf,$af,$af,$ae,$bf,$af,$af,$fc
	.byte $bb,$ba,$bb,$ba,$bb,$ba,$ea,$ff,$bb,$bb,$bb,$ab,$ab,$bb,$aa,$ef
	.byte $bb,$aa,$ab,$aa,$aa,$bb,$bb,$ee,$bb,$bb,$ba,$bb,$aa,$ab,$bb,$ee
	.byte $ff,$ff,$fb,$fb,$fa,$ff,$fb,$ff,$0f,$0f,$00,$00,$00,$00,$00,$00

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