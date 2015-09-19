declare @sptable table ([Database Name] varchar(100),[File Name] varchar(100),[Physical Name] varchar(1000), [Total Size in MB] int, [Available Space In MB] float, Type int)

insert into @sptable
exec sp_msforeachdb '
use [?];
SELECT db_name() as ''Database Name'', name AS ''File Name'' , physical_name AS ''Physical Name'', size/128 AS ''Total Size in MB'',

size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128.0 AS ''Available Space In MB'',type

FROM sys.database_files'