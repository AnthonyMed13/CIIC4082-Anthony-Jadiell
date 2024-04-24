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
  clock_frames: .res 1
  clock: .res 1
  clock_hundreds1: .res 1
  clock_hundreds2: .res 1
  clock_tens1: .res 1
  clock_tens2: .res 1
  clock_units1: .res 1
  clock_units2: .res 1
  clock_posx: .res 1
  clock_posy: .res 1
  clock_h: .res 1
  clock_t: .res 1
  clock_u: .res 1
  clock_temp: .res 1
  total_time: .res 1
	.exportzp player1_x, player1_y, player1_dir, player1_ws, player1_cs, player1_ult, player1_urt, player1_llt, player1_lrt
	.exportzp frame_counter1, pad1, world_selector, zptemp, zptemp2,zptemp3, scroll, clock, clock_frames, clock_posx, clock_posy, clock_hundreds1, clock_hundreds2, clock_tens1, clock_tens2, clock_units1, clock_units2, total_time
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

  LDA player1_x
  CMP #$f0
  BEQ check_finish
  JMP start

  check_finish:
  LDA player1_y
  CMP #$20
  BEQ continues

  start:
; read controller
  LDA world_selector
  CMP #$01
  BNE ness

  continues:
  LDA clock
  STA total_time
  CMP #$00
  BEQ game_over
  LDA #$78
  STA clock

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

LDA clock
CMP #$00
BEQ game_over

LDA player1_x
  CMP #$f0
  BEQ check_victory
  JMP keep_going

  check_victory:
  LDA player1_y
  CMP #$50
  BEQ victory

keep_going:
LDA player1_x
JSR read_controller1
JSR update_player1
JSR draw_players
JSR draw_clock
JSR update_clock
JSR update_clock_tiles
JMP ski

game_over:
JSR draw_gameover
JSR draw_clock
JMP ski

victory:
JSR draw_victory
LDA clock
ADC total_time
STA total_time
LDA #$f0
SBC total_time
STA clock 
LDA #$74
STA clock_posx
LDA #$B0
STA clock_posy
JSR draw_clock

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

  .proc draw_clock
;Save values on stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;Tiles of clock
  LDA clock_hundreds1
  STA $0211
  LDA clock_hundreds2
  STA $0215
  LDA clock_tens1
  STA $0219
  LDA clock_tens2
  STA $021d
  LDA clock_units1
  STA $0221
  LDA clock_units2
  STA $0225

 
  ; write clock tile attributes
  ; use palette 01
  LDA #$21
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  STA $0222
  STA $0226


  ; top left tile:
  LDA clock_posy
  STA $0210
  LDA clock_posx
  STA $0213
  
    ; bottom left tile (y + 8):
  LDA clock_posy
  CLC
  ADC #$08
  STA $0214
  LDA clock_posx
  STA $0217

  ; top middle tile (x + 8):
  LDA clock_posy
  STA $0218
  LDA clock_posx
  CLC
  ADC #$08
  STA $021b


  ; bottom middle tile (x + 8, y + 8)
  LDA clock_posy
  CLC
  ADC #$08
  STA $021c

  LDA clock_posx
  CLC
  ADC #$08
  STA $021f

  ; top right tile (x + 16):
  LDA clock_posy
  STA $0220
  LDA clock_posx
  CLC
  ADC #$10
  STA $0223

  ; bottom right tile (x + 16, y + 8)
  LDA clock_posy
  CLC
  ADC #$08
  STA $0224

  LDA clock_posx
  CLC
  ADC #$10
  STA $0227


  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_clock
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA clock
  CMP #$00
  BEQ end_subroutine
  LDA clock_frames
  CMP #$3C
  BEQ restart_counter
  INC clock_frames
  JMP end_subroutine

  restart_counter:
  LDA #$00
  STA clock_frames
  DEC clock


  end_subroutine:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_clock_tiles
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

LDA clock
STA clock_temp
    
    ; Calculate the hundreds digit
LDX #$00          ; Clear X register
STX clock_h     ; Clear the 'hundreds' variable
divide_by_100:
INX
SEC               ; Set carry flag
SBC #$64          ; Subtract 100 from the accumulator
BPL divide_by_100 ; If carry is clear, continue subtraction
DEX
STX clock_h

LDA clock_h
CMP #$00
BEQ continue_tens
sub_hundreds:
LDA clock_temp
SBC #$64  
STA clock_temp
DEX      
TXA 
CMP #$00
BNE sub_hundreds
    
; Calculate the tens digit
continue_tens:
LDX #$00        
STX clock_t  
LDA clock_temp    
divide_by_10:
INX
SEC               ; Set carry flag
SBC #$0A          ; Subtract 10 from the accumulator
BPL divide_by_10  ; If carry is clear, continue subtraction
DEX               ; Increment X (counts the tens digit            ; Load the tens digit from X
STX clock_t         ; Store the tens digit in the 'tens' variable


LDA clock_t
CMP #$00
BEQ continue_units
sub_tens:
LDA clock_temp
SBC #$0A
STA clock_temp
DEX      
TXA 
CMP #$00
BNE sub_tens
    
continue_units:
LDA clock_temp
STA clock_u    


LDA clock_u
CMP #$00
BEQ units0
CMP #$01
BEQ units1
CMP #$02
BEQ units2
CMP #$03
BEQ units3
CMP #$04
BEQ units4
CMP #$05
BEQ units5
CMP #$06
BEQ units6
CMP #$07
BEQ units7
CMP #$08
BEQ units8

LDA #$4A
STA clock_units1
LDA #$5A
STA clock_units2
JMP change_tens

units0:
LDA #$41
STA clock_units1
LDA #$51
STA clock_units2
JMP change_tens

units1:
LDA #$42
STA clock_units1
LDA #$52
STA clock_units2
JMP change_tens

units2:
LDA #$43
STA clock_units1
LDA #$53
STA clock_units2
JMP change_tens

units3:
LDA #$44
STA clock_units1
LDA #$54
STA clock_units2
JMP change_tens

units4:
LDA #$45
STA clock_units1
LDA #$55
STA clock_units2
JMP change_tens

units5:
LDA #$46
STA clock_units1
LDA #$56
STA clock_units2
JMP change_tens

units6:
LDA #$47
STA clock_units1
LDA #$57
STA clock_units2
JMP change_tens

units7:
LDA #$48
STA clock_units1
LDA #$58
STA clock_units2
JMP change_tens

units8:
LDA #$49
STA clock_units1
LDA #$59
STA clock_units2
JMP change_tens

change_tens:
LDA clock_t
CMP #$00
BEQ tens0
CMP #$01
BEQ tens1
CMP #$02
BEQ tens2
CMP #$03
BEQ tens3
CMP #$04
BEQ tens4
CMP #$05
BEQ tens5
CMP #$06
BEQ tens6
CMP #$07
BEQ tens7
CMP #$08
BEQ tens8

LDA #$4A
STA clock_tens1
LDA #$5A
STA clock_tens2
JMP change_hundreds

tens0:
LDA #$41
STA clock_tens1
LDA #$51
STA clock_tens2
JMP change_hundreds

tens1:
LDA #$42
STA clock_tens1
LDA #$52
STA clock_tens2
JMP change_hundreds

tens2:
LDA #$43
STA clock_tens1
LDA #$53
STA clock_tens2
JMP change_hundreds

tens3:
LDA #$44
STA clock_tens1
LDA #$54
STA clock_tens2
JMP change_hundreds

tens4:
LDA #$45
STA clock_tens1
LDA #$55
STA clock_tens2
JMP change_hundreds

tens5:
LDA #$46
STA clock_tens1
LDA #$56
STA clock_tens2
JMP change_hundreds

tens6:
LDA #$47
STA clock_tens1
LDA #$57
STA clock_tens2
JMP change_hundreds

tens7:
LDA #$48
STA clock_tens1
LDA #$58
STA clock_tens2
JMP change_hundreds

tens8:
LDA #$49
STA clock_tens1
LDA #$59
STA clock_tens2
JMP change_hundreds

change_hundreds:
LDA clock_h
CMP #$00
BEQ hundreds0
CMP #$01
BEQ hundreds1

LDA #$43
STA clock_hundreds1
LDA #$53
STA clock_hundreds2
JMP end_subroutine

hundreds0:
LDA #$41
STA clock_hundreds1
LDA #$51
STA clock_hundreds2
JMP end_subroutine

hundreds1:
LDA #$42
STA clock_hundreds1
LDA #$52
STA clock_hundreds2

  end_subroutine:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

  .proc draw_gameover
;Save values on stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;Tiles values
  LDA #$61
  ;STA $0211
  STA $0229
  LDA #$62
  STA $022D
  LDA #$63
  STA $0231
  LDA #$64
  STA $0235
  LDA #$65
  STA $0239
  LDA #$66
  STA $023D
  LDA #$67
  STA $0241
  LDA #$68
  STA $0245

  LDA #$71
  STA $0249
  LDA #$72
  STA $024D
  LDA #$73
  STA $0251
  LDA #$74
  STA $0255
  LDA #$75
  STA $0259
  LDA #$76
  STA $025D
  LDA #$77
  STA $0261
  LDA #$78
  STA $0265

  LDA #$81
  STA $0269
  LDA #$82
  STA $026D
  LDA #$83
  STA $0271
  LDA #$84
  STA $0275
  LDA #$67
  STA $0279
  LDA #$68
  STA $027D
  LDA #$85
  STA $0281
  LDA #$86
  STA $0285

  LDA #$91
  STA $0289
  LDA #$92
  STA $028D
  LDA #$93
  STA $0291
  LDA #$94
  STA $0295
  LDA #$77
  STA $0299
  LDA #$78
  STA $029D
  LDA #$95
  STA $02A1
  LDA #$96
  STA $02A5

 
  ; write tile attributes
  ; use palette 01
  LDA #$21
  ;STA $0212
  STA $022A
  STA $022E
  STA $0232
  STA $0236
  STA $023a
  STA $023e
  STA $0242
  STA $0246

  STA $024a
  STA $024e
  STA $0252
  STA $0256
  STA $025a
  STA $025e
  STA $0262
  STA $0266

  STA $026a
  STA $026e
  STA $0272
  STA $0276
  STA $027a
  STA $027e
  STA $0282
  STA $0286

  STA $028a
  STA $028e
  STA $0292
  STA $0296
  STA $029a
  STA $029e
  STA $02a2
  STA $02a6


  LDA #$70
  STA $0228
  LDA #$60
  STA $022b
  
  LDA #$70
  STA $022c
  LDA #$68
  STA $022f

  LDA #$70
  STA $0230
  LDA #$70
  STA $0233

  LDA #$70
  STA $0234
  LDA #$78
  STA $0237

  LDA #$70
  STA $0238
  LDA #$80
  STA $023b
  
  LDA #$70
  STA $023c
  LDA #$88
  STA $023f

  LDA #$70
  STA $0240
  LDA #$90
  STA $0243

  LDA #$70
  STA $0244
  LDA #$98
  STA $0247
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDA #$78
  STA $0248
  LDA #$60
  STA $024b
  
  LDA #$78
  STA $024c
  LDA #$68
  STA $024f

  LDA #$78
  STA $0250
  LDA #$70
  STA $0253

  LDA #$78
  STA $0254
  LDA #$78
  STA $0257

  LDA #$78
  STA $0258
  LDA #$80
  STA $025b
  
  LDA #$78
  STA $025c
  LDA #$88
  STA $025f

  LDA #$78
  STA $0260
  LDA #$90
  STA $0263

  LDA #$78
  STA $0264
  LDA #$98
  STA $0267

  ;;;;;;;;;;;;;;;;;;;;;

  LDA #$80
  STA $0268
  LDA #$60
  STA $026b
  
  LDA #$80
  STA $026c
  LDA #$68
  STA $026f

  LDA #$80
  STA $0270
  LDA #$70
  STA $0273

  LDA #$80
  STA $0274
  LDA #$78
  STA $0277

  LDA #$80
  STA $0278
  LDA #$80
  STA $027b
  
  LDA #$80
  STA $027c
  LDA #$88
  STA $027f

  LDA #$80
  STA $0280
  LDA #$90
  STA $0283

  LDA #$80
  STA $0284
  LDA #$98
  STA $0287

  ;;;;;;;;;;;;;;;;;;;

  LDA #$88
  STA $0288
  LDA #$60
  STA $028b
  
  LDA #$88
  STA $028c
  LDA #$68
  STA $028f

  LDA #$88
  STA $0290
  LDA #$70
  STA $0293

  LDA #$88
  STA $0294
  LDA #$78
  STA $0297

  LDA #$88
  STA $0298
  LDA #$80
  STA $029b
  
  LDA #$88
  STA $029c
  LDA #$88
  STA $029f

  LDA #$88
  STA $02a0
  LDA #$90
  STA $02a3

  LDA #$88
  STA $02a4
  LDA #$98
  STA $02a7

  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_victory
;Save values on stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;Tiles values
  LDA #$A5
  STA $0229
  LDA #$A6
  STA $022D
  LDA #$81
  STA $0231
  LDA #$82
  STA $0235
  LDA #$A1
  STA $0239
  LDA #$A2
  STA $023D

  LDA #$B5
  STA $0241
  LDA #$B6
  STA $0245
  LDA #$91
  STA $0249
  LDA #$92
  STA $024D
  LDA #$B1
  STA $0251
  LDA #$B2
  STA $0255

  LDA #$65
  STA $0259
  LDA #$66
  STA $025D
  LDA #$63
  STA $0261
  LDA #$64
  STA $0265
  LDA #$A7
  STA $0269
  LDA #$A8
  STA $026D
  LDA #$67
  STA $0271
  LDA #$68
  STA $0275


  LDA #$75
  STA $0279
  LDA #$76
  STA $027D
  LDA #$73
  STA $0281
  LDA #$74
  STA $0285
  LDA #$B7
  STA $0289
  LDA #$B8
  STA $028D
  LDA #$77
  STA $0291
  LDA #$78
  STA $0295


  LDA #$87
  STA $0299
  LDA #$88
  STA $029D
  LDA #$a3
  STA $02A1
  LDA #$A4
  STA $02A5

  LDA #$97
  STA $02A9
  LDA #$98
  STA $02AD
  LDA #$B3
  STA $02B1
  LDA #$B4
  STA $02B5

 
  ; write tile attributes
  ; use palette 01
  LDA #$21
  ;STA $0212
  STA $022A
  STA $022E
  STA $0232
  STA $0236
  STA $023a
  STA $023e
  STA $0242
  STA $0246

  STA $024a
  STA $024e
  STA $0252
  STA $0256
  STA $025a
  STA $025e
  STA $0262
  STA $0266

  STA $026a
  STA $026e
  STA $0272
  STA $0276
  STA $027a
  STA $027e
  STA $0282
  STA $0286

  STA $028a
  STA $028e
  STA $0292
  STA $0296
  STA $029a
  STA $029e
  STA $02a2
  STA $02a6

  STA $02aa
  STA $02ae
  STA $02b2
  STA $02b6

;;;;;;;;;;;;;;;;;;;;;
  LDA #$60
  STA $0228
  LDA #$68
  STA $022b
  
  LDA #$60
  STA $022c
  LDA #$70
  STA $022f

  LDA #$60
  STA $0230
  LDA #$78
  STA $0233

  LDA #$60
  STA $0234
  LDA #$80
  STA $0237

  LDA #$60
  STA $0238
  LDA #$88
  STA $023b
  
  LDA #$60
  STA $023c
  LDA #$90
  STA $023f

  LDA #$68
  STA $0240
  LDA #$68
  STA $0243

  LDA #$68
  STA $0244
  LDA #$70
  STA $0247

  LDA #$68
  STA $0248
  LDA #$78
  STA $024b
  
  LDA #$68
  STA $024c
  LDA #$80
  STA $024f

  LDA #$68
  STA $0250
  LDA #$88
  STA $0253

  LDA #$68
  STA $0254
  LDA #$90
  STA $0257

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDA #$70
  STA $0258
  LDA #$60
  STA $025b
  
  LDA #$70
  STA $025c
  LDA #$68
  STA $025f

  LDA #$70
  STA $0260
  LDA #$70
  STA $0263

  LDA #$70
  STA $0264
  LDA #$78
  STA $0267

  LDA #$70
  STA $0268
  LDA #$80
  STA $026b
  
  LDA #$70
  STA $026c
  LDA #$88
  STA $026f

  LDA #$70
  STA $0270
  LDA #$90
  STA $0273

  LDA #$70
  STA $0274
  LDA #$98
  STA $0277

  LDA #$78
  STA $0278
  LDA #$60
  STA $027b
  
  LDA #$78
  STA $027c
  LDA #$68
  STA $027f

  LDA #$78
  STA $0280
  LDA #$70
  STA $0283

  LDA #$78
  STA $0284
  LDA #$78
  STA $0287

  LDA #$78
  STA $0288
  LDA #$80
  STA $028b
  
  LDA #$78
  STA $028c
  LDA #$88
  STA $028f

  LDA #$78
  STA $0290
  LDA #$90
  STA $0293

  LDA #$78
  STA $0294
  LDA #$98
  STA $0297

  ;;;;;;;;;;;;;;;;;;

  LDA #$80
  STA $0298
  LDA #$70
  STA $029b
  
  LDA #$80
  STA $029c
  LDA #$78
  STA $029f

  LDA #$80
  STA $02a0
  LDA #$80
  STA $02a3

  LDA #$80
  STA $02a4
  LDA #$88
  STA $02a7

  LDA #$88
  STA $02a8
  LDA #$70
  STA $02ab
  
  LDA #$88
  STA $02ac
  LDA #$78
  STA $02af

  LDA #$88
  STA $02b0
  LDA #$80
  STA $02a3

  LDA #$88
  STA $02b4
  LDA #$88
  STA $02b7

  ;Retrieve values from stack
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