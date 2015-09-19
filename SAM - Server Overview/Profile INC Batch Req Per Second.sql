USE zzPerfMon
GO
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

/*Declare variables*/
DECLARE 
	@UsedDataGB DECIMAL (10,2),
	@UsedLogGB DECIMAL (10,2),
	@TotalMemoryGB DECIMAL (10,2),
	@NUMACount INT,
	@CPUCount INT,
	@MaxSQLMemory DECIMAL (10,2),
	@Ratio VARCHAR(100),
	@DatabaseCount int,
	@MaxDBSizeGB decimal (10,2),
	@MaxDBName nvarchar(100),
	@CPUDetail nvarchar(100),
	@CollectionStartDate char(24)



/* Min Collection Date */
set @CollectionStartDate=(select MIN (CounterDateTime)
from CounterData
where CounterID=1)


/* CPU information */

declare @CPUTable table (value varchar(100),data nvarchar(500))
	
insert into @CPUTable
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString';

set @CPUDetail=(select data from @CPUTable) 

/* User Database Count */
set @DatabaseCount=(select count (1) from sys.databases where database_id not in (1,2,3,4))

/* Largest User DB name and size */
select top 1 
@MaxDBName=db_name(database_id),
@MaxDBSizeGB=CONVERT(DECIMAL(10,2),(MAX(size * 8.00) / 1024.00 / 1024.00)) 
FROM master.sys.master_files
where type<>1 and database_id not in (1,2,3,4)
group by database_id
order by CONVERT(DECIMAL(10,2),(MAX(size * 8.00) / 1024.00 / 1024.00)) desc




/* 1. Total Disk Space */
Set @UsedDataGB=(select CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) 
FROM master.sys.master_files
where type<>1 and database_id not in (1,2,3,4)
)

--Set @UsedLogGB=(select CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) 
--FROM master.sys.master_files
--where type=1
--)

--/* 2. Total Physical Memory GB */
--create table #SVer(ID int,  Name  sysname, Internal_Value int, Value nvarchar(512))
--insert #SVer exec master.dbo.xp_msver
                
----SET @TotalMemoryGB=(
--SELECT CAST(Internal_Value/1024.0 as decimal(10,0)) 
--FROM #SVer
--WHere Name = 'PhysicalMemory'
----)

--drop table #SVer     

/* 4. Memory assigned to SQL */
SET @MaxSQLMemory=(select CAST(value_in_use as int)/1024
FROM sys.configurations
WHERE name ='max server memory (MB)')


/* 3. Disk space to memory ratio */
SET @ratio=' '+(SELECT CAST(CAST(@UsedDataGB/@MaxSQLMemory AS DECIMAL(10,0)) AS VARCHAR(100))+':1 ')





/* 5. Number of NUMA Nodes */
SET @NUMACount=(select max(parent_node_id)+1 
from sys.dm_os_schedulers
where status ='VISIBLE ONLINE')


/* 6. Schedulers per NUMA */
SET @CPUCount=( SELECT max(scheduler_id)+1 
from sys.dm_os_schedulers
where status ='VISIBLE ONLINE')



--SELECT 
--	@UsedDataGB   AS 'Total Data Space GB',
--	@UsedLogGB   AS 'Total Log Space GB',
--	@TotalMemoryGB AS 'Total Memory GB',
--	@MaxSQLMemory  AS 'Max SQL Server Memory GB',
--	@NUMACount	   AS 'NUMA Count',
--	@CPUCount	   AS 'CPU Count',
--	@Ratio 		   AS 'Data GB to Memory GB Ratio'


/* PLE Analysis */


DECLARE @PLE TABLE (machinename VARCHAR(100), VALUE FLOAT);
DECLARE @CPU TABLE (machinename VARCHAR(100), VALUE FLOAT);
DECLARE @IOPS TABLE (machinename VARCHAR(100), VALUE FLOAT);
DECLARE @BRPS TABLE (machinename VARCHAR(100), VALUE FLOAT);

declare @max int 
SET @max=(
SELECT CAST(value_in_use AS INT)
FROM sys.configurations
WHERE name LIKE '%max server memory%')

DECLARE @threshold INT
SET @threshold=((@max/1024)/4) * 300

; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,CounterValue,MachineName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName  LIKE '%Buffer Manager%'
        AND cdt.CounterName IN( 'Page life expectancy')
        --AND cdt.InstanceName = '_Total'
),
TestDetail AS
(
	SELECT Year,CounterValue, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile, machinename
	FROM (
		SELECT
		SUBSTRING(CounterDateTime,1,4) AS Year, 
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4))AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4) ORDER BY CounterValue desc) AS Position
		FROM viewCPU
		WHERE SUBSTRING(CounterDateTime,1,4)='2015'
	)  T
)
INSERT INTO @PLE
SELECT DISTINCT machinename,MAX(percentile )
FROM TestDetail 
--WHERE ceiling(Percentile)=100
WHERE CounterValue>@threshold
GROUP BY MachineName


/* CPU Analysis */
; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,CounterValue,MachineName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('Processor')
        AND cdt.CounterName IN( '% Processor Time')
        AND cdt.InstanceName = '_Total'
),
TestDetail AS
(
	SELECT Year,CounterValue, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile, machinename
	FROM (
		SELECT
		SUBSTRING(CounterDateTime,1,4) AS Year, 
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4))AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4) ORDER BY CounterValue ) AS Position
		FROM viewCPU
		WHERE SUBSTRING(CounterDateTime,1,4)='2015'
	)  T
)
INSERT INTO @CPU
SELECT DISTINCT machinename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName


/* CPU Analysis */
; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,CounterValue,MachineName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
       cdt.CounterName ='Batch Requests/sec'
),
TestDetail AS
(
	SELECT Year,CounterValue, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile, machinename
	FROM (
		SELECT
		SUBSTRING(CounterDateTime,1,4) AS Year, 
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4))AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4) ORDER BY CounterValue ) AS Position
		FROM viewCPU
		WHERE SUBSTRING(CounterDateTime,1,4)='2015'
	)  T
)
INSERT INTO @BRPS
SELECT DISTINCT machinename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName


/* IOPS Analysis */


; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,SUM(CounterValue) AS 'countervalue',MachineName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Disk Reads/sec', 'Disk Writes/sec')
        AND cdt.InstanceName = '_Total'
GROUP BY CounterDateTime,MachineName
),
TestDetail AS
(
	SELECT Year,CounterValue, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile, machinename
	FROM (
		SELECT
		SUBSTRING(CounterDateTime,1,4) AS Year, 
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4))AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4) ORDER BY CounterValue ASC) AS Position
		FROM viewCPU
		WHERE SUBSTRING(CounterDateTime,1,4)='2015'
	)  T
)
INSERT INTO @IOPS
SELECT DISTINCT machinename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName






SELECT 
	@CollectionStartDate as 'Collection Start Date',
	c.machinename AS 'Machine Name',
	@UsedDataGB   AS 'Total Data Space GB',
	--@UsedLogGB   AS 'Total Log Space GB',
	--@TotalMemoryGB AS 'Total Physical Memory GB',
	@MaxSQLMemory  AS 'Max SQL Server Memory GB',
	@Ratio 		   AS 'Data Space GB:Max SQL Memory GB',
	@DatabaseCount as 'Database Count',
	@MaxDBSizeGB as 'Largest Database Size GB',
	@MaxDBName as 'Name of Largest Database',
	@CPUDetail as 'Make of CPU', 
	@CPUCount	   AS 'CPU Count',
	@NUMACount	   AS 'NUMA Count',
	c.value AS 'Max CPU % for 95% of Workload',
	i.value AS 'Max IOPS for 95% of Workload',
	p.value AS '% PLE above Memory Threshold',
	b.VALUE as 'Batch Requests Per Second for 95% of Workload'
FROM @CPU c 
JOIN @PLE p ON c.machinename=p.machinename
JOIN @IOPS i ON c.machinename=i.machinename
JOIN @BRPS b on c.machinename=b.machinename
--order by [Total Data Space GB] desc







