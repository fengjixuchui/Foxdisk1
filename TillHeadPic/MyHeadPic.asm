;提取头像数据，显示
;基本思想:  以两种颜色来显示图象，存储的时候以一个位来表示，也就是说120X120的图象
;           只需要(120*120)/8=1800 字节存储信息，大约3.6个扇区，可以存储在前面的扇区里。
;  					子程序如果不计存储空间的话，还可以更大些，只要不超过255，而且可以整除8的都可以
;						就是说可到252X252，再大就不行了，和程序的写法有关系建议必须小于200X200
;输入：字节MyPicPage 和headpic数据
;			 常量规定图象大小HEADPIC_WIDTH HEADPIC_HEIGHT 
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