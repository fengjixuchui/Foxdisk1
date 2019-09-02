;主管理系统
;提供设置boundary、内外网分区管理、配色方案选择
;----------------------------------------------------------------
;*子程序名：	MainSystem														**
;*子程序名：	MainSystem_DIS												**
;*子程序名：	MSysFunBut_DIS												**
;*子程序名：	MainSys_WPart													**
;*子程序名：	MainSys_NPart													**
;*子程序名：	MSys_DisErr														**
;----------------------------------------------------------------
;****************************************************;
;*子程序名：	MainSystem														**
;*功能：			提供设置boundary、内外网分区管理、配色**
;*											方案选择										**
;*入口参数：													              **
;*出口参数：	内外网的分区设定											**
;*使用说明：  																			**
;****************************************************;
MainSystem  PROC NEAR 
  PUSHA
  ;
  MOV	DS:[Msys_NW_AFlag],00H          ;初始化为假设内外网都没有活动分区
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
	MOV	DS:[Msys_BUT_SEL],0			;当前的选择是 0 (0 boundary  1 outter mangment 2 inner mangment
	;                                            3 match colors 4 set ok)
MSys_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;确认键(Enter)
	JZ	MSys_SEL_ENTER
	CMP	AX,4800H
	JZ	MSys_UPSEL
	CMP	AX,5000H
	JZ	MSys_DOWNSEL
	JMP	MSys_GET_USEIN
MSys_UPSEL:
	PlaySound Freg_UpMove,Time_UpMove
	MOV	DL,Msys_BUT_SEL
	CMP	DL,0 						;处理上移出界
	JZ	MSys_DLEQU0				;DL=0处理
	DEC	DL
	MOV	DS:[Msys_BUT_SEL],DL
	JMP	MSys_DIS_SELFRAME
MSys_DLEQU0:
	MOV	DS:[Msys_BUT_SEL],4	
	JMP	MSys_DIS_SELFRAME
MSys_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,Msys_BUT_SEL
	CMP	DL,4						;处理下移出界
	JZ	MSys_DLEQU4				;DL=4处理
	INC	DL
	MOV	DS:[Msys_BUT_SEL],DL
	JMP	MSys_DIS_SELFRAME
MSys_DLEQU4:
	MOV	DS:[Msys_BUT_SEL],0	
	JMP	MSys_DIS_SELFRAME
MSys_DIS_SELFRAME:
	;显示选定框  
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
	OR	AL,02H				;外网设置好了
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_StartCode
MSys_InnerM:
	CALL MainSys_NPart
	MOV	AL,Msys_NW_AFlag
	OR	AL,01H				;内网设置好了
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_StartCode
MSys_MatchColors:
	CALL	MatchCMangment
	JMP	MSys_StartCode
MSys_SetOK:
	;检查内外网分区是否符合要求了
	;在这里主要检查是否都存在活动分区
	;检测外网
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
	AND	AL,0FDH									;外网没有设置好
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_SOK_TestW_DONE
MSys_SOK_W_EXISTAC:
	MOV	AL,Msys_NW_AFlag
	OR	AL,02H									;外网设置好了
	MOV	DS:[Msys_NW_AFlag],AL
MSys_SOK_TestW_DONE:
	;检测内网
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
	AND	AL,0FEH							;内网没有设置好
	MOV	DS:[Msys_NW_AFlag],AL
	JMP	MSys_SOK_TestN_DONE
MSys_SOK_N_EXISTAC:
	MOV	AL,Msys_NW_AFlag
	OR	AL,01H							;内网设置好了
	MOV	DS:[Msys_NW_AFlag],AL
MSys_SOK_TestN_DONE:
	;根据检测的结果接受或者错误提示
	MOV	AL,Msys_NW_AFlag
	CALL MSys_DisErr
	JNC MainSystem_EXIT			;符合要求
	XOR AX,AX
	INT 16H									;按任意键继续
	JMP MSys_StartCode
	;
MainSystem_EXIT:
	
	;判断是否改变了内外网的分区，是则写硬盘，否则不写
	;先比较外网分区表
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,STARTSECTOR+2   ;外网分区存储
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
	CALL	StrNCmp						;比较分区表是否改变，CF=1改变了
	JC	Msys_NWPart_Altered
	;再比较内网分区表
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,STARTSECTOR+3   ;内网分区存储
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
	CALL	StrNCmp						;比较分区表是否改变，CF=1改变了
	JNC	Msys_NWPart_NotAlter	
Msys_NWPart_Altered:
	;写内外网分区和安装标志
	MOV	EAX,'BOUL'
	MOV	DWORD PTR My_SetupFlag,EAX
	;写内外网分区表
	MOV	SI,OFFSET FOXWAI
	MOV	EBX,STARTSECTOR+2
	MOV	AH,43H
	MOV	AL,3						;写三个扇区 LBA0
	CALL	RdWrNSector	
Msys_NWPart_NotAlter:
	;退出去前，将本身显示消去
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
;*子程序名：	MainSystem_DIS												**
;*功能：			画出主管理界面												**
;*入口参数：													              **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
MainSystem_DIS PROC NEAR
  PUSHA
  ;
  ;
  ;设置窗口及标题栏
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_MAIN_Caption			;设置标题
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
;*子程序名：	MSysFunBut_DIS												**
;*功能：			画出主管理界面四个功能按钮						**
;*入口参数：													              **
;*出口参数：																				**
;*使用说明：  																			**
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
;*子程序名：	MainSys_WPart													**
;*功能：			管理外网分区													**
;*入口参数：	如果已经安装，参数为当前外网分区			**
;*											STARTSECTOR+2	              **
;*						否则为当前硬盘分区										**
;*出口参数：	FOXWAI_PART														**
;*使用说明：  																			**
;****************************************************;
MainSys_WPart PROC NEAR
  PUSHA
  ;先检测是否已经安装
  MOV	EAX,DWORD PTR DS:[My_SetupFlag]
  CMP	EAX,'BOUL'											;安装标志
  JZ	MainS_WPart_Installed
	;第一次安装的处理:读取当前的用户分区当作外网分区
	MOV	SI,OFFSET FOXWAI
	MOV	EBX,0
	MOV	AH,42H
	MOV	AL,1						;读一个扇区 LBA0
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
  ;已经安装，将当前外网分区作为参数传入
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

  MOV	AX,BOUNDARY									;Boundary是否已经设定
  CMP	AX,0
  JZ	MainS_WPart_NotExist_BD			;未设定
  DEC AX
  MOV DS:[PM_MAXCYL],AX
  JMP	MainS_WPart_PutMaxCyled
MainS_WPart_NotExist_BD:
	MOV	AX,HDMAXCAP
	DEC AX 													;不能超过或者等于最大磁道数
	MOV DS:[PM_MAXCYL],AX
MainS_WPart_PutMaxCyled:
	MOV	DS:[PM_MINCYL],0
;  
	MOV	DX,OFFSET STR_OUTTER_PARTSYS
 	CALL PartMangment	
 	;传送已经接收好的外网分区
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
;*子程序名：	MainSys_NPart													**
;*功能：			管理内网分区													**
;*入口参数：	当前内网分区													**
;*											STARTSECTOR+3	              **
;*出口参数：	FOXNEI_PART														**
;*使用说明：  																			**
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

  MOV	AX,BOUNDARY									;Boundary是否已经设定
  CMP	AX,0
  JZ	MainS_NPart_NotExist_BD			;未设定
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
 	;传送已经接收好的外网分区
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
;*子程序名：	MSys_DisErr														**
;*功能：			错误显示															**
;*入口参数：	AL=01 内网符合 AL=02 外网符合         **
;*出口参数：	CF=0无错误  Cf=1 显示错误							**
;*使用说明： 显示内外网分区未设置好的提示						**
;****************************************************;
MSys_DisErr PROC NEAR
  PUSHA
  MOV	BL,AL
  AND	BL,03H
  CMP	BL,03H
  JZ	MSys_NOT_DisErrS
  ;
  PUSH AX   					;保存输入
  ;设置窗口及标题栏
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_MAIN_Caption			;设置标题
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
	;显示错误1
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
	;显示错误2
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