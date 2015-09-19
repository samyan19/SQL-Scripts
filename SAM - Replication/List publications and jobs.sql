select a.publication, b.name as CurrentJobName 
from distribution.dbo.MSdistribution_agents a
inner join msdb.dbo.sysjobs b
on a.job_id = b.job_id 
union
select a.publication, b.name as CurrentJobName  
from distribution.dbo.MSlogreader_agents a
inner join msdb.dbo.sysjobs b
on a.job_id = b.job_id 
union
select a.publication, b.name as CurrentJobName 
from distribution.dbo.MSsnapshot_agents a
inner join msdb.dbo.sysjobs b
on a.job_id = b.job_id 
