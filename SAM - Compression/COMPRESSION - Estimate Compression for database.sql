-- Determine the estimated impact of compression
-- NOTE: This script is only for SQL Server Enterprise and Developer edition.
set nocount on

-- We create a temp table for the result
if (object_id('tempdb..#comp', 'U') is not null)
  drop table #comp
go 
create table #comp
(
  object_name sysname
 ,schema_name sysname
 ,index_id int
 ,partition_number int
 ,[size_with_current_compression_setting (KB)] bigint
 ,[size_with_requested_compression_setting (KB)] bigint
 ,[sample_size_with_current_compression_setting (KB)] bigint
 ,[sample_size_with_requested_compression_setting (KB)] bigint
)
go

-- Calculate estimated impact of page level compression for all
-- user-tables and indexes in all schemas.
-- NOTE:
--  1) To get the estimated impact of row level compression change the last parameter
--     of sp_estimate_data_compression_savings to 'row' instead.
--  2) We don't care about partitioning here. If this is important for you,
--     you have to modify forth parameter of sp_estimate_data_compression_savings.
--     Please refer to BOL.
declare @cmd nvarchar(max)
set @cmd = ''
select @cmd = @cmd
    +';insert #comp exec sp_estimate_data_compression_savings '''
    + schema_name(schema_id)+''','''
    + name + ''',null, null, ''row'''
  from sys.tables
 where objectproperty(object_id, 'IsUserTable') = 1
exec (@cmd)

;
-- Do some further calculations for a more meaningful result
with compressionSavings as
(
  select quotename(schema_name) + '.' + quotename(object_name) as table_name
        ,index_id
        ,[size_with_current_compression_setting (KB)]
        ,[size_with_requested_compression_setting (KB)]
        ,cast(case
                when [size_with_current_compression_setting (KB)] = 0 then 0
                else 100.0*(1.0-1.0
                       *[size_with_requested_compression_setting (KB)]
                       /[size_with_current_compression_setting (KB)])
              end as decimal(6,2)) as [Estimated Savings (%)]
  from #comp
)
select cs.table_name
       ,isnull(i.name, i.type_desc) as index_name
       ,cs.[size_with_current_compression_setting (KB)]/1024 as [size_with_current_compression_setting (MB)]
       ,cs.[size_with_requested_compression_setting (KB)]/1024 as [size_with_requested_compression_setting (MB)]
       ,cs.[Estimated Savings (%)]
   from compressionSavings as cs
        left outer join sys.indexes as i
                     on i.index_id = cs.index_id
                    and i.object_id = object_id(cs.table_name, 'U')
  order by cs.[Estimated Savings (%)] desc

-- Get rid of the temp table
drop table #comp
go




