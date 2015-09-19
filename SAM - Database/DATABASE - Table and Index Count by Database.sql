declare @dbstats table ([DatabaseName] varchar(100),[TableCount] int,[IndexCount] int)

insert into @dbstats
exec sp_msforeachdb '
use [?];
select 
db_name() as DBName,
count(o.name) as TableCount,
Sum(
	case 
		when (i.type=2) then 1 else 0 end) as IndexCount
FROM sys.indexes i
INNER JOIN sys.objects o ON i.[object_id] = o.[object_id]
INNER JOIN sys.schemas s ON o.[schema_id] = s.[schema_id]
where o.type=''U''
and o.name not in (''master'',''tempdb'',''model'',''msdb'')
'

select * from @dbstats