USE zzPerfMon
GO
declare @Results table(machinename varchar(1024),instancename varchar(1024),countername varchar(1024), value float)


if OBJECT_ID('tempdb..#temp') is not null
	drop table #temp;


SELECT 
		 SUBSTRING(CounterDateTime,1,4) as CounterYear,CounterValue,MachineName,InstanceName,counterName,cdt.CounterID
INTO #TEMP
FROM    dbo.CounterDetails cdt
        INNER JOIN dbo.CounterData cd ON cdt.CounterID = cd.CounterID
        INNER JOIN dbo.DisplayToID d ON d.GUID = cd.GUID
WHERE  
        ObjectName in ('LogicalDisk')
        AND cdt.CounterName IN( 'Avg. Disk sec/Read','Avg. Disk sec/Write','Disk Read Bytes/sec', 'Disk Write Bytes/sec','Disk Reads/sec', 'Disk Writes/sec')
		and InstanceName <> '_Total' --and instancename not like 'Harddisk%'
		and CounterDateTime>='2015-06-17'


create clustered index idx_temp on #TEMP (counteryear asc,counterid asc, countervalue asc)

;WITH CounterViewAgg AS
(
	SELECT CounterYear,InstanceName, countername, CounterValue, ValueCount, (100.00/ValueCount)*Position AS Percentile, machinename
	FROM (
		SELECT
		CounterYear, 
		InstanceName,
		countername,
		CounterValue,
		machinename,
		COUNT(*) OVER (PARTITION BY CounterYear,counterid)AS ValueCount,
		ROW_NUMBER() OVER (PARTITION BY CounterYear,counterid ORDER BY CounterValue ) AS Position
		FROM #TEMP
	)  T
)
insert into @Results
SELECT DISTINCT machinename,instanceName,countername,(MAX(CounterValue )) as value
FROM CounterViewAgg 
WHERE ceiling(Percentile)=95
GROUP BY MachineName,InstanceName,countername


--select * from @Results

select machinename, instancename, [Avg. Disk sec/Read],[Avg. Disk sec/Write],([Disk Read Bytes/sec]+[Disk Write Bytes/sec])/1024/1024 as 'MB/sec', [Disk Reads/sec]+[Disk Writes/sec] as IOPS
from 
(
	select machinename,instancename,countername,value
	from @Results
)up pivot (sum(value) for countername in ([Avg. Disk sec/Read],[Avg. Disk sec/Write],[Disk Read Bytes/sec], [Disk Write Bytes/sec],[Disk Reads/sec],[Disk Writes/sec])) as pvt



if OBJECT_ID('tempdb..#temp') is not null
	drop table #temp;


