;luobing 2007-2-8
CTRLREG  EQU  43H							;���ÿ��ƼĴ���
C0ADR    EQU  40H							;������0�˿ڵ�ַ
C1ADR    EQU  41H							;������1�˿ڵ�ַ
C2ADR    EQU  42H							;������2�˿ڵ�ַ
;���ֽ���
WAITFREG=330
WAITN=50
HalfPai=120
OnePai=2*HalfPai
TwoPai=4*HalfPai
THREEPAI=6*HalfPai
;
L_IODELAY MACRO 	DelayTime					;����ʱ����ʱ����Ϊ��λ
	PUSHA
	MOV	AX,DelayTime
	CALL	DELAY  
	POPA
  ENDM 
DELAY10MS MACRO 										;��ʱ10ms
	PUSH CX
	MOV	CX,297H
	CALL	WAITF
	POP CX
  ENDM
PlaySound MACRO FregData,TimeData
  MOV	SI,OFFSET FregData
  MOV	BP,OFFSET TimeData									
  CALL  PLAY_MUSIC
  ENDM
.MODEL SMALL
    .386
.DATA
	MUS_FREG		DW 262,262,294,262,349
							DW 330,WAITFREG,262,262,294,262
							DW 392,349,WAITFREG,262,262,523
							DW 440,349,330,WAITFREG,294,466
							DW 466,440,262,392,349,'$'
	MUS_TIME		DW 2 DUP(HalfPai),2 DUP(OnePai)
							DW TwoPai,WAITN,2 DUP(HalfPai),2 DUP(OnePai)
							DW OnePai,TwoPai,WAITN,2 DUP(HalfPai),OnePai
							DW 3 DUP(OnePai),THREEPAI,WAITN,HalfPai
							DW HalfPai,3 DUP(OnePai),TwoPai
	
	Freg_NwSel			DW 294,330,294,262,'$'
	Time_NwSel 			DW 3 DUP(OnePai),TwoPai
	Freg_UpMove     DW  330,294,'$'
	Time_UpMove     DW  HalfPai,HalfPai
	Freg_DownMove   DW  294,262,'$'
	Time_DownMove   DW  HalfPai,HalfPai
	Freg_Enter      DW  392,349,'$'
	Time_Enter      DW  OnePai,TwoPai
	Mus1_FREG	      DW 330,294,262,294,3 DUP(330)
						      DW 3 DUP(294),330,392,392
						      DW 330,294,262,294,4 DUP(330)
						      DW 294,294,330,294,262,'$'
	Mus1_TIME       DW 6 DUP(HalfPai),ONEPAI
						      DW 2 DUP(HalfPai,HalfPai,ONEPAI)
						      DW 12 DUP(HalfPai),TwoPai
;=======================================================
.STACK
	            DW 'OL'
	MYSTACK	    DW 20 DUP (0) 
	MYSTACKEND  DW 'OL'
;========================================================
.CODE 			 
START:
	MOV	AX,@DATA
	MOV	DS,AX
	MOV	AX,@STACK
	MOV	SS,AX
	MOV	AX,OFFSET MYSTACKEND
	MOV	SP,AX
	;
	PUSH	DS
	POP	ES
	;PlaySound Mus1_FREG,Mus1_TIME
	;xor ax,ax
	;int 16h
	PlaySound Freg_NwSel,Time_NwSel
	;xor ax,ax
	;int 16h
	;PlaySound Freg_UpMove,Time_UpMove
	;xor ax,ax
	;int 16h
	;PlaySound Freg_DownMove,Time_DownMove
	;xor ax,ax
	;int 16h
	;PlaySound Freg_Enter,Time_Enter
	;xor ax,ax
	;int 16h
	MOV	AX,4C00H
	INT	21H
;;
;*********************************************************;
;*�ӳ�������	PLAY_MUSIC													    	 **
;*���ܣ�			����																	     **
;*��ڲ�����	DS:SI Ƶ������ƫַ							     			 **
;*���ڲ�����																				     **
;*ע�⣺																								 **
;*********************************************************;	
PLAY_MUSIC PROC NEAR 	
  PUSHA
PLAYMUS:
	MOV	DI,[SI]
	CMP	DI,'$'
	JE	PMus_END_PLAY
	MOV	BX,DS:[BP]
	CALL	GENSOUND
	ADD	SI,2
	ADD	BP,2
	JMP	PLAYMUS
PMus_END_PLAY:
  POPA
	RET
PLAY_MUSIC ENDP
;*********************************************************;
;*�ӳ�������	GENSOUND														    	 **
;*���ܣ�			ͨ�÷�������													     **
;*��ڲ�����	DI:Ƶ��  BX ����ʱ�� 10ms����ֵ     			 **
;*���ڲ�����																				     **
;*ע�⣺																								 **
;*********************************************************;	
GENSOUND PROC NEAR
  PUSHA
  MOV	AL,0B6H									;Init timer2
  OUT	CTRLREG,AL
  MOV	DX,12H									;Timer divisor
  MOV	AX,348CH								;1193100HZ/Freq
  DIV DI
  OUT	C2ADR,AL 								;write timer2 low byte
  MOV	AL,AH
  OUT C2ADR,AL 								;write timer2 high byte
  IN	AL,61H
  MOV	AH,AL
  OR AL,03H
  OUT	61H,AL 									;turn speaker on
GS_WAIT1:
	;MOV	CX,2800
	;L_IODELAY 10
;GS_DELAY:
	;LOOP	GS_DELAY							;��ʱbx*10ms
	DELAY10MS
	DEC	BX
	JNZ	GS_WAIT1
	MOV	AL,AH
	OUT	61H,AL
 POPA
  RET
GENSOUND ENDP
	

;*********************************************************;
;*�ӳ�������	DELAY 															    	 **
;*���ܣ�			��ʱ																	     **
;*��ڲ�����	ax = delay time in milliseconds     			 **
;*���ڲ�����																				     **
;*��ע��		����int15������ʱ														 **
;*********************************************************;	
DELAY      PROC NEAR
					 PUSH CX
					 PUSH DX
           MOV  DX,1000                 ; MULTIPLY BY 1000 (CONVERT TO MICRO)
           MUL  DX                      ; DX:AX = TIME IN MICROSECONDS
           XCHG AX,DX                   ; CX:DX = TIME
           XCHG AX,CX                   ;
           MOV  AH,86H                  ; BIOS DELAY SERVICE
           INT  15H                     ;
           POP DX
           POP CX
           RET                          ;
DELAY      ENDP    	
;*********************************************************;
;*�ӳ�������	WAITF 															    	 **
;*���ܣ�			��ʱ																	     **
;*��ڲ�����	CX = 15.08us �ı���							     			 **
;*���ڲ�����																				     **
;*��ע��		IBM PC 61h��PB4ÿ15.08us����һ��						 **
;*********************************************************;	
WAITF PROC NEAR
	PUSH AX
WAITF1:
	IN	AL,61H
	AND AL,10H
	CMP	AL,AH
	JE	WAITF1
	MOV	AH,AL
	LOOP	WAITF1
	POP	AX
	RET
WAITF ENDP

;;
;;
END START