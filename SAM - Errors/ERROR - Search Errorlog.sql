Create table #errors (LogDate datetime, process nvarchar(100), text nvarchar(4000))

insert into #errors
exec  xp_readerrorlog

select * 
from  #errors
where text != 'Login failed for user ''BESTLIVE\svc_scom''. Reason: Failed to open the explicitly specified database. [CLIENT: <local machine>]'
and LogDate > GETDATE()-1
order by LogDate desc

drop  table #errors




--exec xp_readerrorlog 1,1,'Deadlock encountered'