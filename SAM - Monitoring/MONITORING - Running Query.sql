DECLARE @OpenQueries TABLE (cpu_time INT , logical_reads bigint , session_id smallint)
INSERT INTO @OpenQueries(cpu_time , logical_reads, session_id)
select r. cpu_time ,r .logical_reads, r.session_id
from sys .dm_exec_sessions as s inner join sys.dm_exec_requests as r
on s. session_id =r .session_id and s.last_request_start_time =r. start_time
where is_user_process in (1 ,0)
and s. session_id <> @@SPID

waitfor delay '00:00:01'

select DISTINCT
   [Head Blocker]  =
        CASE
            -- session has an active request, is blocked, but is blocking others or session is idle but has an open tran and is blocking others
            WHEN r. session_id IS NOT NULL AND (r. blocking_session_id = 0 OR r. session_id IS NULL) THEN '1'
            -- session is either not blocking someone, or is blocking someone but is blocked by another party
            ELSE ''
        END,
r.session_id
,r. request_id
,r. status
--,h.[text]
,substring( h.text , ( r.statement_start_offset /2)+ 1 , ((case r.statement_end_offset when -1 then datalength (h. text)  else r.statement_end_offset end - r .statement_start_offset)/ 2) + 1) as text
, r. blocking_session_id
, s. [host_name]
, s. login_name
, r. wait_type
,wt. wait_type as [task-level wait type]
, wt. waiting_task_address
,wt. wait_duration_ms as [task-level wait duration]
,wt. resource_description
,(tsu. user_objects_alloc_page_count+tsu .internal_objects_alloc_page_count)* 8/1024 as [tempdbUsage mb]
,mg. dop
,r. total_elapsed_time/60000 as [ElapseTime mins]
, r. cpu_time-t .cpu_time as CPUDiff
, r. logical_reads-t .logical_reads as ReadDiff
, r. wait_time/6000 as [wait_time(sec)]
, r. last_wait_type
, r. wait_resource
, r. command
, db_name (r. database_id) as DatabaseName
--,ot.scheduler_id
--, r.granted_query_memory
,mg. requested_memory_kb
,mg. granted_memory_kb
,mg. used_memory_kb
,mg. max_used_memory_kb
,mg. is_next_candidate --Is this process the next candidate for a memory grant
, r. reads
, r. writes, r .row_count
, s. program_name, r .plan_handle
--, qp.query_plan

from sys .dm_exec_sessions as s inner join sys.dm_exec_requests as r with (NOLOCK)  
on s. session_id =r .session_id and s.last_request_start_time =r. start_time
left join @OpenQueries as t on t. session_id=s .session_id
left JOIN sys. dm_exec_query_memory_grants mg with (NOLOCK) ON s.session_id= mg.session_id
left JOIN sys. dm_db_task_space_usage tsu with (NOLOCK) ON s.session_id= tsu.session_id
LEFT JOIN sys. dm_os_waiting_tasks wt WITH (NOLOCK) on s.session_id= wt.session_id
LEFT JOIN sys. dm_os_tasks ot WITH (NOLOCK) ON s .session_id= ot.session_id
CROSS APPLY sys. dm_exec_sql_text(r .sql_handle) h
--CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) qp
where is_user_process in (1 ,0)
and s. session_id <> @@SPID
order by 3 desc
option (maxdop 1)



--select * from sys.dm_exec_sessions where session_id=118
--SELECT * from sys.dm_exec_query_plan(0x060006003E423E2C40E1EF18020000000000000000000000)
/*
select scheduler_id, count(*) from sys.dm_os_tasks
group BY scheduler_id
ORDER BY scheduler_id

SELECT scheduler_id,
current_tasks_count,
runnable_tasks_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255;
*/
