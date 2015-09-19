declare @sptable table ([Database Name] varchar(100),[File Name] varchar(100),[Physical Name] varchar(1000), [Total Size in MB] int, [Available Space In MB] float, Type int)

insert into @sptable
exec sp_msforeachdb '
use [?];
SELECT db_name() as ''Database Name'', name AS ''File Name'' , physical_name AS ''Physical Name'', size/128 AS ''Total Size in MB'',

size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS ''Available Space In MB'',type

FROM sys.database_files'



select * from @sptable
WHERE type =0
and [Physical Name] LIKE 'L%'
ORDER BY [Available Space In MB] DESC



/*============================================

List including when database was last accessed

==============================================*/

declare @sptable table ([Database Name] varchar(100),[File Name] varchar(100),[Physical Name] varchar(1000), [Total Size in MB] int, [Available Space In MB] float, Type int)

insert into @sptable
exec sp_msforeachdb '
use [?];
SELECT db_name() as ''Database Name'', name AS ''File Name'' , physical_name AS ''Physical Name'', size/128 AS ''Total Size in MB'',

size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS ''Available Space In MB'',type

FROM sys.database_files'


;with CTE as(
SELECT name, last_access =(select X1= max(LA.xx)
from ( select xx =
max(last_user_seek)
where max(last_user_seek)is not null
union all
select xx = max(last_user_scan)
where max(last_user_scan)is not null
union all
select xx = max(last_user_lookup)
where max(last_user_lookup) is not null
union all
select xx =max(last_user_update)
where max(last_user_update) is not null) LA)
FROM master.dbo.sysdatabases sd 
left outer join sys.dm_db_index_usage_stats s 
on sd.dbid= s.database_id 
group by sd.name
)
select s.*,cte.last_access 
from @sptable s
join CTE on s.[Database Name]=cte.name
WHERE type =0
and [Physical Name] LIKE 'L%'
ORDER BY [Available Space In MB] DESC
