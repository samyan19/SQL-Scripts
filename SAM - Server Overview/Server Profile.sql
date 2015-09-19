USE zzPerfMon
GO

/*Declare variables*/
DECLARE 
	@UsedDataGB INT,
	@UsedLogGB INT,
	@TotalMemoryGB INT,
	@NUMACount INT,
	@CPUCount INT,
	@MaxSQLMemory INT,
	@Ratio VARCHAR(100)

/* 1. Total Disk Space */
Set @UsedDataGB=(select CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) 
FROM master.sys.master_files
where type<>1
)

Set @UsedLogGB=(select CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) 
FROM master.sys.master_files
where type=1
)

/* 2. Total Physical Memory GB */
create table #SVer(ID int,  Name  sysname, Internal_Value int, Value nvarchar(512))
insert #SVer exec master.dbo.xp_msver
                
SET @TotalMemoryGB=(SELECT Internal_Value/1024
FROM #SVer
WHere Name = 'PhysicalMemory')

drop table #SVer     



/* 3. Disk space to memory ratio */
SET @ratio=(SELECT CAST(@UsedDataGB/@TotalMemoryGB AS VARCHAR(100))+':1')


/* 4. Memory assigned to SQL */
SET @MaxSQLMemory=(select CAST(value_in_use as int)/1024
FROM sys.configurations
WHERE name ='max server memory (MB)')


/* 5. Number of NUMA Nodes */
SET @NUMACount=(select max(parent_node_id)+1 
from sys.dm_os_schedulers
where status ='VISIBLE ONLINE')


/* 6. Schedulers per NUMA */
SET @CPUCount=( SELECT max(scheduler_id)+1 
from sys.dm_os_schedulers
where status ='VISIBLE ONLINE')



/***
/* 7. Disk and CPU Aggregates*/
;WITH disk AS (
SELECT	SUM(sub.DiskMin) AS DiskMin,
		SUM(sub.DiskMax) AS DiskMax,
		SUM(sub.DiskAvg) AS DiskAvg,
		MachineName
FROM (
SELECT 
		 MachineName ,
		MIN(CounterValue) AS DiskMin,
        MAX(CounterValue) AS DiskMax,
        AVG(CounterValue) AS DiskAvg
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Disk Writes/sec','Disk Reads/sec')
        AND cdt.InstanceName = '_Total'
GROUP BY MachineName ,
        CounterName ,
        InstanceName ,
        DisplayString ) sub
		GROUP BY MachineName
		)
, cpu AS 
(SELECT 
		 MachineName ,
		MIN(CounterValue) AS cpuMin,
        MAX(CounterValue) AS cpuMax,
        AVG(CounterValue) AS cpuAvg
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('Processor')
        AND cdt.CounterName IN( '% Processor Time')
        AND cdt.InstanceName = '_Total'
GROUP BY MachineName ,
        CounterName ,
        InstanceName ,
        DisplayString )
SELECT 
	disk.MachineName,
	@UsedDataGB   AS 'Total Data Space GB',
	@UsedLogGB   AS 'Total Log Space GB',
	@TotalMemoryGB AS 'Total Memory GB',
	@MaxSQLMemory  AS 'Max SQL Server Memory GB',
	@NUMACount	   AS 'NUMA Count',
	@CPUCount	   AS 'CPU Count',
	@Ratio 		   AS 'Data GB to Memory GB Ratio',
	DiskMin as 'Min IOPS',
	DiskMax as 'Max IOPS',
	DiskAvg as 'Avg IOPS',
	CPUMin  as 'Min CPU',
	CPUMax  as 'Max CPU',
	CPUAvg  as 'Avg CPU'
FROM disk
JOIN cpu ON disk.MachineName=cpu.MachineName
***/



