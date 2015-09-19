/*

Without using the vw in zzPerfMon

*/

USE zzPerfMon
GO
; WITH viewCPU AS 
(SELECT 
		 CounterDateTime,CounterValue,MachineName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Avg. Disk sec/Read')
        AND cdt.InstanceName <> 'C:'
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
SELECT DISTINCT machinename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName



