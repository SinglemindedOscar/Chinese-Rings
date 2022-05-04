;
;    Chinese Rings
;
;    Copyright 2022 SinglemindedOscar
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <https://www.gnu.org/licenses/>.
;
    PROCESSOR   16F57
    PAGEWIDTH   132
    RADIX       dec
    EXPAND
;
#include <xc.inc>
;
skipnz  MACRO
    btfsc   STATUS,STATUS_Z_POSITION
  ENDM
;
skipz  MACRO
    btfss   STATUS,STATUS_Z_POSITION
  ENDM
;
clrc  MACRO
    bcf	     STATUS, STATUS_C_POSITION
  ENDM
;
;   Set the configuration word
;
    CONFIG  OSC = HS              ; Oscillator selection bits (HS oscillator)
    CONFIG  WDT = OFF             ; Watchdog timer enable bit (WDT disabled)
    CONFIG  CP = OFF              ; Code protection bit (Code protection off)
;
;   Declare one byte in RAM
;
    PSECT   udata,delta=1
    CounterL:	   DS	    1
    CounterH:	   DS	    1	
    GrayPrevL:	   DS	    1
    GrayPrevH:	   DS	    1
    GrayNextL:	   DS	    1
    GrayNextH:	   DS	    1
    InputL:	   DS	    1
    InputH:	   DS	    1
    OutputL:	   DS	    1
    OutputH:	   DS	    1
    DelayCnt:	   DS       1
;
    PSECT   code, delta=2, class=CODE, abs
    goto    Start
;
;   Delay sub
;
Delay:
    clrf    DelayCnt
Delay1:
    incf    DelayCnt
    movf    DelayCnt,w
    goto    $ + 1
    goto    $ + 1
    goto    $ + 1
    goto    $ + 1
    goto    $ + 1
    xorlw   80H
    skipz
    goto    Delay1
    retlw   0
;
;   Main
;
Start:
    ;	Initialize GPIO
    movlw   0fdH    ; RA0 as input, RA1 as output
    tris    BANKMASK(PORTA)
    movlw   00H    ; output			  ;  
    tris    BANKMASK(PORTB)
    movlw   0ffH    ; input
    tris    BANKMASK(PORTC)
    clrw
    movwf   BANKMASK(PORTA)
    movwf   BANKMASK(PORTB)
    ;	Initialize GPIO buffer
    clrf    InputL
    clrf    InputH
    clrf    OutputL
    clrf    OutputH
    ;	Initialize counters
    clrf    CounterL
    clrf    CounterH
    movlw   0ffH
    movwf   GrayPrevL	;   0xffff
    movwf   GrayPrevH
    movlw   01H
    movwf   GrayNextL	;   0x0001
    clrf    GrayNextH
Loop:
LED:
    movf    OutputL,w
    movwf   BANKMASK(PORTB)
    btfsc   OutputH, 0
    goto    $ + 3
    bcf	    RA1
    goto    $ + 2
    bsf	    RA1
Push:
    ;   first check
    comf    BANKMASK(PORTC),w
    skipz
    goto    $ + 3
    btfsc   RA0
    goto    Loop
    call    Delay
    ;   second check
    comf    BANKMASK(PORTC),w
    skipz
    goto    $ + 3
    btfsc   RA0
    goto    Loop
    call    Delay
    ;   third check
    comf    BANKMASK(PORTC),w
    skipz
    goto    $ + 3
    btfsc   RA0
    goto    Loop
    ;   store push buttons condition to input buffer
    movwf   InputL
    clrf    InputH
    btfss   RA0
    bsf	   InputH,0
Release:
    ;   first check
    comf    BANKMASK(PORTC),w
    skipz
    goto    Release
    btfss   RA0
    goto    Release
    call    Delay
    ;   second check
    comf    BANKMASK(PORTC),w
    skipz
    goto    Release
    btfss   RA0
    goto    Release
    call    Delay
    ;   third check
    comf    BANKMASK(PORTC),w
    skipz
    goto    Release
    btfss   RA0
    goto    Release	
CountDown:
    movf    InputL,w
    xorwf   OutputL,w
    xorwf   GrayPrevL,w
    skipz
    goto    CountUp
    movf    InputH,w
    xorwf   OutputH,w
    xorwf   GrayPrevH,w
    skipz
    goto    CountUp
    ;	counter decriment
    decf    CounterL
    incfsz  CounterL,w
    goto    $ + 2
    decf    CounterH
    ;	copy to output buffer
    movf    GrayPrevL,w
    movwf   OutputL
    movf    GrayPrevH,w
    movwf   OutputH
    goto    GrayPrev
CountUp:
    movf    InputL,w
    xorwf   OutputL,w
    xorwf   GrayNextL,w
    skipz
    goto    Loop
    movf    InputH,w
    xorwf   OutputH,w
    xorwf   GrayNextH,w
    skipz
    goto    Loop
    ;	counter increment
    incfsz  CounterL
    goto    $ + 2
    incf    CounterH
    ;	copy to output buffer
    movf    GrayNextL,w
    movwf   OutputL
    movf    GrayNextH,w
    movwf   OutputH
GrayPrev:
    movf    CounterL,w	    ; Counter lower limit is 0000H
    skipz
    goto    GrayPrev1
    movf    CounterH,w
    skipz
    goto    GrayPrev1
    movlw   0ffH
    movwf   GrayPrevL
    movwf   GrayPrevH
    goto    GrayNext
    ;	Decliment counter
GrayPrev1:
    movf    CounterL,w	    ; Copy Counter value
    movwf   GrayPrevL
    movf    CounterH,w
    movwf   GrayPrevH
    ;	counter decriment
    decf    GrayPrevL
    incfsz  GrayPrevL,w
    goto    $ + 2
    decf    GrayPrevH
    ;	Encode to gray code
GrayPrev2:    
    clrc
    rrf	    GrayPrevH,w	    ; Rotate right
    xorwf   GrayPrevH
    rrf	    GrayPrevL,w
    xorwf   GrayPrevL
GrayNext:
    movlw   55H
    xorwf   CounterL,w	    ; Counter upper limit is 0155H (Gray code 01FFH)
    skipz
    goto    GrayNext1
    movlw   01H
    xorwf   CounterH,w
    skipz
    goto    GrayNext1
    movlw   0ffH
    movwf   GrayNextL
    movwf   GrayNextH
    goto    Loop
    ;	Set gray code (Counter value - 1)
GrayNext1:
    movf    CounterL,w	    ; Copy Counter value
    movwf   GrayNextL
    movf    CounterH,w
    movwf   GrayNextH
    ;	counter increment
    incfsz  GrayNextL
    goto    $ + 2
    incf    GrayNextH
GrayNext2:    
    clrc
    rrf	    GrayNextH,w	    ; Rotate right
    xorwf   GrayNextH
    rrf	    GrayNextL,w
    xorwf   GrayNextL
    goto    Loop
;
    PSECT   ResetVec,class=CODE,delta=2
ResetVec:
    nop
    end     ResetVec