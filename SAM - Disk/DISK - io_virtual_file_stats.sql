/*
<10ms good
10-15ms ok
>15ms bad
*/



SELECT a.io_stall, a.io_stall_read_ms, a.io_stall_write_ms, a.num_of_reads, 
a.num_of_writes, a.io_stall_read_ms/a.num_of_reads AS msperread,a.io_stall_write_ms/a.num_of_writes AS msperwrite,
--a.sample_ms, 
a.num_of_bytes_read/a.num_of_reads as bpr, a.num_of_bytes_written/a.num_of_writes as bpw, a.io_stall_write_ms, 
( ( a.size_on_disk_bytes / 1024 ) / 1024.0 ) AS size_on_disk_mb, 
db_name(a.database_id) AS dbname, 
b.name, a.file_id, 
db_file_type = CASE 
                   WHEN a.file_id = 2 THEN 'Log' 
                   ELSE 'Data' 
                   END, 
UPPER(SUBSTRING(b.physical_name, 1, 2)) AS disk_location 
FROM sys.dm_io_virtual_file_stats (NULL, NULL) a 
JOIN sys.master_files b ON a.file_id = b.file_id 
AND a.database_id = b.database_id 
where a.num_of_reads>0 and a.num_of_writes>0
ORDER BY msperread DESC 