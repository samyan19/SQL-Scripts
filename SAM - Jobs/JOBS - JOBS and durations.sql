select distinct j.name,j.enabled,jh.run_status,dbo.agent_datetime(jh.run_date,jh.run_time)as run_datetime,convert(varchar(100),run_duration/10000) +'h '+convert(varchar(100),run_duration/100%100)+'m '+convert(varchar(100),run_duration%100) +'s' as duration 
from sysjobs j 
inner join sysjobhistory jh on j.job_id=jh.job_id 
--inner join sysjobactivity ja on jh.instance_id=ja.job_history_id
where j.name='HDSUpdateStatistics' and jh.step_id=0
--group by j.job_id,j.name,j.enabled,jh.run_status,run_date,run_time,run_duration
order by run_datetime desc 
