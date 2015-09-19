SELECT DB_NAME(m.database_id) AS DatabaseName
, ds.name AS FileGroupName
, m.Name AS FileName
, m.type_desc AS 'FileType'
, CEILING(num_of_bytes_read*1.0 / (num_of_bytes_read*1.0 + num_of_bytes_written*1.0) * 100) AS 'Read %'
, CAST((v.size_on_disk_bytes / 1024.0 / 1024 / 1024) AS MONEY) AS 'FileSizeGB'
, CAST((v.num_of_bytes_read / 1024.0 / 1024 / 1024) AS MONEY) AS 'ReadGB'
, CAST((v.num_of_bytes_written / 1024.0 / 1024 / 1024) AS MONEY) AS 'WrittenGB'
, m.physical_name
FROM sys.dm_io_virtual_file_stats(NULL, NULL) v
INNER JOIN sys.master_files m on m.database_id = v.database_id AND v.file_id = m.file_id
INNER JOIN sys.data_spaces ds ON m.data_space_id = ds.data_space_id
ORDER BY [Read %] desc,FileSizeGB DESC,ReadGB desc