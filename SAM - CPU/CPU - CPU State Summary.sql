
SELECT 
  parent_node_id, 
  COUNT(*) As [# Schedulers],
  AVG(current_tasks_count) AS avg_tasks_count, 
  AVG(runnable_tasks_count) AS avg_tasks_count, 
  AVG(active_workers_count) AS avg_workers_count, 
  AVG(load_factor) AS avg_load_factor
FROM sys.dm_os_schedulers
WHERE [status] = N'VISIBLE ONLINE'
GROUP BY parent_node_id;



/* PEr scheduler */
SELECT current_tasks_count,runnable_tasks_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
AND [status] = 'VISIBLE ONLINE';
