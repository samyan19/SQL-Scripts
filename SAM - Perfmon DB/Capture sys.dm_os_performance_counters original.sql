/*
http://www.patrickkeisler.com/2013/01/spperformancecounters-get-health-check.html


*/

USE DBA_Admin;
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp_PerformanceCounters]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[sp_PerformanceCounters]
GO

CREATE PROCEDURE [dbo].[sp_PerformanceCounters]
AS

/********************************************************************

  File Name:    sp_PerformanceCounters.sql

  Applies to:   SQL Server 2005
                SQL Server 2008
                SQL Server 2008 R2
                
  Purpose:      To aggregate overall performance data since SQL 
                Server was last started. The data is pulled from
                sys.dm_os_performance_counters. The code was adapted 
                from material taken from http://goo.gl/czeyC. 
                Written by Kevin Kline (MVP) with Brent Ozar (MCM, MVP) 
                and contributions by Christian Bolton (MCM, MVP), 
                Bob Ward (Microsoft), Rod Colledge (MVP), and Raoul Illyaos.

  Author:       Patrick Keisler (Samuel Yanzu - contributor)

  Version:      1.0.2
  
  Updates:      1.0.1 - Fixed description issue for Lock Requests/sec
                1.0.2 - Fixed SQL Server start time calculation issue
				1.0.3 - Amended to persist data into SQL table 

  Date:         08/08/2013

  Help:         http://www.patrickkeisler.com/
  
  License:      (C) 2013 Patrick Keisler
                sp_PerformanceCounters is free to download and use for 
                personal, educational, and internal corporate purposes, 
                provided that this header is preserved. Redistribution 
                or sale sp_PerformanceCounters in whole or in part, 
                is prohibited without the author's express written consent.

********************************************************************/


SET NOCOUNT ON;
SET ARITHABORT ON;

DECLARE 
     @InstanceName VARCHAR(100)
    ,@SQLServerName VARCHAR(255)
    ,@TempValue1 DECIMAL(25,5)
    ,@TempValue2 DECIMAL(25,5)
    ,@CalcCntrValue DECIMAL(25,2)
    ,@StartDate DATETIME
    ,@UpTime DECIMAL(25,0)
    ,@UpTimeMs DECIMAL(25,0);

-- Get the SQL Server instance name.
SELECT @InstanceName = CONVERT(VARCHAR,SERVERPROPERTY('InstanceName'));

IF @InstanceName IS NOT NULL
    SET @SQLServerName = 'MSSQL$' + @InstanceName;
ELSE
    SET @SQLServerName = 'SQLServer';

-- Get SQL Server start time.
-- The sqlserver_start_time column does not exist in sys.dm_os_sys_info in SQL Server 2005, so we will calculate the uptime based on the tempdb creation date. 
SELECT @StartDate = create_date FROM master.sys.databases WHERE database_id = 2;

-- Calculate SQL Server uptime in seconds.
SELECT @UpTime = DATEDIFF(ss,@StartDate,CURRENT_TIMESTAMP);

-- Calculate SQL Server uptime in milliseconds.
SELECT @UpTimeMs = @UpTime * 1000;

-- Create temp table to hold performance data.
IF OBJECT_ID('dba_admin..PerformanceCounters') IS NULL
BEGIN
	CREATE TABLE PerformanceCounters(
		 Id int IDENTITY(1,1)
		,PerformanceObject VARCHAR(128)
		,CounterName VARCHAR(128)
		,InstanceName VARCHAR(128)
		,TimeFrame VARCHAR(128)
		,ActualValue VARCHAR(128)
		,IdealValue  VARCHAR(128)
		,Description VARCHAR(1000)
		,CollectionDateTime datetime default getdate()
	);
END

-- Get Database Pages
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'Number of database pages in the buffer pool with database content.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Database Pages';

-- Get Target Pages
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'Ideal number of pages in the buffer pool based on the configured Max Server Memory in sp_configure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Target pages';

-- Get Free Pages
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'> 640'
    ,'Total number of pages available across all free list. A value less than 640 (5MB) may indicate physical memory pressure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Free pages';

-- Get Stolen Pages
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'Total number of page stolen from the buffer pool to satisfy other memory needs, such as plan cache and workspace memory.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Stolen pages';

-- Get Total Server Memory (KB)
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'Total amount of dynamic memory that SQL is currently consuming. This value should grow until its equal to Target Server Memory.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Memory Manager'
AND counter_name = 'Total Server Memory (KB)';

-- Get Target Server Memory (KB)
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'Total amount of dynamic memory that SQL is willing to consume based on the configured Max Server Memory in sp_configure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Memory Manager'
AND counter_name = 'Target Server Memory (KB)';

-- Get Memory Grants Pending
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'0'
    ,'Current number of processes waiting for memory. Anything above 0 for an extended period of time is an indicator of memory pressure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Memory Manager'
AND counter_name = 'Memory Grants Pending';

-- Get Free list stalls/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 2'
    ,'Number of requests per second where data requests wait for a free page in memory. Any value above 2 is an indicator of memory pressure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Free list stalls/sec';

-- Get Lazy writes/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 20'
    ,'Number of buffers the Lazy Writer writes to disk to free up buffer space. Zero is ideal, but any value greater than 20 is an indicator of memory pressure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Lazy writes/sec';

-- Get Checkpoint pages/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of dirty pages pages per second that are flushed by the checkpoint process. Checkpoint frequency controled by the Recovery Interval setting in sp_configure. High values for this counter is an indicator of memory pressure or that the recovery interval is set too high.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Checkpoint pages/sec';

-- Get Page life expectancy
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'> 300'
    ,'Number of seconds a data page to stay in the buffer pool without references.  A value under 300 may be an indicator of memory pressure; however index optimization may help.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Page life expectancy';

-- Get Page lookups / Batch Requests
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Page lookups/sec';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Batch Requests/sec';

IF @TempValue2 <> 0
    SET @CalcCntrValue = (@TempValue1/@TempValue2);
ELSE
    SET @CalcCntrValue = 0;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':Buffer Manager'
    ,'Page lookups / Batch Requests'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue)
    ,'< 100'
    ,'Number of batch requests to find a page in the buffer pool per batch request.  When this ratio exceeds 100, then you may have bad execution plans or too many adhoc queries.';

-- Get Page reads/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 90'
    ,'Number of physical database page reads issued.  Values above 90 could be a result of poor indexing or is an indicator of memory pressure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Page reads/sec';

-- Get Page writes/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 90'
    ,'Number of physical database page writes issued. Values over 90 should be cross-checked with "Lazy writes/sec" and "Checkpoint" counters. If the other counters are also high, then it is an indicator of memory pressure.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Page writes/sec';

-- Get Readahead pages / Page reads
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Readahead pages/sec';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Buffer Manager'
AND counter_name = 'Page reads/sec';

IF @TempValue2 <> 0
    SET @CalcCntrValue = (@TempValue1/@TempValue2*100);
ELSE
    SET @CalcCntrValue = 0;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':Buffer Manager'
    ,'Readahead pages / Page reads'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue,0) + '%'
    ,'< 20%'
    ,'Percentage of page reads that were readahead reads.  High number of readahead reads for each page read could be an indicator of memory pressure.';


/******************************************
    Workload Section Header
******************************************/

-- Get Batch Requests/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of batch requests per second.  Good indicator of the activity level of the server.  Should be cross-checked with other counters such as CPU utilization.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Batch Requests/sec';

-- Get Transactions/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime),0)
    ,'See description'
    ,'Number of transactions started for all databases.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Transactions/sec'
ORDER BY instance_name;

-- Get SQL Compilations / Batch Requests
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'SQL Compilations/sec';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Batch Requests/sec';

IF @TempValue2 <> 0 AND @UpTime <> 0 
    SET @CalcCntrValue = (@TempValue1/@TempValue2) * 100;
ELSE
    SET @CalcCntrValue = 0;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':SQL Statistics'
    ,'SQL Compilations / Batch Requests'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue) + '%'
    ,'< 10%'
    ,'Percentage of batch requests that required a SQL compilation (including recompiles). The lower this value the better. High values often could mean too many adhoc queryies. Also consider enabling Optimize for Ad Hoc Workloads" in sp_configure.';

-- Get SQL Re-Compilations / SQL Compilations
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'SQL Re-Compilations/sec';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'SQL Compilations/sec';

IF @TempValue2 <> 0
    SET @CalcCntrValue = (@TempValue1/@TempValue2) * 100;
ELSE
    SET @CalcCntrValue = 0;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':SQL Statistics'
    ,'SQL Re-Compilations / SQL Compilations'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue) + '%'
    ,'< 10%'
    ,'Percentage of all SQL Compilations that were recompiles.';

-- Get SQL Attention rate
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'~ 0'
    ,'Number of times the client requested to end the session. This could be timeouts or frequent query cancellations by the end user.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'SQL Attention rate';

-- Get Active cursors
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'Number of active cursors.  Frequent use of cursors can lead to performance issues.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Cursor Manager by Type'
AND counter_name = 'Active cursors'
ORDER BY instance_name;

-- Get Errors/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime),0)
    ,'~ 0'
    ,'Number of errors per second.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Errors'
AND counter_name = 'Errors/sec'
ORDER BY instance_name;

-- Deprecated Features
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,''
    ,'Total since SQL startup'
    ,SUM(cntr_value)
    ,'~ 0'
    ,'Number of deprecated featured used since SQL started up. This counter is only relavant when considering an upgrade to a newer version of SQL Server.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Deprecated Features'
GROUP BY object_name,counter_name


/******************************************
    User & Locks Section Header
******************************************/

-- Get Logins/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 2'
    ,'Total number of user logins started per second. Any value over 2 may indicate insufficient connection pooling.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':General Statistics'
AND counter_name = 'Logins/sec';

-- Get Logouts/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 2'
    ,'Total number of user logins started per second. Any value over 2 may indicate insufficient connection pooling.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':General Statistics'
AND counter_name = 'Logouts/sec';

-- Get User connections
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,''
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value)
    ,'See description'
    ,'The number of users connected to the SQL Server.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':General Statistics'
AND counter_name = 'User connections';

-- Get Latch Waits/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 10'
    ,'The number latch requests that could not be granted immediately and had to wait before being granted. Latches are lightweight means of holding a server resource.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Latches'
AND counter_name = 'Latch Waits/sec';

-- Get Avg Latch Wait Time (ms)
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Latches'
AND counter_name = 'Avg Latch Wait Time (ms)';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Latches'
AND counter_name = 'Average Latch Wait Time Base';

SET @CalcCntrValue = @TempValue1/@TempValue2;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':Latches'
    ,'Avg Latch Wait Time (ms)'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue)
    ,'< 2'
    ,'Average latch wait time (ms) for latch requests that had to wait.';

-- Get Lock Waits/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'0'
    ,'Number of lock requests that could not be satisfied immediately and caused the caller to wait. Values greater than zero indicate some blocking is occuring.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Locks'
AND counter_name = 'Lock Waits/sec'
ORDER BY instance_name;

-- Get Average Lock Wait Time (ms)
WITH BaseValue AS
(
SELECT * FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Locks'
AND counter_name = 'Average Wait Time Base'
)
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(MsValue.object_name)
    ,RTRIM(MsValue.counter_name)
    ,RTRIM(MsValue.instance_name)
    ,'Avg since SQL startup'
    ,ActualValue = CASE 
        WHEN BaseValue.cntr_value = 0 THEN 0
        ELSE MsValue.cntr_value/BaseValue.cntr_value
     END
    ,'< 500'
    ,'The average amount of wait time (ms) for each lock request that had to wait. An average wait time longer than 500ms may indicate excessive blocking.'
FROM sys.dm_os_performance_counters MsValue join BaseValue
ON MsValue.object_name = BaseValue.object_name AND MsValue.instance_name = BaseValue.instance_name
WHERE MsValue.object_name = @SQLServerName+':Locks'
AND MsValue.counter_name = 'Average Wait Time (ms)';

-- Get Lock Requests/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 1000'
    ,'The number of new locks and lock converted per second. This metric should correspond to "Batch Requests/sec". Values of > 1000 may indicate very large numbers of rows.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Locks'
AND counter_name = 'Lock Requests/sec'
ORDER BY instance_name;

-- Get Lock Timeouts/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 1'
    ,'Number of lock requests that timed out, including requests for NOWAIT locks. A value greater than zero might indicate that user queries are timing out.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Locks'
AND counter_name = 'Lock Timeouts/sec'
ORDER BY instance_name;

-- Get Number of Deadlocks/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 1'
    ,'Number of lock requests that timed out, including requests for NOWAIT locks. A value greater than zero might indicate that user queries are timing out.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Locks'
AND counter_name = 'Number of Deadlocks/sec'
ORDER BY instance_name;

-- Get Table Lock Escalations/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'The number of times locks ona a table were escalated locks from page-level or row-level to table-level.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Table Lock Escalations/sec';


/******************************************
    Data Access Section Header
******************************************/

-- Get Full Scans/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of full scans on either base tables or indexes. If CPU utilization is also high, then it may be caused by missing indexes.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Full Scans/sec';

-- Get Index Searches/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of index searches when doing range scans, single-index fetches, and repositioning within an index.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Index Searches/sec';

-- Get Index Searches / Full Scans
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Index Searches/sec';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Full Scans/sec';

IF @TempValue2 <> 0
    SET @CalcCntrValue = (@TempValue1/@TempValue2);
ELSE
    SET @CalcCntrValue = 0;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':Access Methods'
    ,'Index Searches / Full Scans'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue)
    ,'> 1000'
    ,'This metric is strictly for OLTP workloads.';

-- Get Page Splits/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of page splits that occur as a result of overflowing index pages. Value should be a low as possible. Excessive page splits may be caused by an incorrect fill factor.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Page Splits/sec';

-- Get Page Splits / Batch Requests
SELECT @TempValue1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Page Splits/sec';

SELECT @TempValue2 = cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Batch Requests/sec';

IF @TempValue2 <> 0
    SET @CalcCntrValue = (@TempValue1/@TempValue2);
ELSE
    SET @CalcCntrValue = 0;

INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     @SQLServerName+':Buffer Manager'
    ,'Page Splits / Batch Requests'
    ,''
    ,'Avg since SQL startup'
    ,CONVERT(VARCHAR,@CalcCntrValue)
    ,'< 5'
    ,'Number of page splits per batch request. To avoid page splits, review table and index design to reduce non-sequential inserts or implement fillfactor and pad_index to leave more empty space per page. NOTE: A high value for this counter is not bad in situations where many new pages are being created, since it includes new page allocations.';

-- Get Workfiles Created/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 20'
    ,'Number of work files created per second. May be part of tempdb processing to store temporary results for hashing joins and other hashing aggregates. High values can indicate thrashing of tempdb.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Workfiles Created/sec';

-- Get Worktables Created/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'< 20'
    ,'Number of work tables created per second. May be part of tempdb processing to store temporary results for spools, LOB variables, XML variables, and cursors. High values can indicate thrashing of tempdb.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Access Methods'
AND counter_name = 'Worktables Created/sec';


/******************************************
    SQL Statistics Hearder
******************************************/


-- Auto-Param Attempts/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of auto-parameterizations per second. Occurs when SQL attempts to resue a cached plan for a previous executed query that is similar to, but not the same as, the current query. The total should be the sum of the failed, safe, and unsafe auto-parameterizations.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Auto-Param Attempts/sec';

-- Failed Auto-Params/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of failed auto-parameterizations per second. This number should be small.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Failed Auto-Params/sec';

-- Safe Auto-Params/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'Number of safe auto-parameterizations per second.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Safe Auto-Params/sec';

-- Unsafe Auto-Params/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime))
    ,'See description'
    ,'A query designated as unsafe when it has characteristics that prevent its cached plan from being shared.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':SQL Statistics'
AND counter_name = 'Unsafe Auto-Params/sec';


/******************************************
    User Database Performance Hearder
******************************************/


-- Log Bytes Flushed/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime),0)
    ,'See description'
    ,'Total number of log bytes flushed per second. Useful for determining utilization of the transaction log.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Log Bytes Flushed/sec'
ORDER BY instance_name;

-- Log Flush Wait Time (ms)
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,'Log Flush Wait Time (ms)'
    ,RTRIM(instance_name)
    ,'Total since SQL startup'
    ,cntr_value
    ,'~ 0'
    ,'Total wait time (ms) to write all transaction log pages.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Log Flush Wait Time'
ORDER BY instance_name;

-- Log Flush Waits/sec
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Avg since SQL startup'
    ,CONVERT(DECIMAL(25,2),(cntr_value/@UpTime),0)
    ,'~ 0'
    ,'The number of times per second SQL Server had to wait for page to be written to the transaction log.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Log Flush Waits/sec'
ORDER BY instance_name;

-- Log Growths
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Total since SQL startup'
    ,cntr_value
    ,'~ 0'
    ,'Total number of times the transaction log has expanded. Each time the transaction log grows, all user activity must halt until the log growth completes.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Log Growths'
ORDER BY instance_name;

-- Log Shrinks
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Total since SQL startup'
    ,cntr_value
    ,'~ 0'
    ,'Total number of times the transaction log has been shrunk.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Log Shrinks'
ORDER BY instance_name;

-- Log Truncations
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Total since SQL startup'
    ,cntr_value
    ,'See description'
    ,'Total number of times the transaction log has been truncated.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Log Truncations'
ORDER BY instance_name;

-- Percent Log Used
INSERT INTO PerformanceCounters(PerformanceObject,CounterName,InstanceName,TimeFrame,ActualValue,IdealValue,Description)
SELECT 
     RTRIM(object_name)
    ,RTRIM(counter_name)
    ,RTRIM(instance_name)
    ,'Current'
    ,CONVERT(VARCHAR,cntr_value,0) + '%'
    ,'< 80%'
    ,'Percentage of log space in use. Since all work in an OLTP database stops until writes can occur to the transaction log, it''s a good idea to ensure the log never fills completely. Hence, the recomendation is keep the log under 80%.'
FROM sys.dm_os_performance_counters
WHERE object_name = @SQLServerName+':Databases'
AND counter_name = 'Percent Log Used'
ORDER BY instance_name;


GO
