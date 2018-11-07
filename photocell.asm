ADC EQU 0x20
CounterC EQU 0X21
CounterB EQU 0X22
CounterA EQU 0X23
waffles EQU 0x24

	org 0x00 ;Inicio del programa en la posici?n cero de memoria
	nop ;Libre (uso del debugger)

_inicio
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	movlw b'01000001' ;A/D conversion Fosc/8
	movwf ADCON0
	;     	     7     6     5    4    3    2       1 0
	; 1Fh ADCON0 ADCS1 ADCS0 CHS2 CHS1 CHS0 GO/DONE ? ADON
	bsf STATUS,RP0 ;Ir banco 1
	bcf STATUS,RP1
	movlw b'00000111'
	movwf OPTION_REG ;TMR0 preescaler, 1:156
	;                7    6      5    4    3   2   1   0 
	; 81h OPTION_REG RBPU INTEDG T0CS T0SE PSA PS2 PS1 PS0
	movlw b'00001110' ;A/D Port AN0/RA0
	movwf ADCON1
	;            7    6     5 4 3     2     1     0 
	; 9Fh ADCON1 ADFM ADCS2 ? ? PCFG3 PCFG2 PCFG1 PCFG0
	bsf TRISA,0 ;RA0 linea de entrada para el ADC
    ;Port A: display output
    bcf	TRISA, 1
   	bcf	TRISA, 2
    bcf	TRISA, 3
   	bcf	TRISA, 4
    bcf	TRISA, 5
    bcf	TRISE, 0
    bcf	TRISE, 1
	clrf TRISB
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
_bucle
	;btfss INTCON,T0IF
	;goto _bucle ;Esperar que el timer0 desborde
	; SE DEBE DE COLOCAR UN DELAY PARA QUE ESPERE LA CONVERSION
	BSF  STATUS,Z
	CALL _PRESPERA
	bcf INTCON,T0IF ;Limpiar el indicador de desborde
	bsf ADCON0,GO ;Comenzar conversion A/D
_espera
	btfsc ADCON0,GO ;ADCON0 es 0? (la conversion esta completa?)
	goto _espera ;No, ir _espera
	movf ADRESH,W ;Si, W=ADRESH
	; 1Eh ADRESH A/D Result Register High Byte
	; 9Eh ADRESL A/D Result Register Low Byte 
	movwf ADC ;ADC=W
	movfw ADC ;W = ADC
    	goto  V1
returnExec
	goto wait

wait
	goto wait	

V1
    movlw D'210'
    subwf ADC, W
    btfss STATUS, C
    goto V2
    movlw 0x0
    movwf waffles
    call case0
    goto returnExec

V2
    movlw D'194'
    subwf ADC, W
    btfss STATUS, C
    goto V3
    movlw 0x1
    movwf waffles
    call case1
    goto returnExec

V3
    movlw D'174'
    subwf ADC, W
    btfss STATUS, C
    goto V4
    movlw 0x2
    movwf waffles
    call case2
    goto returnExec

V4
    movlw D'158'
    subwf ADC, W
    btfss STATUS, C
    goto V5
    movlw 0x3
    movwf waffles
    call case3
    goto returnExec

V5
    movlw D'138'
    subwf ADC, W
    btfss STATUS, C
    goto V6
    movlw 0x4
    movwf waffles
    call case4
    goto returnExec

V6
    movlw D'117'
    subwf ADC, W
    btfss STATUS, C
    goto V7
    movlw 0x5
    movwf waffles
    call case5
    goto returnExec

V7
    movlw D'82'
    subwf ADC, W
    btfss STATUS, C
    goto V8
    movlw 0x6
    movwf waffles
    call case6
    goto returnExec

V8
    movlw D'51'
    subwf ADC, W
    btfss STATUS, C
    goto V9
    movlw 0x7
    movwf waffles
    call case7
    goto returnExec

V9
    movlw D'28'
    subwf ADC, W
    btfss STATUS, C
    goto V10
    movlw 0x8
    movwf waffles
    call case8
    goto returnExec

V10
    ; movlw D'0'
    ; subwf ADC, W
    ; btfss STATUS, N
    ; goto V10<--
    ;btfsc STATUS, C
    movlw 0x9
    movwf waffles
    call case9
    goto returnExec

_PRESPERA
	MOVLW 0XFF
	MOVWF CounterA
	MOVWF COUNTERb
	MOVWF COUNTERc	
	CALL ESPE
	RETURN	
	
ESPE
	DECFSZ	CounterA,0X01
	GOTO	ESPE
	CALL	ESPE2
	RETURN
ESPE2
	DECFSZ	COUNTERb,0X01
	GOTO	ESPE2
	CALL	ESPE3
	RETURN
ESPE3
	DECFSZ	COUNTERc,0X01
	GOTO	ESPE3
	RETURN	

case0
    bcf PORTA, 1
    bcf PORTA, 2
    bcf PORTA, 3
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bsf PORTE, 1
    return 
case1
    bsf PORTA, 1
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bsf PORTE, 1
    bcf PORTA, 2
    bcf PORTA, 3
    return
case2
    bcf PORTA, 1
    bcf PORTA, 2
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 1
    bsf PORTA, 3
    bsf PORTE, 0
    return
case3
    bcf PORTA, 1
    bcf PORTA, 2
    bcf PORTA, 3
    bcf PORTA, 4
    bcf PORTE, 1
    bsf PORTE, 0
    bsf PORTA, 5
    return
case4
    bcf PORTA, 2
    bcf PORTA, 3
    bcf PORTE, 0
    bcf PORTE, 1
    bsf PORTA, 1
    bsf PORTA, 4
    bsf PORTA, 5
    return
case5
    bcf PORTA, 3
    bcf PORTA, 4
    bcf PORTE, 0
    bcf PORTE, 1
    bcf PORTA, 1
    bsf PORTA, 5
    bsf PORTA, 2
    return
case6
    bcf PORTA, 3
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bcf PORTE, 1
    bcf PORTA, 1
    bsf PORTA, 2
    return
case7
    bcf PORTA, 1
    bcf PORTA, 2
    bcf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bsf PORTE, 1
    return
case8
    bcf PORTA, 1
    bcf PORTA, 2
    bcf PORTA, 3
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bcf PORTE, 1
    return
case9
    bcf PORTA, 1
    bcf PORTA, 2
    bcf PORTA, 3
    bcf PORTA, 4
    bcf PORTE, 0
    bcf PORTE, 1
    bsf PORTA, 5
    return
