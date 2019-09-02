;ģ���������ӳ���
;Ϊfoxdisk�������򵥵�ʹ������������
;2007-3-8 luobing
;*�ӳ�������	PLAY_MUSIC													    	 **
;*�ӳ�������	GENSOUND														    	 **
;*�ӳ�������	DELAY 															    	 **
;*�ӳ�������	WAITF 															    	 **
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
;;
;;
END START