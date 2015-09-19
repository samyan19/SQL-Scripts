select
schemas.name as table_schema,
tbls.name as table_name,
i.name as index_name,
i.id as table_id,
i.indid as index_id,
i.groupid,
i.rowmodctr as modifiedRows,
(select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2) as rowcnt,
convert(DECIMAL(18,8), convert(DECIMAL(18,8),i.rowmodctr) / convert(DECIMAL(18,8),(select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2))) as ModifiedPct,
stats_date( i.id, i.indid ) as lastStatsUpdate,
'False' as Processed
into ##updateStatsQueue
from sysindexes i
inner join sysobjects tbls on i.id = tbls.id
inner join sysusers schemas on tbls.uid = schemas.uid
inner join information_schema.tables tl
on tbls.name = tl.table_name
and schemas.name = tl.table_schema
and tl.table_type='BASE TABLE'
where 0 < i.indid and i.indid < 255
and table_schema <> 'sys'
and i.rowmodctr <> 0
and (select max(rowcnt) from sysindexes i2 where i.id = i2.id and i2.indid < 2) > 0

select * from ##updateStatsQueue

drop table ##updateStatsQueue