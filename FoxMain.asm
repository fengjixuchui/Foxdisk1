;
;------------------------------------------------------------------
;*子程序名：	FOXMAIN																**
;*子程序名：	DISP_MAIN_SEL													**
;*子程序名：	LOAD_MsMBR 														**
;*子程序名：	PUTNWBUTTON														**
;------------------------------------------------------------------
;****************************************************;
;*子程序名：	FOXMAIN																**
;*功能：			主程序																**
;*入口参数：	无																		**
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
FOXMAIN  PROC NEAR
  PUSHA
  ;首先判断是否是第一次安装，是的话出现主系统管理界面
  MOV	EAX,DWORD PTR DS:[My_SetupFlag]
  CMP	EAX,'BOUL'
  JNZ	FoxMain_MainM	
  ;出现内外选择界面
FoxMain_MainMenu:
  CALL DISP_MAIN_SEL	
  PlaySound Freg_NwSel,Time_NwSel
FoxMain_GetUserIn:
  XOR	AX,AX          			;获取用户输入：31H 32H  Enter
  INT 16H
  CMP	AL,31H							;选择外网
  JZ	FoxMain_SelWai
  CMP	AL,32H							;选择内网
  JZ	FoxMain_SelNei			
  CMP	AX,01C0DH						;Enter直接进入当前系统
  JZ	FoxMain_Enter
  CMP	AX,01900H						;'ALT+P',进入主系统管理
  JZ	FoxMain_MainM	
  CMP	AX,02F00H
  JZ	FoxMain_About		
  JMP	FoxMain_GetUserIn
FoxMain_SelWai:
	MOV	AL,1
	CALL LOAD_MsMBR
	JMP	FoxMain_MainMenu
FoxMain_SelNei:
	MOV	AL,2
	CALL LOAD_MsMBR
	JMP	FoxMain_MainMenu
FoxMain_Enter:
	PlaySound Freg_Enter,Time_Enter
	MOV	AL,0
	CALL LOAD_MsMBR
	JMP	FoxMain_MainMenu
FoxMain_MainM:
	CALL MainSystem
	JMP	FoxMain_MainMenu
FoxMain_About:
	CALL FoxAbout
	JMP	FoxMain_MainMenu
  ;
  POPA
  RET
FOXMAIN ENDP
;****************************************************;
;*子程序名：	DISP_MAIN_SEL													**
;*功能：			显示内外网选择界面										**
;*入口参数：	无																		**
;*出口参数：																				**
;*使用说明：  																			**
;****************************************************;
DISP_MAIN_SEL	PROC	NEAR
	CALL	DISP_FRAME
	;设置内外网选择菜单
	;外网
	MOV	AX,NW_STR_WAI
	PUSH	AX
	MOV	DX,OFFSET	STR_SYWAI
	PUSH	DX
	MOV	AX,BUTTON_TOP_WAI
	PUSH	AX
	MOV	AX,BUTTON_LEFT_WAI
	PUSH	AX
	CALL	PUTNWBUTTON
	ADD	SP,8
	;内网
	MOV	AX,NW_STR_NEI
	PUSH	AX
	MOV	DX,OFFSET	STR_SYNEI
	PUSH	DX
	MOV	AX,BUTTON_TOP_NEI
	PUSH	AX
	MOV	AX,BUTTON_LEFT_NEI
	PUSH	AX
	CALL	PUTNWBUTTON
	ADD	SP,8
	RET
DISP_MAIN_SEL	ENDP
;*********************************************************;
;*子程序名：	LOAD_MsMBR 														     **
;*功能：			将4000:200处的数据改写为：微软的引导代码和 **
;*            用户的分区表,并进入引导										 **
;*入口参数：	AL 0:直接用当前的分区引导				     			 **
;*							 1:使用外网的分区引导(startsector+2)		 **
;*							 2:使用内网的分区引导(startsector+2)		 **
;*出口参数：																				     **
;*注意：																								 **
;*********************************************************;
LOAD_MsMBR PROC NEAR
    PUSHA
    PUSH DS
    PUSH ES
    ;
    PUSH CS
    POP DS    
    JMP  LOAD_MsM_LEADCODE
MicrosoftMBR LABEL BYTE
             DB  033H,0C0H,08EH,0D0H,0BCH,000H,07CH,0FBH
             DB  050H,007H,050H,01FH,0FCH,0BEH,01BH,07CH
             DB  0BFH,01BH,006H,050H,057H,0B9H,0E5H,001H
             DB  0F3H,0A4H,0CBH,0BDH,0BEH,007H,0B1H,004H
             DB  038H,06EH,000H,07CH,009H,075H,013H,083H
             DB  0C5H,010H,0E2H,0F4H,0CDH,018H,08BH,0F5H
             DB  083H,0C6H,010H,049H,074H,019H,038H,02CH
             DB  074H,0F6H,0A0H,0B5H,007H,0B4H,007H,08BH
             DB  0F0H,0ACH,03CH,000H,074H,0FCH,0BBH,007H
             DB  000H,0B4H,00EH,0CDH,010H,0EBH,0F2H,088H
             DB  04EH,010H,0E8H,046H,000H,073H,02AH,0FEH
             DB  046H,010H,080H,07EH,004H,00BH,074H,00BH
             DB  080H,07EH,004H,00CH,074H,005H,0A0H,0B6H
             DB  007H,075H,0D2H,080H,046H,002H,006H,083H
             DB  046H,008H,006H,083H,056H,00AH,000H,0E8H
             DB  021H,000H,073H,005H,0A0H,0B6H,007H,0EBH
             DB  0BCH,081H,03EH,0FEH,07DH,055H,0AAH,074H
             DB  00BH,080H,07EH,010H,000H,074H,0C8H,0A0H
             DB  0B7H,007H,0EBH,0A9H,08BH,0FCH,01EH,057H
             DB  08BH,0F5H,0CBH,0BFH,005H,000H,08AH,056H
             DB  000H,0B4H,008H,0CDH,013H,072H,023H,08AH
             DB  0C1H,024H,03FH,098H,08AH,0DEH,08AH,0FCH
             DB  043H,0F7H,0E3H,08BH,0D1H,086H,0D6H,0B1H
             DB  006H,0D2H,0EEH,042H,0F7H,0E2H,039H,056H
             DB  00AH,077H,023H,072H,005H,039H,046H,008H
             DB  073H,01CH,0B8H,001H,002H,0BBH,000H,07CH
             DB  08BH,04EH,002H,08BH,056H,000H,0CDH,013H
             DB  073H,051H,04FH,074H,04EH,032H,0E4H,08AH
             DB  056H,000H,0CDH,013H,0EBH,0E4H,08AH,056H
             DB  000H,060H,0BBH,0AAH,055H,0B4H,041H,0CDH
             DB  013H,072H,036H,081H,0FBH,055H,0AAH,075H
             DB  030H,0F6H,0C1H,001H,074H,02BH,061H,060H
             DB  06AH,000H,06AH,000H,0FFH,076H,00AH,0FFH
             DB  076H,008H,06AH,000H,068H,000H,07CH,06AH
             DB  001H,06AH,010H,0B4H,042H,08BH,0F4H,0CDH
             DB  013H,061H,061H,073H,00EH,04FH,074H,00BH
             DB  032H,0E4H,08AH,056H,000H,0CDH,013H,0EBH
             DB  0D6H,061H,0F9H,0C3H,049H,06EH,076H,061H
             DB  06CH,069H,064H,020H,070H,061H,072H,074H
             DB  069H,074H,069H,06FH,06EH,020H,074H,061H
             DB  062H,06CH,065H,000H,045H,072H,072H,06FH
             DB  072H,020H,06CH,06FH,061H,064H,069H,06EH
             DB  067H,020H,06FH,070H,065H,072H,061H,074H
             DB  069H,06EH,067H,020H,073H,079H,073H,074H
             DB  065H,06DH,000H,04DH,069H,073H,073H,069H
             DB  06EH,067H,020H,06FH,070H,065H,072H,061H
             DB  074H,069H,06EH,067H,020H,073H,079H,073H
             DB  074H,065H,06DH,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,02CH,044H,063H
             DB  0EFH,099H,0EFH,099H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,000H,000H
             DB  000H,000H,000H,000H,000H,000H,055H,0AAH
LOAD_MsM_LEADCODE:
	CMP	AL,0									;Enter进入
	JZ	LoadMM_Enter
	CMP	AL,1									;外网
	JZ	LoadMM_SelWai
	CMP	AL,2									;内网
	JZ  LoadMM_SelNei
	JMP	LOAD_MsM_LEADCODE
LoadMM_Enter:								;直接引导
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,0   							;当前MBR LBA0
	MOV	AH,42H
	MOV	AL,1
	CALL	RdWrNSector
  JMP LoadMM_LoadOS
LoadMM_SelWai:
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,0   							;当前MBR LBA0
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
	CALL	StrNCmp						;比较分区表是否为外网，CF=1不是
	JNC	LoadMM_LoadOS
	;写分区表
	PUSH DS
	POP ES
	MOV	SI,OFFSET FOXW_PART1
	MOV	DI,OFFSET BUF_PART1
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	CL,4
	MUL CL
	MOV	CX,AX
	CLD
	REP MOVSB
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,0   							;当前MBR LBA0
	MOV	AH,43H
	MOV	AL,1
	CALL	RdWrNSector
	JMP LoadMM_LoadOS
LoadMM_SelNei:
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,0   							;当前MBR LBA0
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
	CALL	StrNCmp						;比较分区表是否为外网，CF=1不是
	JNC	LoadMM_LoadOS
	;写分区表
	PUSH DS
	POP ES
	MOV	SI,OFFSET FOXN_PART1
	MOV	DI,OFFSET BUF_PART1
	XOR AX,AX
	MOV	AL,SIZE Part_Entry
	MOV	CL,4
	MUL CL
	MOV	CX,AX
	CLD
	REP MOVSB
	MOV	SI,OFFSET MBRBUF 
	MOV	EBX,0   							;当前MBR LBA0
	MOV	AH,43H
	MOV	AL,1
	CALL	RdWrNSector
	JMP LoadMM_LoadOS
LoadMM_LoadOS:  
	;到此为止，当前MBRBUF存放的是选定的分区表
	STI
	PUSH CS
	POP ES
	PUSH CS
	POP DS
	MOV	SI,OFFSET MicrosoftMBR
	MOV	DI,OFFSET MBRBUF
	MOV	CX,01BEH
	CLD
  REP MOVSB
  STI 
  MOV AX,0003H
  INT 10H
  CLI
  MOV SP,7C00H 			;规定SP为启动用的栈
  CLD

  MOV AX,0
  MOV ES,AX
  MOV AX,7C00H
  MOV DI,AX   			 ;ES:DI=0000:7C00
  PUSH CS
  POP DS
  MOV SI,200H        ;DS:SI=4000:200

  MOV CX,200H
  REPNZ  MOVSW       ;DS:SI == ES:DI(CX)

  STI
  DB 0EAH     				;JMP 0000:7C00H
  DW 7C00H
  DW 0000H
 									      ;注意，程序不会返回了，此时是走了int19h的流程
  POP ES
  POP DS
	POPA  
  RET
LOAD_MsMBR ENDP
;****************************************************; 
;*子程序名：	PUTNWBUTTON														** 
;*功能：			显示按钮															** 
;*入口参数：	堆栈中从顶到底：color S(字符串地址)		** 
;*								top,left													** 
;*出口参数：																				** 
;*调用说明：将S压栈																	** 
;*					注意调用后平衡堆栈											**
;*****************************************************
PUTNWBUTTON	PROC	NEAR
	PUSH	BP
	MOV	BP,SP					;[BP+4]=LEFT,[BP+6]=TOP,[BP+8]=PTEXT(POINT STRING),[BP+10]=COLOR
	SUB	SP,6
	PUSH	SI
	PUSH	DI
	MOV	SI,WORD PTR [BP+4]
	MOV	DI,WORD PTR [BP+6]
   ;
	PUSH	WORD PTR [BP+8]
	CALL	NEAR PTR STRLEN
	POP	CX
	MOV	WORD PTR [BP-2],AX					;LENGTH OF STING->[BP-2]
  ;	
	MOV	AX,WORD PTR [BP-2]
	ADD	AX,4
	MOV	CL,3
	SHL	AX,CL
	;XOR	AH,AH								;若要修改,注意此段
	;MOV	DL,BYTE PTR CHARWIDTH
	;MUL	DL
	MOV	DX,SI
	ADD	DX,AX
	DEC	DX
	MOV	WORD PTR [BP-4],DX					;[BP-4]=RIGHT
   ;
	MOV	AX,DI
	ADD	AX,DEFAULTBUTTONHEIGHT
	DEC	AX
	MOV	WORD PTR [BP-6],AX					;[BP-6]=BOTTOM
  ;	
	MOV	AX,NWBUT_LightShadow_COLOR
	PUSH	AX
	PUSH	DI
	PUSH	WORD PTR [BP-4]
	PUSH	SI
	CALL	NEAR PTR HLINE
	ADD	SP,8
  ;	
	MOV	AX,NWBUT_LightShadow_COLOR
	PUSH	AX
	PUSH	SI
	PUSH	WORD PTR [BP-6]
	PUSH	DI
	CALL	NEAR PTR VLINE
	ADD	SP,8
  ;	
	MOV	AX,NWBUT_GrayShadow_COLOR
	PUSH	AX
	MOV	AX,WORD PTR [BP-6]
	DEC	AX
	PUSH	AX
	MOV	AX,WORD PTR [BP-4]
	DEC	AX
	PUSH	AX
	MOV	AX,SI
	INC	AX
	PUSH	AX
	CALL	NEAR PTR HLINE
	ADD	SP,8
  ;
	MOV	AX,NWBUT_DarkShadow_COLOR
	PUSH	AX
	PUSH	WORD PTR [BP-6]
	PUSH	WORD PTR [BP-4]
	PUSH	SI
	CALL	NEAR PTR HLINE
	ADD	SP,8
  ;	
	MOV	AX,NWBUT_GrayShadow_COLOR
	PUSH	AX
	MOV	AX,WORD PTR [BP-4]
	DEC	AX
	PUSH	AX
	MOV	AX,WORD PTR [BP-6]
	DEC	AX
	PUSH	AX
	MOV	AX,DI
	INC	AX
	PUSH	AX
	CALL	NEAR PTR VLINE
	ADD	SP,8
 ;
	MOV	AX,NWBUT_DarkShadow_COLOR
	PUSH	AX
	PUSH	WORD PTR [BP-4]
	PUSH	WORD PTR [BP-6]
	PUSH	DI
	CALL	NEAR PTR VLINE
	ADD	SP,8
   ;		PUTSTR(LEFT+CHARWIDTH*2,TOP+CHARHEIGHT/2,PTEXT,COLOR);
	PUSH	WORD PTR [BP+10]
	PUSH	WORD PTR [BP+8]
	MOV	AX,CHARHEIGHT
	SHR	AX,1
	ADD	AX,[BP+6]
	PUSH	AX
	MOV	AX,CHARWIDTH
	SHL	AX,1
	ADD	AX,[BP+4]
	PUSH	AX
	CALL	NEAR PTR PUTSTR
	ADD	SP,8
   ;
	POP	DI
	POP	SI
	MOV	SP,BP
	POP	BP
	RET	
PUTNWBUTTON	ENDP