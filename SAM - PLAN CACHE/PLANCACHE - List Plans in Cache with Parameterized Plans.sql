/* 
https://sqlserverfast.com/blog/hugo/2014/01/parameterization-and-filtered-indexes-part-1/

*/
 
 
 WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

SELECT usecounts, cacheobjtype, objtype, text , db_name(d.database_id), cp.plan_handle,qs.plan_handle, qs.query_plan_hash, qs.creation_time,qs.query_hash, er.plan_handle,q.query_plan,cp.size_in_bytes
,stmt.value('(@ParameterizedPlanHandle)',
                       'varchar(64)') AS ParameterizedPlanHandle
FROM sys.dm_exec_cached_plans  cp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle)  st 
cross apply sys.dm_exec_query_plan(plan_handle) q
cross apply q.query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
left join sys.dm_exec_query_stats qs on cp.plan_handle=qs.plan_handle
left join sys.dm_exec_requests er on cp.plan_handle=er.plan_handle
join sys.databases d on st.dbid = d.database_id
--WHERE usecounts = 1   
where db_name(d.database_id) = 'TEST'
ORDER BY usecounts DESC;  
GO
