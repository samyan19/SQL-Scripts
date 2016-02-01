--USE zzPerfMon
--GO
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
	@CPUDetail nvarchar(100)

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

Set @UsedLogGB=(select CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) 
FROM master.sys.master_files
where type=1
)

/* 2. Total Physical Memory GB */
create table #SVer(ID int,  Name  sysname, Internal_Value int, Value nvarchar(512))
insert #SVer exec master.dbo.xp_msver
                
SET @TotalMemoryGB=(
SELECT CAST(Internal_Value/1024.0 as decimal(10,0)) 
FROM #SVer
WHere Name = 'PhysicalMemory'
)

drop table #SVer     

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



declare @max int 
SET @max=(
SELECT CAST(value_in_use AS INT)
FROM sys.configurations
WHERE name LIKE '%max server memory%')

DECLARE @threshold INT
SET @threshold=((@max/1024)/4) * 300







SELECT 
	@@SERVERNAME as server_name,
	SERVERPROPERTY('productversion') as version,
	SERVERPROPERTY('edition') as edition,
	SERVERPROPERTY('productlevel') as sp_level,
	--@@VERSION,
	@UsedDataGB   AS 'total_data_gb',
	@UsedLogGB   AS 'total_log_GB',
	@UsedDataGB+@UsedLogGB as total_db_space_used_gb,
	@TotalMemoryGB AS 'physical_memory_gb',
	@MaxSQLMemory  AS 'max_sql_memory_gb',
	@Ratio 		   AS 'data:sqlmemory_ratio',
	@DatabaseCount as 'db_count',
	@MaxDBSizeGB as 'max_db_gb',
	@MaxDBName as 'max_db_name',
	@CPUDetail as 'cpu_make', 
	@CPUCount	   AS 'cpu_count',
	@NUMACount	   AS 'numa_count'
