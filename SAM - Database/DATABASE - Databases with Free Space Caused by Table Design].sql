



SELECT
   DB_NAME(database_id), 
   SUM(free_space_in_bytes) / 1024 AS 'Free_KB'
FROM sys.dm_os_buffer_descriptors
WHERE database_id <> 32767
GROUP BY database_id
ORDER BY SUM(free_space_in_bytes) DESC
GO



