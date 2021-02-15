;******************************************************************************
; 
;  Author:  Joseph Morales
;  Last Modified On: 27 May 2020
;  lab2_3_2.asm
;
; *****************************************************************************
.include "ATxmega128a1udef.inc"
;******************************END OF INCLUDES*********************************
.equ stackInit = 0x3FFF
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

ldi r16, 0x12
sts TCC0_PER, r16
ldi r16, 0x7A
sts TCC0_PER+1, r16

ldi r16, TC_CLKSEL_DIV64_gc 
sts TCC0_CTRLA, r16

ldi r16, 0xFF ;1111 1111
sts PORTC_DIRSET, r16

ldi r17, 1
ldi r20, 0
PROGRAM:
cpi r20, 60
breq TIMER_RESET

	LOOP:	
	lds r18, TCC0_INTFLAGS
	sbrs r18, 0
	rjmp LOOP

	inc r20
	sts TCC0_INTFLAGS, r17	
	sts PORTC_OUTTGL, r20	
	rjmp PROGRAM

	TIMER_RESET:
	ldi r20, 0
	rjmp program