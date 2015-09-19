USE zzPerfMon
GO
/*
REF:
http://blogs.msdn.com/b/mcsukbi/archive/2013/04/12/sql-server-page-life-expectancy.aspx

select distinct objectname,CounterName,InstanceName
from CounterDetails
*/

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
SELECT DISTINCT machinename,MAX(percentile )
FROM TestDetail 
--WHERE ceiling(Percentile)=100
WHERE CounterValue>@threshold
GROUP BY MachineName



