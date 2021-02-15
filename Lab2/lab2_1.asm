;******************************************************************************
;  Last Modified By: Joseph Morales
;  Last Modified On: 27 May 2020
;  
;******************************************************************************
;*********************************INCLUDES*************************************
.include "ATxmega128a1udef.inc"
;******************************END OF INCLUDES*********************************

;********************************MAIN PROGRAM**********************************
.cseg

.org 0x0
	rjmp MAIN

.org 0x100

MAIN:
;loading 1111 1111 into register set to set LEDs to outputs and switches to inputs
ldi r16, 0xFF
sts PORTA_DIRCLR, r16
sts PORTC_DIRSET, r16

LOOP:
lds r16, PORTA_IN
sts PORTC_OUT, r16
rjmp LOOP	

;*****************************END OF MAIN PROGRAM *****************************
