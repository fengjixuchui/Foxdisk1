/*2007-02-09 luobing 本程序为底层界面程序安装的安装程序，调试完毕*/
/*2007-02-07本程序专为foxdisk程序制作，不作他用*/
/*          不写startsect+2  +3 两个扇区，这是foxdisk存放内外网分区表的地方*/
#include	<dos.h>
#include	<bios.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<mem.h>

#include	"MyDisk.h"

#define	STARTSECTOR	0x06											/*要安装的起始扇区*/
#define RESSECTOR	0x1													/*保留的扇区数，从LBA0x3f往前算*/
#define FILENAME	"fox.bin"

unsigned char InstallMyPro(char * InsFle,int disk_no,char Installmin);
long	int GetFileLength(FILE	*fp);

/*	0:硬盘不存在
//	1:安装文件不存在
//	2:安装文件太大，硬盘空间不够
//	3:已经安装过，硬盘的主引导扇区已经写过了
//	4:内存拷贝不成功
//	5:硬盘写出错
//  6:内存分配失败
*/
char  szHelpContext[] = \
"Syntax is:  setin.exe [options]\n" 
" /? or /H   Display Help file\n"
" /r or /R   Install My MBR\n"
"Error code table:\n"
"\t\tNo.\tmeaning\n"
"\t\t 0 \tHardDisk not exist\n"
"\t\t 1 \tinstall file not exist\n"
"\t\t 2 \tnot enough space to install\n"
"\t\t 3 \tthe programma was installed\n"
"\t\t 4 \tmemory copy error\n"
"\t\t 5 \twrite the harddisk error\n"
"\t\t 6 \talloc memory error\n";

void	main(int argc,char *argv[])
{
	union	REGS	inregs,outregs;
	struct	SREGS	segs;
	int	disk_count,disk_no[4];
	int	i;
	char Installflag;				//存储用户参数设置的种类
	
	Installflag=0x03;				//0 正常安装  1 最小安装 2 强行安装 3无效，不需要安装

	if(argc==1)
	{
		Installflag=0;
	}
	else if(argc==2)
	{
		for(i=1;i<argc;i++)
		{
			if((argv[i][0] == '/')||(argv[i][0] == '-'))
      {
      	switch(argv[i][1])
       	{
         	case '?':
         	case 'h':
         	case 'H':
          	printf(szHelpContext);
             break;
          case 'R':
          case 'r':
          	Installflag=1;			//最小安装
          	break;
          case 'Y':
          case 'y':
            Installflag=2;
            break;
         	default:
             break;        
        }
      }
    }
	}
	//根据接受到的参数开始处理
	if(Installflag!=0x03)
	{
		disk_count=0;
		for(i=0;i<4;i++)
		{
			inregs.h.ah=0x10;
			inregs.h.dl=0x80+i;
			int86(0x13,&inregs,&outregs);
			if(outregs.h.ah==0x0)
			{
				disk_no[disk_count]=i;
				disk_count++;
			}
		}
		
		if(disk_count==0)
		{
			printf("Error 0: There is no Harddisk,please check it.");
			return;
		}
		for(i=0;i<disk_count;i++)
		{
			printf("\nNow installing HardDisk %d",i);
			switch(InstallMyPro(FILENAME,disk_no[i],Installflag))
			{
				case	0:
					printf("\n  Installed successfully,thank you.");
					break;
				case	1:
					printf("\n  Error 1");
					break;
				case	2:
					printf("\n  Error 2");
					break;
				case	3:
					printf("\n  Error 3");
					break;
				case	4:
					printf("\n  Error 4");
					break;
				case	5:
					printf("\n  Error 5");
						break;
				case	6:
					printf("\n  Error 6");
					break;
				default:
					break;
			}
		}
	}
}

/*InstallMyPro
//入口参数: InsFle：安装文件名  disk_no:硬盘号(0 1 2 3)
//					Installmin:是否是小安装模式(只写MBR区) 1 是  其他则不是:2 强行安装，不管错误3
//出口参数: 0:操作成功   非0:错误返回 
//													 1:安装文件不存在
//													 2:安装文件太大，硬盘空间不够
//													 3:已经安装过，硬盘的主引导扇区已经写过了
//													 4:内存拷贝不成功
//													 5:硬盘写出错
//  												 6:内存分配失败
//备注：安装程序其实要写两次：一是MBR区，文件的起始512字节 二是将文件写到
//														规定的起始扇区直到0x3e处
*/
unsigned char InstallMyPro(char * InsFle,int disk_no,char Installmin)
{
	FILE	*fp;																		/*读文件变量*/
	long int FileLength;
	union	REGS	inregs,outregs;
	struct	SREGS	segs;
	DiskAddressPacket 	*diskpage; 								/*EBOIS int13h*/
	BootSector	priboot;													/*主分区*/
	BootSector	bufsec;
	//BootSector	insboot[0x3f-1-STARTSECTOR];		/*可用的分区总数,保留一个扇区以备它用*/
	unsigned char * insboot;
	
	if((insboot=malloc(512*(0x3e-1-STARTSECTOR+1-RESSECTOR)))==NULL)
	{
		return 6;
	}
	if((fp=fopen(InsFle,"rb")) ==NULL)
	{
		//printf("Cannot open install file: %s.",InsFle);
		free(insboot);
		return 1;
	}
	FileLength=GetFileLength(fp);
	if(FileLength>(1L*((0x3e-1-STARTSECTOR+1-RESSECTOR)*512)))
	{
		free(insboot);
		fclose(fp);
		return 2;
	}
	fread(&bufsec,sizeof(BootSector),1,fp);			/*读取文件开始的512字节到缓冲区*/
	/*第一步：写主引导扇区*/
	/*读主引导扇区，放进priboot内*/
	inregs.h.ah=0x2;
	inregs.h.al=1;
	inregs.h.ch=0;
	inregs.h.cl=1;
	inregs.h.dh=0;
	inregs.h.dl=0x80+disk_no;
	inregs.x.bx=(unsigned)&priboot;
	segread(&segs);
	int86x(0x13,&inregs,&outregs,&segs);
	if(Installmin!=2)
	{
		if(!memcmp(&priboot,&bufsec,446))
		{
			free(insboot);
			fclose(fp);
			return 3;
		}
	}
	if(!memcpy(&priboot,&bufsec,446))
	{
		free(insboot);
		fclose(fp);
		return 4;
	}
	/*写主引导扇区，priboot*/
	inregs.h.ah=0x3;
	inregs.h.al=1;
	inregs.h.ch=0;
	inregs.h.cl=1;
	inregs.h.dh=0;
	inregs.h.dl=0x80+disk_no;
	inregs.x.bx=(unsigned)&priboot;
	segread(&segs);
	int86x(0x13,&inregs,&outregs,&segs);
	if(outregs.h.ah!=0x0)
	{
		free(insboot);
		fclose(fp);
		return 5;
	}
	/*写startsector，引导用priboot*/
	inregs.h.ah=0x3;
	inregs.h.al=1;
	inregs.h.ch=0;
	inregs.h.cl=1+STARTSECTOR;
	inregs.h.dh=0;
	inregs.h.dl=0x80+disk_no;
	inregs.x.bx=(unsigned)&priboot;
	segread(&segs);
	int86x(0x13,&inregs,&outregs,&segs);
	if(outregs.h.ah!=0x0)
	{
		free(insboot);
		fclose(fp);
		return 5;
	}
	if(Installmin!=1)
	{
		/*第二步：将文件写到规定的起始扇区*/
		fseek(fp,0L,SEEK_SET);											/*文件位置指示器回到文件头*/
		if(Installmin!=2)
		{
			fseek(fp,2048L,SEEK_SET);											/*文件位置指示器到内外网分区之后的扇区*/
		}
		else
		{
			fseek(fp,2560L,SEEK_SET);											/*文件位置指示器到内外网分区之后的扇区*/
		}
		fread(insboot,(int)(FileLength),1,fp);			/*读取文件到缓冲区*/
		/*写*/
		inregs.h.ah=0x43;
		inregs.h.al=0x0;
		inregs.h.dl=0x80+disk_no;
		diskpage=malloc(16*sizeof(char));
		diskpage->PacketSize=0x10;
		diskpage->Reserved1=0;
		if(Installmin!=2)							//还有配色方案的扇区
		{
			diskpage->BlockCount=0x3e-1-STARTSECTOR+1-RESSECTOR-4;			
		}
		else
		{
			diskpage->BlockCount=0x3e-1-STARTSECTOR+1-RESSECTOR-5;
		}
		
		diskpage->Reserved2=0;
		diskpage->BufferAddr=(long int)(insboot);
		if(Installmin!=2)
		{
			diskpage->BlockNum1=STARTSECTOR+4;				
		}
		else
		{
			diskpage->BlockNum1=STARTSECTOR+5;
		}
		diskpage->BlockNum2=0x0;
		inregs.x.si=(unsigned int)diskpage;
		segread(&segs);
		int86x(0x13,&inregs,&outregs,&segs);
		if(outregs.h.ah!=0x0)
		{
			free(insboot);
			fclose(fp);
			return 5;
		}
	}
	fclose(fp);
	free(insboot);
	return 0;
}
/*GetFileLength
//获取文件的大小（字节数）
//入口参数: FILE	*fp 文件的指针
//出口参数: -1:操作不成功   非0:长度
//备注：
*/
long	int GetFileLength(FILE	*fp)
{
	long int curpos,length;
	
	curpos=ftell(fp);
	fseek(fp,0L,SEEK_END);
	length=ftell(fp);
	fseek(fp,curpos,SEEK_SET);
	return length;
}