;-----------------------------------------------------------------
;*子程序名：	BoundaryMangment											**
;*子程序名：	BoundaryM_DIS													**
;-----------------------------------------------------------------
;****************************************************;
;*子程序名：	BoundaryMangment											**
;*功能：			Boundary设置管理											**
;*入口参数：													              **
;*出口参数：	Boundary															**
;*使用说明：  																			**
;****************************************************;
BoundaryMangment PROC NEAR
  PUSHA 
  CALL BoundaryM_DIS
  ;
BM_GET_NEW_Boundary:
	MOV	AX,OFFSET STR_BM_SetBD
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,BM_SetBD_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],BM_SetBD_Y
  ;清除用户上次的输入
   MOV	CL,6
BM_CLR_PRE_USERIN:
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
  JNZ	BM_CLR_PRE_USERIN
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
	MOV	AX,5
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2 										;平衡堆栈
	MOV	AL,STD_BUF_COUNT
	CMP	AL,0 										;无输入
	JZ BM_GET_NEW_Boundary
	;五字节 STD_BUF->STD_D2H_BUF	
	MOV	DI,OFFSET STD_D2H_BUF
	MOV DWORD PTR [DI],030303030H
	MOV BYTE PTR [DI+4],030H
	;
	XOR CX,CX
	MOV	CL,STD_BUF_COUNT
	MOV	SI,OFFSET STD_BUF
	ADD SI,CX
	DEC SI
	ADD	DI,4           ;5个字节，定位
	STD                ;方向标志（减方向）
	REP MOVSB
	;		
  CALL DW_STR2HEX						;AX=用户输入的值
  ;开始比较
  JC BM_GET_NEW_Boundary		;输入值溢出，大于0ffffh
  MOV	CX,HDMAXCAP
  CMP	AX,CX
  JAE BM_GET_NEW_Boundary
  MOV	DS:BOUNDARY,AX  			;新的Boundary设定好了
	;
	;提供确定选择
	;RE SET
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_RE_SET
	PUSH AX
	MOV	AX,BM_RE_SET_Y
	PUSH AX
	MOV	AX,BM_RE_SET_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_ACCEPT
	PUSH AX
	MOV	AX,BM_ACCEPT_Y
	PUSH AX
	MOV	AX,BM_ACCEPT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	;获取用户的输入，(确定或者重填)并显示
	MOV	DS:[BD_BUT_SEL],1			;当前的选择是 1 (1 Set OK  2 Re Set)
BM_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;确认键(Enter)
	JZ	BM_SEL_ENTER;BoundaryM_EXIT
	CMP	AX,4800H
	JZ	BM_UPSEL
	CMP	AX,5000H
	JZ	BM_DOWNSEL
	JMP	BM_GET_USEIN
BM_SEL_ENTER:
	PlaySound Freg_Enter,Time_Enter
	MOV	DL,BD_BUT_SEL
	CMP	DL,1
	JZ	BoundaryM_EXIT
	CMP	DL,2
	JZ	BM_GET_NEW_Boundary
	JMP	BM_SEL_ENTER
BM_UPSEL:
	PlaySound Freg_UpMove,Time_UpMove
	MOV	DL,BD_BUT_SEL
	CMP	DL,1 						;处理上移出界
	JZ	BM_DLEQU1				;DL=1处理
	DEC	DL
	MOV	DS:[BD_BUT_SEL],DL
	JMP	BM_DIS_SELFRAME
BM_DLEQU1:
	MOV	DS:[BD_BUT_SEL],2	
	JMP	BM_DIS_SELFRAME
BM_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,BD_BUT_SEL
	CMP	DL,2						;处理下移出界
	JZ	BM_DLEQU2				;DL=2处理
	INC	DL
	MOV	DS:[BD_BUT_SEL],DL
	JMP	BM_DIS_SELFRAME
BM_DLEQU2:
	MOV	DS:[BD_BUT_SEL],1	
	JMP	BM_DIS_SELFRAME
BM_DIS_SELFRAME:
	MOV	DL,BD_BUT_SEL
	CMP	DL,1
	JZ	BM_DISSEL1	
	CMP	DL,2
	JZ	BM_DISSEL2
	JMP	BM_DIS_SELFRAME
BM_DISSEL1:
	;RE SET
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_RE_SET
	PUSH AX
	MOV	AX,BM_RE_SET_Y
	PUSH AX
	MOV	AX,BM_RE_SET_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;SEL SET OK
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_ACCEPT
	PUSH AX
	MOV	AX,BM_ACCEPT_Y
	PUSH AX
	MOV	AX,BM_ACCEPT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	BM_GET_USEIN
BM_DISSEL2:
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_ACCEPT
	PUSH AX
	MOV	AX,BM_ACCEPT_Y
	PUSH AX
	MOV	AX,BM_ACCEPT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_RE_SET
	PUSH AX
	MOV	AX,BM_RE_SET_Y
	PUSH AX
	MOV	AX,BM_RE_SET_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	BM_GET_USEIN
BoundaryM_EXIT:
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
BoundaryMangment ENDP
;****************************************************;
;*子程序名：	BoundaryM_DIS													**
;*功能：			画出管理界面													**
;*入口参数：	当前的boundary和最大磁道              **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
BoundaryM_DIS PROC NEAR
  PUSHA
  ;
  ;设置窗口及标题栏
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET	STR_BM_Caption			;设置标题
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
	MOV	AX,OFFSET STR_BM_ACCEPT
	PUSH AX
	MOV	AX,BM_ACCEPT_Y
	PUSH AX
	MOV	AX,BM_ACCEPT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8	
	;RE SET
	MOV	AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_RE_SET
	PUSH AX
	MOV	AX,BM_RE_SET_Y
	PUSH AX
	MOV	AX,BM_RE_SET_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;
	;显示当前boundary和最大磁道数
	;显示boundary 字符
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_CurrentBD
	PUSH AX
	MOV	AX,BM_CURRENT_MES_Y
	PUSH AX
	MOV	AX,BM_CURRENT_MES_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;Boundary 转换为字符串，并显示
	MOV	AX,BOUNDARY
  CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET STR_BD_BUF
  MOV	EAX,DWORD PTR DS:[SI]
  MOV	DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV	BYTE PTR DS:[DI+4],AL
  MOV	AX,OFFSET STR_BM_CurrentBD
  PUSH AX
  CALL STRLEN
  POP CX
  MOV	CL,CHARWIDTH
  MUL CL
  MOV	CX,AX
  MOV	AX,PM_PartMessage_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_BD_BUF
  PUSH AX
  MOV	AX,BM_CURRENT_MES_Y
	PUSH AX
	MOV	AX,BM_CURRENT_MES_X
	ADD	AX,CX
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;显示HDMAX
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_CurHDMax	
	PUSH AX
	MOV	AX,BM_CURRENT_MES_Y+CHARHEIGHT+CHARHEIGHT/2
	PUSH AX
	MOV	AX,BM_CURRENT_MES_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,HDMAXCAP
  CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET STR_HDMaxCap
  MOV	EAX,DWORD PTR DS:[SI]
  MOV	DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV	BYTE PTR DS:[DI+4],AL
  MOV	AX,OFFSET STR_BM_CurHDMax
  PUSH AX
  CALL STRLEN
  POP CX
  MOV	CL,CHARWIDTH
  MUL CL
  MOV	CX,AX
  MOV	AX,PM_PartMessage_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_HDMaxCap
  PUSH AX
  MOV	AX,BM_CURRENT_MES_Y+CHARHEIGHT+CHARHEIGHT/2
	PUSH AX
	MOV	AX,BM_CURRENT_MES_X
	ADD	AX,CX
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;显示当前设置boundary的字符串
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BM_SetBD	
	PUSH AX
	MOV	AX,BM_SetBD_Y
	PUSH AX
	MOV	AX,BM_SetBD_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
  POPA
  RET
BoundaryM_DIS ENDP