/*2007-02-09 luobing ������Ϊ�ײ�������װ�İ�װ���򣬵������*/
/*2007-02-07������רΪfoxdisk������������������*/
/*          ��дstartsect+2  +3 ��������������foxdisk���������������ĵط�*/
#include	<dos.h>
#include	<bios.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<mem.h>

#include	"MyDisk.h"

#define	STARTSECTOR	0x06											/*Ҫ��װ����ʼ����*/
#define RESSECTOR	0x1													/*����������������LBA0x3f��ǰ��*/
#define FILENAME	"fox.bin"

unsigned char InstallMyPro(char * InsFle,int disk_no,char Installmin);
long	int GetFileLength(FILE	*fp);

/*	0:Ӳ�̲�����
//	1:��װ�ļ�������
//	2:��װ�ļ�̫��Ӳ�̿ռ䲻��
//	3:�Ѿ���װ����Ӳ�̵������������Ѿ�д����
//	4:�ڴ濽�����ɹ�
//	5:Ӳ��д����
//  6:�ڴ����ʧ��
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
	char Installflag;				//�洢�û��������õ�����
	
	Installflag=0x03;				//0 ������װ  1 ��С��װ 2 ǿ�а�װ 3��Ч������Ҫ��װ

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
          	Installflag=1;			//��С��װ
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
	//���ݽ��ܵ��Ĳ�����ʼ����
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
//��ڲ���: InsFle����װ�ļ���  disk_no:Ӳ�̺�(0 1 2 3)
//					Installmin:�Ƿ���С��װģʽ(ֻдMBR��) 1 ��  ��������:2 ǿ�а�װ�����ܴ���3
//���ڲ���: 0:�����ɹ�   ��0:���󷵻� 
//													 1:��װ�ļ�������
//													 2:��װ�ļ�̫��Ӳ�̿ռ䲻��
//													 3:�Ѿ���װ����Ӳ�̵������������Ѿ�д����
//													 4:�ڴ濽�����ɹ�
//													 5:Ӳ��д����
//  												 6:�ڴ����ʧ��
//��ע����װ������ʵҪд���Σ�һ��MBR�����ļ�����ʼ512�ֽ� ���ǽ��ļ�д��
//														�涨����ʼ����ֱ��0x3e��
*/
unsigned char InstallMyPro(char * InsFle,int disk_no,char Installmin)
{
	FILE	*fp;																		/*���ļ�����*/
	long int FileLength;
	union	REGS	inregs,outregs;
	struct	SREGS	segs;
	DiskAddressPacket 	*diskpage; 								/*EBOIS int13h*/
	BootSector	priboot;													/*������*/
	BootSector	bufsec;
	//BootSector	insboot[0x3f-1-STARTSECTOR];		/*���õķ�������,����һ�������Ա�����*/
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
	fread(&bufsec,sizeof(BootSector),1,fp);			/*��ȡ�ļ���ʼ��512�ֽڵ�������*/
	/*��һ����д����������*/
	/*���������������Ž�priboot��*/
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
	/*д������������priboot*/
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
	/*дstartsector��������priboot*/
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
		/*�ڶ��������ļ�д���涨����ʼ����*/
		fseek(fp,0L,SEEK_SET);											/*�ļ�λ��ָʾ���ص��ļ�ͷ*/
		if(Installmin!=2)
		{
			fseek(fp,2048L,SEEK_SET);											/*�ļ�λ��ָʾ��������������֮�������*/
		}
		else
		{
			fseek(fp,2560L,SEEK_SET);											/*�ļ�λ��ָʾ��������������֮�������*/
		}
		fread(insboot,(int)(FileLength),1,fp);			/*��ȡ�ļ���������*/
		/*д*/
		inregs.h.ah=0x43;
		inregs.h.al=0x0;
		inregs.h.dl=0x80+disk_no;
		diskpage=malloc(16*sizeof(char));
		diskpage->PacketSize=0x10;
		diskpage->Reserved1=0;
		if(Installmin!=2)							//������ɫ����������
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
//��ȡ�ļ��Ĵ�С���ֽ�����
//��ڲ���: FILE	*fp �ļ���ָ��
//���ڲ���: -1:�������ɹ�   ��0:����
//��ע��
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