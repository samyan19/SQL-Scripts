insert into SESSIONINFOTABLE

select 
r.session_id,h.text as 'complete text',substring(h.text, (r.statement_start_offset/2)+1 , ((case r.statement_end_offset when -1 then datalength(h.text)  else r.statement_end_offset end - r.statement_start_offset)/2) + 1) as 'Running statement',
r.plan_handle,r.database_id,
r.blocking_session_id,r.wait_type,
s.host_name,s.program_name,s.host_process_id,
s.login_name,
r.total_elapsed_time/60000 as [ElapseTime mins],r.command,p.query_plan, CURRENT_TIMESTAMP cdt 
--into sessioninfotable
from sys.dm_exec_requests r
inner join sys.dm_exec_sessions s on s.session_id=r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) h
cross apply sys.dm_exec_query_plan (r.plan_handle)p
where s.session_id<>@@SPID
/*r.status<>'background'
and r.command<>'AWAITING COMMAND'
and s.session_id>50*/