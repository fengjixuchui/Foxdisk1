#ifndef	MYDISK_H
#define MYDISK_H
/*1 Ӳ�̷�������*/
typedef	struct	Part_Entrytag
{
	unsigned char		part_flag;
	unsigned char		beginning_head;
	unsigned char		beginning_sector;
	unsigned char		beginning_cylinder;
	unsigned char		file_system;
	unsigned char		ending_head;
	unsigned char		ending_sector;
	unsigned char		ending_cylinder;
	long	int	first_sector;
	long	int	sector_count;
}Part_Entry;

/*2 ����������*/
typedef	struct	BootSectortag
{
	unsigned char		loader[240];
	unsigned char		reserved1[206];
	Part_Entry	part[4];
	unsigned	int	end_flag;
}BootSector;

/*3 ���пռ���Ϣ��*/
typedef	struct	FreeSpacetag
{
	long	int	beginning_logsector;
	long	int	ending_logsector;
	long	int	logsector_count;
}FreeSpace;

/*4 ��������ַ���ݰ�*/
typedef struct DriveParametersPackettag
{
    short	int	InfoSize;          /* ���ݰ��ߴ� (26 �ֽ�)*/
    short	int	Flags;             /* ��Ϣ��־*/
    long	int	Cylinders;         /* ����������*/
   	long	int	Heads;             /* ���̴�ͷ��*/
    long	int	SectorsPerTrack;   /* ÿ�ŵ�������*/
    long	int	Sectors1;          /* ������������*/
    long	int	Sectors2;
    short	int	SectorSize;        /* �����ߴ� (���ֽ�Ϊ��λ)*/
    double	SegEver;
}DriveParametersPacket;

/*5  ���̵�ַ���ݰ�   */
typedef struct DiskAddressPackettag
{
   unsigned char		PacketSize;		    /*���ݰ��ߴ�(16�ֽ�)*/
   unsigned char		Reserved1;       	/* ==0*/
   unsigned char		BlockCount;     	/*Ҫ��������ݿ����(������Ϊ��λ)*/
   unsigned char		Reserved2;  		  /* ==0*/
   long	int	BufferAddr;    		        /*���仺���ַ(segment:offset)*/
   long	int	BlockNum1;		            /*������ʼ���Կ��ַ*/
   long	int	BlockNum2;
}DiskAddressPacket;

#endif