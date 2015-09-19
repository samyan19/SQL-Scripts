select
   objtype,
   count(*)as number_of_plans,
   sum(cast(size_in_bytes as bigint))/1024/1024 as size_in_MBs,
   avg(usecounts)as avg_use_count
from sys.dm_exec_cached_plans
group by objtype