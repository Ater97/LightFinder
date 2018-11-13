DATO 	EQU 0x21
NUM1	EQU 0x22
NUM2	EQU 0x23
CONT	EQU 0x24
BACK	EQU 0x25
VARDISPLAY EQU 0x26

HEAD
	ORG 0x00
	GOTO START
	
START	
	BSF 	STATUS, 5	;banco 0
	CLRF	TRISB		;salida
	CLRF	TRISC		;salida
	CLRF	TRISD		;salida
	MOVLW	B'11111111'
	MOVWF	TRISC 		;entrada
	MOVWF	TRISB		;entrada
	bcf	TRISA, 1
	bcf	TRISA, 2
	bcf	TRISA, 3
	bcf	TRISA, 4
	bcf	TRISA, 5
	bcf	TRISE, 0
	bcf	TRISE, 1
	BCF 	STATUS, RP0 

MENU:	
	BTFSC	PORTB, 0
	call	PUTNUM1
	BTFSC	PORTB, 1
	call	PUTNUM2
	BTFSC	PORTB, 2
	call	SUMA
	BTFSC	PORTB, 3
	call	RESTA
	BTFSC	PORTB, 4
	call	MULT
	BTFSC	PORTB, 5
	call	DIV
	MOVFW	PORTD
	MOVWF	VARDISPLAY
	call	SHOWVARDISPLAY
	GOTO 	MENU
	
PUTNUM1:
	MOVF	PORTC, W
	MOVWF	NUM1
	RETURN
	
PUTNUM2:
	MOVF	PORTC, W
	MOVWF	NUM2
	RETURN
	
SUMA:
	MOVF	NUM1, W
	ADDWF	NUM2, 0
	MOVWF	PORTD
	RETURN
	
RESTA:
	MOVF	NUM2, W
	SUBWF	NUM1, 0
	MOVWF	PORTD
	RETURN
	
MULT:
	MOVLW	B'00000000'
	MOVWF	BACK
	MOVF	NUM1, W
	MOVWF	CONT
MULT2:
	MOVF	NUM2, W
	ADDWF	BACK, 1
	DECFSZ	CONT, 1 ;decrement f, skip if 0
	GOTO	MULT2	
	MOVF	BACK, W
	MOVWF	PORTD
	RETURN
									
DIV:
	MOVLW	B'00000000'
	MOVWF	BACK
	MOVF	NUM1, W
	MOVWF	CONT
DIV2:	
	MOVF	NUM2, W
	SUBWF	CONT, 1
	BTFSC	STATUS, C 
	GOTO	INCDIV
	MOVF	BACK, W
	MOVWF	PORTD
	RETURN
	
INCDIV:
	INCF	BACK, 1
	GOTO	DIV2
	;result		carry zero (status)
	;positive     1		0
	;zero		  1		1
	;negative     0     0


SHOWVARDISPLAY: ;show varphotocell on display
 	movlw 0x00
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case0d

 	movlw 0x01
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case1d

	movlw 0x02
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case2d

 	movlw 0x03
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case3d

 	movlw 0x04
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case4d

	movlw 0x05
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case5d

 	movlw 0x06
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case6d

 	movlw 0x07
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case7d

 	movlw 0x08
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case8d

 	movlw 0x09
    subwf VARDISPLAY, W
    BTFSC STATUS, z
    goto  case9d	
endshow:
	RETURN

case0d
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bcf PORTE, 1
    goto	endshow
case1d
    bcf PORTA, 1
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bcf PORTE, 1
    bsf PORTA, 2
    bsf PORTA, 3
    goto	endshow
case2d
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 1
    bcf PORTA, 3
    bcf PORTE, 0
    goto	endshow
case3d
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTE, 1
    bcf PORTE, 0
    bcf PORTA, 5
    goto	endshow
case4d
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTE, 0
    bsf PORTE, 1
    bcf PORTA, 1
    bcf PORTA, 4
    bcf PORTA, 5
    goto	endshow
case5d
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTE, 0
    bsf PORTE, 1
    bsf PORTA, 1
    bcf PORTA, 5
    bcf PORTA, 2
    goto	endshow
case6d
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bsf PORTE, 1
    bsf PORTA, 1
    bcf PORTA, 2
    goto	endshow
case7d
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bcf PORTE, 1
    goto	endshow
case8d
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bsf PORTE, 1
    goto	endshow
case9d
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTE, 0
    bsf PORTE, 1
    bcf PORTA, 5
    goto	endshow