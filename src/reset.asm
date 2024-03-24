.include "constants.inc"

.segment "ZEROPAGE"
.importzp player1_x, player1_y, player2_x, player2_y, player3_x, player3_y, player4_x, player4_y, player1_dir, player2_dir, player3_dir, player4_dir, player1_ws, player2_ws, player3_ws, player4_ws, player1_cs, player2_cs, player3_cs, player4_cs, player1_ult, player1_urt, player1_llt, player1_lrt,player2_ult, player2_urt, player2_llt, player2_lrt, player3_ult, player3_urt, player3_llt, player3_lrt
.importzp player4_ult, player4_urt, player4_llt, player4_lrt, frame_counter1, frame_counter2, frame_counter3, frame_counter4
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
  LDA #$70
  STA player1_x
  LDA #$40
  STA player1_y
  LDA #$70
  STA player2_x
  LDA #$50
  STA player2_y
  LDA #$70
  STA player3_x
  LDA #$60
  STA player3_y
  LDA #$70
  STA player4_x
  LDA #$70
  STA player4_y
  LDA #$00
  STA player1_dir
  LDA #$01
  STA player2_dir
  LDA #$03
  STA player3_dir
  LDA #$02
  STA player4_dir
  LDA #$01
  STA player1_ws
  LDA #$01
  STA player2_ws
  LDA #$01
  STA player3_ws
  LDA #$01
  STA player4_ws
  LDA #$00
  STA player1_cs
  LDA #$00
  STA player2_cs
  LDA #$00
  STA player3_cs
  LDA #$00
  STA player4_cs
  LDA #$01
  STA player1_ult
  LDA #$02
  STA player1_urt
  LDA #$11
  STA player1_llt
  LDA #$12
  STA player1_lrt
  LDA #$21
  STA player2_ult
  LDA #$22
  STA player2_urt
  LDA #$31
  STA player2_llt
  LDA #$32
  STA player2_lrt
  LDA #$27
  STA player3_ult
  LDA #$28
  STA player3_urt
  LDA #$37
  STA player3_llt
  LDA #$38
  STA player3_lrt
  LDA #$07
  STA player4_ult
  LDA #$08
  STA player4_urt
  LDA #$17
  STA player4_llt
  LDA #$18
  STA player4_lrt

  LDA #$00
  STA frame_counter1
  STA frame_counter2
  STA frame_counter3
  STA frame_counter4
  JMP main
.endproc
