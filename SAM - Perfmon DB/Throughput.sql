USE zzPerfMon
GO
; WITH viewCPU AS 
(SELECT 
		 MachineName, 
		 SUBSTRING(CounterDateTime,1,4) AS CounterYear,
		 CounterDateTime,
		 instancename,
		 SUM(CounterValue) AS 'countervalue'

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Disk Read Bytes/sec', 'Disk Write Bytes/sec')
        AND cdt.InstanceName not IN ('C:','_Total')
		AND SUBSTRING(CounterDateTime,1,4)='2015'
GROUP BY CounterDateTime,MachineName,instancename
),
TestDetail AS
(
	SELECT CounterYear,CounterValue, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile, machinename,instancename
	FROM (
		SELECT
		CounterYear, 
		CounterValue,
		machinename,
		instancename,
		COUNT(*) OVER (PARTITION BY CounterYear,instancename)AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY CounterYear,instancename ORDER BY CounterValue ASC) AS Position
		FROM viewCPU
	)  T
)
SELECT DISTINCT machinename,instancename,MAX(CounterValue)/1024 AS 'KB/sec'
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName,instancename


/*
--USE zzPerfMon
--GO
--select distinct objectname,CounterName,InstanceName
--from CounterDetails


136591756.776113
135985237.879924
*/