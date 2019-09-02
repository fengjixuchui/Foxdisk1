;控制台I/O,底层汇编用来接收用户输入和输出的标准程序（我是这样预定的）
;luobing 2007-2-28
;*子程序名：	PUTCURSOR															** 
;*子程序名：	GETSTRING															** 
;*子程序名：	DW_STR2HEX														**
;*子程序名：	DB_STR2HEX														**
;*子程序名：	DW_HEX2STR														**
;*子程序名：	DB_HEX2STR														**
;*子程序名：	DD_HEX2STR														**
;*子程序名：	PUTCURSOR															** 
;*子程序名：	GETSTRING															** 
;*子程序名：	DW_STR2HEX														**
;*子程序名：	DB_STR2HEX														**
;*子程序名：	DW_HEX2STR														**
;*子程序名：	DB_HEX2STR														**
;*子程序名：	DD_HEX2STR														**
;*子程序名：	STRNCMP																**
;----------------------------------------------------------------------------
;****************************************************; 
;*子程序名：	PUTCURSOR															** 
;*功能：			显示光标															** 
;*入口参数：	堆栈中从顶到底：x,y,color							** 
;*出口参数：	改变了xcur,ycur(当前xy坐标)						** 
;*调用说明：先将color压栈,其次y,x										** 
;*					注意调用后平衡堆栈											** 
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
	ADD	AX,CHARHEIGHT				;光标的高度是字符高度
	DEC	AX									
	PUSH	AX
	PUSH	SI
	CALL	NEAR PTR VLINE
	ADD	SP,8
	INC	DI
PUTCUR_ADD:
	CMP	DI,2								;光标的宽度是2
	JL	SHORT PUTCUR_CTRL
   ;
	POP	DI
	POP	SI
	POP	BP
	POPA
	RET	
PUTCURSOR	ENDP
;****************************************************; 
;*子程序名：	GETSTRING															** 
;*功能：			从键盘读入一串数字字符，回车返回			** 
;*入口参数：	Count:读入的字符个数，压栈(<50)				** 
;*出口参数：																				** 
;*调用说明：	使用后必须去STD取字符，								** 
;*					注意调用后平衡堆栈											** 
;*****************************************************
GetString PROC NEAR
  PUSHA                   ;压栈8个寄存器
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
  MOV	DS:[STD_BUF_COUNT],00H				;初始化STD 
GETS_USERIN:
	XOR	AX,AX
  INT 16H
  CMP	AX,1C0DH						;Enter
  JZ	GETS_IN_ENTER
  CMP	AX,0E08H						;Backspace 回退键
  JZ  GETS_IN_BK
  CMP	AL,'0'
  JAE	GETS_IN_JUDVALID0		;判断输入是否有效
  CMP	AL,'9'
  JBE	GETS_IN_JUDVALID9		;判断输入是否有效
  JMP	GETS_USERIN
GETS_IN_JUDVALID0:				;大于'0' 继续判断
	CMP	AL,'9'
	JBE	GETS_IN_ISVALID
	JMP	GETS_USERIN
GETS_IN_JUDVALID9:				;小于'9' 继续判断
	CMP	AL,'0'
	JAE	GETS_IN_ISVALID
	JMP	GETS_USERIN
;@@1有效输入的处理
GETS_IN_ISVALID:
	;1 改变控制台的缓冲区
	;AL=输入
  MOV	DX,AX 									;保存用户输入
  XOR	AX,AX
	MOV	AL,STD_BUF_COUNT
	MOV	CX,WORD PTR [BP+20]			;CX=Count
	CMP	AL,CL
	JAE	GETS_USERIN							;最大只能接受用户规定的个数
	MOV	BX,OFFSET STD_BUF
	ADD	BX,AX
  MOV AX,DX 									;还原用户输入
	MOV	BYTE PTR DS:[BX],AL
	MOV	CL,STD_BUF_COUNT
	INC	CL
	MOV	DS:[STD_BUF_COUNT],CL
	;2 在当前位置显示字符
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
	;3 光标后移,显示
	MOV	BX,PM_CURSOR_COLOR
	PUSH BX
	MOV	BX,YCUR
	PUSH BX
	MOV	BX,XCUR
	ADD BX,CHARWIDTH		;后移一个字符的宽度
	PUSH BX
	CALL	PUTCURSOR
	ADD	SP,6
	JMP	GETS_USERIN
GETS_IN_BK:
;@@2回退键处理：STD_BUF_COUNT-1,STD_BUF清除一个字符
	;						光标前移，当前显示消除
	XOR	AX,AX
	MOV	AL,STD_BUF_COUNT
	CMP	AL,0
	JZ	GETS_USERIN		;无字符可以消除
	DEC AL
	MOV	DS:[STD_BUF_COUNT],AL
	MOV	BX,OFFSET STD_BUF
	ADD	BX,AX
	MOV BYTE PTR DS:[BX],00H	;消除字符
	;显示
	;消除光标
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
	;消除显示的字符
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
;*子程序名：	DW_STR2HEX														**
;*功能：			字符串转换为十六进制字								**
;*入口参数：	STD_D2H_BUF 五个字节									**
;*出口参数：	CF=0 AX=结果	CF=1 溢出								**
;*使用说明：  																			**
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
;*子程序名：	DB_STR2HEX														**
;*功能：			字符串转换为十六进制字节							**
;*入口参数：	STD_D2H_BUF 两个字节									**
;*出口参数：	AL=结果																**
;*使用说明：  																			**
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
;*子程序名：	DW_HEX2STR														**
;*功能：			十六进制字转换为字符串								**
;*入口参数：	AX																		**
;*出口参数：	STD_D2H_BUF中													**
;*使用说明：  AX  (0~FFFF)否则会出错								**
;****************************************************;
DW_HEX2STR PROC NEAR
  PUSHA
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	EDX,030303030H
  MOV	DWORD PTR DS:[SI],EDX
  MOV	BYTE PTR [SI+4],30H
  ;将AX转换为压缩BCD码
  XOR EDX,EDX 					;防止溢出，使用32位除法
  XOR ESI,ESI
  MOV	CX,0AH
  DIV CX              ;商 AX  余数 DX ①
  MOV	ESI,EDX
  XOR	DX,DX
  DIV CX 							;商 AX  余数 DX ②
  AND	DX,0FH
  SHL DX,4
  ADD	ESI,EDX
  XOR	DX,DX
  DIV CX 							;商 AX  余数 DX ③
  AND	DX,0FH
  SHL DX,8
  ADD	ESI,EDX
  XOR	DX,DX
  DIV CX 							;商 AX  余数 DX ④
  AND	DX,0FH
  SHL DX,12
  ADD	ESI,EDX
  XOR	DX,DX
  DIV CX 							;商 AX  余数 DX ⑤
  AND DX,0FH
  SHL EDX,16
  AND EDX,0F0000H
  ADD ESI,EDX
  MOV EAX,ESI
  ;转换为字符串
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
;*子程序名：	DB_HEX2STR														**
;*功能：			十六进制字节转换为字符串							**
;*入口参数：	AL																		**
;*出口参数：	STD_D2H_BUF中													**
;*使用说明：  AL  (0~99)否则会出错									**
;****************************************************;
DB_HEX2STR PROC NEAR
  PUSHA
  MOV	SI,OFFSET STD_D2H_BUF
  MOV	EDX,030303030H
  MOV	DWORD PTR DS:[SI],EDX
  ;将AX转换为压缩BCD码
  XOR AH,AH 					;使用16位除法
  MOV	CX,0AH
  DIV CL              ;商 AL  余数 AH 
  ADD	AH,30H
  ADD	AL,30H
  MOV	WORD PTR DS:[SI],AX
  ;
  POPA
  RET
DB_HEX2STR ENDP

;****************************************************;
;*子程序名：	DD_HEX2STR														**
;*功能：			十六进制字转换为字符串								**
;*入口参数：	EAX																		**
;*出口参数：	STD_D2H_BUF中													**
;*使用说明：  EAX  (0~99999999)否则会出错						**
;****************************************************;
DD_HEX2STR PROC NEAR
  PUSHA
  MOV	SI,OFFSET STD_DWORD2H_BUF
  MOV	EDX,030303030H
  MOV	DWORD PTR DS:[SI],EDX
  ADD	SI,4
  MOV	DWORD PTR DS:[SI],EDX
  ;将EAX转换为压缩BCD码
  MOV	CL,0
  XOR ESI,ESI 					;防止溢出，使用64位除法
DD_H2S_DIVLOOP:
	XOR EDX,EDX
	CMP	CL,4*8
	JAE	DD_H2S_DIV_OVER
  MOV EBX,0AH
  DIV EBX                 ;商 EAX  余数 EDX 
  AND EDX,0FH
  SHL EDX,CL
  ADD ESI,EDX
  ADD CL,4
  JMP DD_H2S_DIVLOOP
DD_H2S_DIV_OVER:
  MOV	EAX,ESI
  ;转换为字符串
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
;*子程序名：	STRNCMP																**
;*功能：			字符串比较														**
;*入口参数：	DS:SI 源字符串	ES:DI 目的字符串			**
;*						CX:比较的字符个数											**
;*出口参数：	CF=1 不相同  CF=0 相同								**
;****************************************************;
StrNCmp  PROC NEAR
  PUSHA
  CLD 				;顺序方向比较
  REPZ CMPSB ;先比较，再使SI,DI加1
  MOV	AL,[SI-1]
  MOV	BL,[DI-1]
  CMP	AL,BL
  JZ	StrNCmp_Match
  STC  				;不相同
  JMP	StrNCmp_EXIT
StrNCmp_Match:
  CLC
StrNCmp_EXIT:	
  POPA
  RET
StrNCmp  ENDP