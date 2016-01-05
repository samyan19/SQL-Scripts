/*
Occur when there aren't any threashs available to service incoming connections

http://www.sqlpassion.at/archive/2011/10/25/troubleshooting-threadpool-waits/
*/
SELECT * FROM sys.dm_os_waiting_tasks
WHERE wait_type = ‘THREADPOOL’
GO
