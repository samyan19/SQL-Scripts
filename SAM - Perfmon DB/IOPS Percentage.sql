USE zzPerfMon
GO
; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,SUM(CounterValue) AS 'countervalue',MachineName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Disk Reads/sec', 'Disk Writes/sec')
        AND cdt.InstanceName not IN ('C:','_Total')
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
SELECT DISTINCT machinename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName



/*
USE zzPerfMon
GO
; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,SUM(CounterValue) AS 'countervalue',MachineName,InstanceName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Disk Reads/sec', 'Disk Writes/sec')
        AND cdt.InstanceName <> 'C:'
GROUP BY CounterDateTime,MachineName,InstanceName
),
TestDetail AS
(
	SELECT Year,CounterValue, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile, machinename,instancename
	FROM (
		SELECT
		SUBSTRING(CounterDateTime,1,4) AS Year, 
		InstanceName,
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4),instancename)AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4),instancename ORDER BY CounterValue ASC) AS Position
		FROM viewCPU
		WHERE SUBSTRING(CounterDateTime,1,4)='2015'
	)  T
)
SELECT DISTINCT machinename,instancename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName,InstanceName
*/