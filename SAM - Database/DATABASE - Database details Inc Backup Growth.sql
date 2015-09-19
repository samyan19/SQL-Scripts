;WITH a AS (
SELECT instance_name AS DatabaseName,
       [Data File(s) Size (KB)]/1024 as [Data File(s) Size (MB)],
       [LOG File(s) Size (KB)]/1024 as [LOG File(s) Size (MB)],
       [Log File(s) Used Size (KB)]/1024 as [Log File(s) Used Size (MB)],
       [Percent Log Used]
FROM
(
   SELECT *
   FROM sys.dm_os_performance_counters
   WHERE counter_name IN
   (
       'Data File(s) Size (KB)',
       'Log File(s) Size (KB)',
       'Log File(s) Used Size (KB)',
       'Percent Log Used'
   )
     AND instance_name != '_Total'
) AS Src
PIVOT
(
   MAX(cntr_value)
   FOR counter_name IN
   (
       [Data File(s) Size (KB)],
       [LOG File(s) Size (KB)],
       [Log File(s) Used Size (KB)],
       [Percent Log Used]
   )
) AS pvt )
,b AS 
(
SELECT database_name
	,CASE WHEN DATEDIFF(DAY,MIN(backup_start_date),MAX(backup_start_date))=0 THEN 0
	else
	CAST(((MAX(BackupSizeGB)-MIN(BackupSizeGB))/DATEDIFF(DAY,MIN(backup_start_date),MAX(backup_start_date))) AS NUMERIC(17,1)) end AS AvgBackupSizeGrowthPerDayMB
FROM 
(
select database_name
	,CAST(backup_size/1024/1024/1024 AS NUMERIC(17,2)) as BackupSizeGB
	,backup_start_date
from msdb.dbo.backupset
where type='D'
) d
GROUP BY database_name
)
SELECT * 
FROM a
JOIN b ON a.DatabaseName=b.Database_Name
ORDER BY 2 desc
