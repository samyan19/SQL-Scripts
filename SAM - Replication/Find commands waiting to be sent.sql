--Commands waiting to be downloaded


declare @xact_seqno varbinary(16)
select @xact_seqno = max(xact_seqno)
from MSsubscriptions
inner join MSpublications
on MSpublications.publication_id = MSsubscriptions.publication_id
inner join MSdistribution_history
on MSdistribution_history.agent_id = MSsubscriptions.agent_id
Where subscriber_db = 'Accnts_Live'
AND Publication = 'Accnts_Live_Oas_Dochead'

declare @str varchar(255)
set @str = master.dbo.fn_varbintohexstr (@xact_seqno)
set @str = left(@str, len(@str) - 8)

if exists(select object_id('tempdb..#trancommands')) drop table #trancommands

create table #trancommands
(xact_seqno varbinary(16) null,
originator_srvname sysname null,
originator_db sysname null,
article_id int null,
type int null,
partial_command bit null,
hashkey int null,
originator_publication_id int null,
originator_db_version int null,
originator_lsn varbinary(16) null,
command nvarchar(1024) null,
command_id int)

insert into #trancommands
exec sp_browsereplcmds @xact_seqno_start = @str
select * from #trancommands where xact_seqno > @xact_seqno


--DROP table #trancommands