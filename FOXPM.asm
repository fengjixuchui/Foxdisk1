;*�ӳ�������	PartMangment													**
;*�ӳ�������	PartM_Init														**
;*�ӳ�������	PartM_DIS															**
;*�ӳ�������	PartM_FunB														**
;*�ӳ�������	PartM_SetActive												**
;*�ӳ�������	PartM_OK           										**
;*�ӳ�������	PartM_Refill       										**
;*�ӳ�������	PartM_DelPartition										**
;*�ӳ�������	PartM_Clr_EditZone										**
;*�ӳ�������	PartM_USERIN													**
;*�ӳ�������	PartM_DIS_PARTxMESS										**
;*�ӳ�������	PartM_Copy_TO_NWPart									**
;*�ӳ�������	PartM_Copy_TO_PARTITIONx							**
;---------------------------------------------------------------------------
;****************************************************;
;*�ӳ�������	PartMangment													**
;*���ܣ�			�����������ϵͳ  										**
;*��ڲ�����	DS:DX	�������ַ���										**
;*						NW_PARTx�����뱣֤��������ȷ��				**
;*���ڲ�����	���ܵ�����Ч��(��)���ķ�������				**
;*						NW_PART1~4														**
;*ʹ��˵����  																			**
;****************************************************;
PartMangment PROC NEAR
  PUSHA
	CALL	PartM_DIS
	CALL	PartM_Init
	;��ȡ�û������룬����ʾ
	MOV	DS:[FUN_BUT_SEL],1			;��ǰ��ѡ���� 1 (1 SetActive  2 refill 3 delete 4 ok)
PM_GET_USEIN:
	XOR AX,AX
	INT 16H
	CMP	AX,01C0DH		;ȷ�ϼ�(Enter)
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
	;�����Ӵ���
	;1 Set Active
	CMP	DL,1
	JZ	PM_OP_SA
	;2 Refill
	CMP	DL,2				
	JZ	PM_OP_REFILL
	;3 delete	
	CMP	DL,3				
	JZ	PM_OP_DELPART
	;4 ok ���
	CMP	DL,4
	JZ	PM_OP_OK
	JMP	PM_SYS_EXIT	
;��ͷ������ʾ����
PM_UPSEL:
	PlaySound Freg_UpMove,Time_UpMove
	MOV	DL,FUN_BUT_SEL
	CMP	DL,1 						;�������Ƴ���
	JZ	PM_DLEQU1				;DL=1����
	DEC	DL
	MOV	DS:[FUN_BUT_SEL],DL
	JMP	PM_DIS_SELFRAME
PM_DLEQU1:
	MOV	DS:[FUN_BUT_SEL],4	
	JMP	PM_DIS_SELFRAME
;��ͷ������ʾ����
PM_DOWNSEL:
	PlaySound Freg_DownMove,Time_DownMove
	MOV	DL,FUN_BUT_SEL
	CMP	DL,4						;�������Ƴ���
	JZ	PM_DLEQU4				;DL=3����
	INC	DL
	MOV	DS:[FUN_BUT_SEL],DL
	JMP	PM_DIS_SELFRAME
PM_DLEQU4:
	MOV	DS:[FUN_BUT_SEL],1	
	JMP	PM_DIS_SELFRAME
;�ĸ���ť�Ĳ�ͬ����
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
	JNC	PM_SYS_EXIT							;��������Ч�������߲��������
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
;��ʾѡ��İ�ť
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
	;�˳�ȥǰ����������ʾ��ȥ
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
;----------------------------����ϵͳ����---------------------------------------------------
;****************************************************;
;*�ӳ�������	PartM_Init														**
;*���ܣ�			�����������ϵͳ��ʼ��								**
;*��ڲ�����	��ǰ����״��													**
;*���ڲ�����																				**
;*ʹ��˵����  ��ʼ����ʾ��ǰ״��										**
;****************************************************;
PartM_Init PROC NEAR
  PUSHA
  ;�����û�����ķ�����ת��ΪCHS��ģʽ
  CALL	PartM_Copy_TO_PARTITIONx
  ;��ʾ��ǰ����״��
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
  CMP AL,0   								;��Ч������������ʾ
  JZ PM_INIT_NEXT_DIS
  MOV	AL,BL
  CALL	PartM_DIS_PARTxMESS
PM_INIT_NEXT_DIS:
  LOOP	PM_INIT_PART_DIS
    
  ;��ʾ��ʼѡ���İ�ť
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
;*�ӳ�������	PartM_DIS															**
;*���ܣ�			����������ϵͳ���� 										**
;*��ڲ�����	DS:DX	�������ַ���										**
;*���ڲ�����																				**
;*ʹ��˵����  ��ܵ�λ�������ɵ����ģ���PUTWINDOW��	**
;*						����˵��															**
;****************************************************;
PartM_DIS PROC NEAR
  PUSHA
	;���ô��ڼ�������
	MOV	AX,PM_CaptionText_COLOR
	PUSH	AX
	;MOV	DX,OFFSET	STR_CAP			;���ñ���
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
	;��ʾboundary �ַ�
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
	;Boundary ת��Ϊ�ַ���������ʾ
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
	;��ʾHDMAX
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
	;��ʾPARTMES
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
	;��ʾ 1 2 3 4
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
	;�˴����༭����
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
	
	;����༭����
	;
	MOV	BL,STR_NUM1
	INC BL
	MOV	DS:[STR_NUM1],BL
	;
	JMP	PM_DIS_NUM
PM_DIS_NUM_OVER:
	POP AX		;ƽ���ջ
	MOV	DS:[STR_NUM1],'1'
	CALL	PartM_FunB
  POPA
  RET
PartM_DIS  ENDP
;****************************************************;
;*�ӳ�������	PartM_FunB														**
;*���ܣ�			��ʾ���ܰ�ť 													**
;*��ڲ�����																				**
;*���ڲ�����																				**
;****************************************************;
PartM_FunB proc near
	PUSHA
;��ʾ���ܰ�ť
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
;----------------------------�ĸ�����------------------------------------------------------------
;****************************************************;
;*�ӳ�������	PartM_SetActive												**
;*���ܣ�			���û����													**
;*��ڲ�����																				**
;*���ڲ�����																				**
;*ʹ��˵����  																			**
;****************************************************;
PartM_SetActive PROC NEAR
  PUSHA
  ;
  ;����Ƿ�����Ч�������жϻ�����Ƿ��趨
  MOV	SI,OFFSET PARTITION1		;�ӵ�һ��������ʼ�ж��Ƿ������Ч����
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
  JNZ	PM_SA_PVALID				;������Ч����������
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
  ;��ʾѡ��ķ�����
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
PM_SACTIVE_USEIN1:
  CALL PartM_USERIN              ;��ʾ�û�����
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
	PUSH AX										;�����û�����
  ;ȷ��
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y+2*CHARHEIGHT
  ;��ԭ�û�������:(1 2 3 4)
  POP BX
  SUB	BL,31H 										;�����û�����	;BL=0,1,2,3
  MOV	DL,0
PM_SACTIVE_USEIN2:
  CALL PartM_USERIN              ;��ʾ�û�����
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
  MOV	DL,0											;��������
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
	;ѡ���˻������Ĵ���
	;1 �ж�ѡ���ķ����Ƿ���Ч
	;
  PUSH BX
  MOV	AL,SIZE PartStruc
  MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	AL,[SI].PartValid
	CMP	AL,0                    ;��0��Ч
	JZ	PM_SACTIVE_INVALID				;ѡ���ķ�����Ч,��ת
	MOV	AX,[SI].PartEnd
	CMP AX,0										;ɾ��������������������
	JZ	PM_SACTIVE_INVALID				;ѡ���ķ�����Ч,��ת
	MOV	AL,[SI].PartType        ;�����ж�
	CMP AL,0CH                  ;FAT32
	JZ PM_SACTIVE_VALID
	CMP AL,07H                  ;NTFS
	JZ PM_SACTIVE_VALID
	CMP AL,06H                  ;FAT16
	JZ PM_SACTIVE_VALID
PM_SACTIVE_INVALID:	
	CALL	PartM_Clr_EditZone		;��Ч������ʾ
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
	;2 ��ʾ(���������ǰ����ʾ Ȼ������ʾ��ǰ��ѡ��)
	;
	POP	BX
	PUSH BX
	
	MOV	CX,4
	;����ϴε���ʾ
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
	;��ʾ��ǰ��ѡ�� 
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
  ;3 ��д��ϵͳ���÷������(flag)��
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
;*�ӳ�������	PartM_OK           										**
;*���ܣ�			�������Ƿ���Ч����д����						**
;*��ڲ�����																				**
;*���ڲ�����	CF=1 AL=1 �����û���趨						**
;*								 AL=0 ����������Ҫ��							**
;*						CF=0 �ɹ�															**
;****************************************************;
PartM_OK PROC NEAR
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  ;����Ƿ�����Ч�������жϻ�����Ƿ��趨
  ;1����Ƿ�����Ч�������жϻ�����Ƿ��趨
  MOV	SI,OFFSET PARTITION1		;�ӵ�һ��������ʼ�ж��Ƿ������Ч����
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
  MOV	SI,OFFSET PARTITION1		;�ӵ�һ��������ʼ�ж��Ƿ������Ч����
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
  ;2 ����������ߵķ�����
  MOV	SI,OFFSET PARTITION1
  CALL TestPartValid				;�����д�ķ����Ƿ����Ҫ��
	JC	PM_OK_InvalidPartS	
	CALL PartM_Copy_TO_NWPart
  JMP	PM_OK_ALL_FINISH
PM_OK_InvalidPartS:
  STC
	MOV	AL,0
	JMP	PM_OK_EXIT
PM_OK_NOTACTIVE:
	MOV	AL,1
  STC   										;CF=1���黹û���꣬û�л����
  JMP	PM_OK_EXIT
PM_OK_PINVALID:							;��������Ч����,���ò���
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
;*�ӳ�������	PartM_Refill       										**
;*���ܣ�			��������															**
;*��ڲ�����	PARTITIONx														**
;*���ڲ�����	PARTITIONx														**
;****************************************************;
PartM_Refill PROC NEAR
  PUSHA
 	;1 ѡ�������ķ���
 	;��ʾѡ��ķ�����
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
  XOR BX,BX
PM_REFILL_SELPART:
  CALL PartM_USERIN              ;��ʾ�û�����
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
;�����Ѿ�ѡ��ã�bl='1'  '2'  '3'  '4'
;2 �趨������ʽ
	SUB	BL,31H
  PUSH BX 								;@@1����ѡ���ķ��� BL=0 1 2 3 
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
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
  ;�����
  MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	;��ȡ�û�����
PM_REFILL_GET_TYPE:
	MOV	AX,2
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2
	MOV	CL,STD_BUF_COUNT
	CMP	CL,0
	JZ	PM_REFILL_GET_TYPE
	;
	;���ֽ� STD_BUF->STD_D2H_BUF	
	MOV	CL,STD_BUF_COUNT
	MOV	AL,8
	MUL	CL
	MOV	CL,AL 							;��λ������ 
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
	CALL	DB_STR2HEX						;al=��������
  POP BX 											;@@1ѡ���ķ��� bl=0 1 2 3
  MOV	DL,AL 									;�����������
  MOV	SI,OFFSET PARTITION1
  MOV	AL,SIZE PartStruc
  MUL	BL
  ADD	SI,AX
  MOV	[SI].PartType,DL
	CALL	PartM_Clr_EditZone
  PUSH BX 										;@@2����ѡ���ķ��� bl=0 1 2 3
  ;3 ��ʼ��ȡ�û�����ķ�����ʼ�ŵ� �ͽ����ŵ�,��ʾ
  ;��ʾ��ǰ���õĴŵ���Ŀ
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ��Ϣ��ʾλ�� 
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
  ;��ȡ��ʼ�ŵ�
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
  ;����û����ϴ�����
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
	MOV	AX,5
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2 										;ƽ���ջ
	MOV	AL,STD_BUF_COUNT
	CMP AL,0
	JZ PM_REFILL_GETSTARTCYL
	;
	;���ֽ� STD_BUF->STD_D2H_BUF	
	MOV	DI,OFFSET STD_D2H_BUF
	MOV DWORD PTR [DI],030303030H
	MOV BYTE PTR [DI+4],030H
	;
	XOR CX,CX
	MOV	CL,STD_BUF_COUNT
	MOV	SI,OFFSET STD_BUF
	ADD SI,CX
	DEC SI
	ADD	DI,4           ;5���ֽڣ���λ
	STD                ;�����־��������
	REP MOVSB
	;		
  CALL DW_STR2HEX						;AX=�û������ֵ
  JC	PM_REFILL_GETSTARTCYL	;������û������ֵ����0ffffh
  MOV	CX,PM_MINCYL
	CMP	AX,CX 								;С�ڵ��ڹ涨����Сֵ���������
	JB	PM_REFILL_GETSTARTCYL
	MOV	CX,PM_MAXCYL
	CMP	AX,CX 								;���ڵ��ڹ涨�����ֵ���������
	JAE	PM_REFILL_GETSTARTCYL
	MOV	DX,AX                 ;DX�����û��趨�Ŀ�ʼ�ŵ�
	;ok,���յ�����Ҫ��Ŀ�ʼ�ŵ�,��д����
	POP BX 											;@@2ѡ���ķ��� bl=0 1 2 3
	PUSH BX 										;@@3����ѡ���ķ��� bl=0 1 2 3
	MOV	AL,SIZE PartStruc
	MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	DS:[SI].PartStart,DX
	;�����ʾ�Ĺ��
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
	;���ս����ŵ�������
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y+2*CHARHEIGHT
  ;����û����ϴ�����
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
	MOV	AX,5
	PUSH AX
	CALL	GETSTRING
	ADD	SP,2 										;ƽ���ջ
	;���ֽ� STD_BUF->STD_D2H_BUF	
	MOV	DI,OFFSET STD_D2H_BUF
	MOV DWORD PTR [DI],030303030H
	MOV BYTE PTR [DI+4],030H
	;
	XOR CX,CX
	MOV	CL,STD_BUF_COUNT
	MOV	SI,OFFSET STD_BUF
	ADD SI,CX
	DEC SI
	ADD	DI,4           ;5���ֽڣ���λ
	STD                ;�����־��������
	REP MOVSB
	;
  CALL DW_STR2HEX						;AX=�û������ֵ
  JC	PM_REFILL_GETENDCYL		;������û������ֵ����0ffffh
	MOV	 DI,AX                 ;DI�����û��趨�Ľ����ŵ�
  POP BX 										;��ǰѡ���ķ���bl=0 1 2 3
  PUSH BX
  MOV	AL,SIZE PartStruc
	MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	DX,DS:[SI].PartStart  ;�û�����Ŀ�ʼ�ŵ�
	;��ʼ�Ƚ��Ƿ����Ҫ��
  MOV	CX,PM_MINCYL
 	CMP	DI,CX 								;С�ڹ涨����Сֵ���������
	JBE	PM_REFILL_GETENDCYL
	MOV	CX,PM_MAXCYL
	CMP	DI,CX 								;���ڹ涨�����ֵ���������
	JA	PM_REFILL_GETENDCYL
	CMP	DI,DX
	JBE  PM_REFILL_GETENDCYL		;С������Ŀ�ʼ�ŵ����������
	MOV	DX,DI                 ;DX�����û��趨�Ľ����ŵ�
	;ok,���յ�����Ҫ��Ľ����ŵ�,��д����
	POP BX 											;@@3ѡ���ķ��� bl=0 1 2 3
	PUSH BX 										;@@4����ѡ���ķ��� bl=0 1 2 3
	MOV	AL,SIZE PartStruc
	MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	DS:[SI].PartEnd,DX
	MOV	DS:[SI].PartValid,01H 	;������Ч�趨
	;
	POP AX 											;@@4ѡ���ķ��� bl=0 1 2 3
	CALL PartM_DIS_PARTxMESS
	CALL PartM_Clr_EditZone
PM_REFILL_EXIT:
  POPA
  RET
PartM_Refill ENDP
;****************************************************;
;*�ӳ�������	PartM_DelPartition										**
;*���ܣ�			ɾ���û�ָ���ķ���										**
;*��ڲ�����																				**
;*���ڲ�����	PARTITIONx														**
;****************************************************;
PartM_DelPartition PROC NEAR
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  ;
  ;����Ƿ�����Ч�������жϻ�����Ƿ��趨
  MOV	SI,OFFSET PARTITION1		;�ӵ�һ��������ʼ�ж��Ƿ������Ч����
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
  JNZ	PM_DelP_PVALID				;������Ч����������
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
  ;��ʾѡ��ķ�����
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y
PM_DelPart_USEIN1:
  CALL PartM_USERIN              ;��ʾ�û�����
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
	PUSH AX										;�����û�����
  ;ȷ��
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
  POP CX                       ;ƽ���ջ
  MOV	CL,CHARWIDTH
  ADD	AL,1
  MUL CL
  ADD	AX,FUN_ASK_X							;��λ�û�����λ�� (���)
  MOV	DS:[XCUR],AX
  MOV	DS:[YCUR],FUN_ASK_Y+2*CHARHEIGHT
  ;��ԭ�û�������:(1 2 3 4)
  POP BX
  SUB	BL,31H 										;�����û�����	;BL=0,1,2,3
  MOV	DL,0
PM_DelPart_USEIN2:
  CALL PartM_USERIN              ;��ʾ�û�����
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
  MOV	DL,0											;��������
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
	;ѡ���˷�����Ĵ���
	;1 �ж�ѡ���ķ����Ƿ���Ч
	;
  PUSH BX
  MOV	AL,SIZE PartStruc
  MUL BL
	MOV	SI,OFFSET PARTITION1
	ADD	SI,AX
	MOV	AL,[SI].PartValid
	CMP	AL,0                    ;��0��Ч
	JZ	PM_DelPart_INVALID			;ѡ���ķ�����Ч,��ת
	JMP PM_DelP_VALID
PM_DelPart_INVALID:	
	CALL	PartM_Clr_EditZone		;��Ч������ʾ
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
  ;2 ��ѡ���ķ��������
  PUSH DS
  POP ES
  MOV	DI,OFFSET PARTITION1
  XOR	AX,AX
  MOV	AL,SIZE PartStruc
  MUL BL
  ADD	DI,AX
  MOV	CX,SIZE PartStruc
  DEC CX 								;ע�⣬�˷����Ǳ�ɾ���ģ����Ի�����Ч����
  CLD 
  MOV	AL,00H
  REP STOSB
;
	MOV	AL,BL
	CALL PartM_DIS_PARTxMESS	
  PUSH BX
  ;�˴����༭����
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
	POP BX 					;��ԭ��ڲ���
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
  POP BX 					;��ԭ��ڲ���
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
  POP BX 					;��ԭ��ڲ���
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
;---------------------------��ϵͳ�Ĺ��ó���-----------------------------------------------
;****************************************************;
;*�ӳ�������	PartM_Clr_EditZone										**
;*���ܣ�			����ӹ��ܵ���ʾ��										**
;*��ڲ�����																				**
;*���ڲ�����																				**
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
;*�ӳ�������	PartM_USERIN													**
;*���ܣ�			��ʾ�û����� 													**
;*��ڲ�����																				**
;*���ڲ�����	ax=�û�����														**
;****************************************************;	
PartM_USERIN	PROC	NEAR
	PUSH CX
	PUSH BX
	PUSH DX
	PUSH SI
	PUSH DI
	
	XOR	AX,AX
	INT 16H
	PUSH AX  							;�����û�����
	CMP	AL,21H
	JB	PM_USERIN_NOT_CLEARDIS
	CMP	AL,7FH
	JA	PM_USERIN_NOT_CLEARDIS
	;����ϴε���ʾ
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
  POP AX  							;�����û�����
  PUSH AX
  CMP	AL,21H            ;ֻ��ʾ�ɼ��ַ�
  JB	PM_USERRIN_EXIT
  CMP	AL,7FH
  JA	PM_USERRIN_EXIT
	MOV	CX,PM_CURSOR_COLOR
	PUSH CX
	PUSH AX 							;��ʾ
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
;*�ӳ�������	PartM_DIS_PARTxMESS										**
;*���ܣ�			��ʾ�涨�ķ�����Ϣ										**
;*��ڲ�����	al=0,1,2,3 PARTITION1									**
;*���ڲ�����																				**
;****************************************************;
PartM_DIS_PARTxMESS PROC NEAR
  PUSHA
  PUSH AX  ;������ڲ���
  ;
  MOV	BL,AL
  MOV	DL,AL
  MOV	AL,SIZE PartStruc
  MUL BL
  MOV	BX,OFFSET PARTITION1
  ADD	BX,AX    										;��λ������1 2 3 4
  ;�ж��Ƿ��ǻ������������ʾ 'A'
  MOV	CL,DS:[BX].PartActive
  CMP	CL,80H
  JNZ	PM_DIS_PARTX_NOTACTIVE
  MOV	CX,PM_ActiveFlag_COLOR
  PUSH CX
	MOV	CX,'A'
  PUSH CX
	MOV	AL,2*CHARHEIGHT
  MUL DL 												;DL=0,1,2,3=��ڲ���
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
  MUL DL 												;DL=0,1,2,3=��ڲ���
	MOV	CX,ACTIVE_FLAG1_Y
	ADD	CX,AX
  PUSH CX
	MOV	CX,ACTIVE_FLAG1_X
  PUSH CX
	CALL	PUTASCII
	ADD	SP,8
PM_DIS_PARTX_DISAC_OVER:
	;�����Ϣ��ʾ
	;��������
	MOV	AL,DS:[BX].PartType
	CALL	DB_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET BUF_STR_PTYPE
  MOV	AX,WORD PTR DS:[SI]
  MOV WORD PTR DS:[DI],AX
  ;��ʼ�ŵ� 
  MOV	AX,DS:[BX].PartStart
	CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET BUF_STR_PSTART
  MOV	EAX,DWORD PTR DS:[SI]
  MOV	DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV BYTE PTR DS:[DI+4],AL
  ;�����ŵ�
  MOV	AX,DS:[BX].PartEnd
	CALL	DW_HEX2STR
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	DI,OFFSET BUF_STR_PEND
  MOV	EAX,DWORD PTR DS:[SI]
  MOV DWORD PTR DS:[DI],EAX
  MOV	AL,BYTE PTR DS:[SI+4]
  MOV BYTE PTR DS:[DI+4],AL
  ;��������
  XOR ECX,ECX
  XOR EAX,EAX
  MOV	CX,DS:[BX].PartEnd
  MOV	AX,DS:[BX].PartStart
  SUB	CX,AX
  CMP	CX,0
  JNZ  PartM_DIS_PARTx_LBASE0			;��ʼ�����ͽ���������ͬ��ʵ���Ǵ������Ƕ���0�����
  MOV	CX,0
  JMP	PartM_DIS_PARTx_LBASE0_DONE
PartM_DIS_PARTx_LBASE0:
  INC	CX    ;��ǰ�����ܴŵ���
PartM_DIS_PARTx_LBASE0_DONE:
  MOV	AX,03EC1H
  MUL ECX     			;������������=EDX:EAX   ;EDX=0
  MOV	ECX,2*1024 		;��'M'Ϊ��λ
  DIV ECX 					;��=eax
	CALL DD_HEX2STR  
	XOR	ECX,ECX
	MOV	CX,8
	PUSH DS
	POP ES
	MOV	SI,OFFSET STD_DWORD2H_BUF
	MOV	DI,OFFSET BUF_STR_PCAP
  CLD
  REP MOVSB
  ;��ʼ��ʾ
  POP BX 					;��ԭ��ڲ���
  PUSH BX
  ;�˴����༭����
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
	POP BX 					;��ԭ��ڲ���
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
  POP BX 					;��ԭ��ڲ���
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
  POP BX 					;��ԭ��ڲ���
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
	POP BX 					;��ԭ��ڲ���
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
;*�ӳ�������	PartM_Copy_TO_NWPart									**
;*���ܣ�			���û����úõķ���ת�����ṩ�Է�����ϵ**
;*						ͳ�Ľӿ�															**
;*��ڲ�����	PARTITION1~4													**
;*���ڲ�����	NW_PART1~4														**
;****************************************************;
PartM_Copy_TO_NWPart PROC NEAR 
  PUSHA
  ;
  ;1 ����ǰ������
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
	;2 �����Ч����������
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
	MOV BP,CX             ;����CX
	MOV	CL,SIZE PartStruc
	CLD
  REP MOVSB
	CALL CHS2LBA
	MOV DI,OFFSET NW_PART1
	MOV SI,OFFSET HD_LBABUF
	MOV CX,BP             ;��ԭCX
	MOV AL,SIZE Part_Entry
	MOV DL,CL
	DEC DL
  MUL DL
	ADD DI,AX
	MOV BP,CX               ;����CX
	MOV CX,SIZE Part_Entry
  CLD
  REP MOVSB
  MOV CX,BP 							;��ԭCX
PM_CNWpart_INVALIDPART:
  LOOP PM_CNWpart_FILL
  POPA
  RET
PartM_Copy_TO_NWPart ENDP
;****************************************************;
;*�ӳ�������	PartM_Copy_TO_PARTITIONx							**
;*���ܣ�			���û�����ķ���ת�������봦����			**
;*��ڲ�����	NW_PART1~4														**
;*���ڲ�����	PARTITION1~4													**
;****************************************************;
PartM_Copy_TO_PARTITIONx PROC NEAR 
  PUSHA
  ;
  ;1 ����ǰ������
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
	;2 ת�������� Nw_part->Partition
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
	MOV BP,CX             ;����CX
	MOV	CL,SIZE Part_Entry
	CLD
  REP MOVSB 						;����Nw_part->HD_LBABUF
	CALL LBA2CHS
	MOV DI,OFFSET PARTITION1
	MOV SI,OFFSET HD_CHSBUF
	MOV CX,BP             ;��ԭCX
	MOV AL,SIZE PartStruc
	MOV DL,CL
	DEC DL
  MUL DL
	ADD DI,AX  							;��λ
	MOV BP,CX               ;����CX
	MOV CX,SIZE PartStruc
  CLD
  REP MOVSB
  MOV CX,BP 							;��ԭCX
  LOOP PM_PARTITIONx_FILL
  POPA
  RET
PartM_Copy_TO_PARTITIONx ENDP

