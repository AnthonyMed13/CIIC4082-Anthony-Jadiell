.include "constants.inc"
.segment "ZEROPAGE"
.importzp zptemp, zptemp2, zptemp3

.segment "CODE"
.import tile_map2, tile_map3, attribute2, attribute3
.export draw_background2

.proc draw_background2
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
			LDA tile_map2,X       
			STA PPUDATA 
			LDA tile_map2,X       
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
		LDA attribute2, X        ; Load an attribute byte (example data)
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
			LDA tile_map3,X       
			STA PPUDATA 
			LDA tile_map3,X       
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
		LDA attribute3, X        ; Load an attribute byte (example data)
		STA PPUDATA      ; Write it to PPU
		INX
		CPX #$40
		BNE LoadAttribute1

	RTS
.endproc