/*
https://support.microsoft.com/en-us/kb/3066750

Take transaction sequence number and commandid in error message (replication monitor) and check existence in MSrepl_errors
*/
select *
from MSrepl_errors
order by time desc

/*
plug ids into sp_browsereplcmds to find the command with the issues
*/
use distribution
GO
exec sp_browsereplcmds '0x000073920006ADB8000300000000','0x000073920006ADB8000300000000'

/*
Plug article id into sys.articles in the publisher to find out the article with the issue
*/
use UAT
GO
select * from sysarticles where artid=48
GO


