/*
Thank this post

http://blogs.adatis.co.uk/blogs/david/archive/2011/06/24/calculating-percentile-brackets-using-sql-server-2008.aspx

*/


;WITH TestDetail AS
(
	SELECT Year,AvgCPU, CPUValueCount, (100.00/CPUValueCount)*Position AS Percentile
	FROM (
		SELECT
		SUBSTRING(date,1,4) AS Year, 
		AvgCPU,
		COUNT(*) OVER (PARTITION BY SUBSTRING(date,1,4))AS CPUValueCount,
		ROW_NUMBER() OVER (PARTITION BY SUBSTRING(date,1,4) ORDER BY AvgCPU ) AS Position
		FROM [zzPerfMon].[dbo].[vwCPU]
		WHERE SUBSTRING(date,1,4)='2015'
	)  T
)
SELECT DISTINCT MAX(avgCPU )
FROM TestDetail 
WHERE ceiling(Percentile)=95




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
SELECT DISTINCT machinename,MAX(CounterValue )
FROM TestDetail 
WHERE ceiling(Percentile)=95
GROUP BY MachineName




SELECT * 
FROM sys.dm_db_persisted_sku_features 
GO 