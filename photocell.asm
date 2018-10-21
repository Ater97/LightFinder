;configuracion 
;status 
    varA    EQU 0x40
    varB    EQU 0x41
    varC    EQU 0x42
    varE    EQU 0x43
    cont    EQU 0x44 
    ADC     EQU 0x45
    CON     EQU 0X46
    CON2    EQU 0X47
    CON3    EQU 0X48
    p1	    EQU 0X49
	ORG 0x00 ;se elige en que posicion de memoria empezaremos 
	GOTO START
;CODE
START
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	movlw b'01000001' ;A/D conversion Fosc/8
	movwf ADCON0
	;     	     7     6     5    4    3    2       1 0
	; 1Fh ADCON0 ADCS1 ADCS0 CHS2 CHS1 CHS0 GO/DONE � ADON
	bsf STATUS,RP0 ;Ir banco 1
	bcf STATUS,RP1
	movlw b'00000111'
	movwf OPTION_REG ;TMR0 preescaler, 1:156
	;                7    6      5    4    3   2   1   0 
	; 81h OPTION_REG RBPU INTEDG T0CS T0SE PSA PS2 PS1 PS0
	movlw b'00001110' ;A/D Port AN0/RA0
	movwf ADCON1
	;            7    6     5 4 3     2     1     0 
	; 9Fh ADCON1 ADFM ADCS2 � � PCFG3 PCFG2 PCFG1 PCFG0
	bsf TRISA,0 ;RA0 linea de entrada para el ADC
	clrf TRISB
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	clrf PORTB ;Limpiar PORTB
    ;---------------------------------------------------
    BSF	STATUS,	5	; BIT SET FILE coloca el registro 5 del banco status en 1
	CLRF	TRISB
	MOVLW	B'00000001'	;Set 1 en los ultimos 4 bits de c
	MOVWF	TRISC
	BCF	STATUS,	5	;Limpiamos el B CON BCF. TRIS ES PARA DIRECCIONES
	MOVLW	0X00
	MOVWF	PORTB	;Movemos de L a W, y de W a F (puerto B)
	BCF	STATUS,	RP0	;Limpiamos el C CON BCF. TRIS ES PARA DIRECCIONES
	MOVLW	0X01
	MOVWF	PORTB	;Movemos de L a W, y de W a F
	;ASIGNAR VALORES A LAS VARIABLES
	MOVLW	B'00000100'
	MOVWF	varA
	MOVLW	B'00001000'
	MOVWF	varB
	MOVLW	B'00000101'
	MOVWF	varC
	MOVLW	B'00000000'
	MOVWF	varE
	MOVLW	B'00000000'
	MOVWF	cont


INIT
MENU ;Verificar si presion� el bot�n, a�adir uno al contador.
	BTFSC	PORTC,0	
	CALL	Incrementar
	;Segun el valor de contador, asignar el valor de varE e imprimir
	GOTO	SwitchCont
Incrementar ;CONT++, SI ES MAYOR A 3 SE RESETEA. =========================	
	INCF	cont,1
	BTFSC	cont,2
	CALL	ResetCont
	RETURN
ResetCont
	MOVLW	B'00000000'
	MOVWF	cont
	RETURN
SwitchCont	;Switch con el contador. casos 0,1,2,3 ========================
	BTFSC	cont,0
	GOTO	CI	;Caso Impar
	GOTO	CP	;Caso Par
CP:
	BTFSC	cont,1
	GOTO	case2	;10
	GOTO	case0	;00
CI:
	BTFSC	cont,1
	GOTO	case3	;11
	GOTO	case1	;01
case0:
	MOVFW	varA
	MOVWF	varE
	GOTO	Imprimir
case1:
	MOVFW	varB
	MOVWF	varE
	GOTO	Imprimir
case2:
	MOVFW	varC
	MOVWF	varE
	GOTO	Imprimir
case3:
	MOVLW	B'00000010'
	MOVWF	varE
	GOTO	Imprimir

Imprimir;MUESTRA EN UN DISPLAY EL VALOR DE varE =========================
	;primer bit de entrada de varE
	BTFSC	varE,0
	GOTO	IMPAR;1,3,5,7,9
	GOTO	PAR ;0,2,4,6,8
PAR ;0,2,4,6,8
	;Segundo bit de entrada de varE
	BTFSC	varE,1
	GOTO	PAR4 ;2,6
	GOTO	PAR2 ;0,4,8
	
PAR2 ;0,4,8
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	CUATRO
	GOTO	PAR3 ;0,8
	
PAR3 ;0,8
	;cuarto bit de entrada de C
	BTFSC	varE,3
	GOTO	OCHO
	GOTO	CERO
PAR4 ;2,6
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	SEIS
	GOTO	DOS
IMPAR ;1,3,5,7,9
	;Segundo bit de entrada de C
	BTFSC	varE,1
	GOTO	IMPAR4 ;3,7
	GOTO	IMPAR2 ;1,5,9
IMPAR2 ;1,5,9
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	CINCO
	GOTO	IMPAR3 ;1,9
IMPAR3 ;1,9
	;cuarto bit de entrada de C
	BTFSC	varE,3
	GOTO	NUEVE
	GOTO	UNO
IMPAR4 ;3,7
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	SIETE
	GOTO	TRES	
CERO
	MOVLW	B'00111111'
	MOVWF	PORTB
	GOTO	MENU
UNO
	MOVLW	B'00000110'
	MOVWF	PORTB
	GOTO	MENU
DOS
	MOVLW	B'01011011'
	MOVWF	PORTB
	GOTO	MENU
TRES
	MOVLW	B'01001111'
	MOVWF	PORTB
	GOTO	MENU

CUATRO
	MOVLW	B'01100110'
	MOVWF	PORTB
	GOTO	MENU
CINCO
	MOVLW	B'01101101'
	MOVWF	PORTB
	GOTO	MENU
SEIS
	MOVLW	B'01111101'
	MOVWF	PORTB
	GOTO	MENU
SIETE
	MOVLW	B'00000111'
	MOVWF	PORTB
	GOTO	MENU

OCHO	
	MOVLW	B'01111111'
	MOVWF	PORTB
	GOTO	MENU
NUEVE
	MOVLW	B'01100111'
	MOVWF	PORTB
	GOTO	MENU
