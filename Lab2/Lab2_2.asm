;******************************************************************************
; 
;  Author:  Joseph Morales
;  Last Modified On: 27 May 2020
;  lab2_2_1.asm
;
; *****************************************************************************
.include "ATxmega128a1udef.inc"
;******************************END OF INCLUDES*********************************
.equ stackInit = 0x3FFF
.equ delayMultiple = 5
;
;********************************MAIN PROGRAM**********************************
.cseg
; configure the reset vector 
;	(ignore meaning of "reset vector" for now)
.org 0x0
	rjmp MAIN

; place main program after interrupt vectors 
;	(ignore meaning of "interrupt vectors" for now)
.org 0x100
MAIN:
ldi r16, low(stackInit)
out CPU_SPL, r16		
ldi r16, high(stackInit)
out CPU_SPH, r16		
ldi r16, 0xFF
sts PORTC_DIRSET, r16


PROGRAM:
ldi r18, delayMultiple
sts PORTC_OUTTGL, r16
rcall DELAY_X_10MS
rjmp PROGRAM

DELAY_X_10MS:
cpi r18, 0
breq PROGRAM
rcall DELAY_10MS
dec r18
rjmp DELAY_X_10MS

DELAY_10MS:
push r16
ldi r16, 73

	LOOP:
	dec r16
	ldi r17, 70

		NESTED_LOOP:		
		dec r17
		cpi r17, 0
		brne NESTED_LOOP

	cpi r16, 0
	brne LOOP
	pop r16
ret

;*****************************END OF MAIN PROGRAM *****************************
