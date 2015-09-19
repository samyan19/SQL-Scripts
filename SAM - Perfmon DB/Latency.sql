USE zzPerfMon
GO
; WITH CounterView AS 
(SELECT 
		 CounterDateTime,CounterValue,MachineName,InstanceName,counterName

FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Avg. Disk sec/Read','Avg. Disk sec/Write')
		and InstanceName <> '_Total'
),
CounterViewAgg AS
(
	SELECT Year,InstanceName, countername, CounterValue, ValueCount, (100.00/ValueCount)*Position AS Percentile, machinename
	FROM (
		SELECT
		SUBSTRING(CounterDateTime,1,4) AS Year, 
		InstanceName,
		countername,
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4),InstanceName,countername)AS ValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CounterDateTime,1,4),InstanceName,countername ORDER BY CounterValue ) AS Position
		FROM CounterView
		WHERE SUBSTRING(CounterDateTime,1,4)='2015'
	)  T
)
SELECT DISTINCT machinename,instanceName,countername,(MAX(CounterValue )*1000) as 'Latency ms'
FROM CounterViewAgg 
WHERE ceiling(Percentile)=95
GROUP BY MachineName,InstanceName,countername





