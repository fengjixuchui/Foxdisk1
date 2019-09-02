		
;#############################################  常量定义开始  #####################################################
INCLUDE FOXEQU.ASM
;#############################################  常量定义结束  #####################################################
;#############################################  结构定义开始  #####################################################
;硬盘管理子系统用到的数据结构
PartStruc	 struc
	PartActive	 db 		?		;LinkPointer:points to next T/Q descriptor or indicates termination by T-flag
	PartType     db     ?
	PartStart		 dw 		?		;presents the actual length (11 bit ) = and 2047
	PartEnd 		 dw 		?		;presents the Status
	;PartCap			 dw     ?   ;硬盘容量
	PartValid		 db     ?		;分区是否有效 （自己用）
PartStruc ends
;真实的分区结构
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

;#############################################  结构定义结束  #####################################################
;
;-----------代码段-----------------------------------------------------------------
.Model Tiny,C
.486P
.CODE
ORG 00H
START:
	CLI
  MOV AX,CS 											;引导程序-PC机将MBR拷贝到0:7c00处 cs=0h
  MOV SS,AX
  MOV SP,7C00H
  MOV DS,AX 											;设置堆栈0:7c00h,数据段ds=0
	CLD
	JMP LOAD_MYCODE
	LBARWBuf     DB 10H,00H,40H,00H,00H,00H,00H,40H,8 DUP(0)	;缓冲区规定为4000:0,其他参数在以下分送
	STR_ERR7		 DB 'ERROR 7: Read HD error.--luobing$'
LOAD_MYCODE:
  MOV SI,OFFSET LBARWBuf
	ADD SI,7C00H 										;定位数据 LBARWBuf
	;CALL GETLBAMAX									;设置硬盘最大可读写空间(对SATA硬盘不一定有效)
	;读硬盘STARTSECTOR处（在此处开始放的是整个文件，而在MBR处只放了本文件的前200h字节）
  MOV WORD PTR [SI+8],STARTSECTOR
  MOV WORD PTR [SI+10],0
  MOV WORD PTR [SI+12],0
  MOV WORD PTR [SI+14],0
	
	;CALL HDISBUSY									;对SATA硬盘不一定有效
	CALL READLBA
	JNB	LOAD_MYCODE_OK							;加载成功
	MOV	DX,OFFSET STR_ERR7					;加载失败则提示，3秒后退出
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
   CLI 														;从此处开始，开始进入底层界面程序的处理部分
	 MOV SI,CS 											;CS=DS=ES=4000H SS=0 SP=7C00H
	 MOV DS,SI
	 MOV ES,SI
	 STI
	 CLD
   CALL MAINMENU									;调用主程序
   ;	      
MYCODE_EXIT:   
   MOV AX,083H										;保持缓冲区
   INT 10H
;-----------------在MBR中用到的子程序 开始----------------------------------
;---------------------------------------------------
;****************************************************;
;*子程序名：	READLBA																**
;*功能：			扩展LBA读															**
;*入口参数：	SI指向的内存已经填充所需参数					**
;*出口参数：	CF=1 读取失败 CF=0 成功								**
;*使用说明：  试五次，其他参数如扩展读(int13h)			**
;****************************************************;
READLBA PROC NEAR
	PUSH BX
	PUSH CX
	PUSH DX
  MOV CX,5
	XOR AX,AX
	INT 13H
	;CALL HDISBUSY			;对SATA硬盘不一定有效
READSTART:
  MOV AX,4200H
  MOV DX,80H
	INT 13H
	JNB READOK					;CF=0 读取成功
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
;*子程序名：	DISPMESS															**
;*功能：			显示字符串(一律从(5,y)处开始)					**
;*入口参数：	DX=字符串偏移													**
;*出口参数：	无																		**
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
;*子程序名：	LBDELAY 															     **
;*功能：			延时																	     **
;*入口参数：	ax = delay time in milliseconds     			 **
;*出口参数：																				     **
;*注意：																								 **
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
;-----------------在MBR中用到的子程序 结束------------------------------------
;-----------------------------------------------------------------------------


;-----------------主程序 开始-------------------------------------------------
ORG 200h
MBRBUF     				  DB 446 DUP (0)
  BUF_PART1					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART2					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART3					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART4					Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H				
ORG 400H
FOXWAI     				  DB 446 DUP (0)												;我们自己要用的外网MBR
	FOXW_PART1				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART2				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART3				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART4				Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H
ORG 600H 
FOXNEI     				  DB 446 DUP (0)												;我们自己要用的内网MBR
	FOXN_PART1				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART2				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART3				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART4				Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H
ORG 800H
FOXBUF LABEL BYTE
	My_SetupFlag		  DB 4 DUP(0)														;字符串'LUOB'表示已经安装
										DB 12 DUP(0)
  include FoxSeeC.inc																			;配色方案的选择
  ORG 09FEH
										DW 0AA55H
ORG 0A00H
MAINMENU PROC NEAR
     MOV AX,CS
     MOV DS,AX
     MOV ES,AX
     JMP	CODESTART	
;-------------主程序要用到的数据 开始----------------------------------------
INCLUDE FOXDATA.ASM
;-------------主程序要用到的数据 结束----------------------------------------
CODESTART:
    CALL INITVIDEO    ;显示模式及颜色寄存器准备完毕
 		CALL GetDiskPara
 		CALL FOXMAIN
    CLC
	  MOV ax,03h
    int 10h
    CALL LOAD_MsMBR
   
MAIN_EXIT:
    RET
MAINMENU ENDP
;-----------------主程序 结束-------------------------------------------------    
;------------------主干模块 结束------------------------------------

INCLUDE FOXSVGA.ASM
INCLUDE FOXPM.ASM
INCLUDE FOXAbout.ASM				;不知道为什么，必须放到上面，否则编译无法通过
INCLUDE FOXSetBD.ASM
INCLUDE FOXSTDIO.ASM
INCLUDE FOXHD.ASM
INCLUDE FOXMainM.ASM
INCLUDE FOXMAIN.ASM
INCLUDE FOXMCM.asm
INCLUDE FOXMUSIC.ASM
;INCLUDE FOXAbout.ASM
;;+++++++++++++++++++++++++++++++ 子程序结束 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;;;
;;;;
END START



