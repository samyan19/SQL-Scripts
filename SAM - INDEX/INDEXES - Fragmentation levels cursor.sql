declare @schema nvarchar(100),
		@table nvarchar (100),
		@fqn nvarchar (100)

DECLARE fragCursor cursor for

select table_schema, table_name
from INFORMATION_SCHEMA.TABLES
where TABLE_SCHEMA like '%dbo%'
and TABLE_NAME like 'Mart_Fact_Consumption%'

open fragCursor

fetch next from fragCursor
into @schema, @table

while @@FETCH_STATUS=0
begin

set @fqn=@schema+'.'+@table
print 'fqn = '+@fqn

SELECT DISTINCT
    object_name(ips.object_id) AS objectname,
    ips.index_id AS indexid,
    i.name,
    i.type_desc,
    ips.partition_number AS partitionnum,
    ips.alloc_unit_type_desc,
    ips.record_count,
    avg_fragmentation_in_percent AS frag
FROM sys.dm_db_index_physical_stats (DB_ID(), object_id(@fqn), NULL , NULL, 'DETAILED') ips
inner JOIN sys.indexes i ON ips.index_id=i.index_id
WHERE i.object_id=ips.object_id

fetch next from fragCursor
into @schema, @table

end
close fragCursor
deallocate fragCursor