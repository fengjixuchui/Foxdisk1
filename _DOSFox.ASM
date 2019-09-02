
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
    .MODEL SMALL
    .486
    .STACK 200H
.DATA
;#############################################  数据段开始  #####################################################
;数据段：显示部分所用数据，硬盘控制所用数据(结构)，提示信息所用字符串
DATABEGIN LABEL BYTE
;===============================字符串============================================
INCLUDE FOXDATA.ASM
;ORG 200h
MBRBUF     				  DB 446 DUP (0)
  BUF_PART1					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART2					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART3					Part_Entry <0,0,0,0,0,0,0,0,00,00>
	BUF_PART4					Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H				
;ORG 400H
FOXWAI     				  DB 446 DUP (0)												;我们自己要用的外网MBR
	FOXW_PART1				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART2				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART3				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXW_PART4				Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H
;ORG 600H 
FOXNEI     				  DB 446 DUP (0)												;我们自己要用的内网MBR
	FOXN_PART1				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART2				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART3				Part_Entry <0,0,0,0,0,0,0,0,00,00>
	FOXN_PART4				Part_Entry <0,0,0,0,0,0,0,0,00,00>
					          DW 0AA55H
;ORG 800H
FOXBUF LABEL BYTE
	My_SetupFlag		  DB 'LUOB';DB 4 DUP(0)														;字符串'LUOB'表示已经安装
										DB 12 DUP(0)
  include FoxSeeC.inc   																	;配色方案的选择							
;ORG 0A00H
ENDDATA         DW  0AA55H      ;结束标志
;#############################################  数据段结束  #####################################################
;
;#############################################  代码段开始  #####################################################
;+++++++++++++++++++++++++++++++ 主程序开始 ++++++++++++++++++++++++++++++++++++++++++
.CODE
START:
 MOV AX,@DATA
 MOV DS,AX 
 MOV ES,AX
 CALL MAIN_MOUDLE
 ;
 MOV  AX,4C00H
 INT 21H
;+++++++++++++++++++++++++++++++ 主程序结束 ++++++++++++++++++++++++++++++++++++++++++
;
;;+++++++++++++++++++++++++++++++ 子程序开始 ++++++++++++++++++++++++++++++++++++++++++
;子程序有六个部分：1 显示部分子程序  2 硬盘控制子程序  3 控制卡的子程序 
;          4 读取CMOS信息(为了以后扩展，后加的子程序也放在这个部分)
;          5 为主程序直接调用的界面子程序
;          6 主干模块
;------------------主干模块 开始------------------------------------
MAIN_MOUDLE PROC NEAR
 ;显示的初始化工作
 CALL INITVIDEO    ;显示模式及颜色寄存器准备完毕
 ;CALL	DISP_MAIN_SEL
 ;CALL BoundaryMangment
 ;CALL GetDiskPara
 CALL FOXMAIN
; CALL AboutDIS
; XOR AX,AX
; INT 16H
 ;MOV	DX,OFFSET STR_OUTTER_PARTSYS
 ;CALL PartMangment
 ;CALL MatchCMangment	
	
MAINEXIT:
 ;返回到3号显示模式
 MOV AX,0003H
 INT 10H
 RET
MAIN_MOUDLE ENDP
;------------------主干模块 结束------------------------------------
INCLUDE FOXSVGA.ASM
INCLUDE FOXPM.ASM
INCLUDE FOXAbout.ASM
INCLUDE FOXSetBD.ASM
INCLUDE FOXSTDIO.ASM
INCLUDE FOXHD.ASM
INCLUDE FOXMainM.ASM
INCLUDE FOXMAIN.ASM
INCLUDE FOXMCM.asm
INCLUDE FOXMUSIC.ASM
;------------------显示部分子程序 结束------------------------------------------------------------
;;+++++++++++++++++++++++++++++++ 子程序结束 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
END START