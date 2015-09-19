/* Total physical memory */ 

SELECT total_physical_memory_kb / ( 1024.0 * 1024 )     total_physical_memory_gb,
       available_physical_memory_kb / ( 1024.0 * 1024 ) available_physical_memory_gb,
       total_page_file_kb / ( 1024.0 * 1024 )           total_page_file_gb,
       available_page_file_kb / ( 1024.0 * 1024 )       available_page_file_gb,
       system_high_memory_signal_state,
       system_low_memory_signal_state,
       system_memory_state_desc
FROM   sys.dm_os_sys_memory

/* max buffer pool memory assigned */

select name,
description,
value_in_use from sys.configurations
where name ='max server memory (MB)'

/* Total SQL memory allocated */

SELECT  
'Total Memory allocated to SQL',
SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks


/* Total allocated to buffer pool */

SELECT  
'Total allocated to buffer pool',
SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks
where type = 'MEMORYCLERK_SQLBUFFERPOOL'
ORDER BY SUM(pages_kb) DESC;


/* memory not allocated to buffer pool */

SELECT  
'Total not allocated to buffer pool',
SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks
where type <> 'MEMORYCLERK_SQLBUFFERPOOL'
ORDER BY SUM(pages_kb) DESC;

/* Full Breadown*/

SELECT  [type] as [Memory Clerk Name], SUM(pages_kb) AS [SPA Memory (KB)],
SUM(pages_kb)/1024 AS [SPA Memory (MB)]
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY SUM(pages_kb) DESC;