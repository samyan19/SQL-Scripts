declare @errors table (LogDate datetime, process nvarchar(100), text nvarchar(4000))

insert into @errors
exec  xp_readerrorlog

select * 
from  @errors
where text like 'Recovery is complete%'
