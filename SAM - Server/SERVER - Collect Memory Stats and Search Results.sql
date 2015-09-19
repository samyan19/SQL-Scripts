/****** Script for SelectTopNRows command from SSMS  ******/

--====================================
--Collect Memory Stats
--====================================

insert into MemoryStats (name,value,cdt)
SELECT 'BufferHitCacheRatio' as name ,(a.cntr_value * 1.0 / b.cntr_value) * 100.0 AS value, GETDATE() as cdt
FROM sys.dm_os_performance_counters  a
JOIN  (SELECT cntr_value,OBJECT_NAME 
FROM sys.dm_os_performance_counters  
WHERE counter_name ='Buffer cache hit ratio base'
AND OBJECT_NAME = 'MSSQL$EXT01:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
WHERE a.counter_name ='Buffer cache hit ratio'
AND a.OBJECT_NAME = 'MSSQL$EXT01:Buffer Manager'   
UNION
SELECT 'PageLifeExpectancy' as name, cntr_value as value, GETDATE() as cdt
FROM sys.dm_os_performance_counters  
WHERE counter_name = 'Page life expectancy'
AND OBJECT_NAME = 'MSSQL$EXT01:Buffer Manager';


--===================================
--Search Results
--====================================



SELECT TOP 1000 [name]
      ,[value]
      ,[cdt]
  FROM [DBA_Admin].[dbo].[MemoryStats]
  where name LIKE '%PageLifeExpectancy%'
  order by cdt DESC



SELECT TOP 1000 [name]
      ,[value]
      ,[cdt]
  FROM [DBA_Admin].[dbo].[MemoryStats]
  where name LIKE '%Buffer%'
  order by cdt DESC
