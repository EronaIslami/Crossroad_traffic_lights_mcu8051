SEKONDI EQU 35H ;ne 35H ruhet vlera e sekondit i cili zvoglohet per -1 cdo 1s

ORG 0000H
LJMP MAIN
ORG 000BH
;;Na duhet vonesa 1s,dmth cdo 1s me u dekrementu vlera ne display
DJNZ 32H,END_T0_ISR0 ;4 here hin ne interrupt dmth arrihet vonesa:4*250us=1000us=1ms
MOV 32H,#4D ;Rimbushet
CPL 78H ;E perdorim flagun qe njehere te shfaqen shifrat e para,pastaj te dyta...
LCALL DISPLAY ;Ekzekutohet cdo 1ms
DJNZ 33H, END_T0_ISR0;;Arrihet vonesa:50*1ms=50ms
MOV 33H,#50D ;Rimbushet
;kur tbohen MS_50 hin qitu, kur hin qitu i thojm ti duhet me hin HERE_20 per mu bon 1 sec, se 20* MS_50 = 1000ms = 1s
DJNZ 34H,END_T0_ISR0 ;Arrihet vonesa:20*50ms=1000ms=1s
MOV 34H,#20D ;Rimbushet
;Pra deri t ekzekutohen rreshtat e mesiperm arrihet vonesa 1s,pas 1s duhet te zvoglohet vlera ne display:
DEC SEKONDI 
;Kur kodi vjen ktu edhe nuk e bajm LJMP do te vazhdoj te pika (2)
LJMP CHECK_SECONDS

END_T0_ISR0:
LJMP END_T0_ISR ;<--- pika (2)

CHECK_SECONDS:
;Pra deri t ekzekutohen rreshtat e mesiperm arrihet vonesa 1s,pas 1s duhet te zvoglohet vlera ne display:
MOV R0,#0D ;msb
MOV R1,SEKONDI ;lsb ;vlera e sekondit dergohet ne R1 qe te pjestohet me 10
MOV R2,#10D ;pjestuesi
LCALL DIV_16BIT_BY_7BIT ;Thirret rutina per pjestim,mbetja ruhet ne R7
MOV 31H,R7 ;Mbetjen e ruajme ne shifren e dyte
MOV A,31H
MOVC A,@A+DPTR
MOV 31H,A
LCALL DIV_16BIT_BY_7BIT
MOV 30H,R7 ;Mbetjen e ruajme ne shifren e pare
MOV A,30H
MOVC A,@A+DPTR
MOV 30H,A
MOV A,SEKONDI ;Vleren e sekondit e dergojme ne A,ashtu qe te behet krahsimi:
CJNE A,#01D,CHECK_IF_ZERO 
;Ndalim dritat tjera:
CLR P1.0
CLR P1.2
CLR P1.5
CLR P1.7
CLR P3.0
CLR P3.2
CLR P3.5
CLR P3.7
;Ndezim driten e verdhe:
SETB P1.1
SETB P1.6
SETB P3.1
SETB P3.6

CHECK_IF_ZERO:
MOV A,SEKONDI ;Vleren e sekondit e dergojme ne A,ashtu qe te behet krahsimi:
CJNE A,#0D, END_T0_ISR
CPL 50H ;Flagu 50H perdoret per nderrimin e gjendjeve te semaforave ne dy raste
JB 50H,NDRYSHO_GJENDJET
SETB P1.0
SETB P1.7
SETB P3.0
SETB P3.7
CLR P1.2
CLR P1.5
CLR P3.2
CLR P3.5
;Ndalim dritat e verdha:
CLR P1.1
CLR P1.6
CLR P3.1
CLR P3.6

SJMP NDRYSHO

NDRYSHO_GJENDJET:
SETB P1.2
SETB P1.5
SETB P3.2
SETB P3.5
CLR P1.0
CLR P1.7
CLR P3.0
CLR P3.7
;Ndalim dritat e verdha:
CLR P1.1
CLR P1.6
CLR P3.1
CLR P3.6

NDRYSHO:
MOV SEKONDI,#30D ;Rimbushet me 30

END_T0_ISR:
RETI

MAIN:
MOV IE,#82H
MOV TMOD,#02H
MOV TH0,#6D ;Cdo 250 us hyn ne interrupt
MOV TL0,#6D
SETB TR0

MOV 32H,#4D
MOV 33H,#50D
MOV 34H,#20D
MOV SEKONDI,#30D

MOV DPTR,#DIGITS
MOV 30H,#4FH ;Shifra e pare 3
MOV 31H,#3FH ;Shifra e dyte  0

SETB P1.0
CLR P1.1
CLR P1.2
CLR P1.5
CLR P1.6
SETB P1.7
SETB P3.0
CLR P3.1
CLR P3.2
CLR P3.5
CLR P3.6
SETB P3.7

SJMP $ 

;rutina i merr numrat si kode te 7seg nga regjistrat 30H dhe 31H
;ne 30H ruhet shifra e pare,ndersa ne 31H shifra e dyte
DISPLAY: ;Heren e pare kur hyn ne interrupt njehere lshohen shifrat e para,pastaj kur hyn heren tjeter lshohen te 
;dytat,pastaj heren tjeter te parat,pastaj heren tjeter te dytat....
;Ashtu qe njehere te lshohen te parat,njehere te dytat ... mundemi permes nje flagu 78H te regjistrit 2F
MOV P2,#0FFH ;i ndal krejt 7seg
JB 78H, SHIFRAT_DYTA
;Nese 78H=0 atehere dergohen shifrat e para:

MOV P0,30H;Dergohet shifra e pare
;I bon ON katodat per shifrat e para:
CLR P2.0
CLR P2.2
CLR P2.4
CLR P2.6
;Ose MOV P2,#10101010B ose MOV P2,#0AAH
;---------------------------------------------------
SJMP END_DISPLAY

SHIFRAT_DYTA:
;---------------------------------------------------

MOV P0,31H ;E dergon shifren e dyte
;I bon ON katodat per shifrat e dyta:
CLR P2.1
CLR P2.3
CLR P2.5
CLR P2.7
;Ose MOV P2,#55H
;---------------------------------------------------
END_DISPLAY:
RET

;----------------DIV_16bit_by_7bit_subroutine---------------------
DIV_16BIT_BY_7BIT:
MOV R5,#0D ;ai gabimi qe ke at dit, se se pasna permirsu
MOV R3,#17D ;rotate bits 17 times
TRY_TO_DIVIDE:
LCALL ROTATE_16BITS 
MOV A,R5
CJNE A,02H, NOT_EQUAL
MOV R5,#00H
SETB C
SJMP END_DIVISION
NOT_EQUAL:
JB CY, LESS_THAN_DIVISOR  ;(A) < direct CY = 1
CLR C
MOV A,R5
SUBB A,R2
MOV R5,A
SETB C
SJMP END_DIVISION
LESS_THAN_DIVISOR:
CLR C
END_DIVISION:
DJNZ R3,TRY_TO_DIVIDE
MOV R5,#00H
CLR C
RET


ROTATE_16BITS:
PUSH PSW ;store the CY
;must store the remainder before the last rotation of bits
;otherwise the remainder is lost
CJNE R3,#01D, DONT_STORE_REMAINDER ; while comparing deletes the CY flag
MOV A,R5 ;store remainder
MOV R7,A
DONT_STORE_REMAINDER:

POP PSW ;pop the CY

MOV A,R1
RLC A
MOV R1,A

MOV A,R0
RLC A
MOV R0,A

MOV A,R5
RLC A
MOV R5,A

MOV A,R4
RLC A
MOV R4,A
RET

DIGITS: DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH

END 