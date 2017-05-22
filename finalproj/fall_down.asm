
;- REGISTERS -------------------------------------------------- -;
;- r24 = game state (start menu:0x0, game play:0x1)
;- r25 = timer low bits
;- r26 = timer high bits
;- r27 = player column coordinate (6 bits)
;- r28 = player row coordinate (5 bits)
;- r29 = vga color
;- r30 = score lower bits
;- r31 = score upper bits

;- CONSTANTS -------------------------------------------------- -;
.equ lfsr_port      = 0x21

.equ led_port       = 0x40
.equ ssegl_port     = 0x41
.equ ssegu_port     = 0x42
.equ vga_col_port   = 0x43
.equ vga_row_port   = 0x44
.equ vga_colr_port  = 0x45
.equ vga_we_port	= 0x46
.equ MOVE_ID        = 0x47
.equ MOVE_OUT_ID    = 0x48

.equ player_colr    = 0xff
.equ floor_colr     = 0x1b
.equ bkgnd_colr     = 0x1

.equ scr_x_max      = 0x27
.equ scr_y_max      = 0x1d

.equ text_x         = 0x07
.equ text_y         = 0x07

.equ r0_save        = 0x30
.equ r1_save		= 0x31
.equ r2_save		= 0x32
.equ r3_save		= 0x33
.equ r4_save	    = 0x34
.equ r5_save	    = 0x35
.equ r6_save	    = 0x36

;- DATA -------------------------------------------------- -;
.dseg
.org  0x70

str_game:	.db 0x3e, 0x41, 0x41, 0x51, 0x32		;- G
			.db 0x3e, 0x09, 0x09, 0x09, 0x3e		;- A
			.db 0x3f, 0x02, 0x04, 0x02, 0x3f		;- M
			.db 0x7f, 0x49, 0x49, 0x49, 0x41		;- E

str_over:	.db 0x3e, 0x41, 0x41, 0x41, 0x3e		;- O
			.db 0x1f, 0x20, 0x40, 0x20, 0x1f		;- V
			.db 0x7f, 0x49, 0x49, 0x49, 0x41		;- E
			.db 0x7f, 0x09, 0x41, 0x51, 0x32		;- R

str_fall: 	.db 0x7f, 0x09, 0x09, 0x09, 0x01		;- F
			.db 0x3e, 0x09, 0x09, 0x09, 0x3e		;- A
			.db 0x7f, 0x40, 0x40, 0x40, 0x40		;- L
			.db 0x7f, 0x40, 0x40, 0x40, 0x40		;- L

str_down:	.db 0x7f, 0x41, 0x41, 0x41, 0x3e		;- D
			.db 0x3e, 0x41, 0x41, 0x41, 0x3e		;- O
			.db 0x3f, 0x40, 0x20, 0x40, 0x3f		;- W
			.db 0x7f, 0x04, 0x08, 0x10, 0x7f		;- N
	
floor0_x: 	.byte 1
floor0_y: 	.byte 1
floor1_x: 	.byte 1
floor1_y: 	.byte 1
floor2_x: 	.byte 1
floor2_y:	.byte 1
		
;- CODE -------------------------------------------------- -;
.cseg
.org  0x100

;- MAIN -------------------------------------------------- -;
main:
		sei
		call rst_game
		mov r20, 0x00
		mov r21, 0x00
		mov r14, bkgnd_colr

start:	call draw_game

		cmp  r24, 0x01				;- check if move to game state
		brne start					;- if not keep displaying main menu

gloop:	call draw_game
		call update_sseg
		out  r26, led_port

		call inc_timer

		cmp  r21, 0x0a
		brcs nmr

		cmp  r27, scr_x_max
		breq nad1
		add  r27, 0x01
nad1:	sub  r21, 0x0a

nmr:	cmp  r20, 0x0a
		brcs nml

		cmp  r27, 0x00
		breq nad2	
		sub  r27, 0x01
nad2:	sub  r20, 0x0a

nml:
		cmp  r28, 0x00				;- if player reaches top of screen they lose
		breq lose

		mov  r0, r25
		and  r0, 0x7f
		cmp  r0, 0x7f
		brne sft_p

		call shift_floor

sft_p:	mov  r0, r25
		and  r0, 0x0f

		cmp  r0, 0x00
		brne gloop

		call update_player

		ld   r2, floor0_y
		ld   r3, floor1_y
		ld   r4, floor2_y

		cmp  r28, r2
		breq upsc
		cmp  r28, r3
		breq upsc
		cmp  r28, r4
		breq upsc
		brn  gloop

upsc:	call inc_score

		brn  gloop					;- loop back to start

lose:	cli							;- turn off interrupts so user can't move anymore

		mov  r14, 0xc0

		call draw_game
		brn  lose

;- SUBROUTINES -------------------------------------------------- -;

;----------------------------------------------------------------------
;- TURNS ON WRITE ENABLE
;----------------------------------------------------------------------
wr_on:
		st   r4, r4_save

		mov  r4, 0xff
		out  r4, vga_we_port

		ld   r4, r4_save

		ret

;----------------------------------------------------------------------
;- TURNS OFF WRITE ENABLE
;----------------------------------------------------------------------
wr_off:
		st   r4, r4_save

		mov  r4, 0x00
		out  r4, vga_we_port

		ld   r4, r4_save

		ret

;----------------------------------------------------------------------
;- STROBES THE WRITE ENABLE TO WRITE TO VGA RAM
;----------------------------------------------------------------------
wr_strb:
		call wr_on
		call wr_off

		ret

;----------------------------------------------------------------------
;- RESETS THE SCORE VARIABLES
;----------------------------------------------------------------------
rst_score:
		mov  r30, 0x00				;- clear score lower bits
		mov  r31, 0x00				;- clear score upper bits

		ret

;----------------------------------------------------------------------
;- RESETS THE PLAYER VARIABLES
;----------------------------------------------------------------------
rst_player:
		st   r0, r0_save

		mov  r27, 0x13
		mov  r28, 0x01

		ld   r0, r0_save

		ret

;----------------------------------------------------------------------
;- RESETS THE TIMER REGISTERS
;----------------------------------------------------------------------
rst_timer:
		mov  r25, 0x00
		mov  r26, 0x00

		ret

;----------------------------------------------------------------------
;- RESETS THE FLOORS LOCATIONS
;----------------------------------------------------------------------
rst_floors:
		st   r0, r0_save

		mov  r0, 0x1d
		st   r0, floor0_y
		in   r0, lfsr_port
		st   r0, floor0_x

		mov  r0, 0x27
		st   r0, floor1_y
		in   r0, lfsr_port
		st   r0, floor1_x

		mov  r0, 0x31
		st   r0, floor2_y
		in   r0, lfsr_port
		st   r0, floor2_x

		ld   r0, r0_save

		ret

;----------------------------------------------------------------------
;- RESETS THE GAME VARIABLES
;----------------------------------------------------------------------
rst_game:
		mov  r24, 0x00				;- reset game state to start menu

		call rst_timer
		call rst_score
		call rst_player
		call rst_floors

		ret

;----------------------------------------------------------------------
;- INCREMENTS THE SOFTWARE TIMER
;----------------------------------------------------------------------
inc_timer:
		add  r25, 0x01				;- increment timer low bits
		addc r26, 0x00				;- add carry

t_nr:	ret

;----------------------------------------------------------------------
;- INCREMENTS THE SCORE
;----------------------------------------------------------------------
inc_score:
		add  r30, 0x01				;- increment lower score bits
		addc r31, 0x00				;- add a carry 

		ret

;----------------------------------------------------------------------
;- WRITES THE SCORE TO THE SEVEN SEGMENT DISPLAY
;----------------------------------------------------------------------
update_sseg:
		out  r30, ssegl_port		;- write lower score bits to sseg
		out  r31, ssegu_port		;- write upper score bits to sseg

		ret

;----------------------------------------------------------------------
;- SHIFTS FLOOR UP BY ONE BLOCK
;----------------------------------------------------------------------
shift_floor:
		st   r0, r0_save			;- save r0
		st   r3, r3_save			;- save r3

		ld   r3, floor0_y			;- get current y coordinate or floor 0
		sub  r3, 0x01				;- adjust y coordinate of floor

		brcc st1

		in   r0, lfsr_port
		st   r0, floor0_x

		mov  r3, scr_y_max
st1:	st   r3, floor0_y			;- write new y coordinate

		ld   r3, floor1_y			;- get current y coordinate or floor 1
		sub  r3, 0x01				;- adjust y coordinate of floor

		brcc st2

		in   r0, lfsr_port
		st   r0, floor1_x

		mov  r3, scr_y_max
st2:	st   r3, floor1_y			;- write new y coordinate

		ld   r3, floor2_y			;- get current y coordinate or floor 2
		sub  r3, 0x01				;- adjust y coordinate of floor

		brcc st3

		in   r0, lfsr_port
		st   r0, floor2_x

		mov  r3, scr_y_max
st3:	st   r3, floor2_y			;- write new y coordinate

		ld   r0, r0_save			;- restore r0
		ld   r3, r3_save			;- restore r3

		ret

;----------------------------------------------------------------------
;- UPDATE PLAYER Y COORDINATE
;----------------------------------------------------------------------
update_player:
		st   r0, r0_save			;- save r0
		st   r1, r1_save			;- save r1
		st   r2, r2_save			;- save r2
		st   r3, r3_save			;- save r3
		st   r4, r4_save			;- save r4

		;- figure out which floor to compare to
		ld   r0, floor0_y
		ld   r1, floor1_y
		ld   r2, floor2_y

		mov  r22, 0x00

		sub  r0, r28
		brcc nc1
		add  r22, 0x01
nc1:	sub  r1, r28
		brcc nc2
		add  r22, 0x01
nc2:	sub  r2, r28
		brcc scmp

		cmp  r22, 0x02
		breq yinc

scmp:	cmp  r0, r1
		brcs r0_sm					;- r0 is smaller than r1
		brn  r1_sm					;- r1 is smaller than r0

r0_sm:	cmp  r0, r2
		brcs chk0					;- r0 is smallest
		brn  chk2					;- r2 is smallest

r1_sm:	cmp  r1, r2
		brcs chk1					;- r1 is smallest
		brn  chk2					;- r2 is smallest

chk0:	ld   r1, floor0_x

		cmp  r1, r27
		breq yinc
		sub  r1, 0x01
		cmp  r1, r27
		breq yinc
		add  r1, 0x02
		cmp  r1, r27
		breq yinc

		ld   r0, floor0_y			;- get floor 0 coordinate
		sub  r0, 0x01				;- subtract 1 from coordinate to refer to block above

		cmp  r0, r28				;- compare player coordinate to floor coordinate
		brcs ninc					;- if player is above floor drop
		breq ninc

chk1:	ld   r1, floor1_x

		cmp  r1, r27
		breq yinc
		sub  r1, 0x01
		cmp  r1, r27
		breq yinc
		add  r1, 0x02
		cmp  r1, r27
		breq yinc

		ld   r0, floor1_y			;- get floor 1 coordinate
		sub  r0, 0x01				;- subtract 1 from coordinate to refer to block above

		cmp  r0, r28				;- compare player coordinate to floor coordinate
		brcs ninc					;- if player is above floor drop
		breq ninc

chk2:	ld   r1, floor2_x

		cmp  r1, r27
		breq yinc
		sub  r1, 0x01
		cmp  r1, r27
		breq yinc
		add  r1, 0x02
		cmp  r1, r27
		breq yinc

		ld   r0, floor2_y			;- get floor 2 coordinate
		sub  r0, 0x01				;- subtract 1 from coordinate to refer to block above

		cmp  r0, r28				;- compare player coordinate to floor coordinate
		brcs ninc					;- if player is above floor drop
		breq ninc

yinc:	add  r28, 0x01
		brn  res

ninc:	mov  r28, r0
res:	ld   r0, r0_save			;- restore r0
		ld   r1, r1_save			;- restore r1
		ld   r1, r1_save			;- restore r2
		ld   r1, r1_save			;- restore r3
		ld   r1, r1_save			;- restore r4

		cmp  r28, scr_y_max
		brcs na

		mov r28, scr_y_max

na:		ret

;----------------------------------------------------------------------
;- CHECKS IF (R0, R1) MATCHES PLAYER COORDINATES
;----------------------------------------------------------------------
chk_player:
		mov  r2, 0x00

		cmp  r0, r27
		brne p_cy
		or   r2, 0x0f

p_cy:	cmp	 r1, r28
		brne p_rt
		or   r2, 0xf0

p_rt:	ret

;----------------------------------------------------------------------
;- CHECKS IF (R0, R1) MATCHES FLOOR COORDINATES
;----------------------------------------------------------------------
chk_floor:
		mov  r2, 0x00

		ld   r3, floor0_y				;- check y0
		cmp  r1, r3
		brne fl1

		ld   r3, floor0_x				;- check x0
		cmp  r0, r3
		breq fl1

		sub  r3, 0x01
		cmp  r0, r3
		breq fl1

		add  r3, 0x02
		cmp  r0, r3
		breq fl1

		mov  r2, 0xff

fl1:	ld   r3, floor1_y				;- check y1
		cmp  r1, r3
		brne fl2

		ld   r3, floor1_x				;- check x1
		cmp  r0, r3
		breq fl2

		sub  r3, 0x01
		cmp  r0, r3
		breq fl2

		add  r3, 0x02
		cmp  r0, r3
		breq fl2

		mov  r2, 0xff

fl2:	ld   r3, floor2_y				;- check y2
		cmp  r1, r3
		brne chd

		ld   r3, floor2_x				;- check x2
		cmp  r0, r3
		breq chd

		sub  r3, 0x01
		cmp  r0, r3
		breq chd

		add  r3, 0x02
		cmp  r0, r3
		breq chd

		mov  r2, 0xff

chd:	ret

;----------------------------------------------------------------------
;- DRAWS THE PLAYER
;----------------------------------------------------------------------
draw_player:
		;call wr_on					;- turn on write enable

		mov  r29, player_colr		;- get player color
		out  r29, vga_colr_port		;- write we and color

		;call wr_off					;- turn off write enable
		call wr_strb

		ret

;----------------------------------------------------------------------
;- DRAWS ONE BLOCK OF THE BACKGROUND
;----------------------------------------------------------------------
draw_bkgnd:
		;call wr_on

		mov  r29, r14		;- get background color
		out  r29, vga_colr_port	;- write we and color

		;call wr_off					;- turn off write enable
		call wr_strb

		ret

;----------------------------------------------------------------------
;- DRAWS ONE BLOCK OF THE FLOOR
;----------------------------------------------------------------------
draw_floor:
		;call wr_on

		mov  r29, floor_colr		;- get background color
		out  r29, vga_colr_port	;- write we and color

		;call wr_off					;- turn off write enable
		call wr_strb

		ret

;----------------------------------------------------------------------
;- DRAWS THE GAME TO THE SCREEN
;----------------------------------------------------------------------
draw_game:
		st   r0, r0_save			;- save r0
		st   r1, r1_save			;- save r1
		st   r2, r2_save			;- save r2
		st   r3, r3_save			;- save r3

		mov  r1, 0xff				;- y iterator
rst_x:	mov  r0, 0xff				;- x iterator

		cmp  r1, scr_y_max			;- check to see if y is at max
		breq drawn					;- if so finish

		add  r1, 0x01				;- increment y
loop:	add  r0, 0x01				;- increment x

		out  r0, vga_col_port
		out  r1, vga_row_port

		;- figure out what to draw --------------------------

		call chk_player				;- check if coordinate is player
		cmp  r2, 0xff
		breq d_plyr					;- if so draw player

		call chk_floor				;- check if coordinate is floor
		cmp  r2, 0xff
		breq d_flr					;- if so draw player

		call draw_bkgnd
		brn  coor

d_plyr:	call draw_player
		brn  coor

d_flr:	call draw_floor
		brn  coor

		;- figure out what to draw --------------------------

		;- upd coordinates
coor:	cmp  r0, scr_x_max			;- see if x coordinate max reached
		breq rst_x

		brn  loop

drawn:	ld   r0, r0_save			;- restore r0
		ld   r1, r1_save			;- restore r1
		ld   r2, r2_save			;- restore r2
		ld   r3, r3_save			;- restore r3

		ret

;- Move_left --------------------------------------------------
right_move: add r21, 0x01
		   ;add  r27, 0x01              ;- no idea what this is doing
           mov  r13, 0x01
nolmv:	   out  r13, MOVE_OUT_ID
		   out  r14, MOVE_OUT_ID
		   retie

;- Move_right --------------------------------------------------
left_move:  ;sub  r27, 0x01
			 add  r20, 0x01
             mov  r13, 0x02
normv:	     out  r13, MOVE_OUT_ID
             out  r14, MOVE_OUT_ID
		     retie

;- Move_both -------------------------------------------------- 
both_move: mov r13, 0x03
		   out  r13, MOVE_OUT_ID
           out  r14, MOVE_OUT_ID

		   retie

;- Move_error --------------------------------------------------
int_error: retie

;- ISR --------------------------------------------------
isr:    cmp  r24, 0x00				;- check if currently in start menu state
		breq g_strt

		mov  r14, 0x00
		
		IN   r12, MOVE_ID           ;- Inputs buttons to RAT MCU
		cmp  r12, 0x00
		BREQ int_error

		cmp  r12, 0x01
		BREQ right_move

		cmp  r12, 0x02
		BREQ left_move

		cmp  r12, 0x03
		breq both_move				;- no idea what this is doing

		retie

g_strt:	mov  r24, 0x01               ;- change to game state

		retie						;- return and enable interrupts

;- INTERRUPT -------------------------------------------------- -;
.org  0x3ff
		brn  isr					;- branch to isr
