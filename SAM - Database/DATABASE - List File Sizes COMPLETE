declare @sptable table ([Database Name] varchar(100),[File Name] varchar(100),[Physical Name] varchar(1000), [Current Size MB] int, [Used Space MB] int, [Free Space MB] float, Type int)

insert into @sptable
exec sp_MSforeachdb '
use [?];
SELECT db_name() as ''Database Name'', name AS ''File Name'' , physical_name AS ''Physical Name'', size/128 AS ''Total Size in MB'',
cast((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0) as int) AS UsedSpaceMB,
size/128.0 - cast((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0) as int)  AS ''Available Space In MB'',type
FROM sys.database_files'



select 
[Database Name],
case 
	when type=0 then 'ROWS'
	when type=1 then 'LOG'
	when type=2 then 'FILESTREAM'
	when type=3 then 'Not supported'
	when type=4 then 'FULL-TEXT'
end as 'Type',
[File Name],[Physical Name],[Current Size MB],[Used Space MB],[Free Space MB]
from @sptable
--WHERE Type =0
--and [Physical Name] LIKE 'F%'
ORDER BY [Database Name] asc,Type desc,[Free Space MB] desc
