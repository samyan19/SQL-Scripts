
select database_name
	,MAX(BackupSizeGB)
	,MIN(BackupSizeGB)
	,MAX(BackupSizeGB)-MIN(BackupSizeGB) as BckGrowthPastNDaysGB	
FROM 
(
select database_name
	,CAST(backup_size/1024/1024/1024 AS NUMERIC(17,2)) as BackupSizeGB
	,backup_start_date
from msdb.dbo.backupset
where type='D'
and backup_start_date>GETDATE()-10
) d
GROUP BY database_name
order by BckGrowthPastNDaysGB desc