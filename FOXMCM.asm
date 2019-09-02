;配色方案的选择
;-------------------------------------------------------------
;*子程序名：	MatchCMangment												**
;*子程序名：	MatchCM_DIS														**
;*子程序名：	MatchCM_DO														**
;*子程序名：	MatchCM_SaveConf											**
;-------------------------------------------------------------
;****************************************************;
;*子程序名：	MatchCMangment												**
;*功能：			配色方案管理													**
;*入口参数：													              **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
MatchCMangment PROC NEAR
  PUSHA 
  CALL MatchCM_DIS
  ;
MCM_GET_NEW_Sol:
	MOV	AX,OFFSET STR_MCM_SelNo
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,MCM_SelSol_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],MCM_SelSol_Y
  ;清除用户上次的输入
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
  ;画光标
  MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	;获取用户输入（开始磁道）
	MOV	AX,1
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2 										;平衡堆栈
	MOV	AL,STD_BUF_COUNT
	CMP	AL,0 										;无输入
	JZ MCM_GET_NEW_Sol
	;开始判断用户的输入					;31H,32H,33H
	MOV	AL,DS:[STD_BUF]
  CMP	AL,31H		
  JZ	MCM_USER_SEL_SOL				;配色方案1
  CMP	AL,32H
  JZ	MCM_USER_SEL_SOL				;配色方案1
  CMP	AL,33H
  JZ	MCM_USER_SEL_SOL				;配色方案3
  JMP	MCM_GET_NEW_Sol	
MCM_USER_SEL_SOL:							;配色方案处理
	CALL MatchCM_DO	
	;提供确定选择
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
	;获取用户的输入，(确定或者重填)并显示
	MOV	DS:[MCM_BUT_SEL	],1			;当前的选择是 1 (1 Set OK  2 Re Set)
MCM_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;确认键(Enter)
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
	CMP	DL,1 						;处理上移出界
	JZ	MCM_DLEQU1				;DL=1处理
	DEC	DL
	MOV	DS:[MCM_BUT_SEL	],DL
	JMP	MCM_DIS_SELFRAME
MCM_DLEQU1:
	MOV	DS:[MCM_BUT_SEL	],2	
	JMP	MCM_DIS_SELFRAME
MCM_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,MCM_BUT_SEL	
	CMP	DL,2						;处理下移出界
	JZ	MCM_DLEQU2				;DL=2处理
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
	;写硬盘startsector+4,保存配置
	CALL MATCHCM_SAVECONF
	
	;消除本程序的所有显示
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
;*子程序名：	MatchCM_DIS														**
;*功能：			画出管理界面													**
;*入口参数：													              **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
MatchCM_DIS PROC NEAR
  PUSHA
  ;
  ;设置窗口及标题栏
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_MCM_Caption			;设置标题
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
	;画出两个按钮
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
	;显示当前选择配色方案的字符串
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
;*子程序名：	MatchCM_DO														**
;*功能：			配色方案选择后的处理									**
;*入口参数：	AL=31H 1号方案 AL＝32H	1号方案 ....  **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
MatchCM_DO PROC NEAR
  PUSHA
  MOV	BL,AL
  SUB	BL,31H
  MOV	DI,OFFSET BackGround_COLOR							;定位目的缓冲区（颜色存储）
  MOV	SI,OFFSET FirstMatchColors							;定位初始源缓冲区
  ;
  MOV DX,OFFSET FirstMatchColors
  MOV	AX,OFFSET FirstMatchColorEnd
  SUB	AX,DX
  ADD	AX,2														;以字为位置单位
  MOV	CX,AX   												;每个方案所用缓冲区的大小(不能超过255)
  MOV	AL,BL
  MUL CL
  ADD	SI,AX														;定位源缓冲区
  ;CX=需要传送的字节数,SI 源  DI 目的
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
;*子程序名：	MatchCM_SaveConf											**
;*功能：			保存当前的配置到硬盘(STARTSECTOR+4)		**
;*入口参数：	FOXBUF(当前选择好的方案)						  **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
MatchCM_SaveConf PROC NEAR
  PUSHA
  ;读取判断是否改变了
  MOV	SI,OFFSET MBRBUF 
	MOV	EBX,STARTSECTOR+4   							;foxbuf对应的扇区
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
	MOV	EBX,STARTSECTOR+4   							;foxbuf对应的扇区
	MOV	AH,43H
	MOV	AL,1
	CALL	RdWrNSector
MCM_SaveC_NOTWRITE:											;没有改配置，不用写硬盘
  POPA
  RET
MatchCM_SaveConf ENDP