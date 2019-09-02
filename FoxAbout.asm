;显示Fox版本，关于的信息
;****************************************************;
;*子程序名：	FoxAbout															**
;*功能：			关于																	**
;*入口参数：													              **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
FOXAbout  PROC NEAR
  PUSHA
  ;
  CALL AboutDis
  XOR AX,AX
  INT 16H
  ;消除本程序的所有显示
	MOV AX,BackGround_COLOR
	PUSH AX
	MOV	AX,FRAME_BOTTOM+CHARHEIGHT*2				;BOTTOM
	PUSH	AX
	MOV	AX,FRAME_RIGHT+2*CHARWIDTH						;RIGHT
	PUSH	AX
	MOV	AX,FRAME_TOP						;TOP
	PUSH	AX
	MOV	AX,FRAME_LEFT						;LEFT
	PUSH	AX
	CALL FILLRECT
	ADD SP,10
  POPA
  RET
FOXAbout ENDP
;****************************************************;
;*子程序名：	AboutDIS															**
;*功能：			画出about界面													**
;*入口参数：													              **
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
AboutDIS PROC NEAR
  PUSHA
  ;
  ;设置窗口及标题栏
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET STR_ABOUT_Caption			;设置标题
	PUSH	DX
	MOV	AX,PM_WND_BK_COLOR
	PUSH	AX
	MOV	AX,FRAME_BOTTOM+CHARHEIGHT*2					;BOTTOM
	PUSH	AX
	MOV	AX,FRAME_RIGHT+2*CHARWIDTH						;RIGHT
	PUSH	AX
	MOV	AX,FRAME_TOP						;TOP
	PUSH	AX
	MOV	AX,FRAME_LEFT						;LEFT
	PUSH	AX
	CALL	PUTWINDOW
	ADD	SP,14
	;画出头像
	;ACCEPT
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,About_Head_Y
	PUSH AX
	MOV	AX,About_Head_X
	PUSH AX
	CALL MyHeadPic
	ADD SP,6	
	;我的信息
	MOV	AX,SEL_BUTTON_NShadow_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Author
	PUSH AX
	MOV	AX,About_MyMes_Y+1
	PUSH AX
	MOV	AX,About_MyMes_X+1
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	
	MOV	AX,SEL_BUTTON_NShadow_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Sex
	PUSH AX
	MOV	AX,About_MyMes_Y+CHARHEIGHT+(CHARHEIGHT/4)*3+1
	PUSH AX
	MOV	AX,About_MyMes_X+1
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,SEL_BUTTON_NShadow_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Age
	PUSH AX
	MOV	AX,About_MyMes_Y+CHARHEIGHT*3+CHARHEIGHT/2+1
	PUSH AX
	MOV	AX,About_MyMes_X+1
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,SEL_BUTTON_NShadow_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Work
	PUSH AX
	MOV	AX,About_MyMes_Y+CHARHEIGHT*5+CHARHEIGHT/4+1
	PUSH AX
	MOV	AX,About_MyMes_X+1
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Author
	PUSH AX
	MOV	AX,About_MyMes_Y
	PUSH AX
	MOV	AX,About_MyMes_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Sex
	PUSH AX
	MOV	AX,About_MyMes_Y+CHARHEIGHT+(CHARHEIGHT/4)*3
	PUSH AX
	MOV	AX,About_MyMes_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Age
	PUSH AX
	MOV	AX,About_MyMes_Y+CHARHEIGHT*3+CHARHEIGHT/2
	PUSH AX
	MOV	AX,About_MyMes_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Work
	PUSH AX
	MOV	AX,About_MyMes_Y+CHARHEIGHT*5+CHARHEIGHT/4
	PUSH AX
	MOV	AX,About_MyMes_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Thank1
	PUSH AX
	MOV	AX,About_Thanks_Y
	PUSH AX
	MOV	AX,About_Thanks_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Thank2
	PUSH AX
	MOV	AX,About_Thanks_Y+CHARHEIGHT*1+CHARHEIGHT/4
	PUSH AX
	MOV	AX,About_Thanks_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Thank3
	PUSH AX
	MOV	AX,About_Thanks_Y+CHARHEIGHT*2+CHARHEIGHT/2
	PUSH AX
	MOV	AX,About_Thanks_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Thank4
	PUSH AX
	MOV	AX,About_Thanks_Y+CHARHEIGHT*3+CHARHEIGHT/4+CHARHEIGHT/2
	PUSH AX
	MOV	AX,About_Thanks_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,OFFSET STR_ABOUT_Thank5
	PUSH AX
	MOV	AX,About_Thanks_Y+CHARHEIGHT*4+CHARHEIGHT
	PUSH AX
	MOV	AX,About_Thanks_X
	PUSH AX
	CALL	PUTSTR
	ADD SP,8
	;
  POPA
  RET
AboutDIS ENDP
;****************************************************;
;*子程序名：	MyHeadPic															**
;*功能：			显示头像															**
;*入口参数：	堆栈中从顶到底：x(word),y	,color			**
;*出口参数：	无																		**
;*调用说明：	color,y,x压栈													**
;*					注意调用后平衡堆栈											**
;*					头像必须是两色的，使用8bitLB压缩算法，	**
;*					且不得大于200*200												**
;****************************************************;
MyHeadPic PROC NEAR
  PUSHA
  PUSH DS
  PUSH ES
  PUSH SI
  PUSH DI
  PUSH BP
	MOV	BP,SP			;为取参数做准备 [BP+28]=X,[BP+30]=Y,[BP+32]=COLOR	
	;SI:定位数据,DX:AX 定位显示位置 BH=Hy(0~119)  BL=Hx(0~14)  8倍压缩
	;						 DX:AX=SCREEN_WIDTH*(Hy+Y)+X+Hx*8+offset(0~7) SI 依次指向下一行Data=[SI+BL]
	;ES=0A000H 显存地址
	MOV DS:MyPicPage,0FFH
	MOV AX,0A000H
	MOV ES,AX
	MOV	BH,0
MyHeadP_WAI:									;※※※※外循环开始※※※※
	CMP BH,(HEADPIC_HEIGHT-1)
	JA	MyHeadP_EXIT
	MOV	SI,OFFSET HEADPIC
	MOV	AL,(HEADPIC_WIDTH/8)
  MUL BH
  ADD SI,AX ;定位行
  ;内循环开始                 ;※※※※内循环开始※※※※
  ;BH不能动
  PUSH BX 				;保存外循环控制计数器
	MOV	BL,0
MyHeadP_NEI:
	CMP	BL,(HEADPIC_WIDTH/8-1)
  JA  MyHeadP_NeiOver
  ;8bit循环开始 ,BL不能动
  PUSH BX          ;保存所有参数
  MOV	CX,0
MyHeadP_8Bit:							;※※※※8bit循环开始※※※※
	CMP	CX,7
	JA MyHeadP_8BitOver
	MOV	BX,SS:[BP-4]
	;取数据
	MOV	DI,BX       ;保存当前的BH,BL
	XOR BH,BH
	MOV	AL,[SI+BX]	;1byte
	SHR AL,CL
	TEST AL,01H     ;检测是否为1 为1的话ZF=0 显示
	JNZ MyHeadP_NotDis
	;计算位置，注意是否要换页
	;DX:AX=SCREEN_WIDTH*(Hy+Y)+X+Hx*8+CX(0~7)   BH=Hy(0~119)  BL=Hx(0~14)
	MOV	BX,SS:[BP-4]
	MOV	AL,8
	MUL BL
	MOV	DI,AX
	XOR AH,AH
	MOV	AL,BH
	ADD	AX,SS:[BP+30]
	MOV	BX,SCREEN_WIDTH
	MUL BX  								;DX:AX=SCREEN_WIDTH*Hy
	ADD	AX,DI
	ADC	DX,0
	ADD	AX,CX
	ADC DX,0  			 
	ADD	AX,SS:[BP+28]				;DX:AX=SCREEN_WIDTH*(Hy+Y)+X+Hx*8+CX(0~7) 
	ADC DX,0
	MOV		DI,AX
	MOV	BL,DS:MyPicPage
	CMP	DL,BL
	JZ	MyHeadP_NotNeedCPage
	MOV	BYTE PTR DS:[MyPicPage],DL  ;需要换页
	MOV		AX,04F05H
	MOV		BX,0
	INT   010H	
MyHeadP_NotNeedCPage:	
	MOV  AX,[BP+32]
	STOSB
MyHeadP_NotDis:							;※※※※8bit循环结束※※※※
	INC CX
	JMP MyHeadP_8Bit
MyHeadP_8BitOver:
  POP BX 					;还原内循环控制计数器
  INC BL 
	JMP	MyHeadP_NEI	
MyHeadP_NeiOver:						  ;※※※※内循环结束※※※※
  POP BX  				;还原外循环控制计数器
  INC BH
  JMP MyHeadP_WAI ;下一个外循环
MyHeadP_EXIT:		
	;
  POP BP
  POP DI
  POP SI
  POP ES
  POP DS
  POPA
  RET
MyHeadPic ENDP