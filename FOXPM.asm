;*子程序名：	PartMangment													**
;*子程序名：	PartM_Init														**
;*子程序名：	PartM_DIS															**
;*子程序名：	PartM_FunB														**
;*子程序名：	PartM_SetActive												**
;*子程序名：	PartM_OK           										**
;*子程序名：	PartM_Refill       										**
;*子程序名：	PartM_DelPartition										**
;*子程序名：	PartM_Clr_EditZone										**
;*子程序名：	PartM_USERIN													**
;*子程序名：	PartM_DIS_PARTxMESS										**
;*子程序名：	PartM_Copy_TO_NWPart									**
;*子程序名：	PartM_Copy_TO_PARTITIONx							**
;---------------------------------------------------------------------------
;****************************************************;
;*子程序名：	PartMangment													**
;*功能：			分区管理的子系统  										**
;*入口参数：	DS:DX	标题栏字符串										**
;*						NW_PARTx（必须保证分区的正确）				**
;*出口参数：	接受到的有效内(外)网的分区存在				**
;*						NW_PART1~4														**
;*使用说明：  																			**
;****************************************************;
PartMangment PROC NEAR
  PUSHA
	CALL	PartM_DIS
	CALL	PartM_Init
	;获取用户的输入，并显示
	MOV	DS:[FUN_BUT_SEL],1			;当前的选择是 1 (1 SetActive  2 refill 3 delete 4 ok)
PM_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;确认键(Enter)
	JZ	PM_OPERATE
	CMP	AX,4800H
	JZ	PM_UPSEL
	CMP	AX,5000H
	JZ	PM_DOWNSEL
	JMP	PM_GET_USEIN
;
PM_OPERATE:
	PlaySound Freg_Enter,Time_Enter
	MOV	DL,FUN_BUT_SEL
	;四种子处理
	;1 Set Active
	CMP	DL,1
	JZ	PM_OP_SA
	;2 Refill
	CMP	DL,2				
	JZ	PM_OP_REFILL
	;3 delete	
	CMP	DL,3				
	JZ	PM_OP_DELPART
	;4 ok 检测
	CMP	DL,4
	JZ	PM_OP_OK
	JMP	PM_SYS_EXIT	
;箭头上移显示处理
PM_UPSEL:
	PlaySound Freg_UpMove,Time_UpMove
	MOV	DL,FUN_BUT_SEL
	CMP	DL,1 						;处理上移出界
	JZ	PM_DLEQU1				;DL=1处理
	DEC	DL
	MOV	DS:[FUN_BUT_SEL],DL
	JMP	PM_DIS_SELFRAME
PM_DLEQU1:
	MOV	DS:[FUN_BUT_SEL],4	
	JMP	PM_DIS_SELFRAME
;箭头下移显示处理
PM_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,FUN_BUT_SEL
	CMP	DL,4						;处理下移出界
	JZ	PM_DLEQU4				;DL=3处理
	INC	DL
	MOV	DS:[FUN_BUT_SEL],DL
	JMP	PM_DIS_SELFRAME
PM_DLEQU4:
	MOV	DS:[FUN_BUT_SEL],1	
	JMP	PM_DIS_SELFRAME
;四个按钮的不同处理
;
PM_OP_SA:
	CALL	PartM_SetActive
	JMP		PM_GET_USEIN
PM_OP_REFILL:
	CALL	PartM_Refill
	JMP		PM_GET_USEIN
PM_OP_DELPART:
	CALL PartM_DelPartition	;...
	JMP	PM_GET_USEIN
PM_OP_OK:
	CALL	PartM_OK
	JNC	PM_SYS_EXIT							;不存在有效分区或者操作完毕了
	CMP	AL,0
	JZ	PM_OP_OK_ERR0
	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR1
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  JMP	PM_OP_OK_ERR2
PM_OP_OK_ERR0:
 	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR0
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  JMP	PM_OP_OK_ERR2
 PM_OP_OK_ERR2:
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  XOR	AX,AX
  INT 16H
  CALL	PartM_Clr_EditZone	
	JMP		PM_GET_USEIN
;显示选择的按钮
PM_DIS_SELFRAME:
	MOV	DL,FUN_BUT_SEL
	CMP	DL,1
	JZ	PM_DISSEL1	
	CMP	DL,2
	JZ	PM_DISSEL2
	CMP	DL,3
	JZ	PM_DISSEL3
	CMP	DL,4
	JZ	PM_DISSEL4
	JMP	PM_DIS_SELFRAME
PM_DISSEL1:	
	CALL	PartM_FunB
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_SETACTIVE
	PUSH AX
	MOV	AX,EDITBUT_Y
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	PM_GET_USEIN
PM_DISSEL2:	
	CALL	PartM_FunB
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_REFILL
	PUSH AX
	MOV	AX,EDITBUT_Y+CHARHEIGHT*2+CHARHEIGHT/4
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	PM_GET_USEIN
PM_DISSEL3:	
	CALL	PartM_FunB
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_DEL_PARTITION
	PUSH AX
	MOV	AX,EDITBUT_Y+CHARHEIGHT*4+CHARHEIGHT/2
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	PM_GET_USEIN
PM_DISSEL4:	
	CALL	PartM_FunB
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_OK
	PUSH AX
	MOV	AX,EDITBUT_Y+CHARHEIGHT*6+CHARHEIGHT/2+CHARHEIGHT/4
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	JMP	PM_GET_USEIN
PM_SYS_EXIT:
	;退出去前，将本身显示消去
	MOV AX,BackGround_COLOR
	PUSH AX
	MOV	AX,MANG_SYS_FRAME_BOTTOM						;BOTTOM
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_RIGHT						;RIGHT
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_TOP						  ;TOP
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_LEFT						  ;LEFT
	PUSH	AX	
	CALL FILLRECT
	ADD SP,10
	;
  POPA
  RET
PartMangment  ENDP
;----------------------------画子系统界面---------------------------------------------------
;****************************************************;
;*子程序名：	PartM_Init														**
;*功能：			分区管理的子系统初始化								**
;*入口参数：	当前分区状况													**
;*出口参数：																				**
;*使用说明：  初始化显示当前状况										**
;****************************************************;
PartM_Init PROC NEAR
  PUSHA
  ;拷贝用户传入的分区表，转换为CHS的模式
  CALL	PartM_Copy_TO_PARTITIONx
  ;显示当前分区状况
  XOR ECX,ECX
  MOV	CL,4
PM_INIT_PART_DIS:
  MOV	AL,SIZE PartStruc
  MOV	BL,CL
  DEC BL
  MUL BL
  MOV SI,OFFSET PARTITION1
  ADD SI,AX
  MOV	AL,DS:[SI].PartValid
  CMP AL,0   								;无效分区，不用显示
  JZ PM_INIT_NEXT_DIS
  MOV	AL,BL
  CALL	PartM_DIS_PARTxMESS
PM_INIT_NEXT_DIS:
  LOOP	PM_INIT_PART_DIS
    
  ;显示初始选定的按钮
  MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_SETACTIVE
	PUSH AX
	MOV	AX,EDITBUT_Y
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL SEL_BUTTON
	ADD SP,8
	;
  POPA
  RET
PartM_Init ENDP


;****************************************************;
;*子程序名：	PartM_DIS															**
;*功能：			分区管理子系统界面 										**
;*入口参数：	DS:DX	标题栏字符串										**
;*出口参数：																				**
;*使用说明：  框架的位置是自由调整的，看PUTWINDOW的	**
;*						函数说明															**
;****************************************************;
PartM_DIS PROC NEAR
  PUSHA
	;设置窗口及标题栏
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	;MOV	DX,OFFSET	STR_CAP			;设置标题
	PUSH	DX
	MOV	AX,PM_WND_BK_COLOR
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_BOTTOM						;BOTTOM
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_RIGHT						;RIGHT
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_TOP						  ;TOP
	PUSH	AX
	MOV	AX,MANG_SYS_FRAME_LEFT						  ;LEFT
	PUSH	AX
	CALL	PUTWINDOW
	ADD	SP,14
	;显示boundary 字符
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_BOUNDARY
	PUSH AX
	MOV	AX,STR_BOUN_Y
	PUSH AX
	MOV	AX,STR_BOUN_X
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
  MOV	AX,OFFSET STR_BOUNDARY
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
  MOV	AX,STR_BOUN_Y
	PUSH AX
	MOV	AX,STR_BOUN_X
	ADD	AX,CX
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;显示HDMAX
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_HDMAX	
	PUSH AX
	MOV	AX,STR_HDMAX_Y
	PUSH AX
	MOV	AX,STR_HDMAX_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	MOV	AX,HDMAXCAP
  CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET STR_HDMaxCap
  MOV	EAX,DWORD PTR DS:[SI]
  MOV	DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV	BYTE PTR DS:[DI+4],AL
  MOV	AX,OFFSET STR_HDMAX
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
  MOV	AX,STR_HDMAX_Y
	PUSH AX
	MOV	AX,STR_HDMAX_X
	ADD	AX,CX
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;显示PARTMES
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_PARTMES
	PUSH AX
	MOV	AX,STR_PARTMES_Y
	PUSH AX
	MOV	AX,STR_PARTMES_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;显示 1 2 3 4
PM_DIS_NUM:
	MOV	AX,PM_StaticText_COLOR
  PUSH AX
	MOV	BL,STR_NUM1
	CMP	BL,'4'
	JA	PM_DIS_NUM_OVER
	MOV	AX,OFFSET STR_NUM1
  PUSH AX
	MOV	BL,STR_NUM1
	SUB	BX,31H
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,STR_NUM1_Y
  PUSH AX
	MOV	AX,STR_NUM1_X
  PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;此处画编辑窗口
	MOV	AX,7
	PUSH AX
	MOV	BL,STR_NUM1
	SUB	BX,31H
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	MOV	AX,9
	PUSH AX
	MOV	BL,STR_NUM1
	SUB	BX,31H
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+12*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	MOV	AX,9
	PUSH AX
	MOV	BL,STR_NUM1
	SUB	BX,31H
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+24*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	MOV	AX,11
	PUSH AX
	MOV	BL,STR_NUM1
	SUB	BX,31H
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+36*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	
	;画完编辑窗口
	;
	MOV	BL,STR_NUM1
	INC BL
	MOV	DS:[STR_NUM1],BL
	;
	JMP	PM_DIS_NUM
PM_DIS_NUM_OVER:
	POP AX		;平衡堆栈
	MOV	DS:[STR_NUM1],'1'
	CALL	PartM_FunB
  POPA
  RET
PartM_DIS  ENDP
;****************************************************;
;*子程序名：	PartM_FunB														**
;*功能：			显示功能按钮 													**
;*入口参数：																				**
;*出口参数：																				**
;****************************************************;
PartM_FunB proc near
	PUSHA
;显示功能按钮
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_SETACTIVE
	PUSH AX
	MOV	AX,EDITBUT_Y
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_REFILL
	PUSH AX
	MOV	AX,EDITBUT_Y+CHARHEIGHT*2+CHARHEIGHT/4
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_DEL_PARTITION
	PUSH AX
	MOV	AX,EDITBUT_Y+CHARHEIGHT*4+CHARHEIGHT/2
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	;
	MOV AX,PM_FunButtonText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_OK
	PUSH AX
	MOV	AX,EDITBUT_Y+CHARHEIGHT*6+CHARHEIGHT/2+CHARHEIGHT/4
	PUSH AX
	MOV	AX,EDITBUT_X
	PUSH AX
	CALL PUTBUTTON
	ADD SP,8
	POPA
	RET
PartM_FunB ENDP
;----------------------------四个功能------------------------------------------------------------
;****************************************************;
;*子程序名：	PartM_SetActive												**
;*功能：			设置活动分区													**
;*入口参数：																				**
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
PartM_SetActive PROC NEAR
  PUSHA
  ;
  ;检测是否有有效分区，判断活动分区是否设定
  MOV	SI,OFFSET PARTITION1		;从第一个分区开始判断是否存在有效分区
  MOV	AL,[SI].PartValid
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  CMP	AL,0
  JNZ	PM_SA_PVALID				;存在有效分区，继续
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK0
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  XOR	AX,AX
  INT 16H
  JMP	PM_SACTIVE_EXIT
PM_SA_PVALID:
  ;显示选择的分区号
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK1
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;;
  MOV	AX,OFFSET STR_SA_ASK1
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
PM_SACTIVE_USEIN1:
  CALL PartM_USERIN              ;显示用户输入
  CMP	AL,'1' 
  JZ	PM_SACTIVE_MSURE
  CMP	AL,'2' 
  JZ	PM_SACTIVE_MSURE
  CMP	AL,'3' 
  JZ	PM_SACTIVE_MSURE
  CMP	AL,'4' 
  JZ	PM_SACTIVE_MSURE
  JMP	PM_SACTIVE_USEIN1
PM_SACTIVE_MSURE:
	PUSH AX										;保存用户输入
  ;确认
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;
  MOV	AX,OFFSET STR_SA_ASK2
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y+2*CHARHEIGHT
  ;还原用户的输入:(1 2 3 4)
  POP BX
  SUB	BL,31H 										;保存用户输入	;BL=0,1,2,3
  MOV	DL,0
PM_SACTIVE_USEIN2:
  CALL PartM_USERIN              ;显示用户输入
  CMP	AX,1C0DH									 ;ENTER
  JZ	PM_SA_USE_ENTER
  CMP	AL,'Y'
  JZ	PM_SACTIVE_Y
	CMP	AL,'y'
  JZ	PM_SACTIVE_Y
  CMP	AL,'N'
  JZ	PM_SACTIVE_N
	CMP	AL,'n'
  JZ	PM_SACTIVE_N
  MOV	DL,0											;其他输入
  JMP	PM_SACTIVE_USEIN2
 PM_SA_USE_ENTER:
 	 PlaySound Freg_Enter,Time_Enter
 	 CMP	DL,1
 	 JZ	PM_SACTIVE_OK
 	 CMP	DL,2
 	 JZ	PM_SACTIVE_EXIT
 	 JMP	PM_SACTIVE_USEIN2
 PM_SACTIVE_Y:
 	MOV	DL,1
 	JMP	PM_SACTIVE_USEIN2
 PM_SACTIVE_N:
 	MOV	DL,2
 	JMP	PM_SACTIVE_USEIN2
PM_SACTIVE_OK:
	;选定了活动分区后的处理
	;1 判断选定的分区是否有效
	;
  PUSH BX
  MOV	AL,SIZE PartStruc
  MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	AL,[SI].PartValid
	CMP	AL,0                    ;非0有效
	JZ	PM_SACTIVE_INVALID				;选定的分区无效,跳转
	MOV	AX,[SI].PartEnd
	CMP AX,0										;删除分区会出现这种情况的
	JZ	PM_SACTIVE_INVALID				;选定的分区无效,跳转
	MOV	AL,[SI].PartType        ;继续判断
	CMP AL,0CH                  ;FAT32
	JZ PM_SACTIVE_VALID
	CMP AL,07H                  ;NTFS
	JZ PM_SACTIVE_VALID
	CMP AL,06H                  ;FAT16
	JZ PM_SACTIVE_VALID
PM_SACTIVE_INVALID:	
	CALL	PartM_Clr_EditZone		;无效分区显示
	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK3
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  XOR	AX,AX
  INT 16H
  POP BX
  JMP	PM_SACTIVE_EXIT
PM_SACTIVE_VALID:
	;2 显示(首先清除以前的显示 然后再显示当前的选择)
	;
	POP	BX
	PUSH BX
	
	MOV	CX,4
	;清除上次的显示
PM_SACTIVE_CLEARDIS:
	MOV	AX,PM_WND_BK_COLOR
  PUSH  AX
	MOV	AX,0FFH
  PUSH  AX
	MOV	AX,2*CHARHEIGHT
	MUL CL
	ADD	AX,ACTIVE_FLAG1_Y
	SUB	AX,2*CHARHEIGHT
  PUSH  AX
	MOV	AX,ACTIVE_FLAG1_X
  PUSH AX
	MOV	SI,CX 					
	CALL	PUTASCII					;
	ADD	SP,8
	MOV	CX,SI
	LOOP PM_SACTIVE_CLEARDIS
	;显示当前的选择 
	POP BX
	PUSH BX
	MOV	CX,PM_ActiveFlag_COLOR
	PUSH	CX
	MOV	CX,'A'
	PUSH	CX
	MOV	AL,2*CHARHEIGHT
	MUL	BL
	MOV	CX,ACTIVE_FLAG1_Y
	ADD	CX,AX
	PUSH	CX
	MOV	CX,ACTIVE_FLAG1_X
	PUSH	CX
	CALL	PUTASCII
	ADD	SP,8
	POP	BX
  ;3 填写子系统所用分区表的(flag)项
  MOV	SI,OFFSET PARTITION1
  MOV	[SI].PartActive,00H
  ADD	SI,SIZE PartStruc
  MOV	[SI].PartActive,00H
  ADD	SI,SIZE PartStruc
  MOV	[SI].PartActive,00H
  ADD	SI,SIZE PartStruc
  MOV	[SI].PartActive,00H
  MOV	SI,OFFSET PARTITION1
  MOV	AL,SIZE PartStruc
  MUL BL
  MOV	SI,OFFSET PARTITION1
  ADD	SI,AX
  MOV	[SI].PartActive,80H
PM_SACTIVE_EXIT:
	CALL	PartM_Clr_EditZone
  POPA
  RET
PartM_SetActive ENDP
;****************************************************;
;*子程序名：	PartM_OK           										**
;*功能：			检测分区是否有效，填写分区						**
;*入口参数：																				**
;*出口参数：	CF=1 AL=1 活动分区没有设定						**
;*								 AL=0 分区不符合要求							**
;*						CF=0 成功															**
;****************************************************;
PartM_OK PROC NEAR
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  ;检测是否有有效分区，判断活动分区是否设定
  ;1检测是否有有效分区，判断活动分区是否设定
  MOV	SI,OFFSET PARTITION1		;从第一个分区开始判断是否存在有效分区
  MOV	AL,[SI].PartValid
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  CMP	AL,0
  JZ	PM_OK_PINVALID
  XOR	AX,AX
  XOR	BX,BX
  MOV	SI,OFFSET PARTITION1		;从第一个分区开始判断是否存在有效分区
  MOV	AL,[SI].PartActive
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartActive
  ADD	AX,BX
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartActive
  ADD	AX,BX
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartActive
  ADD	AX,BX
  CMP	AX,80H
  JNZ PM_OK_NOTACTIVE
  ;2 回填，给调用者的分区表
  MOV	SI,OFFSET PARTITION1
  CALL TestPartValid				;检测填写的分区是否符合要求
	JC	PM_OK_InvalidPartS	
	CALL PartM_Copy_TO_NWPart
  JMP	PM_OK_ALL_FINISH
PM_OK_InvalidPartS:
  STC
	MOV	AL,0
	JMP	PM_OK_EXIT
PM_OK_NOTACTIVE:
	MOV	AL,1
  STC   										;CF=1事情还没做完，没有活动分区
  JMP	PM_OK_EXIT
PM_OK_PINVALID:							;不存在有效分区,不用操作
PM_OK_ALL_FINISH:
  CLC
PM_OK_EXIT:
  POP DI
  POP SI
  POP DX
  POP CX
  POP BX 
  RET
PartM_OK ENDP
;****************************************************;
;*子程序名：	PartM_Refill       										**
;*功能：			分区操作															**
;*入口参数：	PARTITIONx														**
;*出口参数：	PARTITIONx														**
;****************************************************;
PartM_Refill PROC NEAR
  PUSHA
 	;1 选定操作的分区
 	;显示选择的分区号
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_RF_ASK1
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;;
  MOV	AX,OFFSET STR_RF_ASK1
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
  XOR BX,BX
PM_REFILL_SELPART:
  CALL PartM_USERIN              ;显示用户输入
  CMP	AX,1C0DH
  JZ	PM_REFILL_SELP_ENTER
  CMP	AL,'1' 
  JZ	PM_REFILL_MSURE
  CMP	AL,'2' 
  JZ	PM_REFILL_MSURE
  CMP	AL,'3' 
  JZ	PM_REFILL_MSURE
  CMP	AL,'4' 
  JZ	PM_REFILL_MSURE
  MOV	BL,0
  JMP	PM_REFILL_SELPART
PM_REFILL_MSURE:
	MOV	BL,AL
	JMP	PM_REFILL_SELPART
PM_REFILL_SELP_ENTER:
	PlaySound Freg_Enter,Time_Enter
	CMP	BL,'1'
	JB	PM_REFILL_SELPART
	CMP BL,'4'
	JA	PM_REFILL_SELPART
	CALL	PartM_Clr_EditZone	
;分区已经选择好，bl='1'  '2'  '3'  '4'
;2 设定分区格式
	SUB	BL,31H
  PUSH BX 								;@@1保存选定的分区 BL=0 1 2 3 
	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_RF_ASK2
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;;
  MOV	AX,OFFSET STR_RF_ASK2
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
  ;
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_RF_TYPE_MES
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;画光标
  MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	;获取用户输入
PM_REFILL_GET_TYPE:
	MOV	AX,2
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2
	MOV	CL,STD_BUF_COUNT
	CMP	CL,0
	JZ	PM_REFILL_GET_TYPE
	;
	;两字节 STD_BUF->STD_D2H_BUF	
	MOV	CL,STD_BUF_COUNT
	MOV	AL,8
	MUL	CL
	MOV	CL,AL 							;移位计数器 
	PUSH DS
	POP ES
	MOV	DI,OFFSET STD_D2H_BUF
	MOV	SI,OFFSET STD_BUF
	MOV	AX,03030H
	MOV DX,WORD PTR DS:[SI]
	XCHG DH,DL
	SHLD AX,DX,CL
	XCHG AH,AL
	MOV WORD PTR ES:[DI],AX
	CALL	DB_STR2HEX						;al=分区类型
  POP BX 											;@@1选定的分区 bl=0 1 2 3
  MOV	DL,AL 									;保存分区类型
  MOV	SI,OFFSET PARTITION1
  MOV	AL,SIZE PartStruc
  MUL	BL
  ADD	SI,AX
  MOV	[SI].PartType,DL
	CALL	PartM_Clr_EditZone
  PUSH BX 										;@@2保存选定的分区 bl=0 1 2 3
  ;3 开始获取用户输入的分区开始磁道 和结束磁道,显示
  ;显示当前可用的磁道数目
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_RF_USEAL
  PUSH AX
  MOV	AX,FUN_ASK_Y+4*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  MOV	AX,PM_MINCYL
  CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET STR_PM_MINCYL
  MOV	EAX,DWORD PTR DS:[SI]
  MOV	DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV	BYTE PTR DS:[DI+4],AL
  MOV	AX,PM_MAXCYL
  CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET STR_PM_MAXCYL
  MOV	EAX,DWORD PTR DS:[SI]
  MOV DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV	BYTE PTR DS:[DI+4],AL
  ;
  MOV	AX,OFFSET STR_RF_USEAL	
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位信息显示位置 
  MOV	SI,AX
  MOV	AX,PM_PartMessage_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_PM_MINCYL
  PUSH AX
  MOV	AX,FUN_ASK_Y+4*CHARHEIGHT
  PUSH AX
  PUSH SI
  CALL	PUTSTR
  ADD	SP,8
  ;获取开始磁道
PM_REFILL_GETSTARTCYL:
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_RF_CYLSTART
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;;
  MOV	AX,OFFSET STR_RF_CYLSTART	
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
  ;清除用户的上次输入
  MOV	CL,6
PM_REFILL_CLR_INPUT1:
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
  JNZ	PM_REFILL_CLR_INPUT1
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
	CMP AL,0
	JZ PM_REFILL_GETSTARTCYL
	;
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
  JC	PM_REFILL_GETSTARTCYL	;溢出，用户输入的值大于0ffffh
  MOV	CX,PM_MINCYL
	CMP	AX,CX 								;小于等于规定的最小值则继续接收
	JB	PM_REFILL_GETSTARTCYL
	MOV	CX,PM_MAXCYL
	CMP	AX,CX 								;大于等于规定的最大值则继续接收
	JAE	PM_REFILL_GETSTARTCYL
	MOV	DX,AX                 ;DX保存用户设定的开始磁道
	;ok,接收到符合要求的开始磁道,填写分区
	POP BX 											;@@2选定的分区 bl=0 1 2 3
	PUSH BX 										;@@3保存选定的分区 bl=0 1 2 3
	MOV	AL,SIZE PartStruc
	MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	DS:[SI].PartStart,DX
	;清除显示的光标
	MOV	AX,PM_WND_BK_COLOR
  PUSH AX
  MOV	AX,0FFH
  PUSH AX
  MOV	AX,YCUR
  PUSH AX
 	MOV	AX,XCUR
  PUSH AX
  CALL	PUTASCII
  ADD	SP,8
	;接收结束磁道的输入
PM_REFILL_GETENDCYL:
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_RF_CYLEND
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;;
  MOV	AX,OFFSET STR_RF_CYLEND	
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y+2*CHARHEIGHT
  ;清除用户的上次输入
  MOV	CL,6
PM_REFILL_CLR_INPUT2:
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
  JNZ	PM_REFILL_CLR_INPUT2
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
  JC	PM_REFILL_GETENDCYL		;溢出，用户输入的值大于0ffffh
	MOV	 DI,AX                 ;DI保存用户设定的结束磁道
  POP BX 										;当前选定的分区bl=0 1 2 3
  PUSH BX
  MOV	AL,SIZE PartStruc
	MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	DX,DS:[SI].PartStart  ;用户输入的开始磁道
	;开始比较是否符合要求
  MOV	CX,PM_MINCYL
 	CMP	DI,CX 								;小于规定的最小值则继续接收
	JBE	PM_REFILL_GETENDCYL
	MOV	CX,PM_MAXCYL
	CMP	DI,CX 								;大于规定的最大值则继续接收
	JA	PM_REFILL_GETENDCYL
	CMP	DI,DX
	JBE  PM_REFILL_GETENDCYL		;小于输入的开始磁道则继续接收
	MOV	DX,DI                 ;DX保存用户设定的结束磁道
	;ok,接收到符合要求的结束磁道,填写分区
	POP BX 											;@@3选定的分区 bl=0 1 2 3
	PUSH BX 										;@@4保存选定的分区 bl=0 1 2 3
	MOV	AL,SIZE PartStruc
	MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	DS:[SI].PartEnd,DX
	MOV	DS:[SI].PartValid,01H 	;分区有效设定
	;
	POP AX 											;@@4选定的分区 bl=0 1 2 3
	CALL PartM_DIS_PARTxMESS
	CALL PartM_Clr_EditZone
PM_REFILL_EXIT:
  POPA
  RET
PartM_Refill ENDP
;****************************************************;
;*子程序名：	PartM_DelPartition										**
;*功能：			删除用户指定的分区										**
;*入口参数：																				**
;*出口参数：	PARTITIONx														**
;****************************************************;
PartM_DelPartition PROC NEAR
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  ;
  ;检测是否有有效分区，判断活动分区是否设定
  MOV	SI,OFFSET PARTITION1		;从第一个分区开始判断是否存在有效分区
  MOV	AL,[SI].PartValid
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  ADD	SI,SIZE PartStruc
  MOV	BL,[SI].PartValid
  OR	AL,BL
  CMP	AL,0
  JNZ	PM_DelP_PVALID				;存在有效分区，继续
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK0
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  XOR	AX,AX
  INT 16H
  JMP	PM_DelP_EXIT
PM_DelP_PVALID:
  ;显示选择的分区号
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK1
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;;
  MOV	AX,OFFSET STR_SA_ASK1
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
PM_DelPart_USEIN1:
  CALL PartM_USERIN              ;显示用户输入
  CMP	AL,'1' 
  JZ	PM_DelPart_MSURE
  CMP	AL,'2' 
  JZ	PM_DelPart_MSURE
  CMP	AL,'3' 
  JZ	PM_DelPart_MSURE
  CMP	AL,'4' 
  JZ	PM_DelPart_MSURE
  JMP	PM_DelPart_USEIN1
PM_DelPart_MSURE:
	PUSH AX										;保存用户输入
  ;确认
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;
  MOV	AX,OFFSET STR_SA_ASK2
  PUSH AX
  CALL	STRLEN
  POP CX                       ;平衡堆栈
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;定位用户输入位置 (光标)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y+2*CHARHEIGHT
  ;还原用户的输入:(1 2 3 4)
  POP BX
  SUB	BL,31H 										;保存用户输入	;BL=0,1,2,3
  MOV	DL,0
PM_DelPart_USEIN2:
  CALL PartM_USERIN              ;显示用户输入
  CMP	AX,1C0DH									 ;ENTER
  JZ	PM_DP_USE_ENTER
  CMP	AL,'Y'
  JZ	PM_DelPart_Y
	CMP	AL,'y'
  JZ	PM_DelPart_Y
  CMP	AL,'N'
  JZ	PM_DelPart_N
	CMP	AL,'n'
  JZ	PM_DelPart_N
  MOV	DL,0											;其他输入
  JMP	PM_DelPart_USEIN2
 PM_DP_USE_ENTER:
 	 PlaySound Freg_Enter,Time_Enter
 	 CMP	DL,1
 	 JZ	PM_DelPart_OK
 	 CMP	DL,2
 	 JZ	PM_DelP_EXIT
 	 JMP	PM_DelPart_USEIN2
 PM_DelPart_Y:
 	MOV	DL,1
 	JMP	PM_DelPart_USEIN2
 PM_DelPart_N:
 	MOV	DL,2
 	JMP	PM_DelPart_USEIN2
PM_DelPart_OK:
	;选定了分区后的处理
	;1 判断选定的分区是否有效
	;
  PUSH BX
  MOV	AL,SIZE PartStruc
  MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	AL,[SI].PartValid
	CMP	AL,0                    ;非0有效
	JZ	PM_DelPart_INVALID			;选定的分区无效,跳转
	JMP PM_DelP_VALID
PM_DelPart_INVALID:	
	CALL	PartM_Clr_EditZone		;无效分区显示
	MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_SA_ASK3
  PUSH AX
  MOV	AX,FUN_ASK_Y
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  ;
  MOV  AX,PM_EditZoneText_COLOR
  PUSH AX
  MOV	AX,OFFSET STR_OK_ERR2
  PUSH AX
  MOV	AX,FUN_ASK_Y+2*CHARHEIGHT
  PUSH AX
  MOV	AX,FUN_ASK_X
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
  XOR	AX,AX
  INT 16H
  POP BX
  JMP	PM_DelP_EXIT											
PM_DelP_VALID:
	POP	BX																				
  ;2 将选定的分区表清除
  PUSH DS
  POP ES
  MOV	DI,OFFSET PARTITION1
  XOR	AX,AX
  MOV	AL,SIZE PartStruc
  MUL BL
  ADD	DI,AX
  MOV	CX,SIZE PartStruc
  DEC CX 								;注意，此分区是被删除的，所以还是有效分区
  CLD 
  MOV	AL,00H
  REP STOSB
;
	MOV	AL,BL
	CALL PartM_DIS_PARTxMESS	
  PUSH BX
  ;此处画编辑窗口
	MOV	AX,7
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	POP BX 					;还原入口参数
  PUSH BX
	MOV	AX,9
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+12*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
  POP BX 					;还原入口参数
  PUSH BX
	MOV	AX,9
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+24*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
  POP BX 					;还原入口参数
	MOV	AX,11
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+36*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
PM_DelP_EXIT:
	CALL	PartM_Clr_EditZone
	;
  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  RET
PartM_DelPartition ENDP
;---------------------------子系统的公用程序-----------------------------------------------
;****************************************************;
;*子程序名：	PartM_Clr_EditZone										**
;*功能：			清除子功能的显示区										**
;*入口参数：																				**
;*出口参数：																				**
;****************************************************;
PartM_Clr_EditZone  PROC NEAR
  PUSHA
	MOV	AX,PM_WND_BK_COLOR
	PUSH AX
	MOV	AX,EDIT_ZONE_BOTTOM
	PUSH AX
	MOV	AX,EDIT_ZONE_RIGHT
	PUSH AX
	MOV	AX,EDIT_ZONE_TOP
	PUSH AX
	MOV	AX,EDIT_ZONE_LEFT
	PUSH AX
	CALL FILLRECT
	ADD	SP,10
  POPA
  RET
PartM_Clr_EditZone ENDP
	;
;****************************************************;
;*子程序名：	PartM_USERIN													**
;*功能：			显示用户输入 													**
;*入口参数：																				**
;*出口参数：	ax=用户输入														**
;****************************************************;	
PartM_USERIN	PROC	NEAR
	PUSH CX
	PUSH BX
	PUSH DX
	PUSH SI
	PUSH DI
	
	XOR	AX,AX
	INT 16H
	PUSH AX  							;保存用户输入
	CMP	AL,21H
	JB	PM_USERIN_NOT_CLEARDIS
	CMP	AL,7FH
	JA	PM_USERIN_NOT_CLEARDIS
	;清除上次的显示
	MOV	CX,PM_WND_BK_COLOR
	PUSH	CX
	MOV	CX,0FFH
	PUSH	CX
	MOV	CX,YCUR
	PUSH	CX
	MOV	CX,XCUR
	PUSH	CX
	CALL	PUTASCII
	ADD	SP,8
PM_USERIN_NOT_CLEARDIS:
  POP AX  							;保存用户输入
  PUSH AX
  CMP	AL,21H            ;只显示可见字符
  JB	PM_USERRIN_EXIT
  CMP	AL,7FH
  JA	PM_USERRIN_EXIT
	MOV	CX,PM_CURSOR_COLOR
	PUSH CX
	PUSH AX 							;显示
	MOV	CX,YCUR
	PUSH	CX
	MOV	CX,XCUR
	PUSH	CX
	CALL	PUTASCII
	ADD	SP,8
PM_USERRIN_EXIT:		
	POP AX
	;
  POP DI
  POP SI
  POP DX
  POP BX
  POP CX
  RET
PartM_USERIN	ENDP
;****************************************************;
;*子程序名：	PartM_DIS_PARTxMESS										**
;*功能：			显示规定的分区信息										**
;*入口参数：	al=0,1,2,3 PARTITION1									**
;*出口参数：																				**
;****************************************************;
PartM_DIS_PARTxMESS PROC NEAR
  PUSHA
  PUSH AX  ;保存入口参数
  ;
  MOV	BL,AL
  MOV	DL,AL
  MOV	AL,SIZE PartStruc
  MUL BL
  MOV	BX,OFFSET PARTITION1
  ADD	BX,AX    										;定位分区表1 2 3 4
  ;判断是否是活动分区，是则显示 'A'
  MOV	CL,DS:[BX].PartActive
  CMP	CL,80H
  JNZ	PM_DIS_PARTX_NOTACTIVE
  MOV	CX,PM_ActiveFlag_COLOR
  PUSH CX
	MOV	CX,'A'
  PUSH CX
	MOV	AL,2*CHARHEIGHT
  MUL DL 												;DL=0,1,2,3=入口参数
	MOV	CX,ACTIVE_FLAG1_Y
	ADD	CX,AX
  PUSH CX
	MOV	CX,ACTIVE_FLAG1_X
  PUSH CX
	CALL	PUTASCII
	ADD	SP,8
	JMP PM_DIS_PARTX_DISAC_OVER
PM_DIS_PARTX_NOTACTIVE:
	MOV	CX,PM_WND_BK_COLOR
  PUSH CX
	MOV	CX,0FFH
  PUSH CX
	MOV	AL,2*CHARHEIGHT
  MUL DL 												;DL=0,1,2,3=入口参数
	MOV	CX,ACTIVE_FLAG1_Y
	ADD	CX,AX
  PUSH CX
	MOV	CX,ACTIVE_FLAG1_X
  PUSH CX
	CALL	PUTASCII
	ADD	SP,8
PM_DIS_PARTX_DISAC_OVER:
	;别的信息显示
	;分区类型
	MOV	AL,DS:[BX].PartType
	CALL	DB_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET BUF_STR_PTYPE
  MOV	AX,WORD PTR DS:[SI]
  MOV WORD PTR DS:[DI],AX
  ;开始磁道 
  MOV	AX,DS:[BX].PartStart
	CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET BUF_STR_PSTART
  MOV	EAX,DWORD PTR DS:[SI]
  MOV	DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV BYTE PTR DS:[DI+4],AL
  ;结束磁道
  MOV	AX,DS:[BX].PartEnd
	CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET BUF_STR_PEND
  MOV	EAX,DWORD PTR DS:[SI]
  MOV DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV BYTE PTR DS:[DI+4],AL
  ;容量计算
  XOR ECX,ECX
  XOR EAX,EAX
  MOV	CX,DS:[BX].PartEnd
  MOV	AX,DS:[BX].PartStart
  SUB	CX,AX
  CMP	CX,0
  JNZ  PartM_DIS_PARTx_LBASE0			;起始扇区和结束扇区相同，实际是处理他们都是0的情况
  MOV	CX,0
  JMP	PartM_DIS_PARTx_LBASE0_DONE
PartM_DIS_PARTx_LBASE0:
  INC	CX    ;当前分区总磁道数
PartM_DIS_PARTx_LBASE0_DONE:
  MOV	AX,03EC1H
  MUL ECX     			;分区扇区总数=EDX:EAX   ;EDX=0
  MOV	ECX,2*1024 		;以'M'为单位
  DIV ECX 					;商=eax
	CALL DD_HEX2STR  
	XOR	ECX,ECX
	MOV	CX,8
	PUSH DS
	POP ES
	MOV	SI,OFFSET STD_DWORD2H_BUF
	MOV	DI,OFFSET BUF_STR_PCAP
  CLD
  REP MOVSB
  ;开始显示
  POP BX 					;还原入口参数
  PUSH BX
  ;此处画编辑窗口
	MOV	AX,7
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	POP BX 					;还原入口参数
  PUSH BX
	MOV	AX,9
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+12*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
  POP BX 					;还原入口参数
  PUSH BX
	MOV	AX,9
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+24*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
  POP BX 					;还原入口参数
  PUSH BX
	MOV	AX,11
	PUSH AX
	MOV	AL,CHARHEIGHT*2
	MUL BL
	ADD	AX,EDITBOX_PART1_Y
	PUSH AX
	MOV	AX,EDITBOX_PART1_X+36*CHARWIDTH
	PUSH AX
	CALL PUTEDITBOX
	ADD SP,6
	;
	POP BX 					;还原入口参数
  MOV	AX,PM_PartMessage_COLOR
  PUSH AX
  MOV	AX,OFFSET BUF_STR_PTYPE
  PUSH AX
  MOV	AL,2*CHARHEIGHT
  MUL BL
  ADD	AX,EDITBOX_PART1_Y
  ADD	AX,CHARHEIGHT/2
  PUSH AX
  MOV	AX,EDITBOX_PART1_X
  ADD	AX,CHARWIDTH/2
  PUSH AX
  CALL	PUTSTR
  ADD	SP,8
	;
	POPA
  RET
PartM_DIS_PARTxMESS ENDP
;****************************************************;
;*子程序名：	PartM_Copy_TO_NWPart									**
;*功能：			将用户设置好的分区转换，提供对访问子系**
;*						统的接口															**
;*入口参数：	PARTITION1~4													**
;*出口参数：	NW_PART1~4														**
;****************************************************;
PartM_Copy_TO_NWPart PROC NEAR 
  PUSHA
  ;
  ;1 清以前的内容
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	BL,4
	MUL BL
	MOV	CX,AX
	MOV	AL,00H
	PUSH DS
	POP ES
	MOV DI,OFFSET NW_PART1
	CLD
  REP STOSB
	;2 检测有效分区，回填
	MOV CX,4
PM_CNWpart_FILL:
	XOR AX,AX
	XOR DX,DX
  MOV SI,OFFSET PARTITION1
	MOV	AL,SIZE PartStruc
	MOV	DL,CL
	DEC DL
	MUL DL
	ADD SI,AX
	MOV AL,DS:[SI].PartValid
	CMP AL,0
	JZ  PM_CNWpart_INVALIDPART
	MOV	DI,OFFSET HD_CHSBUF
	MOV BP,CX             ;保存CX
	MOV	CL,SIZE PartStruc
	CLD
  REP MOVSB
	CALL CHS2LBA
	MOV DI,OFFSET NW_PART1
	MOV SI,OFFSET HD_LBABUF
	MOV CX,BP             ;还原CX
	MOV AL,SIZE Part_Entry
	MOV DL,CL
	DEC DL
  MUL DL
	ADD DI,AX
	MOV BP,CX               ;保存CX
	MOV CX,SIZE Part_Entry
  CLD
  REP MOVSB
  MOV CX,BP 							;还原CX
PM_CNWpart_INVALIDPART:
  LOOP PM_CNWpart_FILL
  POPA
  RET
PartM_Copy_TO_NWPart ENDP
;****************************************************;
;*子程序名：	PartM_Copy_TO_PARTITIONx							**
;*功能：			将用户送入的分区转换，送入处理区			**
;*入口参数：	NW_PART1~4														**
;*出口参数：	PARTITION1~4													**
;****************************************************;
PartM_Copy_TO_PARTITIONx PROC NEAR 
  PUSHA
  ;
  ;1 清以前的内容
	XOR AX,AX
	MOV	AL,SIZE PartStruc
	MOV	BL,4
	MUL BL
	MOV	CX,AX
	MOV	AL,00H
	PUSH DS
	POP ES
	MOV DI,OFFSET PARTITION1
	CLD
  REP STOSB
	;2 转换，回填 Nw_part->Partition
	MOV CX,4
PM_PARTITIONx_FILL:
	XOR AX,AX
	XOR DX,DX
  MOV SI,OFFSET NW_PART1
	MOV	AL,SIZE Part_Entry
	MOV	DL,CL
	DEC DL
	MUL DL
	ADD SI,AX
	MOV	DI,OFFSET HD_LBABUF
	MOV BP,CX             ;保存CX
	MOV	CL,SIZE Part_Entry
	CLD
  REP MOVSB 						;传送Nw_part->HD_LBABUF
	CALL LBA2CHS
	MOV DI,OFFSET PARTITION1
	MOV SI,OFFSET HD_CHSBUF
	MOV CX,BP             ;还原CX
	MOV AL,SIZE PartStruc
	MOV DL,CL
	DEC DL
  MUL DL
	ADD DI,AX  							;定位
	MOV BP,CX               ;保存CX
	MOV CX,SIZE PartStruc
  CLD
  REP MOVSB
  MOV CX,BP 							;还原CX
  LOOP PM_PARTITIONx_FILL
  POPA
  RET
PartM_Copy_TO_PARTITIONx ENDP

