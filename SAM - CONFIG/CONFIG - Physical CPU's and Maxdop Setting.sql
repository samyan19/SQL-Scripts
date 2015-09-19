/*optimal maxdop*/

select case
         when cpu_count / hyperthread_ratio > 8 then 8
         else select cpu_count / hyperthread_ratio
       end as optimal_maxdop_setting
from sys.dm_os_sys_info;

-- Hardware Information for SQL Server 2005
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio
AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count],
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)]
FROM sys.dm_os_sys_info OPTION (RECOMPILE);

-- Hardware information from SQL Server 2008 and 2008 R2
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio
AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count],
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)],
sqlserver_start_time
FROM sys.dm_os_sys_info OPTION (RECOMPILE);

-- Hardware information from SQL Server Denali
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio
AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count],
physical_memory_kb/1024 AS [Physical Memory (MB)],
affinity_type_desc, virtual_machine_type_desc,
sqlserver_start_time
FROM sys.dm_os_sys_info OPTION (RECOMPILE);