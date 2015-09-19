/*
High current tasks indicate blocking
High runnable tasks = CPU pressure
High > 20
Medium >10
Low <9
*/


-- Get Avg task count and Avg runnable task count
SELECT AVG(current_tasks_count) AS [Avg Task Count], 
AVG(runnable_tasks_count) AS [Avg Runnable Task Count]
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
AND [status] = 'VISIBLE ONLINE';



-- Get count per core
SELECT current_tasks_count,runnable_tasks_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
AND [status] = 'VISIBLE ONLINE';