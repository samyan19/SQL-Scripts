select total_worker_time/execution_count as AvgCPU, total_worker_time AS TotalCPU
, total_elapsed_time/execution_count as AvgDuration, total_elapsed_time AS TotalDuration  
, total_logical_reads/execution_count as AvgReads, total_logical_reads AS TotalReads
, execution_count   
, substring(st.text, (qs.statement_start_offset/2)+1  
, ((case qs.statement_end_offset  when -1 then datalength(st.text)  
else qs.statement_end_offset  
end - qs.statement_start_offset)/2) + 1) as txt  
, query_plan
from sys.dm_exec_query_stats as qs  
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st  
cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp 
order by 1 desc