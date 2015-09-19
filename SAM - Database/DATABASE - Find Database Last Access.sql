SELECT name, last_access =(select X1= max(LA.xx)
from ( select xx =
max(last_user_seek)
where max(last_user_seek)is not null
union all
select xx = max(last_user_scan)
where max(last_user_scan)is not null
union all
select xx = max(last_user_lookup)
where max(last_user_lookup) is not null
union all
select xx =max(last_user_update)
where max(last_user_update) is not null) LA)
FROM master.dbo.sysdatabases sd 
left outer join sys.dm_db_index_usage_stats s 
on sd.dbid= s.database_id 
group by sd.name
