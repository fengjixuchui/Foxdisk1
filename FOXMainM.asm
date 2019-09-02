;������ϵͳ
;�ṩ����boundary������������������ɫ����ѡ��
;----------------------------------------------------------------
;*�ӳ�������	MainSystem														**
;*�ӳ�������	MainSystem_DIS												**
;*�ӳ�������	MSysFunBut_DIS												**
;*�ӳ�������	MainSys_WPart													**
;*�ӳ�������	MainSys_NPart													**
;*�ӳ�������	MSys_DisErr														**
;----------------------------------------------------------------
;****************************************************;
;*�ӳ�������	MainSystem														**
;*���ܣ�			�ṩ����boundary������������������ɫ**
;*											����ѡ��										**
;*��ڲ�����													              **
;*���ڲ�����	�������ķ����趨											**
;*ʹ��˵����  																			**
;****************************************************;
MainSystem  PROC NEAR 
  PUSHA
  ;
  MOV	DS:[Msys_NW_AFlag],00H          ;��ʼ��Ϊ������������û�л����
MSys_StartCode:
  CALL MainSystem_DIS
  MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MIAN_SBD
	PUSH AX
	MOV AX,MSys_BD_Y
	PUSH AX
	MOV	AX,MSys_BD_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	MOV	DS:[Msys_BUT_SEL],0			;��ǰ��ѡ���� 0 (0 boundary  1 outter mangment 2 inner mangment
	;                                            3 match colors 4 set ok)
MSys_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;ȷ�ϼ�(Enter)
	JZ	MSys_SEL_ENTER
	CMP	AX,4800H
	JZ	MSys_UPSEL
	CMP	AX,5000H
	JZ	MSys_DOWNSEL
	JMP	MSys_GET_USEIN
MSys_UPSEL:
	PlaySound Freg_UpMove,Time_UpMove
	MOV	DL,Msys_BUT_SEL
	CMP	DL,0 						;�������Ƴ���
	JZ	MSys_DLEQU0				;DL=0����
	DEC	DL
	MOV	DS:[Msys_BUT_SEL],DL
	JMP	MSys_DIS_SELFRAME
MSys_DLEQU0:
	MOV	DS:[Msys_BUT_SEL],4	
	JMP	MSys_DIS_SELFRAME
MSys_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,Msys_BUT_SEL
	CMP	DL,4						;�������Ƴ���
	JZ	MSys_DLEQU4				;DL=4����
	INC	DL
	MOV	DS:[Msys_BUT_SEL],DL
	JMP	MSys_DIS_SELFRAME
MSys_DLEQU4:
	MOV	DS:[Msys_BUT_SEL],0	
	JMP	MSys_DIS_SELFRAME
MSys_DIS_SELFRAME:
	;��ʾѡ����  
	CALL MSysFunBut_DIS
	;SEL
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	XOR AX,AX
	MOV	AX,OFFSET STR_MIAN_SBD
	PUSH AX
	CALL STRLEN
	ADD SP,2
	INC AL
	MOV	CL,Msys_BUT_SEL
	MUL CL
	MOV	BX,OFFSET STR_MIAN_SBD
	ADD AX,BX
	PUSH AX
	XOR AX,AX
	MOV	AL,CHARHEIGHT*2+(CHARHEIGHT/4)
	MUL CL
	ADD AX,MSys_BD_Y
	PUSH AX
	MOV	AX,MSys_BD_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	MSys_GET_USEIN
MSys_SEL_ENTER:
	PlaySound Freg_Enter,Time_Enter
	MOV	DL,Msys_BUT_SEL
	CMP	DL,0
	JZ	MSys_SetBoundary
	CMP	DL,1
	JZ	MSys_OutterM
	CMP	DL,2
	JZ	MSys_InnerM
	CMP	DL,3
	JZ	MSys_MatchColors
	CMP	DL,4
	JZ	MSys_SetOK
	JMP MSys_SEL_ENTER
MSys_SetBoundary:
	CALL	BoundaryMangment
	JMP	MSys_StartCode
MSys_OutterM:
	CALL MainSys_WPart
	MOV	AL,Msys_NW_AFlag
	OR	AL,02H				;�������ú���
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_StartCode
MSys_InnerM:
	CALL MainSys_NPart
	MOV	AL,Msys_NW_AFlag
	OR	AL,01H				;�������ú���
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_StartCode
MSys_MatchColors:
	CALL	MatchCMangment
	JMP	MSys_StartCode
MSys_SetOK:
	;��������������Ƿ����Ҫ����
	;��������Ҫ����Ƿ񶼴��ڻ����
	;�������
	MOV	CX,4
	XOR	BX,BX
MSys_SOK_TestW:
	MOV	SI,OFFSET FOXW_PART1
	XOR	DX,DX
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	DX,CX
	DEC DL
	MUL DL
	ADD	SI,AX
	ADD	BL,[SI].part_flag
	LOOP	MSys_SOK_TestW
	CMP	BL,80H
	JZ	MSys_SOK_W_EXISTAC
	MOV	AL,Msys_NW_AFlag
	AND	AL,0FDH									;����û�����ú�
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_SOK_TestW_DONE
MSys_SOK_W_EXISTAC:
	MOV	AL,Msys_NW_AFlag
	OR	AL,02H									;�������ú���
	MOV	DS:[Msys_NW_AFlag],AL
MSys_SOK_TestW_DONE:
	;�������
	MOV	CX,4
	XOR	BX,BX
MSys_SOK_TestN:
	MOV	SI,OFFSET FOXN_PART1
	XOR	DX,DX
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	DX,CX
	DEC DL
	MUL DL
	ADD	SI,AX
	ADD	BL,[SI].part_flag
	LOOP	MSys_SOK_TestN
	CMP	BL,80H
	JZ	MSys_SOK_N_EXISTAC
	MOV	AL,Msys_NW_AFlag
	AND	AL,0FEH							;����û�����ú�
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_SOK_TestN_DONE
MSys_SOK_N_EXISTAC:
	MOV	AL,Msys_NW_AFlag
	OR	AL,01H							;�������ú���
	MOV	DS:[Msys_NW_AFlag],AL
MSys_SOK_TestN_DONE:
	;���ݼ��Ľ�����ܻ��ߴ�����ʾ
	MOV	AL,Msys_NW_AFlag
	CALL MSys_DisErr
	JNC MainSystem_EXIT			;����Ҫ��
	XOR AX,AX
	INT 16H									;�����������
	JMP MSys_StartCode
	;
MainSystem_EXIT:
	
	;�ж��Ƿ�ı����������ķ���������дӲ�̣�����д
	;�ȱȽ�����������
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,STARTSECTOR+2   ;���������洢
	MOV	AH,42H
	MOV	AL,1
	CALL	RdWrNSector
	MOV	SI,OFFSET FOXW_PART1
	MOV	DI,OFFSET BUF_PART1
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	CL,4
	MUL CL
	MOV	CX,AX
	CALL	StrNCmp						;�ȽϷ������Ƿ�ı䣬CF=1�ı���
	JC	Msys_NWPart_Altered
	;�ٱȽ�����������
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,STARTSECTOR+3   ;���������洢
	MOV	AH,42H
	MOV	AL,1
	CALL	RdWrNSector
	MOV	SI,OFFSET FOXN_PART1
	MOV	DI,OFFSET BUF_PART1
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	CL,4
	MUL CL
	MOV	CX,AX
	CALL	StrNCmp						;�ȽϷ������Ƿ�ı䣬CF=1�ı���
	JNC	Msys_NWPart_NotAlter	
Msys_NWPart_Altered:
	;д�����������Ͱ�װ��־
	MOV	EAX,'BOUL'
	MOV	DWORD PTR My_SetupFlag,EAX
	;д������������
	MOV	SI,OFFSET FOXWAI
	MOV	EBX,STARTSECTOR+2
	MOV	AH,43H
	MOV	AL,3						;д�������� LBA0
	CALL	RdWrNSector	
Msys_NWPart_NotAlter:
	;�˳�ȥǰ����������ʾ��ȥ
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
MainSystem ENDP
;****************************************************;
;*�ӳ�������	MainSystem_DIS												**
;*���ܣ�			�������������												**
;*��ڲ�����													              **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
MainSystem_DIS PROC NEAR
  PUSHA
  ;
  ;
  ;���ô��ڼ�������
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_MAIN_Caption			;���ñ���
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
	CALL	MSysFunBut_DIS
  POPA
  RET
MainSystem_DIS ENDP
;****************************************************;
;*�ӳ�������	MSysFunBut_DIS												**
;*���ܣ�			��������������ĸ����ܰ�ť						**
;*��ڲ�����													              **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
MSysFunBut_DIS PROC NEAR
	PUSHA
	;SET BOUNDARY
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MIAN_SBD
	PUSH AX
	MOV	AX,MSys_BD_Y
	PUSH AX
	MOV	AX,MSys_BD_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	;OUTTER PART MANGMENT
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MAIN_WPART
	PUSH AX
	MOV	AX,MSys_WPart_Y
	PUSH AX
	MOV	AX,MSys_WPart_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	;INNER PART MANGMENT
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MAIN_NPART
	PUSH AX
	MOV	AX,MSys_NPart_Y
	PUSH AX
	MOV	AX,MSys_NPart_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	;MATCH COLORS
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MAIN_COLOR
	PUSH AX
	MOV	AX,MSys_MatchC_Y
	PUSH AX
	MOV	AX,MSys_MatchC_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;set ok
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_MAIN_OK
	PUSH AX
	MOV	AX,MSys_SetOK_Y
	PUSH AX
	MOV	AX,MSys_SetOK_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;
	
	POPA
	RET
MSysFunBut_DIS ENDP
;****************************************************;
;*�ӳ�������	MainSys_WPart													**
;*���ܣ�			������������													**
;*��ڲ�����	����Ѿ���װ������Ϊ��ǰ��������			**
;*											STARTSECTOR+2	              **
;*						����Ϊ��ǰӲ�̷���										**
;*���ڲ�����	FOXWAI_PART														**
;*ʹ��˵����  																			**
;****************************************************;
MainSys_WPart PROC NEAR
  PUSHA
  ;�ȼ���Ƿ��Ѿ���װ
  MOV	EAX,DWORD PTR DS:[My_SetupFlag]
  CMP	EAX,'BOUL'											;��װ��־
  JZ	MainS_WPart_Installed
	;��һ�ΰ�װ�Ĵ���:��ȡ��ǰ���û�����������������
	MOV	SI,OFFSET FOXWAI
	MOV	EBX,0
	MOV	AH,42H
	MOV	AL,1						;��һ������ LBA0
	CALL	RdWrNSector
	;
	PUSH DS
	POP ES
	MOV	DI,OFFSET FOXWAI
	MOV	CX,446
	MOV	AL,00H
	CLD
  REP STOSB
MainS_WPart_Installed:
  ;�Ѿ���װ������ǰ����������Ϊ��������
  MOV	AL,SIZE Part_Entry
  MOV	CL,4
  MUL CL
  MOV	CX,AX
  PUSH DS
  POP ES
  MOV SI,OFFSET FOXW_PART1
  MOV DI,OFFSET NW_PART1
  CLD
  REP MOVSB

  MOV	AX,BOUNDARY									;Boundary�Ƿ��Ѿ��趨
  CMP	AX,0
  JZ	MainS_WPart_NotExist_BD			;δ�趨
  DEC AX
  MOV DS:[PM_MAXCYL],AX
  JMP	MainS_WPart_PutMaxCyled
MainS_WPart_NotExist_BD:
	MOV	AX,HDMAXCAP
	DEC AX 													;���ܳ������ߵ������ŵ���
	MOV DS:[PM_MAXCYL],AX
MainS_WPart_PutMaxCyled:
	MOV	DS:[PM_MINCYL],0
;  
	MOV	DX,OFFSET STR_OUTTER_PARTSYS
 	CALL PartMangment	
 	;�����Ѿ����պõ���������
 	XOR AX,AX
 	MOV AL,SIZE Part_Entry
 	MOV CL,4
 	MUL CL
 	MOV	CX,AX
 	PUSH DS
 	POP ES
 	MOV	SI,OFFSET NW_PART1
 	MOV	DI,OFFSET FOXW_PART1
 	CLD
 	REP MOVSB
 ;
  POPA
  RET
MainSys_WPart ENDP
;****************************************************;
;*�ӳ�������	MainSys_NPart													**
;*���ܣ�			������������													**
;*��ڲ�����	��ǰ��������													**
;*											STARTSECTOR+3	              **
;*���ڲ�����	FOXNEI_PART														**
;*ʹ��˵����  																			**
;****************************************************;
MainSys_NPart PROC NEAR 
  PUSHA
  ;
  MOV	AL,SIZE Part_Entry
  MOV	CL,4
  MUL CL
  MOV	CX,AX
  PUSH DS
  POP ES
  MOV SI,OFFSET FOXN_PART1
  MOV DI,OFFSET NW_PART1
  CLD
  REP MOVSB

  MOV	AX,BOUNDARY									;Boundary�Ƿ��Ѿ��趨
  CMP	AX,0
  JZ	MainS_NPart_NotExist_BD			;δ�趨
 	INC AX
  MOV DS:[PM_MinCYL],AX
  JMP	MainS_NPart_PutMinCyled
MainS_NPart_NotExist_BD:
	MOV DS:[PM_MINCYL],0
MainS_NPart_PutMinCyled:
	MOV	AX,HDMAXCAP
	DEC AX
	MOV	DS:[PM_MAXCYL],AX
;  
	MOV	DX,OFFSET STR_INNER_PARTSYS
 	CALL PartMangment	
 	;�����Ѿ����պõ���������
 	XOR AX,AX
 	MOV AL,SIZE Part_Entry
 	MOV CL,4
 	MUL CL
 	MOV	CX,AX
 	PUSH DS
 	POP ES
 	MOV	SI,OFFSET NW_PART1
 	MOV	DI,OFFSET FOXN_PART1
 	CLD
 	REP MOVSB
  POPA
  RET
MainSys_NPart ENDP

;****************************************************;
;*�ӳ�������	MSys_DisErr														**
;*���ܣ�			������ʾ															**
;*��ڲ�����	AL=01 �������� AL=02 ��������         **
;*���ڲ�����	CF=0�޴���  Cf=1 ��ʾ����							**
;*ʹ��˵���� ��ʾ����������δ���úõ���ʾ						**
;****************************************************;
MSys_DisErr PROC NEAR
  PUSHA
  MOV	BL,AL
  AND	BL,03H
  CMP	BL,03H
  JZ	MSys_NOT_DisErrS
  ;
  PUSH AX   					;��������
  ;���ô��ڼ�������
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_MAIN_Caption			;���ñ���
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
	POP AX
	;
	MOV	BL,AL
	AND	BL,01H
	CMP	BL,1
	JZ	MSys_NOT_DisErr1
	PUSH AX
	;��ʾ����1
	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_MAIN_ERR1
  PUSH AX
  MOV	AX,MSys_ERR1_Y
  PUSH AX
  MOV	AX,MSys_ERR1_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
	;
	POP AX
MSys_NOT_DisErr1:
	MOV	BL,AL
	AND	BL,02H
	CMP	BL,2
	JZ	MSys_NOT_DisErr2
	;��ʾ����2
	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_MAIN_ERR2
  PUSH AX
  MOV	AX,MSys_ERR2_Y
  PUSH AX
  MOV	AX,MSys_ERR2_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
MSys_NOT_DisErr2:
  STC
  JMP MSys_DisErr_Exit
MSys_NOT_DisErrS:
  CLC 
MSys_DisErr_Exit:	
  POPA
  RET
MSys_DisErr ENDP