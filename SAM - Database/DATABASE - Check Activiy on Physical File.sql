SELECT DB_NAME(mf.database_id) AS databaseName
,mf.physical_name
,num_of_reads
,num_of_bytes_read
,num_of_writes
,num_of_bytes_written
,size_on_disk_bytes
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs
JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id
AND mf.file_id = divfs.file_id
--WHERE DB_NAME(mf.database_id) = 'tempdb'
ORDER BY 1, 3 DESC