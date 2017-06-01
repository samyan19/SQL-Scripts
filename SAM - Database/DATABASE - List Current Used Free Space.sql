declare @sptable table ([Database Name] varchar(100),[File Name] varchar(100),[Physical Name] varchar(1000), [Current Size MB] int, [Used Space MB] int, [Free Space MB] float, Type int)

insert into @sptable
exec sp_MSforeachdb '
use [?];
SELECT db_name() as ''Database Name'', name AS ''File Name'' , physical_name AS ''Physical Name'', size/128 AS ''Total Size in MB'',
cast((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0) as int) AS UsedSpaceMB,
size/128.0 - cast((CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0) as int)  AS ''Available Space In MB'',type
FROM sys.database_files'



select * from @sptable
WHERE Type =0
and [Physical Name] LIKE 'F%'
ORDER BY [Free Space MB] DESC

