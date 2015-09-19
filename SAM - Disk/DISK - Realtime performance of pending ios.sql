/*
realtime performance of pending ios/msec
*/

SELECT db_name(database_id) as 'Database',
file_name(file_id) as 'File',
io_stall,
io_pending_ms_ticks 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) iovfs,
 sys.dm_io_pending_io_requests as iopior
WHERE iovfs.file_handle = iopior.io_handle


/*

You should run this query when you suspect your current performance problem is related to an I/O bottleneck. You can verify this by running this query a few times to see whether this is a temporary overload or a continuous problem. After you confirm that you have an I/O issue, this query helps you locate the database files that are causing the issue. Keep in mind that this maybe an I/O issue, but you should also check to make sure excessive table scans or poor indexing is not the problem.

You can also capture Perfmon logs for further analysis using these counters:

SQL Server:Databases object:
------------------------------
Log Bytes Flushed/sec
Log Flushes/sec
Log Flush Wait Time

Logical Disk or Physical Disk object:
------------------------------------------
Current Disk Queue Length
Avg. Disk/sec Read, Avg. Disk/Write
Avg. Disk Bytes/Read, Avg. Disk Bytes/Write
Disk Reads/sec, Disk Writes/sec
Disk Read Bytes/sec, Disk Write Bytes/sec 

*/