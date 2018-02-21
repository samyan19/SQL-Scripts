/* minimum date in msdb */
select database_name
	,MIN(backup_start_date)
from msdb.dbo.backupset
where type='D'
group by database_name

/* number of days from today and minimum date */
select DATEDIFF(day,'2018-01-22 07:00:17.000',getdate())

/* backup growth including percentage */
select database_name
	,MIN(BackupSizeGB) as Min
	,MAX(BackupSizeGB) as Max
	,MAX(BackupSizeGB)-MIN(BackupSizeGB) as BckGrowthPastNDaysGB
	,CASE WHEN MIN(BackupSizeGB)<> 0
	 THEN (MAX(BackupSizeGB)-MIN(BackupSizeGB))*100/MIN(BackupSizeGB)
	 ELSE 0 END as '% Increase'
	,CASE WHEN MIN(BackupSizeGB)<> 0
	 THEN (1+((MAX(BackupSizeGB)-MIN(BackupSizeGB))/MIN(BackupSizeGB)))*MAX(BackupSizeGB)
	 ELSE 0 END as 'Projected backup size'
FROM 
(
select database_name
	,CAST(backup_size/1024/1024/1024 AS NUMERIC(17,2)) as BackupSizeGB
	,backup_start_date
from msdb.dbo.backupset
where type='D'
and backup_start_date>GETDATE()-30
) d
GROUP BY database_name
order by BckGrowthPastNDaysGB desc
