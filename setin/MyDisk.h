#ifndef	MYDISK_H
#define MYDISK_H
/*1 硬盘分区表项*/
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

/*2 主引导扇区*/
typedef	struct	BootSectortag
{
	unsigned char		loader[240];
	unsigned char		reserved1[206];
	Part_Entry	part[4];
	unsigned	int	end_flag;
}BootSector;

/*3 空闲空间信息块*/
typedef	struct	FreeSpacetag
{
	long	int	beginning_logsector;
	long	int	ending_logsector;
	long	int	logsector_count;
}FreeSpace;

/*4 驱动器地址数据包*/
typedef struct DriveParametersPackettag
{
    short	int	InfoSize;          /* 数据包尺寸 (26 字节)*/
    short	int	Flags;             /* 信息标志*/
    long	int	Cylinders;         /* 磁盘柱面数*/
   	long	int	Heads;             /* 磁盘磁头数*/
    long	int	SectorsPerTrack;   /* 每磁道扇区数*/
    long	int	Sectors1;          /* 磁盘总扇区数*/
    long	int	Sectors2;
    short	int	SectorSize;        /* 扇区尺寸 (以字节为单位)*/
    double	SegEver;
}DriveParametersPacket;

/*5  磁盘地址数据包   */
typedef struct DiskAddressPackettag
{
   unsigned char		PacketSize;		    /*数据包尺寸(16字节)*/
   unsigned char		Reserved1;       	/* ==0*/
   unsigned char		BlockCount;     	/*要传输的数据块个数(以扇区为单位)*/
   unsigned char		Reserved2;  		  /* ==0*/
   long	int	BufferAddr;    		        /*传输缓冲地址(segment:offset)*/
   long	int	BlockNum1;		            /*磁盘起始绝对块地址*/
   long	int	BlockNum2;
}DiskAddressPacket;

#endif