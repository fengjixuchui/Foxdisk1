;FOXHD.ASM
;Ӳ�̴������ӳ��򣬰����ŵ�ת����Ӳ�̷��ʵ�
;luobing 2007-3-1
;�ŵ�->LBA  LBA->�ŵ�
;����˼�����£�������Ӳ�̻���Ϊ�߼��ŵ�(cyl),�Դ�Ϊ���ݽ��з���
;								�������0�ŵ��������lba 3f��ʼ����
;								������㷨���£�
;										start chs :0	 	0			1  
;										end   chs :3ffh	feh		3fh
;									��LBA����䣬startLBA����������3f*ffh,endLBA������������3f*ffh������1
;��׼���㷨����(ҵ��)��
;									c=LBA div (ph * ps) +Cs(��ʼ�����,0 ����1023)
;									h=(LBA	div	ps)	mod ph	+Hs( 0 )
;									s=LBA	mod	ps	+	Ss		( 1 )						һ����˵:ph=0ffh,ps=03fh
;����int 13h ��8�Ź��ܣ��õ�max cyl,max sec,max head,����MaxCyl=(cl and c0h>>8) + ch
;									MaxSec=cl and 03fh  MaxHead=dh
;									ph=MaxHead+1   ps=MaxSec 
;������MaxCyl��ʱ��,c=MaxCyl,�������㷽������
;*�ӳ�������	GetDiskPara														**
;*�ӳ�������	LBA2CHS																**
;*�ӳ�������	CHS2LBA																**
;*�ӳ�������	GETDISKATTR														**
;*�ӳ�������	GetDiskPara														**
;*�ӳ�������	LBA2CHS																**
;*�ӳ�������	CHS2LBA																**
;*�ӳ�������	GETDISKATTR														**
;*�ӳ�������	TestPartValid													**
;*�ӳ�������	RWDISKLBA															**
;*�ӳ�������	RdWrNSector														**
;----------------------------------------------------------------------
;****************************************************;
;*�ӳ�������	GetDiskPara														**
;*���ܣ�			��ȡ����(CHS)													**
;*��ڲ�����																				**
;*���ڲ�����																				**
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
  SHR AX,8     ;AL=CYL��8λ
  XOR AH,AH
  MOV BL,CL
  AND BL,0C0H  ;BL=CYL��2λ
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
;*�ӳ�������	LBA2CHS																**
;*���ܣ�			��LBAģʽת��Ϊ�ŵ�(CHS)							**
;*��ڲ�����	HD_LBABUF															**
;*���ڲ�����	HD_CHSBUF															**
;*ע��:				�����LBA����Ҫ��֤��Ч�����ӳ������ **
;*						д��Ч��														**
;****************************************************;
LBA2CHS PROC NEAR 
  PUSHA
  ;�建����HD_CHSBUF
  XOR CX,CX
  MOV	CL,SIZE PartStruc
  MOV	AL,00H
  PUSH DS
  POP ES
  MOV	DI,OFFSET HD_CHSBUF
  CLD
  REP STOSB
  ;
  MOV	BP,1									;BP=1 δ����start=0 ,end=0
  ;
  PUSH DS
  POP ES
  MOV	DI,OFFSET HD_LBABUF   ;DI LBA��ʽ
  MOV	SI,OFFSET HD_CHSBUF   ;SI �ŵ���ʽ
  MOV	EBX,sector_count
  CMP	EBX,0									;�򵥼������Ƿ���Ч��������СΪ0��
  JZ	LBA2CHS_INVALID_PART
  ;�������־
  MOV AL,[DI].part_flag
  MOV [SI].PartActive,AL
  ;��������
  MOV AL,[DI].file_system
  MOV [SI].PartType,AL
  ;������ʼLBA->��ʼ�ŵ�
  XOR EDX,EDX
  XOR EAX,EAX
  MOV EAX,DWORD PTR [DI].first_sector
  XOR ECX,ECX
  MOV CX,PerHeadSec
  DIV ECX         ;EAX/ECX->EAX,��������
  MOV	[SI].PartStart,AX
  ;�������LBA->�����ŵ�
  XOR EDX,EDX
  XOR EAX,EAX
  MOV EAX,DWORD PTR [DI].first_sector
  MOV EBX,DWORD PTR [DI].sector_count
  ADD EAX,EBX
  CMP	EAX,0				;����ǿ�ʼʱ�򣬿�ʼ�ͽ�����������0
  JNZ LBA2CHS_ENDLBA_GE0
  MOV	EAX,1				;��֤����������Ϊ0
  MOV	BP,0
LBA2CHS_ENDLBA_GE0:
  DEC EAX 
  XOR ECX,ECX
  MOV CX,PerHeadSec
  DIV ECX         ;EAX/ECX->EAX,��������
  MOV	[SI].PartEnd,AX
  ;��д������Ч��־
  CMP	BP,0
  JZ	LBA2CHS_INVALID_PART
  MOV	[SI].PartValid,1
LBA2CHS_INVALID_PART:
  ;
  POPA
  RET
LBA2CHS ENDP
;****************************************************;
;*�ӳ�������	CHS2LBA																**
;*���ܣ�			���ŵ�(CHS)ģʽת��ΪLBA							**
;*��ڲ�����	HD_CHSBUF															**
;*���ڲ�����	HD_LBABUF															**
;****************************************************;
CHS2LBA PROC NEAR 
  PUSHA
  PUSH DS
  POP ES
  ;�建����HD_CHSBUF
  XOR CX,CX
  MOV	CL,SIZE Part_Entry 
  MOV	AL,00H
  PUSH DS
  POP ES
  MOV	DI,OFFSET HD_LBABUF
  CLD
  REP STOSB
  ;
  MOV	SI,OFFSET HD_CHSBUF   ;SI �ŵ���ʽ
  MOV	DI,OFFSET HD_LBABUF   ;DI LBA��ʽ
  ;�������־
  MOV	AL,[SI].PartActive
  MOV [DI].part_flag,AL
  ;��������
  MOV AL,[SI].PartType
  MOV [DI].file_system,AL
  ;��ʼ�ŵ�->lba
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
  ;��������
  XOR EDX,EDX
  XOR EAX,EAX
  MOV	AX,[SI].PartEnd
  INC AX
  XOR ECX,ECX
  MOV CX,PerHeadSec
  MUL ECX
  DEC EAX      							;EAX=EndSector  LBA
  PUSH EAX                  ;�����������������LBA��ַ
  MOV EDX,DWORD PTR [DI].first_sector
  SUB EAX,EDX
  INC EAX
  MOV DWORD PTR [DI].sector_count,EAX
  ;��ʼת��Ϊ�����е���ʼCHS�ͽ���CHS
  ;��ʼCHS
  XOR EDX,EDX
  XOR EAX,EAX
  MOV	EAX,[DI].first_sector
  XOR ECX,ECX
  MOV	CL,PerSec									;h=(LBA	div	ps)	mod ph	+0
  DIV ECX 											;EAX/EBX->EAX ����EDX
  INC DX
  PUSH DX  											;s=LBA	mod	ps	+	1	,dl�д����sector,����֮
  XOR EDX,EDX
  XOR ECX,ECX
  MOV	CL,PerHead
  DIV ECX 												;EAX/EBX->EAX ����EDX,DL�д����head
  PUSH DX 												;����
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
  AND DX,0300H										;����2λ
  SHR DX,2
  OR BL,DL 												;AL=CYLINDER BL=SECTOR BH=HEAD
  MOV	[DI].beg_head,BH
  MOV	[DI].beg_sector,BL
  MOV	[DI].beg_cylinder,AL
  ;����CHS
  XOR EDX,EDX
  XOR EAX,EAX
  POP EAX                       ;������LBA��ַ
  XOR ECX,ECX
  MOV	CL,PerSec									;h=(LBA	div	ps)	mod ph	+0
  DIV ECX 											;EAX/EBX->EAX ����EDX
  INC DX
  PUSH DX  											;s=LBA	mod	ps	+	1	,dl�д����sector,����֮
  XOR EDX,EDX
  XOR ECX,ECX
  MOV	CL,PerHead
  DIV ECX 												;EAX/EBX->EAX ����EDX,DL�д����head
  PUSH DX 												;����
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
  AND DX,0300H										;����2λ
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
;*�ӳ�������	GETDISKATTR														**
;*���ܣ�			��ȡ��������													**
;*��ڲ�����	��																		**
;*���ڲ�����	CF=0	�ɹ�				CF=1  ʧ��					**
;							AL=0  ֧����չ		AL=1  ��֧����չ		**
;****************************************************;
GETDISKATTR	PROC	NEAR
	MOV	AH,41H
	MOV	BX,55AAH
	MOV	DL,80H			;ȱʡ��ΪӲ����IDE1 ����
	INT	13H
	JC	GDA_NOSUPPORT		;����ʧ�ܣ���֧����չ��д
	CMP	BX,0AA55H
	JNZ	GDA_NOSUPPORT		;����ʧ�ܣ���֧����չ��д
	;֧����չ��д�Ļ���ʼ����������
	MOV	AX,4800H
	MOV	DX,0080H
	MOV	SI,OFFSET EDPARA_TABLE		;���ʹ��̲���
	INT	13H
	;����EDD
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
;*�ӳ�������	TestPartValid													**
;*���ܣ�			��������Ч��												**
;*��ڲ�����	SI=�����ṹ���ƫ�����(��partition)	**
;*���ڲ�����	CF=0	��Ч				CF=1  ��Ч					**
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
  CMP	DL,0										;������Ч�����ñȽ�
  JZ	TestPart_V_Compare
  ;����ķ���������˷����Ƚ�
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
  ADD	DI,AX 											;��λʣ�µķ���λ��
  MOV	BL,[DI].PartValid
  CMP	BL,0												;������Ч�����ñȽ�
 	JZ	TestPV_NextPart	
 	MOV	BX,[DI].PartStart						;��ʼ������ʼ�Ƚ�
 	MOV	AX,[SI].PartStart						;si ��ʼ�ŵ�
 	CMP	BX,AX
 	JB	TestPV_EndSec1							;< Ҫ�ȽϷ�����first sector
 	MOV DX,[SI].PartEnd							;si �����ŵ�
 	CMP	BX,DX
 	JBE TestPV_Invalid_Part
  JMP	TestPV_EndSec2							;> Ҫ�ȽϷ�����end sector
TestPV_EndSec1:
	MOV	BX,[DI].PartEnd							;�����ŵ�
	MOV	AX,[SI].PartStart						;si ��ʼ�ŵ�
	CMP	BX,AX
	JB	TestPV_NextPart
	JMP	TestPV_Invalid_Part
TestPV_EndSec2:
	MOV	BX,[DI].PartEnd							;�����ŵ�
	INC BX
	MOV DX,[SI].PartEnd							;si �����ŵ�
	CMP	BX,DX
	JA	TestPV_NextPart
	JMP	TestPV_Invalid_Part
  ;
TestPartValid_OK:
  CLC
  JMP	TestPartValid_EXIT
TestPV_Invalid_Part:
  STC                             ;������Ч����
TestPartValid_EXIT:
  POPA
  RET
TestPartValid ENDP
;---------------Ӳ�̲������ӳ���-----------------
;****************************************************;
;*�ӳ�������	RWDISKLBA															**
;*���ܣ�			��չ��дӲ��													**
;*��ڲ�����	EDAP_TABLE,AH(�����Լ�����)					**
;*���ڲ�����	CF=0 �ɹ�    CF=1ʧ��									**
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
;*�ӳ�������	RdWrNSector														**
;*���ܣ�			��дN������														**
;*��ڲ�����	DS:SI   512 �ֽڻ�����								**
;*						EBX:		��ʼ��ַ											**
;*						AL:			��������(1~127)								**
;*						AH: 42H ��  43H д										**
;*���ڲ�����	CF=1 ʧ��  CF=0 �ɹ� ���ݴ��ڻ�������	**
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