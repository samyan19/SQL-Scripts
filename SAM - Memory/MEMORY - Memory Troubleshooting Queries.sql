
--Overall
SELECT * FROM SYS.DM_OS_SYS_INFO 



select * FROM sys.dm_os_memory_nodes

select * from sys.dm_os_memory_clerks
order by virtual_memory_reserved_kb DESC


--Data Cache
--pages in cache
SELECT * FROM sys.dm_os_buffer_descriptors

--Database in cache
select count(*)*8/1024 as 'cached size (mb)'
,case database_id
when 32767 then 'ResourceDB'
else db_name(database_id)
end as 'Database'
from sys.dm_os_buffer_descriptors
group by db_name(database_id), database_id
order by 'Cached Size (MB)' desc



select * from sys.dm_os_memory_cache_counters


--plan cache

select * FROM sys.dm_exec_cached_plans
go
SELECT count(*) as 'number of plans',
sum(cast(size_in_bytes as bigint))/1024/1024 as 'Plan Cache Size (MB)'
from sys.dm_exec_cached_plans

select * from sys.dm_exec_query_plan(0x05000400A5436923B800D610000000000000000000000000)


select * from sys.dm_os_buffer_descriptors






-- size by os clerk
select 
	type,
	sum(virtual_memory_reserved_kb) as [VM Reserved],
	sum(virtual_memory_committed_kb) as [VM Committed],
	sum(awe_allocated_kb) as [AWE Allocated],
	sum(shared_memory_reserved_kb) as [SM Reserved], 
	sum(shared_memory_committed_kb) as [SM Committed],
	sum(multi_pages_kb) as [MultiPage Allocator],
	sum(single_pages_kb) as [SinlgePage Allocator]
from 
	sys.dm_os_memory_clerks 
group by type
order by type
--Buffer Pool (Single Page):sum(virtual_memory_committed_kb) + sum(single_pages_kb) as [SinlgePage Allocator]