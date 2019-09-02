;模拟声音的子程序
;为foxdisk而做，简单的使用扬声器发音
;2007-3-8 luobing
;*子程序名：	PLAY_MUSIC													    	 **
;*子程序名：	GENSOUND														    	 **
;*子程序名：	DELAY 															    	 **
;*子程序名：	WAITF 															    	 **
;*********************************************************;
;*子程序名：	PLAY_MUSIC													    	 **
;*功能：			发声																	     **
;*入口参数：	DS:SI 频率数据偏址							     			 **
;*出口参数：																				     **
;*注意：																								 **
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
;*子程序名：	GENSOUND														    	 **
;*功能：			通用发声程序													     **
;*入口参数：	DI:频率  BX 持续时间 10ms倍数值     			 **
;*出口参数：																				     **
;*注意：																								 **
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
	;LOOP	GS_DELAY							;延时bx*10ms
	DELAY10MS
	DEC	BX
	JNZ	GS_WAIT1
	MOV	AL,AH
	OUT	61H,AL
 POPA
  RET
GENSOUND ENDP
	

;*********************************************************;
;*子程序名：	DELAY 															    	 **
;*功能：			延时																	     **
;*入口参数：	ax = delay time in milliseconds     			 **
;*出口参数：																				     **
;*备注：		利用int15产生延时														 **
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
;*子程序名：	WAITF 															    	 **
;*功能：			延时																	     **
;*入口参数：	CX = 15.08us 的倍数							     			 **
;*出口参数：																				     **
;*备注：		IBM PC 61h的PB4每15.08us触发一次						 **
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
;;
;;
END START