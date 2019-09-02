;����̨I/O,�ײ������������û����������ı�׼������������Ԥ���ģ�
;luobing 2007-2-28
;*�ӳ�������	PUTCURSOR															** 
;*�ӳ�������	GETSTRING															** 
;*�ӳ�������	DW_STR2HEX														**
;*�ӳ�������	DB_STR2HEX														**
;*�ӳ�������	DW_HEX2STR														**
;*�ӳ�������	DB_HEX2STR														**
;*�ӳ�������	DD_HEX2STR														**
;*�ӳ�������	PUTCURSOR															** 
;*�ӳ�������	GETSTRING															** 
;*�ӳ�������	DW_STR2HEX														**
;*�ӳ�������	DB_STR2HEX														**
;*�ӳ�������	DW_HEX2STR														**
;*�ӳ�������	DB_HEX2STR														**
;*�ӳ�������	DD_HEX2STR														**
;*�ӳ�������	STRNCMP																**
;----------------------------------------------------------------------------
;****************************************************; 
;*�ӳ�������	PUTCURSOR															** 
;*���ܣ�			��ʾ���															** 
;*��ڲ�����	��ջ�дӶ����ף�x,y,color							** 
;*���ڲ�����	�ı���xcur,ycur(��ǰxy����)						** 
;*����˵�����Ƚ�colorѹջ,���y,x										** 
;*					ע����ú�ƽ���ջ											** 
;*****************************************************
PUTCURSOR	PROC	NEAR
	PUSHA
	PUSH	BP
	MOV	BP,SP								;;[BP+20]=X,[BP+22]=Y,[BP+24]=COLOR
	PUSH	SI
	PUSH	DI
	MOV	SI,WORD PTR [BP+22]			;si=y
   ;	
	MOV	AX,WORD PTR [BP+20]
	MOV	XCUR,AX
   ;
	MOV	YCUR,SI
   ;	
	XOR	DI,DI
	JMP	SHORT PUTCUR_ADD
PUTCUR_CTRL:
   ;	
	PUSH	WORD PTR [BP+24]
	PUSH	WORD PTR [BP+20]
	MOV	AX,SI
	ADD	AX,CHARHEIGHT				;���ĸ߶����ַ��߶�
	DEC	AX									
	PUSH	AX
	PUSH	SI
	CALL	NEAR PTR VLINE
	ADD	SP,8
	INC	DI
PUTCUR_ADD:
	CMP	DI,2								;���Ŀ����2
	JL	SHORT PUTCUR_CTRL
   ;
	POP	DI
	POP	SI
	POP	BP
	POPA
	RET	
PUTCURSOR	ENDP
;****************************************************; 
;*�ӳ�������	GETSTRING															** 
;*���ܣ�			�Ӽ��̶���һ�������ַ����س�����			** 
;*��ڲ�����	Count:������ַ�������ѹջ(<50)				** 
;*���ڲ�����																				** 
;*����˵����	ʹ�ú����ȥSTDȡ�ַ���								** 
;*					ע����ú�ƽ���ջ											** 
;*****************************************************
GetString PROC NEAR
  PUSHA                   ;ѹջ8���Ĵ���
	PUSH	BP
	MOV	BP,SP								;;[BP+20]=Count
	PUSH	SI
	PUSH	DI
	;MOV	CX,WORD PTR [BP+20]			;CX=Count
  ;
  MOV	AL,0
  MOV	CX,50
  MOV	DI,OFFSET STD_BUF
  PUSH DS
  POP ES
  CLD
  REP STOSB
  MOV	DS:[STD_BUF_COUNT],00H				;��ʼ��STD 
GETS_USERIN:
	XOR	AX,AX
  INT 16H
  CMP	AX,1C0DH						;Enter
  JZ	GETS_IN_ENTER
  CMP	AX,0E08H						;Backspace ���˼�
  JZ  GETS_IN_BK
  CMP	AL,'0'
  JAE	GETS_IN_JUDVALID0		;�ж������Ƿ���Ч
  CMP	AL,'9'
  JBE	GETS_IN_JUDVALID9		;�ж������Ƿ���Ч
  JMP	GETS_USERIN
GETS_IN_JUDVALID0:				;����'0' �����ж�
	CMP	AL,'9'
	JBE	GETS_IN_ISVALID
	JMP	GETS_USERIN
GETS_IN_JUDVALID9:				;С��'9' �����ж�
	CMP	AL,'0'
	JAE	GETS_IN_ISVALID
	JMP	GETS_USERIN
;@@1��Ч����Ĵ���
GETS_IN_ISVALID:
	;1 �ı����̨�Ļ�����
	;AL=����
  MOV	DX,AX 									;�����û�����
  XOR	AX,AX
	MOV	AL,STD_BUF_COUNT
	MOV	CX,WORD PTR [BP+20]			;CX=Count
	CMP	AL,CL
	JAE	GETS_USERIN							;���ֻ�ܽ����û��涨�ĸ���
	MOV	BX,OFFSET STD_BUF
	ADD	BX,AX
  MOV AX,DX 									;��ԭ�û�����
	MOV	BYTE PTR DS:[BX],AL
	MOV	CL,STD_BUF_COUNT
	INC	CL
	MOV	DS:[STD_BUF_COUNT],CL
	;2 �ڵ�ǰλ����ʾ�ַ�
	MOV	BX,PM_WND_BK_COLOR
	PUSH BX
	MOV	BX,0FFH
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTASCII
	ADD	SP,8
	MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	PUSH AX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTASCII
	ADD	SP,8
	;3 ������,��ʾ
	MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	ADD BX,CHARWIDTH		;����һ���ַ��Ŀ��
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	JMP	GETS_USERIN
GETS_IN_BK:
;@@2���˼�����STD_BUF_COUNT-1,STD_BUF���һ���ַ�
	;						���ǰ�ƣ���ǰ��ʾ����
	XOR	AX,AX
	MOV	AL,STD_BUF_COUNT
	CMP	AL,0
	JZ	GETS_USERIN		;���ַ���������
	DEC AL
	MOV	DS:[STD_BUF_COUNT],AL
	MOV	BX,OFFSET STD_BUF
	ADD	BX,AX
	MOV BYTE PTR DS:[BX],00H	;�����ַ�
	;��ʾ
	;�������
	MOV	BX,PM_WND_BK_COLOR
	PUSH BX
	MOV	BX,0FFH
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTASCII
	ADD	SP,8
	;
	MOV	AX,XCUR
	SUB	AX,CHARWIDTH
	MOV	DS:[XCUR],AX
	;������ʾ���ַ�
	MOV	BX,PM_WND_BK_COLOR
	PUSH BX
	MOV	BX,0FFH
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTASCII
	ADD	SP,8
	;
	MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	;
	JMP	GETS_USERIN
GETS_IN_ENTER:
	PlaySound Freg_Enter,Time_Enter
	
	POP	DI
	POP	SI
	POP	BP
  POPA
	RET	
GetString ENDP
;****************************************************;
;*�ӳ�������	DW_STR2HEX														**
;*���ܣ�			�ַ���ת��Ϊʮ��������								**
;*��ڲ�����	STD_D2H_BUF ����ֽ�									**
;*���ڲ�����	CF=0 AX=���	CF=1 ���								**
;*ʹ��˵����  																			**
;****************************************************;
DW_STR2HEX PROC NEAR
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  XOR	ESI,ESI
  XOR	EAX,EAX
  XOR	EDX,EDX
  XOR ECX,ECX
  MOV	BX,OFFSET STD_D2H_BUF
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  MOV	CX,10000
  MUL	ECX
  MOV	ESI,EAX
  INC BX
  XOR	EAX,EAX
  XOR	EDX,EDX
  XOR ECX,ECX
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  MOV	CX,1000
  MUL	ECX
  ADD	ESI,EAX
  XOR	EAX,EAX
  XOR	EDX,EDX
  XOR ECX,ECX
  INC BX
  XOR	EAX,EAX
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  MOV	CL,100
  MUL	ECX
  ADD	ESI,EAX
  XOR	EAX,EAX
  XOR	EDX,EDX
  XOR ECX,ECX
  INC BX
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  MOV	CL,10
  MUL	ECX
  ADD	ESI,EAX
  XOR	EAX,EAX
  XOR	EDX,EDX
  XOR ECX,ECX
  INC BX
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  ADD ESI,EAX
  MOV	EAX,ESI
  CMP	EAX,0FFFFH
  JA	DW_STR2HEX_OVERFLOW
  CLC
  JMP	DW_STR2HEX_EXIT
DW_STR2HEX_OVERFLOW:
  STC
DW_STR2HEX_EXIT:
  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  RET
DW_STR2HEX ENDP
;****************************************************;
;*�ӳ�������	DB_STR2HEX														**
;*���ܣ�			�ַ���ת��Ϊʮ�������ֽ�							**
;*��ڲ�����	STD_D2H_BUF �����ֽ�									**
;*���ڲ�����	AL=���																**
;*ʹ��˵����  																			**
;****************************************************;
DB_STR2HEX PROC NEAR
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  XOR	SI,SI
  XOR	AX,AX
  MOV	BX,OFFSET STD_D2H_BUF
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  MOV	CL,10
  MUL	CL
  MOV	SI,AX
  INC BX
  XOR	AX,AX
  MOV	AL,BYTE PTR DS:[BX]
  SUB	AL,30H
  ADD SI,AX
  MOV	AX,SI
  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  RET
DB_STR2HEX ENDP
;****************************************************;
;*�ӳ�������	DW_HEX2STR														**
;*���ܣ�			ʮ��������ת��Ϊ�ַ���								**
;*��ڲ�����	AX																		**
;*���ڲ�����	STD_D2H_BUF��													**
;*ʹ��˵����  AX  (0~FFFF)��������								**
;****************************************************;
DW_HEX2STR PROC NEAR
  PUSHA
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	EDX,030303030H
  MOV	DWORD PTR DS:[SI],EDX
  MOV	BYTE PTR [SI+4],30H
  ;��AXת��Ϊѹ��BCD��
  XOR EDX,EDX 					;��ֹ�����ʹ��32λ����
  XOR ESI,ESI
  MOV	CX,0AH
  DIV CX              ;�� AX  ���� DX ��
  MOV	ESI,EDX
  XOR	DX,DX
  DIV CX 							;�� AX  ���� DX ��
  AND	DX,0FH
  SHL DX,4
  ADD	ESI,EDX
  XOR	DX,DX
  DIV CX 							;�� AX  ���� DX ��
  AND	DX,0FH
  SHL DX,8
  ADD	ESI,EDX
  XOR	DX,DX
  DIV CX 							;�� AX  ���� DX ��
  AND	DX,0FH
  SHL DX,12
  ADD	ESI,EDX
  XOR	DX,DX
  DIV CX 							;�� AX  ���� DX ��
  AND DX,0FH
  SHL EDX,16
  AND EDX,0F0000H
  ADD ESI,EDX
  MOV EAX,ESI
  ;ת��Ϊ�ַ���
  XOR ECX,ECX
  MOV	CL,5
  MOV	BX,OFFSET STD_D2H_BUF
  ADD	BX,4
DW_H2S_LOOP:
	MOV	DL,AL
	AND	DL,0FH
	ADD	DL,30H
	MOV BYTE PTR DS:[BX],DL
  DEC BX
	SHR EAX,4
	LOOP DW_H2S_LOOP
	;
  POPA
  RET
DW_HEX2STR ENDP
;****************************************************;
;*�ӳ�������	DB_HEX2STR														**
;*���ܣ�			ʮ�������ֽ�ת��Ϊ�ַ���							**
;*��ڲ�����	AL																		**
;*���ڲ�����	STD_D2H_BUF��													**
;*ʹ��˵����  AL  (0~99)��������									**
;****************************************************;
DB_HEX2STR PROC NEAR
  PUSHA
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	EDX,030303030H
  MOV	DWORD PTR DS:[SI],EDX
  ;��AXת��Ϊѹ��BCD��
  XOR AH,AH 					;ʹ��16λ����
  MOV	CX,0AH
  DIV CL              ;�� AL  ���� AH 
  ADD	AH,30H
  ADD	AL,30H
  MOV	WORD PTR DS:[SI],AX
  ;
  POPA
  RET
DB_HEX2STR ENDP

;****************************************************;
;*�ӳ�������	DD_HEX2STR														**
;*���ܣ�			ʮ��������ת��Ϊ�ַ���								**
;*��ڲ�����	EAX																		**
;*���ڲ�����	STD_D2H_BUF��													**
;*ʹ��˵����  EAX  (0~99999999)��������						**
;****************************************************;
DD_HEX2STR PROC NEAR
  PUSHA
  MOV	SI,OFFSET STD_DWORD2H_BUF
  MOV	EDX,030303030H
  MOV	DWORD PTR DS:[SI],EDX
  ADD	SI,4
  MOV	DWORD PTR DS:[SI],EDX
  ;��EAXת��Ϊѹ��BCD��
  MOV	CL,0
  XOR ESI,ESI 					;��ֹ�����ʹ��64λ����
DD_H2S_DIVLOOP:
	XOR EDX,EDX
	CMP	CL,4*8
	JAE	DD_H2S_DIV_OVER
  MOV EBX,0AH
  DIV EBX                 ;�� EAX  ���� EDX 
  AND EDX,0FH
  SHL EDX,CL
  ADD ESI,EDX
  ADD CL,4
  JMP DD_H2S_DIVLOOP
DD_H2S_DIV_OVER:
  MOV	EAX,ESI
  ;ת��Ϊ�ַ���
  XOR	ECX,ECX
  MOV	CL,8
  MOV	BX,OFFSET STD_DWORD2H_BUF
  ADD	BX,7
DD_H2S_LOOP:
	MOV	DL,AL
	AND	DL,0FH
	ADD	DL,30H
	MOV BYTE PTR DS:[BX],DL
  DEC BX
	SHR EAX,4
	LOOP DD_H2S_LOOP
	;
  POPA
  RET
DD_HEX2STR ENDP
;****************************************************;
;*�ӳ�������	STRNCMP																**
;*���ܣ�			�ַ����Ƚ�														**
;*��ڲ�����	DS:SI Դ�ַ���	ES:DI Ŀ���ַ���			**
;*						CX:�Ƚϵ��ַ�����											**
;*���ڲ�����	CF=1 ����ͬ  CF=0 ��ͬ								**
;****************************************************;
StrNCmp  PROC NEAR
  PUSHA
  CLD 				;˳����Ƚ�
  REPZ CMPSB ;�ȱȽϣ���ʹSI,DI��1
  MOV	AL,[SI-1]
  MOV	BL,[DI-1]
  CMP	AL,BL
  JZ	StrNCmp_Match
  STC  				;����ͬ
  JMP	StrNCmp_EXIT
StrNCmp_Match:
  CLC
StrNCmp_EXIT:	
  POPA
  RET
StrNCmp  ENDP