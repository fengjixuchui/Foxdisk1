;FOXHD.ASM
;硬盘处理的子程序，包括磁道转换、硬盘访问等
;luobing 2007-3-1
;磁道->LBA  LBA->磁道
;基本思想如下：将整个硬盘划分为逻辑磁道(cyl),以此为依据进行分区
;								特殊的是0磁道，必须从lba 3f开始计算
;								其余的算法如下：
;										start chs :0	 	0			1  
;										end   chs :3ffh	feh		3fh
;									对LBA的填充，startLBA必须能整除3f*ffh,endLBA必须是能整除3f*ffh的数减1
;标准的算法如下(业界)：
;									c=LBA div (ph * ps) +Cs(起始柱面号,0 或者1023)
;									h=(LBA	div	ps)	mod ph	+Hs( 0 )
;									s=LBA	mod	ps	+	Ss		( 1 )						一般来说:ph=0ffh,ps=03fh
;利用int 13h 的8号功能，得到max cyl,max sec,max head,其中MaxCyl=(cl and c0h>>8) + ch
;									MaxSec=cl and 03fh  MaxHead=dh
;									ph=MaxHead+1   ps=MaxSec 
;当超过MaxCyl的时候,c=MaxCyl,其他计算方法不变
;*子程序名：	GetDiskPara														**
;*子程序名：	LBA2CHS																**
;*子程序名：	CHS2LBA																**
;*子程序名：	GETDISKATTR														**
;*子程序名：	GetDiskPara														**
;*子程序名：	LBA2CHS																**
;*子程序名：	CHS2LBA																**
;*子程序名：	GETDISKATTR														**
;*子程序名：	TestPartValid													**
;*子程序名：	RWDISKLBA															**
;*子程序名：	RdWrNSector														**
;----------------------------------------------------------------------
;****************************************************;
;*子程序名：	GetDiskPara														**
;*功能：			获取参数(CHS)													**
;*入口参数：																				**
;*出口参数：																				**
;****************************************************;
GetDiskPara PROC NEAR
  PUSHA
  PUSH ES
  ;
  MOV AH,08
  MOV DL,80H
  INT 13H
  MOV DS:MaxHead,DH
  MOV AL,CL
  AND AL,03FH
  MOV DS:MaxSec,AL
  MOV AX,CX
  SHR AX,8     ;AL=CYL低8位
  XOR AH,AH
  MOV BL,CL
  AND BL,0C0H  ;BL=CYL高2位
  SHL BX,2
  AND BX,0300H
  OR AX,BX
  MOV	DS:MaxCyl,AX
  ;
  MOV	AL,BYTE PTR DS:[MaxHead]
  INC AL
  MOV DS:PerHead,AL
  MOV AL,BYTE PTR DS:[MaxSec]
  MOV DS:PerSec,AL
  XOR CX,CX
  XOR AX,AX
  MOV	AL,PerHead
  MOV	CL,PerSec
  MUL CL
  MOV	DS:PerHeadSec,AX
  ;
  CALL GETDISKATTR
  MOV	EAX,EDPARA_TOTAL
  MOV	DS:HDMAXSECTOR,EAX
  DEC EAX
  XOR EDX,EDX
  XOR EBX,EBX
  MOV BX,PerHeadSec
  DIV EBX
  MOV	DS:HDMAXCAP,AX
  POP ES
  POPA
  RET
GetDiskPara ENDP
;****************************************************;
;*子程序名：	LBA2CHS																**
;*功能：			将LBA模式转换为磁道(CHS)							**
;*入口参数：	HD_LBABUF															**
;*出口参数：	HD_CHSBUF															**
;*注意:				送入的LBA分区要保证有效（此子程序会填 **
;*						写有效域）														**
;****************************************************;
LBA2CHS PROC NEAR 
  PUSHA
  ;清缓冲区HD_CHSBUF
  XOR CX,CX
  MOV	CL,SIZE PartStruc
  MOV	AL,00H
  PUSH DS
  POP ES
  MOV	DI,OFFSET HD_CHSBUF
  CLD
  REP STOSB
  ;
  MOV	BP,1									;BP=1 未遇到start=0 ,end=0
  ;
  PUSH DS
  POP ES
  MOV	DI,OFFSET HD_LBABUF   ;DI LBA方式
  MOV	SI,OFFSET HD_CHSBUF   ;SI 磁道方式
  MOV	EBX,sector_count
  CMP	EBX,0									;简单检测分区是否有效：分区大小为0吗？
  JZ	LBA2CHS_INVALID_PART
  ;活动分区标志
  MOV AL,[DI].part_flag
  MOV [SI].PartActive,AL
  ;分区类型
  MOV AL,[DI].file_system
  MOV [SI].PartType,AL
  ;计算起始LBA->开始磁道
  XOR EDX,EDX
  XOR EAX,EAX
  MOV EAX,DWORD PTR [DI].first_sector
  XOR ECX,ECX
  MOV CX,PerHeadSec
  DIV ECX         ;EAX/ECX->EAX,余数丢弃
  MOV	[SI].PartStart,AX
  ;计算结束LBA->结束磁道
  XOR EDX,EDX
  XOR EAX,EAX
  MOV EAX,DWORD PTR [DI].first_sector
  MOV EBX,DWORD PTR [DI].sector_count
  ADD EAX,EBX
  CMP	EAX,0				;如果是开始时候，开始和结束扇区都是0
  JNZ LBA2CHS_ENDLBA_GE0
  MOV	EAX,1				;保证结束扇区不为0
  MOV	BP,0
LBA2CHS_ENDLBA_GE0:
  DEC EAX 
  XOR ECX,ECX
  MOV CX,PerHeadSec
  DIV ECX         ;EAX/ECX->EAX,余数丢弃
  MOV	[SI].PartEnd,AX
  ;填写分区有效标志
  CMP	BP,0
  JZ	LBA2CHS_INVALID_PART
  MOV	[SI].PartValid,1
LBA2CHS_INVALID_PART:
  ;
  POPA
  RET
LBA2CHS ENDP
;****************************************************;
;*子程序名：	CHS2LBA																**
;*功能：			将磁道(CHS)模式转换为LBA							**
;*入口参数：	HD_CHSBUF															**
;*出口参数：	HD_LBABUF															**
;****************************************************;
CHS2LBA PROC NEAR 
  PUSHA
  PUSH DS
  POP ES
  ;清缓冲区HD_CHSBUF
  XOR CX,CX
  MOV	CL,SIZE Part_Entry 
  MOV	AL,00H
  PUSH DS
  POP ES
  MOV	DI,OFFSET HD_LBABUF
  CLD
  REP STOSB
  ;
  MOV	SI,OFFSET HD_CHSBUF   ;SI 磁道方式
  MOV	DI,OFFSET HD_LBABUF   ;DI LBA方式
  ;活动分区标志
  MOV	AL,[SI].PartActive
  MOV [DI].part_flag,AL
  ;分区类型
  MOV AL,[SI].PartType
  MOV [DI].file_system,AL
  ;开始磁道->lba
  XOR EDX,EDX
  XOR EAX,EAX
  MOV AX,[SI].PartStart	
  XOR ECX,ECX
  MOV CX,PerHeadSec
  MUL ECX 									;EAX*ECX->EAX
  CMP EAX,0
  JZ CHS2LBA_STARTLBA_EQU0
  MOV	[DI].first_sector,EAX
  JMP	CHS2LBA_START_OPOVER
CHS2LBA_STARTLBA_EQU0:
	MOV [DI].first_sector,0000003FH
CHS2LBA_START_OPOVER:	
  ;扇区总数
  XOR EDX,EDX
  XOR EAX,EAX
  MOV	AX,[SI].PartEnd
  INC AX
  XOR ECX,ECX
  MOV CX,PerHeadSec
  MUL ECX
  DEC EAX      							;EAX=EndSector  LBA
  PUSH EAX                  ;保存分区结束扇区的LBA地址
  MOV EDX,DWORD PTR [DI].first_sector
  SUB EAX,EDX
  INC EAX
  MOV DWORD PTR [DI].sector_count,EAX
  ;开始转换为分区中的起始CHS和结束CHS
  ;开始CHS
  XOR EDX,EDX
  XOR EAX,EAX
  MOV	EAX,[DI].first_sector
  XOR ECX,ECX
  MOV	CL,PerSec									;h=(LBA	div	ps)	mod ph	+0
  DIV ECX 											;EAX/EBX->EAX 余数EDX
  INC DX
  PUSH DX  											;s=LBA	mod	ps	+	1	,dl中存放了sector,保存之
  XOR EDX,EDX
  XOR ECX,ECX
  MOV	CL,PerHead
  DIV ECX 												;EAX/EBX->EAX 余数EDX,DL中存放了head
  PUSH DX 												;保存
  MOV	AX,DS:[SI].PartStart
  MOV CX,MaxCyl
  CMP AX,CX
  JB  CHS2LBA_START_BIOSVAL
  MOV AX,MaxCyl
CHS2LBA_START_BIOSVAL:
  POP CX
  POP BX 													
  MOV BH,CL                       ;BL=SECTOR BH=HEAD AX=CYLINDER
  MOV DX,AX
  AND DX,0300H										;保留2位
  SHR DX,2
  OR BL,DL 												;AL=CYLINDER BL=SECTOR BH=HEAD
  MOV	[DI].beg_head,BH
  MOV	[DI].beg_sector,BL
  MOV	[DI].beg_cylinder,AL
  ;结束CHS
  XOR EDX,EDX
  XOR EAX,EAX
  POP EAX                       ;结束的LBA地址
  XOR ECX,ECX
  MOV	CL,PerSec									;h=(LBA	div	ps)	mod ph	+0
  DIV ECX 											;EAX/EBX->EAX 余数EDX
  INC DX
  PUSH DX  											;s=LBA	mod	ps	+	1	,dl中存放了sector,保存之
  XOR EDX,EDX
  XOR ECX,ECX
  MOV	CL,PerHead
  DIV ECX 												;EAX/EBX->EAX 余数EDX,DL中存放了head
  PUSH DX 												;保存
  MOV	AX,DS:[SI].PartEnd
  MOV CX,MaxCyl
  CMP AX,CX
  JB  CHS2LBA_END_BIOSVAL
  MOV AX,MaxCyl
CHS2LBA_END_BIOSVAL:
  POP CX
  POP BX 													
  MOV BH,CL                       ;BL=SECTOR BH=HEAD AX=CYLINDER
  MOV DX,AX
  AND DX,0300H										;保留2位
  SHR DX,2
  OR BL,DL 												;AL=CYLINDER BL=SECTOR BH=HEAD
  MOV	[DI].end_head,BH
  MOV	[DI].end_sector,BL
  MOV	[DI].end_cylinder,AL
  ;	
  POPA
  RET
CHS2LBA ENDP
;****************************************************;
;*子程序名：	GETDISKATTR														**
;*功能：			获取磁盘属性													**
;*入口参数：	无																		**
;*出口参数：	CF=0	成功				CF=1  失败					**
;							AL=0  支持扩展		AL=1  不支持扩展		**
;****************************************************;
GETDISKATTR	PROC	NEAR
	MOV	AH,41H
	MOV	BX,55AAH
	MOV	DL,80H			;缺省认为硬盘在IDE1 主盘
	INT	13H
	JC	GDA_NOSUPPORT		;访问失败，不支持扩展读写
	CMP	BX,0AA55H
	JNZ	GDA_NOSUPPORT		;访问失败，不支持扩展读写
	;支持扩展读写的话开始填充磁盘属性
	MOV	AX,4800H
	MOV	DX,0080H
	MOV	SI,OFFSET EDPARA_TABLE		;传送磁盘参数
	INT	13H
	;传送EDD
	MOV AX,EDD_SEG
	MOV	ES,AX
	MOV	DI,EDD_OFFSET
	MOV	SI,OFFSET EDD_BASEPORT			;SI->EDD
	MOV	CX,8
GDA_FILLEDD:
	MOV	AX,ES:WORD PTR [DI]
	MOV	[SI],AX
	INC	SI
	INC	SI
	INC	DI
	INC	DI
	LOOP	GDA_FILLEDD
	MOV	AL,0
	JMP	GDA_EXIT
GDA_NOSUPPORT:	
	MOV	AL,1
GDA_EXIT:
	RET
GETDISKATTR	ENDP
;****************************************************;
;*子程序名：	TestPartValid													**
;*功能：			检测分区有效性												**
;*入口参数：	SI=分区结构体的偏移入口(如partition)	**
;*出口参数：	CF=0	有效				CF=1  无效					**
;****************************************************;
TestPartValid PROC NEAR
  PUSHA
  MOV	CX,0FFFFH
TestPart_V_Compare:  
	INC	CX
	CMP	CX,2
	JA	TestPartValid_OK
  ;
  MOV	AL,SIZE PartStruc
  MUL CL
  ADD	SI,AX
  MOV	DL,[SI].PartValid				;
  CMP	DL,0										;分区无效，不用比较
  JZ	TestPart_V_Compare
  ;后面的分区依次与此分区比较
  MOV	BP,3
  SUB	BP,CX 											;BP=3-CX  CL:BP 0:3 1:2 2:1
  INC BP
TestPV_NextPart: 
	DEC	BP 
	CMP	BP,1
	JB	TestPart_V_Compare

  MOV DI,SI
  MOV	AL,SIZE PartStruc
  MOV	BX,BP
  MUL	BL
  ADD	DI,AX 											;定位剩下的分区位置
  MOV	BL,[DI].PartValid
  CMP	BL,0												;分区无效，不用比较
 	JZ	TestPV_NextPart	
 	MOV	BX,[DI].PartStart						;开始分区开始比较
 	MOV	AX,[SI].PartStart						;si 开始磁道
 	CMP	BX,AX
 	JB	TestPV_EndSec1							;< 要比较分区的first sector
 	MOV DX,[SI].PartEnd							;si 结束磁道
 	CMP	BX,DX
 	JBE TestPV_Invalid_Part
  JMP	TestPV_EndSec2							;> 要比较分区的end sector
TestPV_EndSec1:
	MOV	BX,[DI].PartEnd							;结束磁道
	MOV	AX,[SI].PartStart						;si 开始磁道
	CMP	BX,AX
	JB	TestPV_NextPart
	JMP	TestPV_Invalid_Part
TestPV_EndSec2:
	MOV	BX,[DI].PartEnd							;结束磁道
	INC BX
	MOV DX,[SI].PartEnd							;si 结束磁道
	CMP	BX,DX
	JA	TestPV_NextPart
	JMP	TestPV_Invalid_Part
  ;
TestPartValid_OK:
  CLC
  JMP	TestPartValid_EXIT
TestPV_Invalid_Part:
  STC                             ;存在无效分区
TestPartValid_EXIT:
  POPA
  RET
TestPartValid ENDP
;---------------硬盘操作的子程序-----------------
;****************************************************;
;*子程序名：	RWDISKLBA															**
;*功能：			扩展读写硬盘													**
;*入口参数：	EDAP_TABLE,AH(必须自己填充表)					**
;*出口参数：	CF=0 成功    CF=1失败									**
;****************************************************;
RWDISKLBA	PROC	NEAR
  PUSHA
	MOV	DL,80H
	MOV	SI,OFFSET	EDAP_TABLE		;DS:SI
	INT	13H
  POPA 
	RET
RWDISKLBA	ENDP
;****************************************************;
;*子程序名：	RdWrNSector														**
;*功能：			读写N个扇区														**
;*入口参数：	DS:SI   512 字节缓冲区								**
;*						EBX:		起始地址											**
;*						AL:			扇区个数(1~127)								**
;*						AH: 42H 读  43H 写										**
;*出口参数：	CF=1 失败  CF=0 成功 数据存在缓冲区内	**
;****************************************************;	
RdWrNSector PROC  NEAR
  PUSHA
  MOV	CX,5
ReadNS_LOOP:
	MOV	EDAP_RWCOUNT,AL
	MOV	EDAP_OFFSET,SI
  PUSH AX
	MOV	AX,DS
	MOV	EDAP_SEG,AX
  POP AX
	MOV	EDAP_RWLBAL,EBX
	MOV	EDAP_RWLBAH,00H
	CALL	RWDISKLBA
	JNC ReadNS_OK
	LOOP ReadNS_LOOP
ReadNS_OK:
  POPA
  RET 
RdWrNSector ENDP
