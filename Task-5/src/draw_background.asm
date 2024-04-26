.include "constants.inc"
.segment "ZEROPAGE"
.importzp zptemp, zptemp2, zptemp3

.segment "CODE"
.import  tile_map, tile_map1, attribute, attribute1
.export draw_background

.proc draw_background
	LDX #$00
	STX zptemp2

	LDA #$10        ; Load the low byte (10 in hex)
	STA zptemp3       ; Store it in ztemp (low byte)
	LDA #$00        ; Load the high byte (0, since 10 is less than 256)
	STA zptemp3+1     ; Store it in ztemp+1 (high byte)

	LDA #$00
	STA zptemp

	FirstWorld:
		LDA PPUSTATUS
		LDA #$20
		STA PPUADDR    
		LDA #$00
		STA PPUADDR  

		OuterLoop:
		Start:
		LDY #$00

		LoopAgain:   
		LDX zptemp2
		Loop:  
			LDA tile_map,X       
			STA PPUDATA 
			LDA tile_map,X       
			STA PPUDATA    
			INX           
			CPX zptemp3  
			BNE Loop
		INY
		CPY #$02
		BNE LoopAgain
		
		LDA zptemp3       ; Load the low byte of ztemp
		CLC             ; Clear the carry flag before addition
		ADC #$10      ; Add 30 (1E in hex) to the accumulator
		STA zptemp3       ; Store the result back in ztemp

		LDA zptemp3+1     ; Load the high byte of ztemp
		ADC #$00        ; Add any carry from the previous addition
		STA zptemp3+1     ; Store the result back in ztemp+1

		STX zptemp2 

		LDA zptemp
		CLC       ; Clear the carry flag to ensure clean addition
		ADC #$01  ; Add with carry the value 1 to the accumulator
		STA zptemp

		CMP #$0F 
		BEQ END

		JMP OuterLoop
	END:
	LDX #$00
	LDA PPUSTATUS    ; Reset the address latch
	LDA #$23         ; High byte of $23C0
	STA PPUADDR
	LDA #$C0         ; Low byte of $23C0
	STA PPUADDR

	LoadAttribute:
		LDA attribute, X        ; Load an attribute byte (example data)
		STA PPUDATA      ; Write it to PPU
		INX
		CPX #$40
		BNE LoadAttribute


	LDX #$00
	STX zptemp2

	LDA #$10        ; Load the low byte (10 in hex)
	STA zptemp3       ; Store it in ztemp (low byte)
	LDA #$00        ; Load the high byte (0, since 10 is less than 256)
	STA zptemp3+1     ; Store it in ztemp+1 (high byte)

	LDA #$00
	STA zptemp

	
		LDA PPUSTATUS
		LDA #$24
		STA PPUADDR    
		LDA #$00
		STA PPUADDR  
		JMP Start1
		OuterLoop1:
		
		Start1:
		LDY #$00

		LoopAgain1:   
		LDX zptemp2
		Loop1:  
			LDA tile_map1,X       
			STA PPUDATA 
			LDA tile_map1,X       
			STA PPUDATA    
			INX           
			CPX zptemp3  
			BNE Loop1
		INY
		CPY #$02
		BNE LoopAgain1
		
		LDA zptemp3       ; Load the low byte of ztemp
		CLC             ; Clear the carry flag before addition
		ADC #$10      ; Add 30 (1E in hex) to the accumulator
		STA zptemp3       ; Store the result back in ztemp

		LDA zptemp3+1     ; Load the high byte of ztemp
		ADC #$00        ; Add any carry from the previous addition
		STA zptemp3+1     ; Store the result back in ztemp+1

		STX zptemp2 

		LDA zptemp
		CLC       ; Clear the carry flag to ensure clean addition
		ADC #$01  ; Add with carry the value 1 to the accumulator
		STA zptemp

		CMP #$0F 
		BEQ END1

		JMP OuterLoop1
		END1:

	LDX #$00
	LDA PPUSTATUS    ; Reset the address latchss
	LDA #$27         ; High byte of $23C0
	STA PPUADDR
	LDA #$C0         ; Low byte of $23C0
	STA PPUADDR

	LoadAttribute1:
		LDA attribute1, X        ; Load an attribute byte (example data)
		STA PPUDATA      ; Write it to PPU
		INX
		CPX #$40
		BNE LoadAttribute1

	RTS
.endproc
; bg:     
;   .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 
;   .byte $03,$00,$00,$00,$00,$00,$03,$16,$14,$00,$00,$00,$00,$00,$00,$00
;   .byte $03,$00,$03,$03,$03,$00,$03,$03,$03,$03,$03,$03,$03,$03,$14,$03
;   .byte $03,$14,$03,$16,$03,$00,$00,$00,$00,$00,$14,$00,$00,$00,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$03,$03,$03,$03,$03,$00,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$00,$00,$00,$00,$03,$00,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$14,$03,$03,$00,$00,$00,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$00,$03,$03,$03,$03,$03,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$00,$03,$14,$00,$00,$00,$03,$00,$03
;   .byte $03,$14,$03,$00,$03,$00,$03,$00,$03,$16,$03,$03,$00,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$00,$03,$03,$03,$03,$00,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$14,$03,$00,$00,$00,$00,$14,$00,$03,$00,$03
;   .byte $03,$00,$03,$00,$03,$00,$03,$03,$03,$03,$03,$03,$03,$03,$00,$03
;   .byte $03,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
;   .byte $03,$03,$03,$16,$16,$16,$16,$16,$16,$16,$16,$16,$16,$16,$16,$03

; bg1:
;   .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
;   .byte $00,$00,$00,$14,$00,$00,$14,$00,$00,$00,$00,$00,$00,$14,$00,$03
;   .byte $16,$00,$03,$00,$16,$00,$03,$00,$03,$03,$03,$00,$03,$03,$03,$03
;   .byte $16,$00,$03,$00,$03,$03,$03,$00,$03,$00,$03,$16,$03,$00,$00,$00
;   .byte $03,$00,$03,$00,$03,$00,$03,$00,$16,$00,$03,$00,$03,$00,$16,$16
;   .byte $03,$00,$03,$00,$03,$00,$00,$00,$03,$00,$03,$00,$03,$14,$14,$03
;   .byte $03,$00,$03,$14,$03,$00,$16,$00,$03,$00,$03,$00,$00,$14,$00,$03
;   .byte $03,$00,$03,$00,$00,$00,$03,$00,$03,$00,$03,$00,$03,$00,$14,$03
;   .byte $03,$00,$03,$03,$16,$00,$03,$00,$03,$00,$03,$00,$03,$00,$00,$03
;   .byte $03,$00,$16,$00,$03,$03,$03,$00,$03,$00,$03,$00,$03,$00,$14,$03
;   .byte $03,$00,$16,$00,$03,$00,$03,$00,$00,$14,$03,$14,$03,$00,$00,$03
;   .byte $03,$00,$16,$00,$03,$00,$03,$03,$03,$00,$03,$00,$03,$14,$00,$03
;   .byte $03,$00,$16,$00,$03,$00,$03,$14,$03,$00,$03,$00,$03,$03,$03,$03
;   .byte $03,$00,$00,$00,$00,$00,$00,$14,$03,$00,$00,$00,$00,$00,$00,$03
;   .byte $16,$03,$03,$03,$03,$03,$03,$03,$03,$16,$16,$16,$16,$16,$16,$03

; attribute:
; 	.byte $aa,$aa,$aa,$ea,$8a,$aa,$aa,$aa,$2a,$ea,$aa,$aa,$aa,$8a,$aa,$a8
; 	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$a2,$aa,$aa,$aa,$aa
; 	.byte $2a,$aa,$aa,$aa,$e2,$aa,$aa,$aa,$aa,$aa,$2a,$aa,$aa,$2a,$aa,$aa
; 	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$0a,$0e,$0f,$0f,$0f,$0f,$0f,$0b
; attribute1:
;   .byte $aa,$2a,$aa,$8a,$aa,$aa,$2a,$aa,$bb,$aa,$ab,$aa,$aa,$ea,$aa,$aa
; 	.byte $aa,$aa,$aa,$aa,$ab,$aa,$2a,$8f,$aa,$a2,$aa,$ab,$aa,$aa,$a2,$8a
; 	.byte $aa,$ba,$ab,$aa,$aa,$aa,$aa,$8a,$aa,$bb,$aa,$aa,$a2,$a2,$2a,$aa
; 	.byte $aa,$ab,$aa,$22,$aa,$aa,$aa,$aa,$0b,$0a,$0a,$0a,$0e,$0f,$0f,$0b