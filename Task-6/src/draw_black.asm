.include "constants.inc"
.segment "ZEROPAGE"
.importzp zptemp, zptemp2, zptemp3

.segment "CODE"
.import  tile_map, tile_map1, attribute, attribute1
.export draw_black

.proc draw_black

LDA #$20        ; Set high byte of nametable address (e.g., $2000)
STA $2006
LDA #$00        ; Set low byte of nametable address
STA $2006
LDX #$00        ; X register as a counter
clear_loop:
    LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007   ; Write tile to nametable
        LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007 
    INX
    CPX #$FF    ; Check if we've filled 256 tiles
    BNE clear_loop
clear_loop2:
    LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007   ; Write tile to nametable
        LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007 
    INX
    CPX #$FF    ; Check if we've filled 256 tiles
    BNE clear_loop2

LDA #$24        ; Set high byte of nametable address (e.g., $2000)
STA $2006
LDA #$00        ; Set low byte of nametable address
STA $2006
LDX #$00        ; X register as a counter
clear_loop3:
    LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007   ; Write tile to nametable
        LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007 
    INX
    CPX #$FF    ; Check if we've filled 256 tiles
    BNE clear_loop3
clear_loop4:
    LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007   ; Write tile to nametable
        LDA #$00    ; Tile index to write (0 for an empty tile)
    STA $2007 
    INX
    CPX #$FF    ; Check if we've filled 256 tiles
    BNE clear_loop4
	RTS
.endproc
