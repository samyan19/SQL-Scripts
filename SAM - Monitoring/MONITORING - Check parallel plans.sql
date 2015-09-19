SELECT r.session_id,
r.request_id,
MAX(ISNULL(exec_context_id, 0)) as nbr_of_workers,
r.sql_handle,
r.statement_start_offset,
r.statement_end_offset,
r.plan_handle
FROM sys.dm_exec_requests r
JOIN sys.dm_os_tasks t ON r.session_id = t.session_id
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
WHERE s.is_user_process = 0x1
GROUP BY r.session_id, r.request_id, r.sql_handle, r.plan_handle,
r.statement_start_offset, r.statement_end_offset
HAVING MAX(ISNULL(exec_context_id, 0)) > 0

/*
SELECT max_workers_count from sys.dm_os_sys_info
SELECT * FROM sys.dm_os_schedulers

select * FROM sys.dm_os_tasks
order BY session_id


SELECT * from sys.dm_os_waiting_tasks
*/