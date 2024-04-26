.include "constants.inc"

.segment "ZEROPAGE"
.importzp player1_x, player1_y, player2_x, player2_y, player3_x, player3_y, player4_x, player4_y, player1_dir, player2_dir, player3_dir, player4_dir, player1_ws, player2_ws, player3_ws, player4_ws, player1_cs, player2_cs, player3_cs, player4_cs, player1_ult, player1_urt, player1_llt, player1_lrt,player2_ult, player2_urt, player2_llt, player2_lrt, player3_ult, player3_urt, player3_llt, player3_lrt
.importzp player4_ult, player4_urt, player4_llt, player4_lrt, frame_counter1, frame_counter2, frame_counter3, frame_counter4, world_selector, bottomR_x, bottomR_y, topR_x, topR_y
.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010
  BIT $2002
vblankwait:
  BIT $2002
  BPL vblankwait

	LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

vblankwait2:
  BIT $2002
  BPL vblankwait2
  ; initialize zero-page values
  LDA #$10
  STA player1_x
  LDA #$C0
  STA player1_y
  LDA #$00
  STA player1_dir
  LDA #$01
  STA player1_ws
  LDA #$00
  STA player1_cs
  LDA #$01
  STA player1_ult
  LDA #$02
  STA player1_urt
  LDA #$11
  STA player1_llt
  LDA #$12
  STA player1_lrt
  LDA #$00
  STA world_selector

  LDA #$00
  STA frame_counter1
  JMP main
.endproc
