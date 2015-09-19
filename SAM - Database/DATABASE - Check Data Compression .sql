/****************************************************************************************
This script recommends data compression types based on Microsoft’s best practice
Author: 		Louis Li
Revision:		Jan 1st, 2014   

Louis.Li@sqlmaster.ca
****************************************************************************************/


--Collect all index stats
if object_id('index_estimates') is not null drop table index_estimates
go
create table index_estimates
(
	database_name sysname not null,
	[schema_name] sysname not null,
	table_name sysname not null,
	index_id int not null,
	update_pct decimal(5,2) not null,
	select_pct decimal(5,2) not null,
	constraint pk_index_estimates primary key (database_name,[schema_name],table_name,index_id)
)
;
go
insert into index_estimates
select
	db_name() as database_name,
	schema_name(t.schema_id) as [schema_name],
	t.name,
	i.index_id,
	i.leaf_update_count * 100.0 / (i.leaf_delete_count + i.leaf_insert_count + i.leaf_update_count + i.range_scan_count + i.singleton_lookup_count + i.leaf_page_merge_count) as UpdatePct,
	i.range_scan_count * 100.0 / (i.leaf_delete_count + i.leaf_insert_count + i.leaf_update_count + i.range_scan_count + i.singleton_lookup_count + i.leaf_page_merge_count) as SelectPct
from 
	sys.dm_db_index_operational_stats(db_id(),null,null,null) i
	inner join sys.tables t on i.object_id = t.object_id
	inner join sys.dm_db_partition_stats p on t.object_id = p.object_id
where
	i.leaf_delete_count + i.leaf_insert_count + i.leaf_update_count + i.range_scan_count + i.singleton_lookup_count + i.leaf_page_merge_count > 0
	and p.used_page_count >= 100  -- only consider tables contain more than 100 pages
	and p.index_id < 2
	and i.range_scan_count / (i.leaf_delete_count + i.leaf_insert_count + i.leaf_update_count + i.range_scan_count + i.singleton_lookup_count + i.leaf_page_merge_count) > .75 -- only consider tables with 75% or greater select percentage
order by
	t.name,
	i.index_id
go
--show data compression candidates
select * from index_estimates;

--Prepare 2 intermediate tables for row compression and page compression estimates
if OBJECT_ID('page_compression_estimates') is not null drop table page_compression_estimates;
go
create table page_compression_estimates
([object_name] sysname not null,
[schema_name] sysname not null,
index_id int not null,
partition_number int not null,
[size_with_current_compression_setting(KB)] bigint not null,
[size_with_requested_compression_setting(KB)] bigint not null,
[sample_size_with_current_compression_setting(KB)] bigint not null,
[sample_size_with_requested_compression_setting(KB)] bigint not null,
constraint pk_page_compression_estimates primary key ([object_name],[schema_name],index_id)
);
go
if OBJECT_ID('row_compression_estimates') is not null drop table row_compression_estimates;
go
create table row_compression_estimates
([object_name] sysname not null,
[schema_name] sysname not null,
index_id int not null,
partition_number int not null,
[size_with_current_compression_setting(KB)] bigint not null,
[size_with_requested_compression_setting(KB)] bigint not null,
[sample_size_with_current_compression_setting(KB)] bigint not null,
[sample_size_with_requested_compression_setting(KB)] bigint not null,
constraint pk_row_compression_estimates primary key ([object_name],[schema_name],index_id)
);
go


--Use cursor and dynamic sql to get estimates  9:18 on my laptop
declare @script_template nvarchar(max) = 'insert ##compression_mode##_compression_estimates exec sp_estimate_data_compression_savings ''##schema_name##'',''##table_name##'',NULL,NULL,''##compression_mode##''';
declare @executable_script nvarchar(max);
declare @schema sysname, @table sysname, @compression_mode nvarchar(20);
declare cur cursor fast_forward for 
select
	i.[schema_name],
	i.[table_name],
	em.estimate_mode
from
	index_estimates i cross join (values('row'),('page')) AS em(estimate_mode)
group by
	i.[schema_name],
	i.[table_name],
	em.estimate_mode;

open cur;
fetch next from cur into @schema, @table, @compression_mode;
while (@@FETCH_STATUS=0)
begin
	set @executable_script = REPLACE(REPLACE(REPLACE(@script_template,'##schema_name##',@schema),'##table_name##',@table),'##compression_mode##',@compression_mode);
	print @executable_script;
	exec(@executable_script);
	fetch next from cur into @schema,@table, @compression_mode;
	
end

close cur;
deallocate cur;

--Show estimates and proposed data compression 
with all_estimates as (
select
	'[' + i.schema_name + '].[' + i.table_name + ']' as table_name,
	case 
		when i.index_id > 0 then '[' + idx.name + ']'
		else null
	end as index_name,
	i.select_pct,
	i.update_pct,
	case 
		when r.[sample_size_with_current_compression_setting(KB)] > 0 then 
			100  - r.[sample_size_with_requested_compression_setting(KB)] * 100.0 / r.[sample_size_with_current_compression_setting(KB)] 
		else
			0.0
	end as row_compression_saving_pct,
	case 
		when p.[sample_size_with_current_compression_setting(KB)] > 0 then
			100  - p.[sample_size_with_requested_compression_setting(KB)] * 100.0 / p.[sample_size_with_current_compression_setting(KB)] 
		else	
			0.0
	end as page_compression_saving_pct
from
	index_estimates i
	inner join row_compression_estimates r on i.schema_name = r.schema_name and i.table_name = r.object_name and i.index_id = r.index_id
	inner join page_compression_estimates p on i.schema_name = p.schema_name and i.table_name = p.object_name and i.index_id = p.index_id
	inner join sys.indexes idx on i.index_id = idx.index_id and object_name(idx.object_id) = i.table_name
), recommend_compression as (
select
	table_name,
	index_name,
	select_pct,
	update_pct,
	row_compression_saving_pct,
	page_compression_saving_pct,
	case 
		when update_pct = 0 then 'Page'
		when update_pct >= 20 then 'Row'
		when update_pct > 0 and update_pct < 20 and page_compression_saving_pct - row_compression_saving_pct < 10 then 'Row'
		else 'Page'
	end as recommended_data_compression
from
	all_estimates
where
	row_compression_saving_pct > 0
	and page_compression_saving_pct > 0
)
select
	table_name,
	index_name,
	select_pct,
	update_pct,
	row_compression_saving_pct,
	page_compression_saving_pct,
	recommended_data_compression,
	case 
		when index_name is null then
			'alter table ' + table_name + ' rebuild with ( data_compression = ' + recommended_data_compression + ')' 
		else
			'alter index ' + index_name + ' on ' + table_name + ' rebuild with ( data_compression = ' + recommended_data_compression + ')' 
	end as [statement]
from
	recommend_compression
order by
	table_name
	
--Clean up
drop table index_estimates;