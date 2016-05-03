/* 
http://dba.stackexchange.com/questions/89834/sql-server-2012-memory-consumption-outside-the-buffer-pool

Check if below matches max mem setting 
*/

SELECT (physical_memory_in_use_kb/1024)/1024 AS [PhysicalMemInUseGB]
FROM sys.dm_os_process_memory;
GO

/*If not follow the below */

--performance counters

--See if anything jumps out here as excessively large:
SELECT counter_name, instance_name, mb = cntr_value/1024.0
  FROM sys.dm_os_performance_counters 
  WHERE (counter_name = N'Cursor memory usage' and instance_name <> N'_Total')
  OR (instance_name = N'' AND counter_name IN 
       (N'Connection Memory (KB)', N'Granted Workspace Memory (KB)', 
        N'Lock Memory (KB)', N'Optimizer Memory (KB)', N'Stolen Server Memory (KB)', 
        N'Log Pool Memory (KB)', N'Free Memory (KB)')
  ) ORDER BY mb DESC;

--top 20 clerks

--You've already done this, but for completeness:
SELECT TOP (21) [type] = COALESCE([type],'Total'), 
  mb = SUM(pages_kb/1024.0)
FROM sys.dm_os_memory_clerks
GROUP BY GROUPING SETS((type),())
ORDER BY mb DESC;

--thread stack size

--First, make sure this is zero, and not some custom number (if it is not 0, find out why, and fix it):

SELECT value_in_use
  FROM sys.configurations 
  WHERE name = N'max worker threads';
But you can also see how much memory is being taken up by thread stacks using:
SELECT stack_size_in_bytes/1024.0/1024 
  FROM sys.dm_os_sys_info;
3rd party modules loaded
SELECT base_address, description, name
  FROM sys.dm_os_loaded_modules 
  WHERE company NOT LIKE N'Microsoft%';

-- you can probably trace down memory usage using the base_address
--memory-related DMVs

--You may also be able to spot something out of the ordinary looking at these DMVs:
SELECT * FROM sys.dm_os_sys_memory;
SELECT * FROM sys.dm_os_memory_nodes WHERE memory_node_id <> 64;


