		
;#############################################  �������忪ʼ  #####################################################
INCLUDE FOXEQU.ASM
;#############################################  �����������  #####################################################
;#############################################  �ṹ���忪ʼ  #####################################################
;Ӳ�̹�����ϵͳ�õ������ݽṹ
PartStruc	 struc
	PartActive	 db 		?		;LinkPointer:points to next T/Q descriptor or indicates termination by T-flag
	PartType     db     ?
	PartStart		 dw 		?		;presents the actual length (11 bit ) = and 2047
	PartEnd 		 dw 		?		;presents the Status
	;PartCap			 dw     ?   ;Ӳ������
	PartValid		 db     ?		;�����Ƿ���Ч ���Լ��ã�
PartStruc ends
;��ʵ�ķ����ṹ
Part_Entry struc
	part_flag		 db     ?
  beg_head     db     ?
  beg_sector   db     ?
  beg_cylinder db     ?
  file_system  db     ?
  end_head     db     ?
  end_sector   db     ?
  end_cylinder db     ?
  first_sector dd     ?
	sector_count dd     ?
Part_Entry ends

;#############################################  �ṹ�������  #####################################################
;
;-----------�����-----------------------------------------------------------------
.Model Tiny,C
.486P
.CODE
ORG 00H
START:
	CLI
  MOV AX,CS 											;��������-PC����MBR������0:7c00�� cs=0h
  MOV SS,AX
  MOV SP,7C00H
  MOV DS,AX 											;���ö�ջ0:7c00h,���ݶ�ds=0
	CLD
	JMP LOAD_MYCODE
	LBARWBuf     DB 10H,00H,40H,00H,00H,00H,00H,40H,8 DUP(0)	;�������涨Ϊ4000:0,�������������·���
	STR_ERR7		 DB 'ERROR 7: Read HD error.--luobing$'
LOAD_MYCODE:
  MOV SI,OFFSET LBARWBuf
	ADD SI,7C00H 										;��λ���� LBARWBuf
	;CALL GETLBAMAX									;����Ӳ�����ɶ�д�ռ�(��SATAӲ�̲�һ����Ч)
	;��Ӳ��STARTSECTOR�����ڴ˴���ʼ�ŵ��������ļ�������MBR��ֻ���˱��ļ���ǰ200h�ֽڣ�
  MOV WORD PTR [SI+8],STARTSECTOR
  MOV WORD PTR [SI+10],0
  MOV WORD PTR [SI+12],0
  MOV WORD PTR [SI+14],0
	
	;CALL HDISBUSY									;��SATAӲ�̲�һ����Ч
	CALL READLBA
	JNB	LOAD_MYCODE_OK							;���سɹ�
	MOV	DX,OFFSET STR_ERR7					;����ʧ������ʾ��3����˳�
	CALL	DISPMESS
	MOV	AX,3000
	CALL	LBDELAY
	JMP	MYCODE_EXIT
LOAD_MYCODE_OK:
  CLI
  DB 0EAH													;JMP INCS:MYCODE_START
  DW OFFSET MYCODE_START
  DW INCS
MYCODE_START:     
   CLI 														;�Ӵ˴���ʼ����ʼ����ײ�������Ĵ�����
	 MOV SI,CS 											;CS=DS=ES=4000H SS=0 SP=7C00H
	 MOV DS,SI
	 MOV ES,SI
	 STI
	 CLD
   CALL MAINMENU									;����������
   ;	      
MYCODE_EXIT:   
   MOV AX,083H										;���ֻ�����
   INT 10H
;-----------------��MBR���õ����ӳ��� ��ʼ----------------------------------
;---------------------------------------------------
;****************************************************;
;*�ӳ�������	READLBA																**
;*���ܣ�			��չLBA��															**
;*��ڲ�����	SIָ����ڴ��Ѿ�����������					**
;*���ڲ�����	CF=1 ��ȡʧ�� CF=0 �ɹ�								**
;*ʹ��˵����  ����Σ�������������չ��(int13h)			**
;****************************************************;
READLBA PROC NEAR
	PUSH BX
	PUSH CX
	PUSH DX
  MOV CX,5
	XOR AX,AX
	INT 13H
	;CALL HDISBUSY			;��SATAӲ�̲�һ����Ч
READSTART:
  MOV AX,4200H
  MOV DX,80H
	INT 13H
	JNB READOK					;CF=0 ��ȡ�ɹ�
	XOR AX,AX
	INT 13H
	LOOP READSTART
READOK:
 	POP DX
	POP CX
	POP BX
	RET
READLBA ENDP
;****************************************************;
;*�ӳ�������	DISPMESS															**
;*���ܣ�			��ʾ�ַ���(һ�ɴ�(5,y)����ʼ)					**
;*��ڲ�����	DX=�ַ���ƫ��													**
;*���ڲ�����	��																		**
;****************************************************;		
DISPMESS	PROC	NEAR
  PUSHA
  MOV SI,DX
  MOV AH,3
  MOV BH,0
	INT	10H
  MOV DL,5
  MOV BH,0
  MOV AH,2
	INT	10H
	
DMLOOP:
  MOV AL,[SI]
	CMP	AL,'$'
	JZ	DMOVER
  MOV AH,9
  MOV BH,0
  MOV BL,1EH
  MOV CX,1
	INT	10H
  MOV AH,3
  MOV BH,0
	INT	10H
  INC	DL
  MOV BH,0
  MOV AH,2
  INT 10H
  INC	SI
  JMP	DMLOOP
DMOVER:	
  POPA
  RET
DISPMESS	ENDP
;*********************************************************;
;*�ӳ�������	LBDELAY 															     **
;*���ܣ�			��ʱ																	     **
;*��ڲ�����	ax = delay time in milliseconds     			 **
;*���ڲ�����																				     **
;*ע�⣺																								 **
;*********************************************************;	
LBDELAY    PROC NEAR
					 PUSH CX
					 PUSH DX
           MOV  DX,1000                 ; MULTIPLY BY 1000 (CONVERT TO MICRO)
           MUL  DX                      ; DX:AX = TIME IN MICROSECONDS
           XCHG AX,DX                   ; CX:DX = TIME
           XCHG AX,CX                   ;
           MOV  AH,86H                  ; BIOS DELAY SERVICE
           INT  15H                     ;
           POP DX
           POP CX
           RET                          ;
LBDELAY      ENDP    
;-----------------��MBR���õ����ӳ��� ����------------------------------------
;-----------------------------------------------------------------------------


;-----------------������ ��ʼ-------------------------------------------------
ORG 200h
MBRBUF     				  DB 446 DUP (0)
  BUF_PART1					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART2					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART3					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART4					Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H				
ORG 400H
FOXWAI     				  DB 446 DUP (0)												;�����Լ�Ҫ�õ�����MBR
	FOXW_PART1				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART2				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART3				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART4				Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H
ORG 600H 
FOXNEI     				  DB 446 DUP (0)												;�����Լ�Ҫ�õ�����MBR
	FOXN_PART1				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART2				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART3				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART4				Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H
ORG 800H
FOXBUF LABEL BYTE
	My_SetupFlag		  DB 4 DUP(0)														;�ַ���'LUOB'��ʾ�Ѿ���װ
										DB 12 DUP(0)
  include FoxSeeC.inc																			;��ɫ������ѡ��
  ORG 09FEH
										DW 0AA55H
ORG 0A00H
MAINMENU PROC NEAR
     MOV AX,CS
     MOV DS,AX
     MOV ES,AX
     JMP	CODESTART	
;-------------������Ҫ�õ������� ��ʼ----------------------------------------
INCLUDE FOXDATA.ASM
;-------------������Ҫ�õ������� ����----------------------------------------
CODESTART:
    CALL INITVIDEO    ;��ʾģʽ����ɫ�Ĵ���׼�����
 		CALL GetDiskPara
 		CALL FOXMAIN
    CLC
	  MOV ax,03h
    int 10h
    CALL LOAD_MsMBR
   
MAIN_EXIT:
    RET
MAINMENU ENDP
;-----------------������ ����-------------------------------------------------    
;------------------����ģ�� ����------------------------------------

INCLUDE FOXSVGA.ASM
INCLUDE FOXPM.ASM
INCLUDE FOXAbout.ASM				;��֪��Ϊʲô������ŵ����棬��������޷�ͨ��
INCLUDE FOXSetBD.ASM
INCLUDE FOXSTDIO.ASM
INCLUDE FOXHD.ASM
INCLUDE FOXMainM.ASM
INCLUDE FOXMAIN.ASM
INCLUDE FOXMCM.asm
INCLUDE FOXMUSIC.ASM
;INCLUDE FOXAbout.ASM
;;+++++++++++++++++++++++++++++++ �ӳ������ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;;;
;;;;
END START



