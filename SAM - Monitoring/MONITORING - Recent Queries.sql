--Pinal Dave
SELECT TOP 20 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
total_worker_time/ execution_count AS AvgCPU ,
(total_elapsed_time /1000000)/ execution_count AS AvgDuration ,
total_logical_reads / execution_count AS AvgReads ,
--qs.creation_time,
qp.query_plan,
DB_NAME(cast(pa.value as int)) AS DatabaseName
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
--where qs.last_execution_time between '2011-03-25 08:00:00.000' and getdate()
--where qs.creation_time between '2010-10-11 08:00:00.000' and GETDATE()
WHERE pa.attribute='dbid'
--AND DB_NAME(cast(pa.value as int)) ='DatabaseName'
ORDER BY qs.total_logical_reads DESC -- logical reads
-- ORDER BY qs.total_logical_writes DESC -- logical writes
--ORDER BY qs.total_worker_time DESC -- CPU time




