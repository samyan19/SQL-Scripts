/* minimum date in msdb */
declare @mindate datetime, @numberOfDays int;

select @mindate= 
--database_name,
	MIN(backup_start_date)
from msdb.dbo.backupset
where type='D'
--group by database_name

select @mindate;

/* number of days from today and minimum date */
select @numberOfDays=DATEDIFF(day,@mindate,getdate());

select @numberOfDays;

/* backup growth including percentage */
;with cte as(
select database_name
	,MIN(BackupSizeGB) as Min
	,MAX(BackupSizeGB) as Max
	,MAX(BackupSizeGB)-MIN(BackupSizeGB) as BckGrowthPastNDaysGB
	,CASE WHEN MIN(BackupSizeGB)<> 0
	 THEN (MAX(BackupSizeGB)-MIN(BackupSizeGB))*100/MIN(BackupSizeGB)
	 ELSE 0 END as 'percent_increase'
	--,CASE WHEN MIN(BackupSizeGB)<> 0
	-- THEN (1+((MAX(BackupSizeGB)-MIN(BackupSizeGB))/MIN(BackupSizeGB)))*MAX(BackupSizeGB)
	-- ELSE 0 END as 'Projected backup size next 30 days'
	 , mf.size/128 as 'current_size'
	 --,CASE WHEN MIN(BackupSizeGB)<> 0
	 -- THEN (1+((MAX(BackupSizeGB)-MIN(BackupSizeGB))/MIN(BackupSizeGB)))*(mf.size/128)
	 --ELSE 0 END as 'Projected size in N days'
FROM 
(
select database_name
	,CAST(backup_size/1024/1024/1024 AS NUMERIC(17,2)) as BackupSizeGB
	,backup_start_date
from msdb.dbo.backupset
where type='D'
and backup_start_date>GETDATE()-30
) d
join sys.master_files mf on d.database_name=db_name(mf.database_id)
where mf.type=0 and mf.name not in ('master','DBA_Admin','model','msdb')
GROUP BY database_name,mf.size
)
select *,current_size-((percent_increase/100)*current_size) as min_size, (current_size-(current_size-((percent_increase/100)*current_size)))/@numberOfDays as growth_per_day_mb
from cte
order by current_size desc
--order by BckGrowthPastNDaysGB desc





--select 661713.704013607-497025


--select 1438.002438571*30
--select 43140.073157130 + 497025
--select * from msdb.dbo.backupset
