;��ʾFox�汾�����ڵ���Ϣ
;****************************************************;
;*�ӳ�������	FoxAbout															**
;*���ܣ�			����																	**
;*��ڲ�����													              **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
FOXAbout  PROC NEAR
  PUSHA
  ;
  CALL AboutDis
  XOR AX,AX
  INT 16H
  ;�����������������ʾ
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
;*�ӳ�������	AboutDIS															**
;*���ܣ�			����about����													**
;*��ڲ�����													              **
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
AboutDIS PROC NEAR
  PUSHA
  ;
  ;���ô��ڼ�������
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	MOV	DX,OFFSET STR_ABOUT_Caption			;���ñ���
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
	;����ͷ��
	;ACCEPT
	MOV	AX,PM_StaticText_COLOR
	PUSH AX
	MOV	AX,About_Head_Y
	PUSH AX
	MOV	AX,About_Head_X
	PUSH AX
	CALL MyHeadPic
	ADD SP,6	
	;�ҵ���Ϣ
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
;*�ӳ�������	MyHeadPic															**
;*���ܣ�			��ʾͷ��															**
;*��ڲ�����	��ջ�дӶ����ף�x(word),y	,color			**
;*���ڲ�����	��																		**
;*����˵����	color,y,xѹջ													**
;*					ע����ú�ƽ���ջ											**
;*					ͷ���������ɫ�ģ�ʹ��8bitLBѹ���㷨��	**
;*					�Ҳ��ô���200*200												**
;****************************************************;
MyHeadPic PROC NEAR
  PUSHA
  PUSH DS
  PUSH ES
  PUSH SI
  PUSH DI
  PUSH BP
	MOV	BP,SP			;Ϊȡ������׼�� [BP+28]=X,[BP+30]=Y,[BP+32]=COLOR	
	;SI:��λ����,DX:AX ��λ��ʾλ�� BH=Hy(0~119)  BL=Hx(0~14)  8��ѹ��
	;						 DX:AX=SCREEN_WIDTH*(Hy+Y)+X+Hx*8+offset(0~7) SI ����ָ����һ��Data=[SI+BL]
	;ES=0A000H �Դ��ַ
	MOV DS:MyPicPage,0FFH
	MOV AX,0A000H
	MOV ES,AX
	MOV	BH,0
MyHeadP_WAI:									;����������ѭ����ʼ��������
	CMP BH,(HEADPIC_HEIGHT-1)
	JA	MyHeadP_EXIT
	MOV	SI,OFFSET HEADPIC
	MOV	AL,(HEADPIC_WIDTH/8)
  MUL BH
  ADD SI,AX ;��λ��
  ;��ѭ����ʼ                 ;����������ѭ����ʼ��������
  ;BH���ܶ�
  PUSH BX 				;������ѭ�����Ƽ�����
	MOV	BL,0
MyHeadP_NEI:
	CMP	BL,(HEADPIC_WIDTH/8-1)
  JA  MyHeadP_NeiOver
  ;8bitѭ����ʼ ,BL���ܶ�
  PUSH BX          ;�������в���
  MOV	CX,0
MyHeadP_8Bit:							;��������8bitѭ����ʼ��������
	CMP	CX,7
	JA MyHeadP_8BitOver
	MOV	BX,SS:[BP-4]
	;ȡ����
	MOV	DI,BX       ;���浱ǰ��BH,BL
	XOR BH,BH
	MOV	AL,[SI+BX]	;1byte
	SHR AL,CL
	TEST AL,01H     ;����Ƿ�Ϊ1 Ϊ1�Ļ�ZF=0 ��ʾ
	JNZ MyHeadP_NotDis
	;����λ�ã�ע���Ƿ�Ҫ��ҳ
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
	MOV	BYTE PTR DS:[MyPicPage],DL  ;��Ҫ��ҳ
	MOV		AX,04F05H
	MOV		BX,0
	INT   010H	
MyHeadP_NotNeedCPage:	
	MOV  AX,[BP+32]
	STOSB
MyHeadP_NotDis:							;��������8bitѭ��������������
	INC CX
	JMP MyHeadP_8Bit
MyHeadP_8BitOver:
  POP BX 					;��ԭ��ѭ�����Ƽ�����
  INC BL 
	JMP	MyHeadP_NEI	
MyHeadP_NeiOver:						  ;����������ѭ��������������
  POP BX  				;��ԭ��ѭ�����Ƽ�����
  INC BH
  JMP MyHeadP_WAI ;��һ����ѭ��
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