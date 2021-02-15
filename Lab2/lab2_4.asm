;******************************************************************************
;  File name: lab2_4.asm
;  Author: Christopher Crary
;  Last Modified By: Eric Schwartz
;  Last Modified On: 23 May 2020
;  Purpose: To allow LED animations to be created with the OOTB µPAD, 
;			OOTB SLB, and OOTB MB (or EBIBB, if a previous version of the kit
;			is used).
;
;			NOTE: The use of this file is NOT required! This file is just given
;			as an example for how to potentially write code more effectively.
;******************************************************************************

;*********************************INCLUDES*************************************

; The inclusion of the following file is REQUIRED for our course, since
; it is intended that you understand concepts regarding how to specify an 
; "include file" to an assembler. 
.include "ATxmega128a1udef.inc"
;******************************END OF INCLUDES*********************************

;******************************DEFINED SYMBOLS*********************************
.equ ANIMATION_START_ADDR	=	0x2000 ;useful, but not required
.equ ANIMATION_SIZE			=	256	;useful, but not required
.equ stackInit = 0x3FFF

;**************************END OF DEFINED SYMBOLS******************************

;******************************MEMORY CONSTANTS********************************
; data memory allocation
.dseg

.org ANIMATION_START_ADDR
ANIMATION:
.byte ANIMATION_SIZE
;***************************END OF MEMORY CONSTANTS****************************

;********************************MAIN PROGRAM**********************************
.cseg
; upon system reset, jump to main program (instead of executing
; instructions meant for interrupt vectors)
.org 0x0
	rjmp MAIN

; place the main program somewhere after interrupt vectors (ignore for now)
.org 0x0100	; >= 0xFD
MAIN:
; initialize the stack pointer
ldi r16, low(stackInit)
out CPU_SPL, r16		
ldi r16, high(stackInit)
out CPU_SPH, r16	

ldi ZL, low(ANIMATION_START_ADDR)	
ldi ZH, high(ANIMATION_START_ADDR)
;ldi r16, byte3(IN_TABLE_ADDR << 1)
;out CPU_RAMPZ, r16
ldi XL, low(ANIMATION_START_ADDR)
ldi XH, high(ANIMATION_START_ADDR)

; initialize relevant I/O modules (switches and LEDs)
	rcall IO_INIT

; initialize (but do not start) the relevant timer/counter module(s)
	rcall TC_INIT

; Initialize the X and Y indices to point to the beginning of the 
; animation table. (Although one pointer could be used to both
; store frames and playback the current animation, it is simpler
; to utilize a separate index for each of these operations.)
; Note: recognize that the animation table is in DATA memory

; begin main program loop 
	
; "EDIT" mode
EDIT:
lds r17, PORTF_IN
sbrs r17, 3 ;S2
; Check if it is intended that "PLAY" mode be started, i.e.,
; determine if the relevant switch has been pressed.
rjmp PLAY
; If it is determined that relevant switch was pressed, 
; go to "PLAY" mode.

; Otherwise, if the "PLAY" mode switch was not pressed,
; update display LEDs with the voltage values from relevant DIP switches
; and check if it is intended that a frame be stored in the animation
; (determine if this relevant switch has been pressed).
lds r25, PORTA_IN
sts PORTC_OUT, r25

sbrs r17, 2
; If the "STORE_FRAME" switch was not pressed,
; branch back to "EDIT".
rjmp TIMER0 ; debounce
; Otherwise, if it was determined that relevant switch was pressed,
; perform debouncing process, e.g., start relevant timer/counter
; and wait for it to overflow. (Write to CTRLA and loop until
; the OVFIF flag within INTFLAGS is set.)
rjmp EDIT
; After relevant timer/counter has overflowed (i.e., after
; the relevant debounce period), disable this timer/counter,
; clear the relevant timer/counter OVFIF flag,
; and then read switch value again to verify that it was
; actually pressed. If so, perform intended functionality, and
; otherwise, do not; however, in both cases, wait for switch to
; be released before jumping back to "EDIT".



; Wait for the "STORE FRAME" switch to be released
; before jumping to "EDIT".
STORE_FRAME_SWITCH_RELEASE_WAIT_LOOP:
lds r18, PORTA_IN
		WAIT:
		lds r17, PORTF_IN
		sbrs r17, 2
		rjmp WAIT
st X+, r18
rjmp EDIT
	
; "PLAY" mode
PLAY:
ldi ZL, low(ANIMATION_START_ADDR)
ldi ZH, high(ANIMATION_START_ADDR)
; Reload the relevant index to the first memory location
; within the animation table to play animation from first frame.


PLAY_LOOP:
lds r17, PORTF_IN
sbrs r17, 2
; Check if it is intended that "EDIT" mode be started
; i.e., check if the relevant switch has been pressed.`
rjmp EDIT
; If it is determined that relevant switch was pressed, 
; go to "EDIT" mode.
ld r22, Z+
;ld r23, X
sts PORTC_OUT, r22
cp ZL, XL
breq PLAY
rjmp TIMER1


; Otherwise, if the "EDIT" mode switch was not pressed,
; determine if index used to load frames has the same
; address as the index used to store frames, i.e., if the end
; of the animation has been reached during playback.
; (Placing this check here will allow animations of all sizes,
; including zero, to playback properly.)
; To efficiently determine if these index values are equal,
; a combination of the "CP" and "CPC" instructions is recommended.


; If index values are equal, branch back to "PLAY" to
; restart the animation.


; Otherwise, load animation frame from table, 
; display this "frame" on the relevant LEDs,
; start relevant timer/counter,
; wait until this timer/counter overflows (to more or less
; achieve the "frame rate"), and then after the overflow,
; stop the timer/counter,
; clear the relevant OVFIF flag,
; and then jump back to "PLAY_LOOP".


; end of program (never reached)
DONE: 
	rjmp DONE
;*****************************END OF MAIN PROGRAM *****************************

;********************************SUBROUTINES***********************************

;******************************************************************************
; Name: IO_INIT 
; Purpose: To initialize the relevant input/output modules, as pertains to the
;		   application.
; Input(s): N/A
; Output: N/A
;******************************************************************************
IO_INIT:
ldi r16, 0xFF
; protect relevant registers

; initialize the relevant I/O
sts PORTC_DIRSET, r16
sts PORTA_DIRCLR, r16
ldi r16, 0x0C
sts PORTF_DIRCLR, r16

; recover relevant registers
	
; return from subroutine
	ret
;******************************************************************************
; Name: TC_INIT 
; Purpose: To initialize the relevant timer/counter modules, as pertains to
;		   application.
; Input(s): N/A
; Output: N/A
;******************************************************************************
TC_INIT:
; protect relevant registers

; initialize the relevant TC modules
ldi r16, 0x12
sts TCC0_PER, r16
ldi r16, 0x7A
sts TCC0_PER+1, r16

ldi r16, 0x40
sts TCC1_PER, r16
ldi r16, 0xC8
sts TCC1_PER+1, r16

;DO NOT OVERRIDE r16


	
; recover relevant registers
	
; return from subroutine
	ret

TIMER0:
ldi r17, 0x01
ldi r16, TC_CLKSEL_DIV2_gc 
sts TCC0_CTRLA, r16

	LOOP0:	
	lds r18, TCC0_INTFLAGS
	sbrs r18, 0
	rjmp LOOP0

	sts TCC0_INTFLAGS, r17	
	rjmp CHECK_1

TIMER1:
ldi r17, 0x01
ldi r16, TC_CLKSEL_DIV2_gc 
sts TCC1_CTRLA, r16

	LOOP1:	
	lds r18, TCC0_INTFLAGS
	sbrs r18, 0
	rjmp LOOP1

	sts TCC0_INTFLAGS, r17	
	rjmp PLAY_LOOP

CHECK_1:
lds r17, PORTF_IN
sbrs r17, 2
rjmp STORE_FRAME_SWITCH_RELEASE_WAIT_LOOP
rjmp EDIT	




;*****************************END OF SUBROUTINES*******************************

;*****************************END OF "lab2_4.asm"******************************