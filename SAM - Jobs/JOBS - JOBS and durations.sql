select distinct j.name,j.enabled,jh.run_status,jh.run_date,jh.run_time,convert(varchar(100),run_duration/10000) +'h '+convert(varchar(100),run_duration/100%100)+'m '+convert(varchar(100),run_duration%100) +'s' as duration
from sysjobs j
inner join sysjobhistory jh on j.job_id=jh.job_id
where j.name='DBA Daily Backup - raCentrica'
order by jh.run_date desc