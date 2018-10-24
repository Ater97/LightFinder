
DATO  	EQU 0x21
COUNTY 	EQU 0x22
COUNTX 	EQU 0x23
LIMITY 	EQU 0x24
LIMITX 	EQU 0x25
P1	  	EQU 0x26
P2    	EQU 0x27
COUNTBETA EQU 0x28
LIMITBETA EQU 0x29

VARMAXX	EQU	0x30
VARMAXY	EQU	0x31
VARPHOTOCELL EQU 0x32
TMPCELL EQU 0x33
TMPY    EQU 0x34
TMPX    EQU 0x35
TMPBETA EQU 0x36
VARMAXBETA  EQU 0x37
LIMITMAXX   EQU 0x38
LIMITMAXY   EQU 0x39
LIMITMAXBETA EQU 0x40

varA    EQU 0x41
varB    EQU 0x42
varC    EQU 0x43
VARDISPLAY  EQU 0x44
cont    EQU 0x45 
ADC     EQU 0x46
CON     EQU 0X47
CON2    EQU 0X48
CON3    EQU 0X49
GROUPNUMBER	EQU 0x50

waffles EQU 0x51
CounterC EQU 0X52
CounterB EQU 0X53
CounterA EQU 0X54
INICIO

	ORG		0x00
	GOTO	START

START
	;1 = in        0  = out
	;BIT SET FILE
	BSF 	STATUS, 5; COLOCAMOS EN S EL BIT 5 DE REG. ESTATUS
	CLRF	TRISB
	CLRF	TRISD   
	                    ;BIT CLEARE FILE
	BCF		STATUS, RP0 ;TODOS LOS PINES DE B SON SALIDAS

	MOVLW	0x00
	MOVWF 	PORTB  ; SET 0 TO ALL PORTS B
	MOVLW	0x00
	MOVWF 	PORTD  ; SET 0 TO ALL PORTS B
	MOVLW 	0xE6        ;NUMBER OF MOVES/STOPS IN Y, E6h = 230d
	MOVWF 	LIMITY 
	MOVLW 	0x20        ;NUMBER OF MOVES IN X
	MOVWF 	LIMITX 
	MOVLW	0x10	    ;NUMBER OF STOPS IN X, 10h = 16d
	MOVWF	LIMITBETA
	call 	CLEANY      ;SET COUNTERS TO 0
	call 	CLEANX
	call 	CLEANBETA
	MOVLW	0x00
	MOVWF	VARPHOTOCELL
;------------------------------------------------------------------------------
                ;CONFIGURATION FOR THE PHOTOCELL 
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
;--------------------------------------------------------------------
;--------------------------------------------------------------------
						;MAIN
MAIN:
    call    SEARCH      ;SEARCH BEST POINT
    call    MOVEGREATER ;GO TO BEST POINT
WAIT:   
    ;DO STUFF
    ;BTFSS	BUTTON
    GOTO    WAIT
    call    RESTART      ;RETURN TO ORIGINAL POSITION & CLEAN EVERYTHING
    GOTO    MAIN
    GOTO    END
SEARCH:
	call	LOOPX ; MOVE X AND Y
	INCF	COUNTBETA,1
	MOVF	LIMITBETA, W	
	SUBWF	COUNTBETA, w
	BTFSS	STATUS,Z
	GOTO	SEARCH
	call	CLEANBETA   ;CLEAN COUNTBETA
	call 	LOOPBETAREVERSE    ;RETURN TO ORIGINAL POSITION
    RETURN

;------------------------------------------------------------------
                        ;MOVE TO GREATER
MOVEGREATER:
	call	LOOPXMAX ; MOVE X 
	INCF	COUNTBETA,1
	MOVF	LIMITMAXBETA, W	
	SUBWF	COUNTBETA, w
	BTFSS	STATUS,Z
	GOTO	MOVEGREATER
    call	LOOPYMAX ; MOVE Y
    call	CLEANBETA
    RETURN

RESTART:
    call    LOOPMAXBETAREVERSE
    call 	LOOPYREVERSEMAX
    RETURN

LOOPMAXBETAREVERSE:
	call 	LOOPXREVERSEMAX
	
	INCF	COUNTBETA,1
	MOVF	LIMITMAXBETA, W	
	SUBWF	COUNTBETA, w
	BTFSS	STATUS,Z
	GOTO	LOOPMAXBETAREVERSE
    RETURN

LOOPXMAX:
	call 	EJEX

	;MOVE ON X
    INCF    COUNTX,1    
	MOVF  	LIMITMAXX, w
	SUBWF 	COUNTX,w
	BTFSS 	STATUS,Z ;CHECK COUNT < limitx
	GOTO 	LOOPXMAX	; JUMP IF COUNT !=  limitx
	
	call 	CLEANX
	RETURN

LOOPYMAX:
	call 	EJEY
	;MOVE ON Y
    INCF    COUNTY,1 ;count++
	MOVF  	LIMITMAXY, w
	SUBWF 	COUNTY,w
	BTFSS 	STATUS,Z ;CHECK COUNT < limity
	GOTO 	LOOPYMAX	; JUMP IF COUNT !=  limity
	;RESET  countY
	call 	CLEANY
	return


LOOPYREVERSEMAX:
	call 	REVERSEEJEY
    INCF    COUNTY,1
	MOVF  	LIMITMAXY, w
	SUBWF 	COUNTY,w
	BTFSS 	STATUS,Z ;CHECK COUNT <32
	GOTO 	LOOPYREVERSEMAX
	call 	CLEANY
	RETURN

LOOPXREVERSEMAX:
	call 	REVERSEEJEX
    INCF    COUNTX,1
	
	MOVF  	LIMITMAXX, w
	SUBWF 	COUNTX,w
	BTFSS 	STATUS,Z ;CHECK COUNT <32
	GOTO 	LOOPXREVERSEMAX
	call 	CLEANX
	RETURN

;-------------------------------------------------------------------
;                   Photocell comparation
;COMPARE:
	;goto 	GET_PHOTOCELL
    ;TMPCELL = READ PHOTOCELL INF.
    ;ASIGNAR A TMPCELL EL NUMERO EN LA ESCALA DE LUZ (0-9)

	;result		carry zero (status)
	;positive     1		0
	;zero		  1		1
	;negative     0     0
COMPARE:
    MOVF    VARPHOTOCELL,W
    SUBWF   TMPCELL, W ; W = VARPHOTOVELL - TMPCELL 
    BTFSS   STATUS, C   ;IF VARPHOTOCELL < TMPCELL ; c=0 if negative
    call    CHANGEPHOTOCELL   
	goto 	DimeElGordito 
    ;return

CHANGEPHOTOCELL:
    MOVLW   TMPCELL
    MOVWF   VARPHOTOCELL  ;PHOTOCELL =  TMPCELL
    MOVLW   TMPY
    MOVWF   VARMAXY     ;VARMAXY = TMPY
    MOVLW   TMPX
    MOVWF   VARMAXX     ;VARMAXX = TMPX
    MOVLW   TMPBETA
    MOVWF   VARMAXBETA  ;VARMAXBETA = TMPBETA
    return 

;---------------------------------------------------------------------
;                       LOOPS
LOOPBETAREVERSE:
	call 	LOOPXREVERSE
	
	INCF	COUNTBETA,1
	MOVF	LIMITBETA, W	
	SUBWF	COUNTBETA, w
	BTFSS	STATUS,Z
	GOTO	LOOPBETAREVERSE
	RETURN

LOOPX: ; LOOP i <= LIMITX
	call 	EJEX

	;MOVE ON X
    INCF    COUNTX,1
	MOVF  	LIMITX, w
	SUBWF 	COUNTX,w
	BTFSS 	STATUS,Z ;CHECK COUNT < limitx
	GOTO 	LOOPX	; JUMP IF COUNT !=  limitx
	call	LOOPY ; MOVE Y

	call 	CLEANX
	RETURN

LOOPY: ;LOOP i <= LIMITY
	call 	EJEY
	;INSERT LOGIC COMPARE VALUE OF PHOTOCELL & SAVE IT
    ;maybe add a delay here \o/
    ;call    COMPARE
	goto 	GET_PHOTOCELL
DimeElGordito:

	;MOVE ON Y
    INCF    COUNTY,1
	MOVF  	LIMITY, w
	SUBWF 	COUNTY,w
	BTFSS 	STATUS,Z ;CHECK COUNT < limity
	GOTO 	LOOPY	; JUMP IF COUNT !=  limity
	;RESET Y
	call 	CLEANY
	call 	LOOPYREVERSE
	return

LOOPYREVERSE:
	call 	REVERSEEJEY
    INCF    COUNTY,1
	MOVF  	LIMITY, w
	SUBWF 	COUNTY,w
	BTFSS 	STATUS,Z ;CHECK COUNT <32
	GOTO 	LOOPYREVERSE
	call 	CLEANY
	RETURN

LOOPXREVERSE:
	call 	REVERSEEJEX
    INCF    COUNTX,1
	MOVF  	LIMITX, w
	SUBWF 	COUNTX,w
	BTFSS 	STATUS,Z ;CHECK COUNT <32
	GOTO 	LOOPXREVERSE
	call 	CLEANX
	RETURN
;-------------------------------------------------------------------
;						DELAYS
Delay ; = 0.0001 seconds
			;496 cycles
	movlw	0xA5
	movwf	p1
Delay_0
	decfsz	p1, f
	goto	Delay_0

			;4 cycles (including call)
	return
;-------------------------------------------------------------------
;						UTILITIES
MOVEVALUE:	
	call 	DELAY
	MOVF	DATO, W  
	MOVWF	PORTB	
	RETURN
CLEANY:
	MOVLW 	0x00  ;se asigna la literal a w (0x00)
	MOVWF 	COUNTY ;muevo w a COUNT 
	RETURN
CLEANX:
	MOVLW 	0x00  ;se asigna la literal a w (0x00)
	MOVWF 	COUNTX ;muevo w a COUNT 
	RETURN
CLEANBETA:
	MOVLW 	0x00  ;se asigna la literal a w (0x00)
	MOVWF 	COUNTBETA ;muevo w a COUNT 
	RETURN
EJEX:	
	call	MV12
	call	MV06
	call	MV03
	call	MV09
	RETURN
EJEY:	
	call	MVY12
	call	MVY6
	call	MVY3
	call	MVY9
	RETURN
REVERSEEJEY:
	;call 	DELAY
	call	MVY9
	call	MVY3
	call	MVY6
	call	MVY12
	RETURN
REVERSEEJEX:
	call  	MV09
	call	MV03
	call	MV06
	call	MV12
	RETURN

MV01:	
	MOVLW	B'00000001'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN

MV02:
	MOVLW	B'00000010'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV03:	
	MOVLW	B'00000011'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN

MV04:
	MOVLW	B'00000100'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV05:
	MOVLW	B'00000101'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV06:
	MOVLW	B'00000110'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV07:
	MOVLW	B'00000111'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV08:
	MOVLW	B'00001000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV09:
	MOVLW	B'00001001'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MV12:
	MOVLW	B'00001100'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVy0:
	MOVLW	B'00000000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY1:
	MOVLW	B'00010000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY2:
	MOVLW	B'00100000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY3:
	MOVLW	B'00110000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY4:
	MOVLW	B'01000000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY5:
	MOVLW	B'01010000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY6:
	MOVLW	B'01100000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY7:
	MOVLW	B'01110000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY8:
	MOVLW	B'10000000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY9:
	MOVLW	B'10010000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
MVY12:
	MOVLW	B'11000000'
	MOVWF	DATO
	call	MOVEVALUE
	RETURN
;-----------------------------------------------------------------
;							PHOTOCELL
GET_PHOTOCELL:
_bucle:
	;btfss INTCON,T0IF
	;goto _bucle ;Esperar que el timer0 desborde
	; SE DEBE DE COLOCAR UN DELAY PARA QUE ESPERE LA CONVERSION
	BSF  STATUS,Z
	CALL _PRESPERA
	bcf INTCON,T0IF ;Limpiar el indicador de desborde
	bsf ADCON0,GO ;Comenzar conversion A/D
_espera:
	btfsc ADCON0,GO ;ADCON0 es 0? (la conversion esta completa?)
	goto _espera ;No, ir _espera
	movf ADRESH,W ;Si, W=ADRESH
	; 1Eh ADRESH A/D Result Register High Byte
	; 9Eh ADRESL A/D Result Register Low Byte 
	movwf ADC ;ADC=W
	movfw ADC ;W = ADC
    	goto  V1
returnExec:
    MOVLW  	waffles ;DATO of Photocell
    MOVWF 	TMPCELL
	goto COMPARE

V1:
    movlw D'210'
    subwf ADC, W
    btfss STATUS, C
    goto V2
    movlw 0x0
    movwf waffles
    call case0
    goto returnExec

V2:
    movlw D'194'
    subwf ADC, W
    btfss STATUS, C
    goto V3
    movlw 0x1
    movwf waffles
    call case1
    goto returnExec

V3:
    movlw D'174'
    subwf ADC, W
    btfss STATUS, C
    goto V4
    movlw 0x2
    movwf waffles
    call case2
    goto returnExec

V4:
    movlw D'158'
    subwf ADC, W
    btfss STATUS, C
    goto V5
    movlw 0x3
    movwf waffles
    call case3
    goto returnExec

V5:
    movlw D'138'
    subwf ADC, W
    btfss STATUS, C
    goto V6
    movlw 0x4
    movwf waffles
    call case4
    goto returnExec

V6:
    movlw D'117'
    subwf ADC, W
    btfss STATUS, C
    goto V7
    movlw 0x5
    movwf waffles
    call case5
    goto returnExec

V7:
    movlw D'82'
    subwf ADC, W
    btfss STATUS, C
    goto V8
    movlw 0x6
    movwf waffles
    call case6
    goto returnExec

V8:
    movlw D'51'
    subwf ADC, W
    btfss STATUS, C
    goto V9
    movlw 0x7
    movwf waffles
    call case7
    goto returnExec

V9:
    movlw D'28'
    subwf ADC, W
    btfss STATUS, C
    goto V10
    movlw 0x8
    movwf waffles
    call case8
    goto returnExec

V10:
    ; movlw D'0'
    ; subwf ADC, W
    ; btfss STATUS, N
    ; goto V10<--
    ;btfsc STATUS, C
    movlw 0x9
    movwf waffles
    call case9
    goto returnExec

_PRESPERA:
	MOVLW 0XFF
	MOVWF CounterA
	MOVWF COUNTERb
	MOVWF COUNTERc	
	CALL ESPE
	RETURN	
	
ESPE:
	DECFSZ	CounterA,0X01
	GOTO	ESPE
	CALL	ESPE2
	RETURN
ESPE2:
	DECFSZ	COUNTERb,0X01
	GOTO	ESPE2
	CALL	ESPE3
	RETURN
ESPE3:
	DECFSZ	COUNTERc,0X01
	GOTO	ESPE3
	RETURN	

case0
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bcf PORTE, 1
    return 
case1
    ;movlw 0x0
    bcf PORTA, 1
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bcf PORTE, 1
    ;movlw 0x1
    bsf PORTA, 2
    bsf PORTA, 3
    return
case2
    ;movlw 0x1
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 1
    ;movlw 0x0
    bcf PORTA, 3
    bcf PORTE, 0
    return
case3
    ;movlw 0x1
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTE, 1
    ;movlw 0x0
    bcf PORTE, 0
    bcf PORTA, 5
    return
case4
    ;movlw 0x1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTE, 0
    bsf PORTE, 1
    ;movlw 0x0
    bcf PORTA, 1
    bcf PORTA, 4
    bcf PORTA, 5
    return
case5
    ;movlw 0x1
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTE, 0
    bsf PORTE, 1
    bsf PORTA, 1
    ;movlw 0x0
    bcf PORTA, 5
    bcf PORTA, 2
    return
case6
    ;movlw 0x1
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bsf PORTE, 1
    bsf PORTA, 1
    ;movlw 0x0
    bcf PORTA, 2
    return
case7
    ;movlw 0x1
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    ;movlw 0x0
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTE, 0
    bcf PORTE, 1
    return
case8
    ;movlw 0x1
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTA, 5
    bsf PORTE, 0
    bsf PORTE, 1
    return
case9
    ;movlw 0x1
    bsf PORTA, 1
    bsf PORTA, 2
    bsf PORTA, 3
    bsf PORTA, 4
    bsf PORTE, 0
    bsf PORTE, 1
    ;movlw 0x0
    bcf PORTA, 5
    return

END