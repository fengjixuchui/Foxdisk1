;��ɫ������ѡ��
;-------------------------------------------------------------
;*�ӳ�������	MatchCMangment												**
;*�ӳ�������	MatchCM_DIS														**
;*�ӳ�������	MatchCM_DO														**
;*�ӳ�������	MatchCM_SaveConf											**
;-------------------------------------------------------------
;****************************************************;
;*�ӳ�������	MatchCMangment												**
;*���ܣ�			��ɫ��������													**
;*��ڲ�����													              **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
MatchCMangment PROC NEAR
  PUSHA 
  CALL MatchCM_DIS
  ;
MCM_GET_NEW_Sol:
	MOV	AX,OFFSET STR_MCM_SelNo
  PUSH AX
  CALL	STRLEN
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,MCM_SelSol_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],MCM_SelSol_Y
  ;����û��ϴε�����
   MOV	CL,2
MCM_CLR_PRE_USERIN:
	DEC CL
  MOV	AX,PM_WND_BK_COLOR
  PUSH AX
  MOV	AX,0FFH
  PUSH AX
  MOV	AX,YCUR
  PUSH AX
  MOV	AL,CHARWIDTH
  MUL	CL
 	ADD	AX,XCUR
  PUSH AX
  CALL	PUTASCII
  ADD	SP,8
  CMP	CL,0
  JNZ	MCM_CLR_PRE_USERIN
  ;�����
  MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	;��ȡ�û����루��ʼ�ŵ���
	MOV	AX,1
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2 										;ƽ���ջ
	MOV	AL,STD_BUF_COUNT
	CMP	AL,0 										;������
	JZ MCM_GET_NEW_Sol
	;��ʼ�ж��û�������					;31H,32H,33H
	MOV	AL,DS:[STD_BUF]
  CMP	AL,31H		
  JZ	MCM_USER_SEL_SOL				;��ɫ����1
  CMP	AL,32H
  JZ	MCM_USER_SEL_SOL				;��ɫ����1
  CMP	AL,33H
  JZ	MCM_USER_SEL_SOL				;��ɫ����3
  JMP	MCM_GET_NEW_Sol	
MCM_USER_SEL_SOL:							;��ɫ��������
	CALL MatchCM_DO	
	;�ṩȷ��ѡ��
	;RE SET
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_RE_SET
	PUSH AX
	MOV	AX,MCM_RE_SET_Y
	PUSH AX
	MOV	AX,MCM_RE_SET_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_ACCEPT
	PUSH AX
	MOV	AX,MCM_ACCEPT_Y
	PUSH AX
	MOV	AX,MCM_ACCEPT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	;��ȡ�û������룬(ȷ����������)����ʾ
	MOV	DS:[MCM_BUT_SEL	],1			;��ǰ��ѡ���� 1 (1 Set OK  2 Re Set)
MCM_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;ȷ�ϼ�(Enter)
	JZ	MCM_SEL_ENTER
	CMP	AX,4800H
	JZ	MCM_UPSEL
	CMP	AX,5000H
	JZ	MCM_DOWNSEL
	JMP	MCM_GET_USEIN
MCM_SEL_ENTER:
	PlaySound Freg_Enter,Time_Enter
	MOV	DL,MCM_BUT_SEL	
	CMP	DL,1
	JZ	MatchCM_EXIT
	CMP	DL,2
	JZ	MCM_GET_NEW_Sol
	JMP	MCM_SEL_ENTER
MCM_UPSEL:
	PlaySound Freg_UpMove,Time_UpMove
	MOV	DL,MCM_BUT_SEL	
	CMP	DL,1 						;�������Ƴ���
	JZ	MCM_DLEQU1				;DL=1����
	DEC	DL
	MOV	DS:[MCM_BUT_SEL	],DL
	JMP	MCM_DIS_SELFRAME
MCM_DLEQU1:
	MOV	DS:[MCM_BUT_SEL	],2	
	JMP	MCM_DIS_SELFRAME
MCM_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,MCM_BUT_SEL	
	CMP	DL,2						;�������Ƴ���
	JZ	MCM_DLEQU2				;DL=2����
	INC	DL
	MOV	DS:[MCM_BUT_SEL	],DL
	JMP	MCM_DIS_SELFRAME
MCM_DLEQU2:
	MOV	DS:[MCM_BUT_SEL	],1	
	JMP	MCM_DIS_SELFRAME
MCM_DIS_SELFRAME:
	MOV	DL,MCM_BUT_SEL	
	CMP	DL,1
	JZ	MCM_DISSEL1	
	CMP	DL,2
	JZ	MCM_DISSEL2
	JMP	MCM_DIS_SELFRAME
MCM_DISSEL1:
	;RE SET
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_RE_SET
	PUSH AX
	MOV	AX,MCM_RE_SET_Y
	PUSH AX
	MOV	AX,MCM_RE_SET_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;SEL SET OK
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_ACCEPT
	PUSH AX
	MOV	AX,MCM_ACCEPT_Y
	PUSH AX
	MOV	AX,MCM_ACCEPT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	MCM_GET_USEIN
MCM_DISSEL2:
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_ACCEPT
	PUSH AX
	MOV	AX,MCM_ACCEPT_Y
	PUSH AX
	MOV	AX,MCM_ACCEPT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_RE_SET
	PUSH AX
	MOV	AX,MCM_RE_SET_Y
	PUSH AX
	MOV	AX,MCM_RE_SET_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	MCM_GET_USEIN
MatchCM_EXIT:
	;дӲ��startsector+4,��������
	CALL MATCHCM_SAVECONF
	
	;�����������������ʾ
	MOV AX,BackGround_COLOR
	PUSH AX
	MOV	AX,FRAME_BOTTOM						;BOTTOM
	PUSH	AX
	MOV	AX,FRAME_RIGHT						;RIGHT
	PUSH	AX
	MOV	AX,FRAME_TOP						;TOP
	PUSH	AX
	MOV	AX,FRAME_LEFT						;LEFT
	PUSH	AX
	CALL FILLRECT
	ADD SP,10
  POPA
  RET
MatchCMangment ENDP
;****************************************************;
;*�ӳ�������	MatchCM_DIS														**
;*���ܣ�			�����������													**
;*��ڲ�����													              **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
MatchCM_DIS PROC NEAR
  PUSHA
  ;
  ;���ô��ڼ�������
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_MCM_Caption			;���ñ���
	PUSH	DX
	MOV	AX,PM_WND_BK_COLOR
	PUSH	AX
	MOV	AX,FRAME_BOTTOM						;BOTTOM
	PUSH	AX
	MOV	AX,FRAME_RIGHT						;RIGHT
	PUSH	AX
	MOV	AX,FRAME_TOP						;TOP
	PUSH	AX
	MOV	AX,FRAME_LEFT						;LEFT
	PUSH	AX
	CALL	PUTWINDOW
	ADD	SP,14
	;����������ť
	;ACCEPT
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_ACCEPT
	PUSH AX
	MOV	AX,MCM_ACCEPT_Y
	PUSH AX
	MOV	AX,MCM_ACCEPT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	;RE SET
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_RE_SET
	PUSH AX
	MOV	AX,MCM_RE_SET_Y
	PUSH AX
	MOV	AX,MCM_RE_SET_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;
	;��ʾ��ǰѡ����ɫ�������ַ���
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_SelNo	
	PUSH AX
	MOV	AX,MCM_SelSol_Y
	PUSH AX
	MOV	AX,MCM_SelSol_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_Solution1
	PUSH AX
	MOV	AX,MCM_SelSol_Y+2*CHARHEIGHT
	PUSH AX
	MOV	AX,MCM_SelSol_X+2*CHARWIDTH
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_Solution2
	PUSH AX
	MOV	AX,MCM_SelSol_Y+3*CHARHEIGHT
	PUSH AX
	MOV	AX,MCM_SelSol_X+2*CHARWIDTH
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MCM_Solution3
	PUSH AX
	MOV	AX,MCM_SelSol_Y+4*CHARHEIGHT
	PUSH AX
	MOV	AX,MCM_SelSol_X+2*CHARWIDTH
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
  POPA
  RET
MatchCM_DIS ENDP
;****************************************************;
;*�ӳ�������	MatchCM_DO														**
;*���ܣ�			��ɫ����ѡ���Ĵ���									**
;*��ڲ�����	AL=31H 1�ŷ��� AL��32H	1�ŷ��� ....  **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
MatchCM_DO PROC NEAR
  PUSHA
  MOV	BL,AL
  SUB	BL,31H
  MOV	DI,OFFSET BackGround_COLOR							;��λĿ�Ļ���������ɫ�洢��
  MOV	SI,OFFSET FirstMatchColors							;��λ��ʼԴ������
  ;
  MOV DX,OFFSET FirstMatchColors
  MOV	AX,OFFSET FirstMatchColorEnd
  SUB	AX,DX
  ADD	AX,2														;����Ϊλ�õ�λ
  MOV	CX,AX   												;ÿ���������û������Ĵ�С(���ܳ���255)
  MOV	AL,BL
  MUL CL
  ADD	SI,AX														;��λԴ������
  ;CX=��Ҫ���͵��ֽ���,SI Դ  DI Ŀ��
  CLD
  REP MOVSB
  MOV	BX,BackGround_COLOR
  CALL SETBACKCOLOR
  CALL MatchCM_DIS
  ;
  POPA
  RET
MatchCM_DO ENDP
;****************************************************;
;*�ӳ�������	MatchCM_SaveConf											**
;*���ܣ�			���浱ǰ�����õ�Ӳ��(STARTSECTOR+4)		**
;*��ڲ�����	FOXBUF(��ǰѡ��õķ���)						  **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
MatchCM_SaveConf PROC NEAR
  PUSHA
  ;��ȡ�ж��Ƿ�ı���
  MOV	SI,OFFSET MBRBUF 
	MOV	EBX,STARTSECTOR+4   							;foxbuf��Ӧ������
	MOV	AH,42H
	MOV	AL,1
	CALL	RdWrNSector
	PUSH DS
	POP ES
	MOV	SI,OFFSET MBRBUF
	MOV DI,OFFSET FOXBUF
	MOV	CX,512
	CALL STRNCMP
	JNC MCM_SaveC_NOTWRITE
	MOV	SI,OFFSET FOXBUF 
	MOV	EBX,STARTSECTOR+4   							;foxbuf��Ӧ������
	MOV	AH,43H
	MOV	AL,1
	CALL	RdWrNSector
MCM_SaveC_NOTWRITE:											;û�и����ã�����дӲ��
  POPA
  RET
MatchCM_SaveConf ENDP