declare @schema nvarchar(100),
		@table nvarchar (100),
		@UpdateStatsQuery nvarchar (100),
		@fqn nvarchar (100)

DECLARE fragCursor cursor for

select table_schema, table_name
from INFORMATION_SCHEMA.TABLES
where TABLE_SCHEMA like '%dbo%'
and TABLE_NAME like 'S0142%'
or TABLE_NAME like 'D0276%'
or TABLE_NAME like 'D0242%'

open fragCursor

fetch next from fragCursor
into @schema, @table

while @@FETCH_STATUS=0
begin

set @fqn=@schema+'.'+@table
set @UpdateStatsQuery='update statistics ' + @fqn

print 'update stats query = '+@UpdateStatsQuery

--exec sp_executesql @UpdateStatsQuery

fetch next from fragCursor
into @schema, @table

end
close fragCursor
deallocate fragCursor